/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { vecAdd, vecMultiply, vecScale, vecSubtract } from 'common/vector';
import { globalEvents } from './events';
import { createLogger } from './logging';

const logger = createLogger('drag');
// Window geometry uses display pixels; browser coordinates use CSS pixels.
const pixelRatio = window.devicePixelRatio ?? 1;
const requestFrame = window.requestAnimationFrame
  ? (callback) => window.requestAnimationFrame(callback)
  : (callback) => setTimeout(callback, 16);
const cancelFrame = window.cancelAnimationFrame
  ? (id) => window.cancelAnimationFrame(id)
  : (id) => clearTimeout(id);

let windowKey = Byond.windowId;
let dragging = false;
let resizing = false;
let screenOffset = [0, 0];
let screenOffsetPromise;
let dragPointOffset;
let resizeMatrix;
let initialSize;
let size;
let winsetRaf;
let pendingWinset = {};
let lastSentWinset = {};

// Ported from tgstation #94439: send only the latest geometry each frame.
const flushWinset = () => {
  winsetRaf = undefined;
  const payload = {};
  if (pendingWinset.pos && pendingWinset.pos !== lastSentWinset.pos) {
    payload.pos = pendingWinset.pos;
  }
  if (pendingWinset.size && pendingWinset.size !== lastSentWinset.size) {
    payload.size = pendingWinset.size;
  }
  pendingWinset = {};
  if (payload.pos || payload.size) {
    Byond.winset(Byond.windowId, payload);
    lastSentWinset = { ...lastSentWinset, ...payload };
  }
};

const scheduleWinset = () => {
  if (winsetRaf === undefined) {
    winsetRaf = requestFrame(flushWinset);
  }
};

const flushWinsetNow = () => {
  if (winsetRaf !== undefined) {
    cancelFrame(winsetRaf);
  }
  flushWinset();
};

export const setWindowKey = (key) => {
  windowKey = key;
};

export const getWindowPosition = () => [
  window.screenLeft * pixelRatio,
  window.screenTop * pixelRatio,
];

export const getWindowSize = () => [
  window.innerWidth * pixelRatio,
  window.innerHeight * pixelRatio,
];

export const setWindowPosition = (vec) => {
  const byondPos = vecAdd(vec, screenOffset);
  lastSentWinset.pos = `${Math.round(byondPos[0])},${Math.round(byondPos[1])}`;
  return Byond.winset(Byond.windowId, {
    pos: lastSentWinset.pos,
  });
};

const setWindowPositionBatched = (vec) => {
  const byondPos = vecAdd(vec, screenOffset);
  pendingWinset.pos = `${Math.round(byondPos[0])},${Math.round(byondPos[1])}`;
  scheduleWinset();
};

export const setWindowSize = (vec) => {
  lastSentWinset.size = `${Math.round(vec[0])}x${Math.round(vec[1])}`;
  return Byond.winset(Byond.windowId, {
    size: lastSentWinset.size,
  });
};

const setWindowSizeBatched = (vec) => {
  pendingWinset.size = `${Math.round(vec[0])}x${Math.round(vec[1])}`;
  scheduleWinset();
};

export const getScreenPosition = () => [
  0 - screenOffset[0],
  0 - screenOffset[1],
];

export const getScreenSize = () => [
  window.screen.availWidth * pixelRatio,
  window.screen.availHeight * pixelRatio,
];

/**
 * Moves an item to the top of the recents array, and keeps its length
 * limited to the number in `limit` argument.
 *
 * Uses a strict equality check for comparisons.
 *
 * Returns new recents and an item which was trimmed.
 */
const touchRecents = (recents, touchedItem, limit = 50) => {
  const nextRecents = [touchedItem];
  let trimmedItem;
  for (let i = 0; i < recents.length; i++) {
    const item = recents[i];
    if (item === touchedItem) {
      continue;
    }
    if (nextRecents.length < limit) {
      nextRecents.push(item);
    } else {
      trimmedItem = item;
    }
  }
  return [nextRecents, trimmedItem];
};

export const storeWindowGeometry = async () => {
  logger.log('storing geometry');
  const geometry = {
    pos: getWindowPosition(),
    size: getWindowSize(),
  };
  storage.set(windowKey, geometry);
  // Update the list of stored geometries
  const [geometries, trimmedKey] = touchRecents(
    (await storage.get('geometries')) || [],
    windowKey
  );
  if (trimmedKey) {
    storage.remove(trimmedKey);
  }
  storage.set('geometries', geometries);
};

