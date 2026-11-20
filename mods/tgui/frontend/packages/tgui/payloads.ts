/**
 * Adapted from tgstation #90295: bounded, acknowledged action chunks.
 * Copyright (c) 2025 tgstation contributors
 * SPDX-License-Identifier: MIT
 */

import { createLogger } from './logging';

const logger = createLogger('payloads');
const CHUNK_SIZE = 1024;
const MAX_PENDING_PAYLOADS = 4;
const PAYLOAD_TIMEOUT = 10000;

type PayloadQueue = {
  chunks: string[];
  index: number;
  timer?: ReturnType<typeof setTimeout>;
};

const queues: Record<string, PayloadQueue> = Object.create(null);
let sequence = 0;

const removeQueue = (id: string) => {
  clearTimeout(queues[id]?.timer);
  delete queues[id];
};

export const clearPayloadQueues = () => {
  for (const id of Object.keys(queues)) {
    removeQueue(id);
  }
};

const renewTimeout = (id: string) => {
  const queue = queues[id];
  clearTimeout(queue.timer);
  queue.timer = setTimeout(() => {
    removeQueue(id);
    logger.error('Timed out sending TGUI payload', id);
  }, PAYLOAD_TIMEOUT);
};

// Account for both JSON escaping and URL encoding of each chunk.
// Keep surrogate pairs intact without requiring modern iterator helpers.
const splitPayload = (value: string) => {
  const chunks: string[] = [];
  let chunk = '';
  let size = 0;
  for (let i = 0; i < value.length; i++) {
    let character = value.charAt(i);
    const code = value.charCodeAt(i);
    const nextCode = value.charCodeAt(i + 1);
    if (
      code >= 0xd800 &&
      code <= 0xdbff &&
      nextCode >= 0xdc00 &&
      nextCode <= 0xdfff
    ) {
      character += value.charAt(++i);
    }
    const encodedSize = encodeURIComponent(
      JSON.stringify(character).slice(1, -1)
    ).length;
    if (size + encodedSize > CHUNK_SIZE) {
      chunks.push(chunk);
      chunk = '';
      size = 0;
    }
    chunk += character;
    size += encodedSize;
  }
  if (chunk) {
    chunks.push(chunk);
  }
  return chunks;
};

const sendChunk = (id: string) => {
  const queue = queues[id];
  renewTimeout(id);
  Byond.sendMessage('payloadChunk', {
    id,
    index: queue.index,
    chunk: queue.chunks[queue.index],
  });
};

export const handlePayloadMessage = (type: string, payload) => {
  if (type !== 'oversizePayloadResponse' && type !== 'acknowlegePayloadChunk') {
    return false;
  }
  const id = payload?.id;
  const queue = typeof id === 'string' && queues[id];
  if (!queue) {
    return true;
  }
  if (!payload.allow) {
    removeQueue(id);
    logger.error('Server rejected TGUI payload', id);
    return true;
  }
  if (type === 'acknowlegePayloadChunk') {
    if (payload.index !== queue.index) {
      return true;
    }
    queue.index++;
  }
  if (queue.index < queue.chunks.length) {
    sendChunk(id);
  } else {
    removeQueue(id);
  }
  return true;
};

export const sendActMessage = (action: string, payload: object) => {
  const type = 'act/' + action;
  const json = JSON.stringify(payload);
  const message = { type, payload: json, tgui: 1, window_id: Byond.windowId };
  const urlSize = Object.keys(message).reduce(
    (size, key) =>
      size +
      encodeURIComponent(key).length +
      encodeURIComponent(String(message[key])).length +
      2,
    8
  );
  if (urlSize <= 2048) {
    Byond.sendMessage(type, payload);
    return;
  }
  if (Object.keys(queues).length >= MAX_PENDING_PAYLOADS) {
    logger.error('Too many pending TGUI payloads');
    return;
  }
  const id = String(Date.now()) + '-' + String(++sequence);
  const chunks = splitPayload(json);
  queues[id] = { chunks, index: 0 };
  renewTimeout(id);
  Byond.sendMessage('oversizedPayloadRequest', {
    type,
    id,
    chunkCount: chunks.length,
  });
};
