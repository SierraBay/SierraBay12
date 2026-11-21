import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from '../../components';
import { FrontierTradeData, TradeOrder } from './types';

export interface OrdersTabProps {
  onEditReason: (orderId: string, currentReason: string) => void;
  onSaveAsCart: (orderId: string) => void;
}

type OrderFilter = 'all' | 'pending' | 'transit' | 'delivered' | 'cancelled';

const stateColor = (order: TradeOrder): string => {
  if (order.state === 'Delivered') {
    return 'good';
  }
  if (order.state === 'Cancelled') {
    return 'bad';
  }
  if (order.paid || order.state === 'Awaiting delivery') {
    return 'teal';
  }
  return 'average';
};

const stateBadgeText = (order: TradeOrder): string => {
  if (order.pending || order.state === 'Requested') {
    return 'Awaiting Approval';
  }
  if (order.paid || order.state === 'Awaiting delivery') {
    return 'In Transit / Awaiting Delivery';
  }
  return order.state;
};

export const OrdersTab = (props: OrdersTabProps, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const { onEditReason, onSaveAsCart } = props;
  const {
    orders = [],
    manager,
    currency,
    budget = 0,
    has_printer: hasPrinterProp,
    pending_orders_count: pendingOrdersCountProp,
  } = data;

  const hasPrinter = hasPrinterProp !== false;

  const [selectedId, setSelectedId] = useLocalState(
    context,
    'selectedOrderId',
    ''
  );
  const [statusFilter, setStatusFilter] = useLocalState<OrderFilter>(
    context,
    'orderStatusFilter',
    'all'
  );

  const pendingCount =
    pendingOrdersCountProp !== undefined
      ? pendingOrdersCountProp
      : orders.filter((o) => o.pending || o.state === 'Requested').length;
  const transitCount = orders.filter(
    (o) => o.paid || o.state === 'Awaiting delivery'
  ).length;
  const deliveredCount = orders.filter((o) => o.state === 'Delivered').length;
  const cancelledCount = orders.filter((o) => o.state === 'Cancelled').length;

  const filteredOrders = orders.filter((o) => {
    if (statusFilter === 'pending') {
      return o.pending || o.state === 'Requested';
    }
    if (statusFilter === 'transit') {
      return o.paid || o.state === 'Awaiting delivery';
    }
    if (statusFilter === 'delivered') {
      return o.state === 'Delivered';
    }
    if (statusFilter === 'cancelled') {
      return o.state === 'Cancelled';
    }
    return true;
  });

  const selectedOrder: TradeOrder | undefined =
    filteredOrders.find((o) => o.id === selectedId) ||
    orders.find((o) => o.id === selectedId) ||
    filteredOrders[0] ||
    orders[0];

  return (
    <Stack fill>
      <Stack.Item grow={1} basis={0}>
        <Section
          fill
          scrollable
          title={
            pendingCount > 0
              ? `Orders (${orders.length} · ${pendingCount} Pending Approval)`
              : `Orders (${orders.length})`
          }
        >
          <Stack mb={0.75} wrap>
            <Stack.Item>
              <Button
                compact
                selected={statusFilter === 'all'}
                content={`All (${orders.length})`}
                onClick={() => setStatusFilter('all')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                selected={statusFilter === 'pending'}
                color={pendingCount > 0 ? 'average' : undefined}
                content={`Pending (${pendingCount})`}
                onClick={() => setStatusFilter('pending')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                selected={statusFilter === 'transit'}
                content={`In Transit (${transitCount})`}
                onClick={() => setStatusFilter('transit')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                selected={statusFilter === 'delivered'}
                content={`Delivered (${deliveredCount})`}
                onClick={() => setStatusFilter('delivered')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                selected={statusFilter === 'cancelled'}
                content={`Cancelled (${cancelledCount})`}
                onClick={() => setStatusFilter('cancelled')}
              />
            </Stack.Item>
          </Stack>
          {filteredOrders.length === 0 ? (
            <NoticeBox>No visible orders matching filter.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Order</Table.Cell>
                <Table.Cell>Buyer</Table.Cell>
                <Table.Cell>Status</Table.Cell>
                <Table.Cell textAlign="right">Total</Table.Cell>
                <Table.Cell textAlign="right">Actions</Table.Cell>
              </Table.Row>
              {filteredOrders.map((order) => (
                <Table.Row key={order.id} className="candystripe">
                  <Table.Cell>
                    <Button
                      compact
                      selected={selectedOrder?.id === order.id}
                      content={order.id}
                      onClick={() => setSelectedId(order.id)}
                    />
                  </Table.Cell>
                  <Table.Cell>
                    <Box bold>{order.buyer}</Box>
                    <Box fontSize="11px" color="label">
                      {order.reason}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box bold color={stateColor(order)}>
                      {stateBadgeText(order)}
                    </Box>
                    {order.delivery_status && (
                      <Box fontSize="10px" color="label">
                        {order.delivery_status}
                      </Box>
                    )}
                    {order.needed_tiles !== undefined &&
                      order.needed_tiles > 0 && (
                        <Box fontSize="10px" color="label">
                          Needs {order.needed_tiles} pad tile(s)
                        </Box>
                      )}
                  </Table.Cell>
                  <Table.Cell textAlign="right">
                    {order.total + order.fee} {currency}
                  </Table.Cell>
                  <Table.Cell textAlign="right">
                    <Stack justify="flex-end">
                      {order.pending && manager && (
                        <Stack.Item>
                          <Button
                            compact
                            color="good"
                            icon="check"
                            tooltip={`Approve from Supply Budget (${budget} ${currency} available)`}
                            onClick={() =>
                              act('approve_order', { id: order.id })
                            }
                          />
                        </Stack.Item>
                      )}
                      {order.cancellable && (
                        <Stack.Item>
                          <Button
                            compact
                            color="bad"
                            icon="trash"
                            tooltip="Cancel"
                            onClick={() =>
                              act('cancel_order', { id: order.id })
                            }
                          />
                        </Stack.Item>
                      )}
                      {hasPrinter && (
                        <Stack.Item>
                          <Button
                            compact
                            icon="print"
                            tooltip="Print receipt"
                            onClick={() => act('print_order', { id: order.id })}
                          />
                        </Stack.Item>
                      )}
                    </Stack>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow={1} basis={0}>
        <Section fill scrollable title="Order Details">
          {selectedOrder ? (
            <Stack vertical>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item label="Order">
                    {selectedOrder.id}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Status"
                    color={stateColor(selectedOrder)}
                  >
                    {stateBadgeText(selectedOrder)}{' '}
                    {selectedOrder.state !== stateBadgeText(selectedOrder) &&
                      `(${selectedOrder.state})`}
                  </LabeledList.Item>
                  {selectedOrder.delivery_status && (
                    <LabeledList.Item label="Telemetry">
                      {selectedOrder.delivery_status}
                    </LabeledList.Item>
                  )}
                  <LabeledList.Item label="Buyer">
                    {selectedOrder.buyer}
                  </LabeledList.Item>
                  <LabeledList.Item label="Reason">
                    {selectedOrder.reason}
                  </LabeledList.Item>
                  <LabeledList.Item label="Breakdown">
                    Goods: {selectedOrder.total} + Handling: {selectedOrder.fee}{' '}
                    = {selectedOrder.total + selectedOrder.fee} {currency}
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
                  {selectedOrder.items.map((row, idx) => (
                    <Table.Row key={idx} className="candystripe">
                      <Table.Cell>
                        <Box>{row.station}</Box>
                        <Box fontSize="11px" color="label">
                          {row.category}
                        </Box>
                      </Table.Cell>
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
                <Stack wrap>
                  {selectedOrder.pending && manager && (
                    <Stack.Item>
                      <Button
                        color="good"
                        icon="check"
                        content={`Approve (${selectedOrder.total} ${currency})`}
                        onClick={() =>
                          act('approve_order', { id: selectedOrder.id })
                        }
                      />
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    <Button
                      icon="save"
                      content="Save as Cart"
                      onClick={() => onSaveAsCart(selectedOrder.id)}
                    />
                  </Stack.Item>
                  {selectedOrder.can_edit_reason && (
                    <Stack.Item>
                      <Button
                        icon="edit"
                        content="Edit Reason"
                        onClick={() =>
                          onEditReason(selectedOrder.id, selectedOrder.reason)
                        }
                      />
                    </Stack.Item>
                  )}
                  {selectedOrder.paid && (
                    <Stack.Item>
                      <Button
                        icon="truck"
                        content="Deliver to Receiver"
                        onClick={() =>
                          act('reroute_order', { id: selectedOrder.id })
                        }
                      />
                    </Stack.Item>
                  )}
                  {hasPrinter && (
                    <Stack.Item>
                      <Button
                        icon="print"
                        content="Print Receipt"
                        onClick={() =>
                          act('print_order', { id: selectedOrder.id })
                        }
                      />
                    </Stack.Item>
                  )}
                  {manager && hasPrinter && (
                    <Stack.Item>
                      <Button
                        icon="print"
                        content="Internal Receipt"
                        onClick={() =>
                          act('print_order', {
                            id: selectedOrder.id,
                            internal: 1,
                          })
                        }
                      />
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
            </Stack>
          ) : (
            <NoticeBox>
              Select an order to review its goods, quantities and prices.
            </NoticeBox>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