export const recallWindowGeometry = async (
  options = {},
  isCurrent = () => true
) => {
  // Only recall geometry in fancy mode
  const geometry = options.fancy && (await storage.get(windowKey));
  if (geometry) {
    logger.log('recalled geometry:', geometry);
  }
  let pos = geometry?.pos || options.pos;
  let size = options.size;
  // Ported from tgstation #65686: default dimensions arrive in CSS pixels.
  const scale = options.scale !== false;
  if (scale && size) {
    size = vecScale(size, pixelRatio);
  }
  // Wait until screen offset gets resolved
  await screenOffsetPromise;
  if (!isCurrent()) {
    return;
  }
  // Aurora #20734: allow physical-size windows independently of Windows DPI.
  document.body.style.setProperty('zoom', scale ? '' : `${100 / pixelRatio}%`);
  document.documentElement.style.setProperty(
    '--scaling-amount',
    scale ? '1' : pixelRatio.toString()
  );
  const areaAvailable = getScreenSize();
  // Set window size
  if (size) {
    // Constraint size to not exceed available screen area.
    size = [
      Math.min(areaAvailable[0], size[0]),
      Math.min(areaAvailable[1], size[1]),
    ];
    setWindowSize(size);
  }
  // Set window position
  if (pos) {
    // Constraint window position if monitor lock was set in preferences.
    if (size && options.locked) {
      pos = constraintPosition(pos, size)[1];
    }
    setWindowPosition(pos);
  }
  // Set window position at the center of the screen.
  else if (size) {
    pos = vecAdd(
      vecScale(areaAvailable, 0.5),
      vecScale(size, -0.5),
      vecScale(screenOffset, -1.0)
    );
    setWindowPosition(pos);
  }
};

export const setupDrag = async () => {
  // Calculate screen offset caused by the windows taskbar
  const windowPosition = getWindowPosition();
  screenOffsetPromise = Byond.winget(Byond.windowId, 'pos').then((pos) => [
    pos.x - windowPosition[0],
    pos.y - windowPosition[1],
  ]);
  screenOffset = await screenOffsetPromise;
  logger.debug('screen offset', screenOffset);
};

/**
 * Constraints window position to safe screen area, accounting for safe
 * margins which could be a system taskbar.
 */
const constraintPosition = (pos, size) => {
  const screenPos = getScreenPosition();
  const screenSize = getScreenSize();
  const nextPos = [pos[0], pos[1]];
  let relocated = false;
  for (let i = 0; i < 2; i++) {
    const leftBoundary = screenPos[i];
    const rightBoundary = screenPos[i] + screenSize[i];
    if (pos[i] < leftBoundary) {
      nextPos[i] = leftBoundary;
      relocated = true;
    } else if (pos[i] + size[i] > rightBoundary) {
      nextPos[i] = rightBoundary - size[i];
      relocated = true;
    }
  }
  return [relocated, nextPos];
};

export const dragStartHandler = (event) => {
  logger.log('drag start');
  dragging = true;
  lastSentWinset = {};
  dragPointOffset = vecSubtract(
    [event.screenX * pixelRatio, event.screenY * pixelRatio],
    getWindowPosition()
  );
  document.addEventListener('mousemove', dragMoveHandler);
  document.addEventListener('mouseup', dragEndHandler);
  globalEvents.emit('window-dragging', true);
  dragMoveHandler(event);
};

const dragEndHandler = (event) => {
  logger.log('drag end');
  dragMoveHandler(event);
  flushWinsetNow();
  document.removeEventListener('mousemove', dragMoveHandler);
  document.removeEventListener('mouseup', dragEndHandler);
  dragging = false;
  globalEvents.emit('window-dragging', resizing);
  storeWindowGeometry();
};

const dragMoveHandler = (event) => {
  if (!dragging) {
    return;
  }
  event.preventDefault();
  setWindowPositionBatched(
    vecSubtract(
      [event.screenX * pixelRatio, event.screenY * pixelRatio],
      dragPointOffset
    )
  );
};

export const resizeStartHandler = (x, y) => (event) => {
  resizeMatrix = [x, y];
  logger.log('resize start', resizeMatrix);
  resizing = true;
  lastSentWinset = {};
  dragPointOffset = vecSubtract(
    [event.screenX * pixelRatio, event.screenY * pixelRatio],
    getWindowPosition()
  );
  initialSize = getWindowSize();
  document.addEventListener('mousemove', resizeMoveHandler);
  document.addEventListener('mouseup', resizeEndHandler);
  globalEvents.emit('window-dragging', true);
  resizeMoveHandler(event);
};

const resizeEndHandler = (event) => {
  logger.log('resize end', size);
  resizeMoveHandler(event);
  flushWinsetNow();
  document.removeEventListener('mousemove', resizeMoveHandler);
  document.removeEventListener('mouseup', resizeEndHandler);
  resizing = false;
  globalEvents.emit('window-dragging', dragging);
  storeWindowGeometry();
};

const resizeMoveHandler = (event) => {
  if (!resizing) {
    return;
  }
  event.preventDefault();
  const currentOffset = vecSubtract(
    [event.screenX * pixelRatio, event.screenY * pixelRatio],
    getWindowPosition()
  );
  const delta = vecSubtract(currentOffset, dragPointOffset);
  // Extra 1x1 area ensures the browser can still see the cursor.
  size = vecAdd(initialSize, vecMultiply(resizeMatrix, delta), [1, 1]);
  // Sane window size values
  size[0] = Math.max(size[0], 150 * pixelRatio);
  size[1] = Math.max(size[1], 50 * pixelRatio);
  setWindowSizeBatched(size);
};
