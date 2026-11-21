import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
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

const orderStatuses = {
  all: { label: 'All statuses', color: 'label' },
  pending: { label: 'Awaiting approval', color: 'average' },
  transit: { label: 'Awaiting delivery', color: 'teal' },
  delivered: { label: 'Delivered', color: 'good' },
  cancelled: { label: 'Cancelled', color: 'bad' },
};

type OrderFilter = keyof typeof orderStatuses;

const statusOptions = Object.entries(orderStatuses).map(([value, status]) => ({
  value,
  displayText: status.label,
}));

const getOrderStatus = (
  order: TradeOrder
): Exclude<OrderFilter, 'all'> | undefined => {
  if (order.state === 'Delivered') {
    return 'delivered';
  }
  if (order.state === 'Cancelled') {
    return 'cancelled';
  }
  if (order.pending || order.state === 'Requested') {
    return 'pending';
  }
  if (order.paid || order.state === 'Awaiting delivery') {
    return 'transit';
  }
};

const getStatusDetails = (order: TradeOrder) => {
  const status = getOrderStatus(order);
  return status
    ? orderStatuses[status]
    : { label: order.state, color: 'label' };
};

export const OrdersTab = (props: OrdersTabProps, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const { onEditReason, onSaveAsCart } = props;
  const { orders = [], manager, currency, has_printer: hasPrinterProp } = data;

  const hasPrinter = Boolean(hasPrinterProp ?? true);

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

  const filteredOrders =
    statusFilter === 'all'
      ? orders
      : orders.filter((order) => getOrderStatus(order) === statusFilter);
  const selectedOrder =
    filteredOrders.find((order) => order.id === selectedId) ||
    filteredOrders[0];

  const selectedStatus = selectedOrder && getStatusDetails(selectedOrder);

  return (
    <Stack fill>
      <Stack.Item grow={1} basis={0}>
        <Section
          fill
          scrollable
          title={'Orders (' + filteredOrders.length + ')'}
          buttons={
            <Dropdown
              width="13em"
              options={statusOptions}
              selected={statusFilter}
              displayText={orderStatuses[statusFilter].label}
              onSelected={(status) => setStatusFilter(status as OrderFilter)}
            />
          }
        >
          {filteredOrders.length === 0 ? (
            <NoticeBox>No orders match this filter.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Order / Buyer</Table.Cell>
                <Table.Cell>Status</Table.Cell>
                <Table.Cell textAlign="right">Total</Table.Cell>
              </Table.Row>
              {filteredOrders.map((order) => (
                <Table.Row key={order.id} className="candystripe">
                  <Table.Cell py={0.5}>
                    <Button
                      compact
                      selected={selectedOrder?.id === order.id}
                      content={order.id}
                      onClick={() => setSelectedId(order.id)}
                    />
                    <Box mt={0.25} color="label">
                      {order.buyer}
                    </Box>
                  </Table.Cell>
                  <Table.Cell color={getStatusDetails(order).color}>
                    {getStatusDetails(order).label}
                  </Table.Cell>
                  <Table.Cell textAlign="right">
                    {order.total + order.fee} {currency}
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
                    color={selectedStatus?.color}
                  >
                    {selectedStatus?.label}
                  </LabeledList.Item>
                  {selectedOrder.delivery_status && (
                    <LabeledList.Item label="Delivery">
                      {selectedOrder.delivery_status}
                    </LabeledList.Item>
                  )}
                  {Boolean(selectedOrder.needed_tiles) && (
                    <LabeledList.Item label="Delivery slots">
                      {selectedOrder.needed_tiles}
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
                  {Boolean(selectedOrder.pending && manager) && (
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
                  {Boolean(selectedOrder.cancellable) && (
                    <Stack.Item>
                      <Button.Confirm
                        icon="times"
                        content="Cancel order"
                        onClick={() =>
                          act('cancel_order', { id: selectedOrder.id })
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
                  {Boolean(selectedOrder.can_edit_reason) && (
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
                  {Boolean(selectedOrder.paid) && (
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
                  {Boolean(manager) && hasPrinter && (
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
