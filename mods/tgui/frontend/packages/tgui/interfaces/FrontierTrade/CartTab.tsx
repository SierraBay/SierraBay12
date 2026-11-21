import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
} from '../../components';
import { CartItem, FrontierTradeData } from './types';

export interface CartTabProps {
  onPurchaseClick: () => void;
  onRequestClick: () => void;
  onSaveClick: () => void;
}

const CartRow = (props: {
  item: CartItem;
  liveStock: number;
  overstock: boolean;
  restricted: boolean;
  remainingOrderLimit: number;
  currency: string;
  act: (action: string, payload?: object) => void;
}) => {
  const {
    item,
    liveStock,
    overstock,
    restricted,
    remainingOrderLimit,
    currency,
    act,
  } = props;
  const maxQty = Math.min(liveStock, item.quantity + remainingOrderLimit);
  const canAddMore = liveStock > item.quantity && remainingOrderLimit > 0;

  return (
    <Table.Row className="candystripe">
      <Table.Cell>
        <Box>{item.station}</Box>
        <Box fontSize="11px" color="label">
          {item.category}
        </Box>
      </Table.Cell>
      <Table.Cell>
        <Box bold color={overstock ? 'bad' : undefined}>
          {item.name}
          {item.stack_size > 0 && ` (${item.stack_size}u/stack)`}
        </Box>
        {Boolean(item.floor_delivery) && (
          <Box fontSize="11px" color="label">
            Floor delivery · {item.quantity} clear{' '}
            {item.quantity === 1 ? 'tile' : 'tiles'}
          </Box>
        )}
        {overstock && (
          <Box fontSize="11px" color="bad" bold>
            Only {liveStock} available
          </Box>
        )}
        {restricted && (
          <Box fontSize="11px" color="average">
            Department access required for personal purchase
          </Box>
        )}
      </Table.Cell>
      <Table.Cell textAlign="right">
        <Stack justify="flex-end" align="center">
          <Stack.Item>
            <Button
              compact
              icon="minus"
              onClick={() => act('remove_cart', { id: item.id })}
            />
          </Stack.Item>
          <Stack.Item>
            <NumberInput
              width="44px"
              step={1}
              value={item.quantity}
              minValue={0}
              maxValue={Math.max(1, liveStock, item.quantity)}
              onChange={(_, value) =>
                act('set_cart_qty', {
                  id: item.id,
                  quantity: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              icon="plus"
              disabled={!canAddMore}
              onClick={() => act('add_cart', { id: item.id })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              content="Max"
              disabled={!canAddMore}
              tooltip={`Set to maximum available (${maxQty})`}
              onClick={() =>
                act('set_cart_qty', {
                  id: item.id,
                  quantity: maxQty,
                })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              color="bad"
              icon="times"
              aria-label="Remove item from cart"
              tooltip="Remove item from cart"
              onClick={() =>
                act('set_cart_qty', {
                  id: item.id,
                  quantity: 0,
                })
              }
            />
          </Stack.Item>
        </Stack>
        {item.stack_size > 0 && (
          <Box fontSize="11px" color="label">
            {item.stack_size * item.quantity} units
          </Box>
        )}
      </Table.Cell>
      <Table.Cell textAlign="right">{item.unit_price}</Table.Cell>
      <Table.Cell textAlign="right" bold>
        {item.price} {currency}
      </Table.Cell>
    </Table.Row>
  );
};

const computeNeededTiles = (
  cart: CartItem[],
  cartFloorNeeded?: number
): number => {
  if (cartFloorNeeded !== undefined) {
    return cartFloorNeeded;
  }
  if (cart.length === 0) {
    return 0;
  }
  return cart.reduce(
    (acc, item) => acc + (item.floor_delivery ? item.quantity : 0),
    cart.some((item) => !item.floor_delivery) ? 1 : 0
  );
};

const CartCheckoutFooter = (props: {
  data: FrontierTradeData;
  hasRestricted: boolean;
  hasOverstock: boolean;
  neededTiles: number;
  act: (action: string, payload?: object) => void;
  onPurchaseClick: () => void;
  onRequestClick: () => void;
}) => {
  const {
    data,
    hasRestricted,
    hasOverstock,
    neededTiles,
    act,
    onPurchaseClick,
    onRequestClick,
  } = props;
  const {
    cart = [],
    cart_total: cartTotal = 0,
    cart_fee: cartFee = 0,
    entropy_limit: staticEntropyLimit,
    currency,
    budget = 0,
    account,
    beacons,
    manager,
    request_wait: requestWait = 0,
  } = data;

  const personalTotal = cartTotal + cartFee;
  const accountKnown = Boolean(
    account?.owner ||
      account?.card_linked ||
      (account?.card_inserted && !account?.card_requires_pin)
  );
  const canAffordPersonal =
    !accountKnown || (account?.balance ?? 0) >= personalTotal;
  const personalShortfall = accountKnown
    ? Math.max(0, personalTotal - (account?.balance ?? 0))
    : 0;
  const canAffordBudget = budget >= cartTotal;
  const budgetShortfall = Math.max(0, cartTotal - budget);

  const freeTiles = beacons?.receiver_free_tiles;
  const canQueueDelivery = !!beacons?.receiver_present;
  const receiverReady = !!beacons?.receiver_ready;
  const receiverEntropy = beacons?.receiver_entropy ?? 0;
  const entropyLimit = staticEntropyLimit || beacons?.entropy_limit || 30;
  const receiverLockedSeconds = beacons?.receiver_locked_seconds ?? 0;
  const estDeliverySeconds =
    beacons?.estimated_delivery_seconds ??
    (receiverLockedSeconds > 0 ? receiverLockedSeconds : 2);

  return (
    <Section title="Checkout">
      <LabeledList>
        <LabeledList.Item label="Receiving beacon">
          <Stack align="center" wrap>
            <Stack.Item>
              <Dropdown
                width="21em"
                options={(beacons?.receivers || []).map((beacon) => ({
                  value: beacon.id,
                  displayText:
                    beacon.label + (beacon.ready ? '' : ' (Not ready)'),
                }))}
                selected={beacons?.receiver_id}
                displayText={beacons?.receiver_label || 'Automatic'}
                onSelected={(id) => act('select_receiver', { id })}
              />
            </Stack.Item>
            <Stack.Item color={receiverReady ? 'label' : 'average'}>
              {receiverReady
                ? 'Ready'
                : canQueueDelivery
                  ? 'Accepting queued orders'
                  : 'Unavailable'}
              {canQueueDelivery &&
                freeTiles !== undefined &&
                ' · ' +
                  freeTiles +
                  ' clear tiles' +
                  (neededTiles > 0 ? ', ' + neededTiles + ' needed' : '')}
              {canQueueDelivery &&
                ' · Entropy ' + receiverEntropy + '/' + entropyLimit}
              {receiverLockedSeconds > 0
                ? ' · Recharging (' + receiverLockedSeconds + 's)'
                : receiverReady && ' · ETA ~' + estDeliverySeconds + 's'}
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Goods subtotal">
          {cartTotal} {currency}
          {Boolean(manager) && (
            <Box as="span" ml={1} color={canAffordBudget ? 'label' : 'bad'}>
              Supply budget: {budget} {currency}
              {!canAffordBudget &&
                ' (Short by ' + budgetShortfall + ' ' + currency + ')'}
            </Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Personal total">
          {personalTotal} {currency} ({cartFee} {currency} handling)
          {accountKnown && (
            <Box as="span" ml={1} color={canAffordPersonal ? 'label' : 'bad'}>
              Balance: {account?.balance ?? 0} {currency}
              {!canAffordPersonal &&
                ' (Short by ' + personalShortfall + ' ' + currency + ')'}
            </Box>
          )}
        </LabeledList.Item>
      </LabeledList>
      {(hasRestricted || hasOverstock) && (
        <Stack mt={0.75} wrap align="center">
          {hasOverstock && (
            <Stack.Item>
              <Button
                icon="wrench"
                color="average"
                content="Fix Stock"
                tooltip="Reduce cart quantities to match available stock"
                onClick={() => act('fix_cart_stock')}
              />
            </Stack.Item>
          )}
          {hasRestricted && (
            <Stack.Item>
              <Button
                icon="filter"
                color="average"
                content="Remove Restricted"
                tooltip="Remove items ineligible for personal purchase"
                onClick={() => act('remove_restricted_cart')}
              />
            </Stack.Item>
          )}
        </Stack>
      )}
      <Stack mt={0.75} wrap align="center">
        <Stack.Item>
          <Button
            icon="credit-card"
            color="good"
            disabled={
              cart.length === 0 ||
              !account?.card_inserted ||
              !canQueueDelivery ||
              hasRestricted ||
              hasOverstock ||
              (accountKnown && !canAffordPersonal)
            }
            content="Pay with Inserted ID"
            onClick={onPurchaseClick}
          />
        </Stack.Item>
        {Boolean(manager) && (
          <Stack.Item>
            <Button
              icon="check"
              disabled={
                cart.length === 0 ||
                !canQueueDelivery ||
                hasOverstock ||
                !canAffordBudget
              }
              content="Pay from Supply Budget"
              onClick={() => act('department')}
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button
            icon="file-alt"
            disabled={cart.length === 0 || requestWait > 0 || hasOverstock}
            content={
              requestWait > 0
                ? 'Request again in ' + requestWait + 's'
                : 'Request Department Funding'
            }
            onClick={onRequestClick}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const CartTab = (props: CartTabProps, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const { onPurchaseClick, onRequestClick, onSaveClick } = props;
  const {
    cart = [],
    cart_count: cartCount = 0,
    cart_floor_needed: cartFloorNeeded,
    cart_overstock_ids: cartOverstockIds = [],
    stocks = {},
    sec_locked: secLocked = {},
    order_limit: orderLimit = 100,
    currency,
    hacked,
  } = data;

  const [vendorFilter, setVendorFilter] = useLocalState(
    context,
    'cartVendorFilter',
    'All'
  );
  const [catFilter, setCatFilter] = useLocalState(
    context,
    'cartCategoryFilter',
    'All'
  );

  const vendors: { id: string; name: string }[] = [];
  for (const item of cart) {
    if (!vendors.some((v) => v.id === item.station_id)) {
      vendors.push({ id: item.station_id, name: item.station });
    }
  }
  const activeVendor = vendors.some((v) => v.id === vendorFilter)
    ? vendorFilter
    : 'All';

  const categories = ['All'];
  for (const item of cart) {
    if (
      (activeVendor === 'All' || item.station_id === activeVendor) &&
      !categories.includes(item.category)
    ) {
      categories.push(item.category);
    }
  }
  const activeCat = categories.includes(catFilter) ? catFilter : 'All';

  const visible = cart.filter(
    (item) =>
      (activeVendor === 'All' || item.station_id === activeVendor) &&
      (activeCat === 'All' || item.category === activeCat)
  );

  const getLiveStock = (item: CartItem): number =>
    item.id in stocks ? stocks[item.id] : item.stock;

  const isItemOverstock = (item: CartItem): boolean =>
    item.quantity > getLiveStock(item) || cartOverstockIds.includes(item.id);

  const isItemRestricted = (item: CartItem): boolean =>
    Boolean(item.restricted || (secLocked[item.id] && !hacked));

  const hasRestricted = cart.some(isItemRestricted);
  const hasOverstock = cart.some(isItemOverstock);
  const neededTiles = computeNeededTiles(cart, cartFloorNeeded);
  const remainingOrderLimit = Math.max(0, orderLimit - cartCount);

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={`Shopping Cart (${cartCount} / ${orderLimit} units)`}
          buttons={
            cart.length > 0 && (
              <>
                <Button icon="save" content="Save Cart" onClick={onSaveClick} />
                <Button.Confirm
                  icon="trash"
                  content="Clear cart"
                  onClick={() => act('clear_cart')}
                />
              </>
            )
          }
        >
          {visible.length === 0 ? (
            <NoticeBox>
              Your cart is empty. Add items from the Catalog tab.
            </NoticeBox>
          ) : (
            <>
              {(vendors.length > 1 || categories.length > 2) && (
                <Stack wrap align="center" mb={0.75}>
                  {vendors.length > 1 && (
                    <Stack.Item>
                      <Dropdown
                        width="16em"
                        options={[
                          { value: 'All', displayText: 'All relays' },
                          ...vendors.map((vendor) => ({
                            value: vendor.id,
                            displayText: vendor.name,
                          })),
                        ]}
                        selected={activeVendor}
                        displayText={
                          vendors.find((vendor) => vendor.id === activeVendor)
                            ?.name || 'All relays'
                        }
                        onSelected={(id) => {
                          setVendorFilter(id);
                          setCatFilter('All');
                        }}
                      />
                    </Stack.Item>
                  )}
                  {categories.length > 2 && (
                    <Stack.Item>
                      <Dropdown
                        width="14em"
                        options={categories.map((cat) => ({
                          value: cat,
                          displayText: cat === 'All' ? 'All categories' : cat,
                        }))}
                        selected={activeCat}
                        displayText={
                          activeCat === 'All' ? 'All categories' : activeCat
                        }
                        onSelected={setCatFilter}
                      />
                    </Stack.Item>
                  )}
                  {(activeVendor !== 'All' || activeCat !== 'All') && (
                    <Stack.Item color="label">
                      Showing {visible.length} of {cart.length} lines. Checkout
                      covers the entire cart.
                    </Stack.Item>
                  )}
                </Stack>
              )}
              <Table>
                <Table.Row header>
                  <Table.Cell>Vendor / Category</Table.Cell>
                  <Table.Cell>Goods</Table.Cell>
                  <Table.Cell textAlign="right">Quantity</Table.Cell>
                  <Table.Cell textAlign="right">Unit</Table.Cell>
                  <Table.Cell textAlign="right">Subtotal</Table.Cell>
                </Table.Row>
                {visible.map((item) => (
                  <CartRow
                    key={item.id}
                    item={item}
                    liveStock={getLiveStock(item)}
                    overstock={isItemOverstock(item)}
                    restricted={isItemRestricted(item)}
                    remainingOrderLimit={remainingOrderLimit}
                    currency={currency}
                    act={act}
                  />
                ))}
              </Table>
            </>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <CartCheckoutFooter
          data={data}
          hasRestricted={hasRestricted}
          hasOverstock={hasOverstock}
          neededTiles={neededTiles}
          act={act}
          onPurchaseClick={onPurchaseClick}
          onRequestClick={onRequestClick}
        />
      </Stack.Item>
    </Stack>
  );
};
