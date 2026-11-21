import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
} from '../../components';
import {
  DeliveryMode,
  formatDuration,
  FrontierTradeData,
  matchesCatalogSearch,
  resolveCatalogGoods,
  ResolvedTradeGood,
  TradeStation,
} from './types';

const PAGE_SIZE = 40;

type SortMode = 'default' | 'name' | 'price_asc' | 'price_desc' | 'stock_desc';

export interface CatalogTabProps {
  selectedStationId: string;
  onSelectStation: (id: string) => void;
  onOpenCart?: () => void;
}

const deliveryBadgeLabel = (good: ResolvedTradeGood): string => {
  const mode: DeliveryMode = good.delivery_mode;
  if (mode === 'livestock') {
    return `Livestock (${good.container_label || 'Critter Crate'})`;
  }
  if (mode === 'large_crate') {
    return good.container_label || 'Large Crate';
  }
  if (mode === 'secure_crate') {
    return good.container_label || 'Secure Crate';
  }
  if (mode === 'crate') {
    return good.container_label || 'Crate';
  }
  if (mode === 'floor' || good.floor_delivery) {
    return 'Floor Delivery';
  }
  return good.container_label || 'Personal Locker';
};

export const CatalogTab = (props: CatalogTabProps, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const { selectedStationId, onSelectStation, onOpenCart } = props;
  const {
    stations = [],
    read_only: readOnly,
    currency,
    cart_count: cartCount = 0,
    cart_total: cartTotal = 0,
    cart_fee: cartFee = 0,
    order_limit: orderLimit = 100,
  } = data;

  const discovered = stations.filter(
    (s) => s.discovered && (!s.black_market || data.hacked)
  );
  const matchedStation: TradeStation | undefined = discovered.find(
    (s) => s.id === selectedStationId
  );
  const isAllRelays = selectedStationId === 'all' || !matchedStation;
  const activeStation: TradeStation | undefined = isAllRelays
    ? undefined
    : matchedStation;

  const [category, setCategory] = useLocalState(
    context,
    'catalogCategory',
    'All'
  );
  const [search, setSearch] = useLocalState(context, 'catalogSearch', '');
  const [page, setPage] = useLocalState(context, 'catalogPage', 1);
  const [inStockOnly, setInStockOnly] = useLocalState(
    context,
    'catalogInStockOnly',
    false
  );
  const [hideRestricted, setHideRestricted] = useLocalState(
    context,
    'catalogHideRestricted',
    false
  );
  const [inCartOnly, setInCartOnly] = useLocalState(
    context,
    'catalogInCartOnly',
    false
  );
  const [sortBy, setSortBy] = useLocalState<SortMode>(
    context,
    'catalogSortBy',
    'default'
  );
  const [expandedGoodId, setExpandedGoodId] = useLocalState<string>(
    context,
    'catalogExpandedGoodId',
    ''
  );

  if (discovered.length === 0) {
    return (
      <NoticeBox>
        No frontier relays discovered yet. Scan contacts with ship sensors.
      </NoticeBox>
    );
  }

  const allResolvedGoods = resolveCatalogGoods(data);
  const needle = search.trim().toLowerCase();

  // Compute per-station search match counts when a search query is active
  const matchCountByStation: Record<string, number> = {};
  let totalSearchMatches = 0;
  if (needle) {
    for (let i = 0; i < allResolvedGoods.length; i++) {
      const g = allResolvedGoods[i];
      if (matchesCatalogSearch(g, needle)) {
        matchCountByStation[g.station_id] =
          (matchCountByStation[g.station_id] || 0) + 1;
        totalSearchMatches++;
      }
    }
  }

  const stationScopedGoods = isAllRelays
    ? allResolvedGoods
    : allResolvedGoods.filter((g) => g.station_id === activeStation?.id);

  const categories = ['All'];
  for (let i = 0; i < stationScopedGoods.length; i++) {
    const cat = stationScopedGoods[i].category;
    if (cat && !categories.includes(cat)) {
      categories.push(cat);
    }
  }
  const effectiveCategory = categories.includes(category) ? category : 'All';

  const filtered = stationScopedGoods.filter((good) => {
    if (effectiveCategory !== 'All' && good.category !== effectiveCategory) {
      return false;
    }
    if (inStockOnly && good.stock <= 0) {
      return false;
    }
    if (hideRestricted && good.restricted) {
      return false;
    }
    if (inCartOnly && good.cart_count <= 0) {
      return false;
    }
    return matchesCatalogSearch(good, needle);
  });

  const sorted =
    sortBy === 'default'
      ? filtered
      : [...filtered].sort((a, b) => {
          if (sortBy === 'name') {
            return a.name.localeCompare(b.name);
          }
          if (sortBy === 'price_asc') {
            return a.price - b.price || a.name.localeCompare(b.name);
          }
          if (sortBy === 'price_desc') {
            return b.price - a.price || a.name.localeCompare(b.name);
          }
          if (sortBy === 'stock_desc') {
            return b.stock - a.stock || a.name.localeCompare(b.name);
          }
          return 0;
        });

  const pageCount = Math.max(1, Math.ceil(sorted.length / PAGE_SIZE));
  const safePage = Math.min(Math.max(1, page), pageCount);
  const visible = sorted.slice(
    (safePage - 1) * PAGE_SIZE,
    safePage * PAGE_SIZE
  );

  const favorRatio = activeStation?.favor_needed
    ? activeStation.favor / activeStation.favor_needed
    : 0;
  const favorColor =
    favorRatio < 0.25 ? 'bad' : favorRatio < 0.5 ? 'average' : 'good';

  const remainingOrderLimit = Math.max(0, orderLimit - cartCount);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section>
          <Stack wrap align="center">
            <Stack.Item>
              <Button
                icon="globe"
                selected={isAllRelays}
                content={
                  needle
                    ? `All Relays (${totalSearchMatches})`
                    : `All Relays (${allResolvedGoods.length})`
                }
                tooltip="Search and browse across all discovered frontier relays at once"
                onClick={() => {
                  onSelectStation('all');
                  setPage(1);
                }}
              />
            </Stack.Item>
            {discovered.map((station) => {
              const matchCount = matchCountByStation[station.id] || 0;
              return (
                <Stack.Item key={station.id}>
                  <Button
                    selected={!isAllRelays && station.id === activeStation?.id}
                    color={station.black_market ? 'bad' : undefined}
                    content={
                      needle
                        ? `${station.label} (${matchCount})`
                        : station.label
                    }
                    tooltip={station.name}
                    onClick={() => {
                      onSelectStation(station.id);
                      setCategory('All');
                      setPage(1);
                    }}
                  />
                </Stack.Item>
              );
            })}
          </Stack>
          <Stack mt={0.5} align="center" wrap>
            <Stack.Item grow>
              {activeStation ? (
                <Stack align="center">
                  <Stack.Item>
                    <Box bold>
                      {activeStation.name}
                      {activeStation.black_market && (
                        <Box as="span" ml={0.5} color="bad">
                          [BLACK MARKET]
                        </Box>
                      )}
                    </Box>
                    <Box fontSize="11px" color="label">
                      Restock in {formatDuration(activeStation.restock_seconds)}{' '}
                      ({activeStation.restock_seconds}s)
                    </Box>
                  </Stack.Item>
                </Stack>
              ) : (
                <Box>
                  <Box bold>
                    All Discovered Frontier Relays ({discovered.length} relays)
                  </Box>
                  <Box fontSize="11px" color="label">
                    Showing {sorted.length} of {allResolvedGoods.length} catalog
                    goods across all active relays
                  </Box>
                </Box>
              )}
            </Stack.Item>
            {activeStation && (
              <Stack.Item width="200px">
                <ProgressBar
                  value={activeStation.favor}
                  minValue={0}
                  maxValue={Math.max(1, activeStation.favor_needed)}
                  color={favorColor}
                >
                  {activeStation.recommendation_unlocked
                    ? `Favor: ${activeStation.favor} (Max Tier)`
                    : `Favor: ${activeStation.favor} / ${activeStation.favor_needed}`}
                </ProgressBar>
              </Stack.Item>
            )}
            <Stack.Item width="240px">
              <Stack align="center">
                <Stack.Item grow>
                  <Input
                    fluid
                    placeholder="Search goods, pack contents..."
                    value={search}
                    onInput={(_, value) => {
                      setSearch(value);
                      setPage(1);
                    }}
                  />
                </Stack.Item>
                {search.length > 0 && (
                  <Stack.Item>
                    <Button
                      compact
                      icon="times"
                      color="bad"
                      tooltip="Clear search"
                      onClick={() => {
                        setSearch('');
                        setPage(1);
                      }}
                    />
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          </Stack>
          <Stack mt={0.5} align="center" justify="space-between" wrap>
            <Stack.Item>
              <Stack align="center" wrap>
                <Stack.Item>
                  <Button
                    compact
                    icon="box-open"
                    selected={inStockOnly}
                    content="In Stock Only"
                    onClick={() => {
                      setInStockOnly(!inStockOnly);
                      setPage(1);
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    compact
                    icon="id-badge"
                    selected={hideRestricted}
                    content="Hide Restricted"
                    tooltip="Only show items eligible for immediate personal ID purchase"
                    onClick={() => {
                      setHideRestricted(!hideRestricted);
                      setPage(1);
                    }}
                  />
                </Stack.Item>
                {!readOnly && (
                  <Stack.Item>
                    <Button
                      compact
                      icon="shopping-basket"
                      selected={inCartOnly}
                      content="In Cart"
                      onClick={() => {
                        setInCartOnly(!inCartOnly);
                        setPage(1);
                      }}
                    />
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item color="label" fontSize="11px">
                  Sort:
                </Stack.Item>
                <Stack.Item>
                  <Button
                    compact
                    selected={sortBy === 'name'}
                    content="Name"
                    onClick={() =>
                      setSortBy(sortBy === 'name' ? 'default' : 'name')
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    compact
                    selected={sortBy === 'price_asc'}
                    content="Price ↑"
                    onClick={() =>
                      setSortBy(
                        sortBy === 'price_asc' ? 'default' : 'price_asc'
                      )
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    compact
                    selected={sortBy === 'price_desc'}
                    content="Price ↓"
                    onClick={() =>
                      setSortBy(
                        sortBy === 'price_desc' ? 'default' : 'price_desc'
                      )
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    compact
                    selected={sortBy === 'stock_desc'}
                    content="Stock ↓"
                    onClick={() =>
                      setSortBy(
                        sortBy === 'stock_desc' ? 'default' : 'stock_desc'
                      )
                    }
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
          <Stack mt={0.5} wrap>
            {categories.map((cat) => (
              <Stack.Item key={cat}>
                <Button
                  compact
                  selected={effectiveCategory === cat}
                  content={cat}
                  onClick={() => {
                    setCategory(cat);
                    setPage(1);
                  }}
                />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {visible.length === 0 ? (
            <NoticeBox>No matching goods found.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>
                  {isAllRelays ? 'Relay / Category' : 'Category'}
                </Table.Cell>
                <Table.Cell>Goods & Manifest</Table.Cell>
                <Table.Cell textAlign="right">Stock</Table.Cell>
                <Table.Cell textAlign="right">Price</Table.Cell>
                {!readOnly && <Table.Cell textAlign="right">Cart</Table.Cell>}
              </Table.Row>
              {visible.map((good) => {
                const hasContents =
                  good.contents_preview && good.contents_preview.length > 0;
                const totalPackItems = hasContents
                  ? good.contents_preview.reduce(
                      (acc, r) => acc + (r.count || 1),
                      0
                    )
                  : 0;
                const isExpanded = expandedGoodId === good.id;
                const maxAddable = Math.min(
                  Math.max(0, good.stock - good.cart_count),
                  remainingOrderLimit
                );

                return (
                  <Table.Row
                    key={good.id}
                    className="candystripe"
                    style={{
                      opacity:
                        good.stock <= 0 && good.cart_count <= 0 ? '0.55' : '1',
                    }}
                  >
                    <Table.Cell>
                      {isAllRelays && (
                        <Box bold fontSize="11px">
                          {good.station_label}
                        </Box>
                      )}
                      <Box color="label" fontSize="11px">
                        {good.category}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Stack align="center" wrap>
                        <Stack.Item>
                          <Box as="span" bold>
                            {good.name}
                            {good.stack_size > 0 &&
                              ` (${good.stack_size}u stack)`}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            as="span"
                            fontSize="10px"
                            color={
                              good.delivery_mode === 'livestock' ||
                              good.floor_delivery
                                ? 'average'
                                : 'label'
                            }
                          >
                            [{deliveryBadgeLabel(good)}]
                          </Box>
                        </Stack.Item>
                        {hasContents && (
                          <Stack.Item>
                            <Button
                              compact
                              icon={isExpanded ? 'chevron-up' : 'list'}
                              content={
                                good.randomized_count > 0
                                  ? `Any ${good.randomized_count} of ${good.contents_preview.length}`
                                  : `Pack (${totalPackItems})`
                              }
                              tooltip="Click to toggle full pack manifest and description"
                              onClick={() =>
                                setExpandedGoodId(isExpanded ? '' : good.id)
                              }
                            />
                          </Stack.Item>
                        )}
                        {good.security_label && (
                          <Stack.Item>
                            <Box
                              as="span"
                              fontSize="10px"
                              bold
                              color={good.sec_locked ? 'bad' : 'good'}
                            >
                              [Alert: {good.security_label}]
                            </Box>
                          </Stack.Item>
                        )}
                        {good.access_labels.length > 0 ? (
                          <Stack.Item>
                            <Box
                              as="span"
                              fontSize="10px"
                              bold
                              color={good.access_satisfied ? 'good' : 'average'}
                            >
                              [
                              {good.access_satisfied ? 'Access OK' : 'Requires'}
                              : {good.access_labels.join(', ')}]
                            </Box>
                          </Stack.Item>
                        ) : (
                          good.has_access_req && (
                            <Stack.Item>
                              <Box
                                as="span"
                                fontSize="10px"
                                bold
                                color={
                                  good.access_satisfied ? 'good' : 'average'
                                }
                              >
                                [
                                {good.access_satisfied
                                  ? 'Access OK'
                                  : 'Dept. Auth Required'}
                                ]
                              </Box>
                            </Stack.Item>
                          )
                        )}
                      </Stack>
                      {hasContents && !isExpanded && (
                        <Box fontSize="11px" color="label">
                          {good.randomized_count > 0
                            ? `Random ${good.randomized_count} of: `
                            : 'Contains: '}
                          {good.contents_preview
                            .slice(0, 4)
                            .map((r) =>
                              r.count > 1 ? `${r.count}x ${r.name}` : r.name
                            )
                            .join(', ')}
                          {good.contents_preview.length > 4 &&
                            ` (+${good.contents_preview.length - 4} more)`}
                        </Box>
                      )}
                      {isExpanded && (
                        <Box
                          mt={0.5}
                          p={0.5}
                          style={{
                            background: 'rgba(0, 0, 0, 0.25)',
                            border: '1px solid rgba(255, 255, 255, 0.12)',
                          }}
                        >
                          {good.desc && (
                            <Box fontSize="11px" mb={0.5}>
                              {good.desc}
                            </Box>
                          )}
                          <Box fontSize="11px" color="label">
                            Delivery Container: {good.container_label}
                            {good.randomized_count > 0 &&
                              ` · Drops any ${good.randomized_count} from list:`}
                          </Box>
                          {good.contents_preview.map((row, idx) => (
                            <Box key={idx} fontSize="11px">
                              • {row.count}x {row.name}
                            </Box>
                          ))}
                        </Box>
                      )}
                      {!hasContents && good.desc && (
                        <Box fontSize="11px" color="label">
                          {good.desc}
                        </Box>
                      )}
                      {good.floor_delivery && (
                        <Box fontSize="11px" color="average">
                          Delivered onto receiving beacon floor.
                        </Box>
                      )}
                      {good.restricted && (
                        <Box fontSize="11px" color="average">
                          {good.sec_locked
                            ? `Requires ${
                                good.security_label || 'higher security alert'
                              } level.`
                            : `Department authorization required for personal purchase.${
                                good.access_labels.length > 0
                                  ? ` (${good.access_labels.join(', ')})`
                                  : ''
                              }`}
                        </Box>
                      )}
                    </Table.Cell>
                    <Table.Cell
                      textAlign="right"
                      color={good.stock <= 0 ? 'bad' : undefined}
                    >
                      {good.stock}
                    </Table.Cell>
                    <Table.Cell textAlign="right">
                      {good.price} {currency}
                    </Table.Cell>
                    {!readOnly && (
                      <Table.Cell textAlign="right">
                        {good.stock <= 0 && good.cart_count <= 0 ? (
                          <Box color="bad" fontSize="11px" bold>
                            Out of Stock
                          </Box>
                        ) : (
                          <Stack justify="flex-end" align="center">
                            <Stack.Item>
                              <Button
                                compact
                                icon="minus"
                                disabled={good.cart_count <= 0}
                                onClick={() =>
                                  act('remove_cart', { id: good.id })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <NumberInput
                                width="44px"
                                step={1}
                                value={good.cart_count}
                                minValue={0}
                                maxValue={Math.max(
                                  1,
                                  good.stock,
                                  good.cart_count
                                )}
                                onChange={(_, value) =>
                                  act('set_cart_qty', {
                                    id: good.id,
                                    quantity: value,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                compact
                                icon="plus"
                                disabled={maxAddable <= 0}
                                tooltip={
                                  remainingOrderLimit <= 0
                                    ? `Order limit (${orderLimit}) reached`
                                    : 'Add 1 to cart'
                                }
                                onClick={() => act('add_cart', { id: good.id })}
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                compact
                                content="+5"
                                disabled={maxAddable <= 0}
                                tooltip="Add up to 5 units to cart"
                                onClick={() =>
                                  act('add_cart', { id: good.id, amount: 5 })
                                }
                              />
                            </Stack.Item>
                          </Stack>
                        )}
                      </Table.Cell>
                    )}
                  </Table.Row>
                );
              })}
            </Table>
          )}
        </Section>
      </Stack.Item>
      {pageCount > 1 && (
        <Stack.Item>
          <Stack justify="center" align="center">
            <Stack.Item>
              <Button
                icon="angle-double-left"
                disabled={safePage <= 1}
                onClick={() => setPage(1)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-left"
                disabled={safePage <= 1}
                onClick={() => setPage(safePage - 1)}
              />
            </Stack.Item>
            <Stack.Item>
              Page {safePage} / {pageCount} ({sorted.length} entries)
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-right"
                disabled={safePage >= pageCount}
                onClick={() => setPage(safePage + 1)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="angle-double-right"
                disabled={safePage >= pageCount}
                onClick={() => setPage(pageCount)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      )}
      {!readOnly && cartCount > 0 && (
        <Stack.Item>
          <Section fitted p={0.75}>
            <Stack align="center" justify="space-between">
              <Stack.Item>
                <Box as="span" bold>
                  Cart: {cartCount} / {orderLimit} units
                </Box>
                <Box as="span" ml={1} color="good" bold>
                  Subtotal: {cartTotal} {currency}
                </Box>
                <Box as="span" ml={0.5} color="label" fontSize="11px">
                  (+{cartFee} {currency} personal handling fee ={' '}
                  {cartTotal + cartFee} {currency})
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  {onOpenCart && (
                    <Stack.Item>
                      <Button
                        compact
                        color="good"
                        icon="shopping-basket"
                        content="Review Cart & Checkout"
                        onClick={onOpenCart}
                      />
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    <Button
                      compact
                      color="bad"
                      icon="trash"
                      content="Clear Cart"
                      onClick={() => act('clear_cart')}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};
