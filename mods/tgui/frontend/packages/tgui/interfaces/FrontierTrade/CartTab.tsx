import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
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
        {item.floor_delivery && (
          <Box fontSize="11px" color="label">
            [Floor Delivery: requires {item.quantity} clear pad tile(s)]
          </Box>
        )}
        {overstock && (
          <Box fontSize="11px" color="bad" bold>
            Out of stock / stale quantity: {item.quantity} in cart, only{' '}
            {liveStock} available!
          </Box>
        )}
        {restricted && (
          <Box fontSize="11px" color="average">
            Department authorization required for personal purchase.
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
              content="+5"
              disabled={!canAddMore}
              onClick={() => act('add_cart', { id: item.id, amount: 5 })}
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
              content="×"
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
  onSaveClick: () => void;
}) => {
  const {
    data,
    hasRestricted,
    hasOverstock,
    neededTiles,
    act,
    onPurchaseClick,
    onRequestClick,
    onSaveClick,
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
  const hasEnoughTiles = freeTiles === undefined || freeTiles >= neededTiles;
  const receiverEntropy = beacons?.receiver_entropy ?? 0;
  const entropyLimit = staticEntropyLimit || beacons?.entropy_limit || 30;
  const receiverLockedSeconds = beacons?.receiver_locked_seconds ?? 0;
  const estDeliverySeconds =
    beacons?.estimated_delivery_seconds ??
    (receiverLockedSeconds > 0 ? receiverLockedSeconds : 2);

  return (
    <Section>
      <NoticeBox info={!hasOverstock} danger={hasOverstock}>
        <Stack vertical>
          <Stack.Item>
            Goods: {cartTotal} {currency}; Personal 20% handling: {cartFee}{' '}
            {currency}; Personal total: {personalTotal} {currency}.
          </Stack.Item>
          <Stack.Item>
            <Stack wrap align="center">
              {accountKnown && (
                <Stack.Item>
                  <Box
                    as="span"
                    bold
                    color={canAffordPersonal ? 'good' : 'bad'}
                  >
                    Personal Balance: {account?.balance ?? 0} {currency}{' '}
                    {canAffordPersonal
                      ? '(Sufficient funds)'
                      : `(Short by ${personalShortfall} ${currency})`}
                  </Box>
                </Stack.Item>
              )}
              {manager && (
                <Stack.Item>
                  <Box as="span" bold color={canAffordBudget ? 'good' : 'bad'}>
                    Supply Budget: {budget} {currency}{' '}
                    {canAffordBudget
                      ? '(Sufficient funds)'
                      : `(Short by ${budgetShortfall} ${currency})`}
                  </Box>
                </Stack.Item>
              )}
              <Stack.Item>
                <Box
                  as="span"
                  color={
                    !beacons?.receiver_ready || !hasEnoughTiles
                      ? 'bad'
                      : receiverLockedSeconds > 0
                        ? 'average'
                        : 'good'
                  }
                >
                  Receiver ({beacons?.receiver_label || 'Automatic'}):{' '}
                  {beacons?.receiver_ready ? 'Ready' : 'Offline / Blocked'}
                  {freeTiles !== undefined &&
                    ` · Pad Tiles: ${neededTiles} needed / ${freeTiles} free`}
                  {` · Entropy: ${receiverEntropy}/${entropyLimit}`}
                  {receiverLockedSeconds > 0
                    ? ` · Instability: ${receiverLockedSeconds}s remaining`
                    : ` · Est. Delivery: ~${estDeliverySeconds}s`}
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </NoticeBox>
      <Stack wrap align="center">
        <Stack.Item>
          <Button
            icon="credit-card"
            color="good"
            disabled={
              cart.length === 0 ||
              !account?.card_inserted ||
              !beacons?.receiver_ready ||
              hasRestricted ||
              hasOverstock ||
              !hasEnoughTiles ||
              (accountKnown && !canAffordPersonal)
            }
            content="Pay with Inserted ID"
            onClick={onPurchaseClick}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="file-alt"
            disabled={cart.length === 0 || requestWait > 0 || hasOverstock}
            content={
              requestWait > 0
                ? `Cooldown: ${requestWait}s`
                : 'Request Department Funding'
            }
            onClick={onRequestClick}
          />
        </Stack.Item>
        {manager && (
          <Stack.Item>
            <Button
              icon="check"
              color="good"
              disabled={
                cart.length === 0 ||
                !beacons?.receiver_ready ||
                hasOverstock ||
                !hasEnoughTiles ||
                !canAffordBudget
              }
              content="Pay from Supply Budget"
              onClick={() => act('department')}
            />
          </Stack.Item>
        )}
        {hasOverstock && (
          <Stack.Item>
            <Button
              icon="wrench"
              color="average"
              content="Fix Stock"
              tooltip="Clamp all cart quantities to current available stock"
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
              tooltip="Remove items that require department authorization so you can pay personally"
              onClick={() => act('remove_restricted_cart')}
            />
          </Stack.Item>
        )}
        <Stack.Item grow />
        <Stack.Item>
          <Button
            icon="save"
            disabled={cart.length === 0}
            content="Save Cart"
            onClick={onSaveClick}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="trash"
            color="bad"
            disabled={cart.length === 0}
            content="Clear"
            onClick={() => act('clear_cart')}
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
      {cart.length > 0 && (
        <Stack.Item>
          <Section>
            <Stack wrap align="center">
              <Stack.Item color="label">Vendors:</Stack.Item>
              <Stack.Item>
                <Button
                  compact
                  selected={activeVendor === 'All'}
                  content="All"
                  onClick={() => {
                    setVendorFilter('All');
                    setCatFilter('All');
                  }}
                />
              </Stack.Item>
              {vendors.map((v) => (
                <Stack.Item key={v.id}>
                  <Button
                    compact
                    selected={activeVendor === v.id}
                    content={v.name}
                    onClick={() => {
                      setVendorFilter(v.id);
                      setCatFilter('All');
                    }}
                  />
                </Stack.Item>
              ))}
            </Stack>
            <Stack mt={0.5} wrap align="center">
              <Stack.Item color="label">Categories:</Stack.Item>
              {categories.map((cat) => (
                <Stack.Item key={cat}>
                  <Button
                    compact
                    selected={activeCat === cat}
                    content={cat}
                    onClick={() => setCatFilter(cat)}
                  />
                </Stack.Item>
              ))}
              {(activeVendor !== 'All' || activeCat !== 'All') && (
                <Stack.Item>
                  <Box as="span" ml={1} fontSize="11px" color="average">
                    Showing {visible.length} of {cart.length} items — checkout
                    applies to entire cart.
                  </Box>
                </Stack.Item>
              )}
            </Stack>
          </Section>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={`Shopping Cart (${cartCount} / ${orderLimit} units)`}
        >
          {visible.length === 0 ? (
            <NoticeBox>
              Your cart is empty. Add items from the Catalog tab.
            </NoticeBox>
          ) : (
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
          onSaveClick={onSaveClick}
        />
      </Stack.Item>
    </Stack>
  );
};
