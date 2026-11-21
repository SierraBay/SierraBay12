import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from '../../components';
import { FrontierTradeData, TradeLogEntry } from './types';

const LOG_KINDS = [
  'All',
  'Request',
  'Purchase',
  'Delivery',
  'Export',
  'Bounty',
  'Refund',
  'Cancelled',
];

const DEFAULT_PAGE_SIZE = 20;

export const LogsTab = (_props, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const {
    logs = [],
    logs_page: backendPage,
    logs_page_size: backendPageSize,
    logs_total: backendTotal,
    has_printer: hasPrinterProp,
    manager,
    currency,
  } = data;

  const hasPrinter = hasPrinterProp !== false;

  const [kindFilter, setKindFilter] = useLocalState(
    context,
    'logKindFilter',
    'All'
  );
  const [search, setSearch] = useLocalState(context, 'logSearch', '');
  const [localPage, setLocalPage] = useLocalState(context, 'logPage', 1);
  const [selectedId, setSelectedId] = useLocalState(
    context,
    'selectedLogId',
    0
  );

  const needle = search.trim().toLowerCase();
  const filtered = logs.filter((entry) => {
    if (kindFilter !== 'All' && entry.kind !== kindFilter) {
      return false;
    }
    if (!needle) {
      return true;
    }
    return (
      entry.title.toLowerCase().includes(needle) ||
      entry.account.toLowerCase().includes(needle) ||
      entry.kind.toLowerCase().includes(needle)
    );
  });

  const pageSize = backendPageSize || DEFAULT_PAGE_SIZE;
  const isBackendPaginated =
    typeof backendTotal === 'number' && backendTotal > logs.length;

  const totalEntries = isBackendPaginated ? backendTotal! : filtered.length;
  const pageCount = Math.max(1, Math.ceil(totalEntries / pageSize));
  const currentPage = isBackendPaginated ? backendPage || localPage : localPage;
  const safePage = Math.min(Math.max(1, currentPage), pageCount);

  const visible = isBackendPaginated
    ? filtered
    : filtered.slice((safePage - 1) * pageSize, safePage * pageSize);

  const selectedEntry: TradeLogEntry | undefined =
    filtered.find((e) => e.id === selectedId) || visible[0];

  const goToPage = (nextPage: number) => {
    const clamped = Math.min(Math.max(1, nextPage), pageCount);
    setLocalPage(clamped);
    act('load_logs', { page: clamped, page_size: pageSize });
  };

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section>
          <Stack align="center" wrap>
            {LOG_KINDS.map((kind) => (
              <Stack.Item key={kind}>
                <Button
                  compact
                  selected={kindFilter === kind}
                  content={kind}
                  onClick={() => {
                    setKindFilter(kind);
                    setLocalPage(1);
                  }}
                />
              </Stack.Item>
            ))}
            <Stack.Item grow>
              <Input
                fluid
                placeholder="Filter invoices..."
                value={search}
                onInput={(_, value) => {
                  setSearch(value);
                  setLocalPage(1);
                }}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow={1} basis={0}>
            <Section
              fill
              scrollable
              title={`Logs (${
                typeof backendTotal === 'number'
                  ? backendTotal
                  : filtered.length
              })`}
            >
              {visible.length === 0 ? (
                <NoticeBox>No matching invoices.</NoticeBox>
              ) : (
                <Table>
                  <Table.Row header>
                    <Table.Cell>#</Table.Cell>
                    <Table.Cell>Time</Table.Cell>
                    <Table.Cell>Action</Table.Cell>
                    <Table.Cell>Subject</Table.Cell>
                    <Table.Cell textAlign="right">Amount</Table.Cell>
                  </Table.Row>
                  {visible.map((entry) => (
                    <Table.Row key={entry.id} className="candystripe">
                      <Table.Cell>
                        <Button
                          compact
                          selected={selectedEntry?.id === entry.id}
                          content={`#${entry.id}`}
                          onClick={() => setSelectedId(entry.id)}
                        />
                      </Table.Cell>
                      <Table.Cell>{entry.time}</Table.Cell>
                      <Table.Cell>{entry.kind}</Table.Cell>
                      <Table.Cell>{entry.title}</Table.Cell>
                      <Table.Cell textAlign="right">
                        {entry.amount} {currency}
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow={1} basis={0}>
            <Section fill scrollable title="Invoice Breakdown">
              {selectedEntry ? (
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Invoice">
                        #{selectedEntry.id} ({selectedEntry.kind})
                      </LabeledList.Item>
                      <LabeledList.Item label="Time">
                        {selectedEntry.time}
                      </LabeledList.Item>
                      <LabeledList.Item label="Account">
                        {selectedEntry.account}
                      </LabeledList.Item>
                      <LabeledList.Item label="Total">
                        {selectedEntry.amount} {currency} (Commission:{' '}
                        {selectedEntry.fee})
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item>
                    <Table>
                      <Table.Row header>
                        <Table.Cell>Vendor</Table.Cell>
                        <Table.Cell>Goods</Table.Cell>
                        <Table.Cell textAlign="right">Qty</Table.Cell>
                        <Table.Cell textAlign="right">Subtotal</Table.Cell>
                      </Table.Row>
                      {selectedEntry.contents.map((row, idx) => (
                        <Table.Row key={idx} className="candystripe">
                          <Table.Cell>{row.station}</Table.Cell>
                          <Table.Cell>{row.name}</Table.Cell>
                          <Table.Cell textAlign="right">
                            {row.quantity}
                            {row.stack_size > 0 &&
                              ` (${row.stack_size * row.quantity}u)`}
                          </Table.Cell>
                          <Table.Cell textAlign="right">
                            {row.subtotal} {currency}
                          </Table.Cell>
                        </Table.Row>
                      ))}
                    </Table>
                  </Stack.Item>
                  <Stack.Item>
                    {hasPrinter ? (
                      <Stack>
                        <Stack.Item>
                          <Button
                            icon="print"
                            content="Print Receipt"
                            onClick={() =>
                              act('print_log', { id: selectedEntry.id })
                            }
                          />
                        </Stack.Item>
                        {manager && (
                          <Stack.Item>
                            <Button
                              icon="print"
                              content="Internal Receipt"
                              onClick={() =>
                                act('print_log', {
                                  id: selectedEntry.id,
                                  internal: 1,
                                })
                              }
                            />
                          </Stack.Item>
                        )}
                      </Stack>
                    ) : (
                      <Box fontSize="11px" color="label">
                        No printer installed on this device.
                      </Box>
                    )}
                  </Stack.Item>
                </Stack>
              ) : (
                <NoticeBox>Select an invoice to view details.</NoticeBox>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {pageCount > 1 && (
        <Stack.Item>
          <Stack justify="center" align="center">
            <Stack.Item>
              <Button
                icon="angle-double-left"
                disabled={safePage <= 1}
                onClick={() => goToPage(1)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-left"
                disabled={safePage <= 1}
                onClick={() => goToPage(safePage - 1)}
              />
            </Stack.Item>
            <Stack.Item>
              Page {safePage} / {pageCount} ({totalEntries} total)
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-right"
                disabled={safePage >= pageCount}
                onClick={() => goToPage(safePage + 1)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="angle-double-right"
                disabled={safePage >= pageCount}
                onClick={() => goToPage(pageCount)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      )}
    </Stack>
  );
};
