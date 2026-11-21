import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
} from '../../components';
import {
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

const sortOptions: { value: SortMode; displayText: string }[] = [
  { value: 'default', displayText: 'Default' },
  { value: 'name', displayText: 'Name' },
  { value: 'price_asc', displayText: 'Lowest price' },
  { value: 'price_desc', displayText: 'Highest price' },
  { value: 'stock_desc', displayText: 'Most in stock' },
];

const GoodDetails = ({ good }: { good: ResolvedTradeGood }) => (
  <Box p={1}>
    {good.desc && <Box mb={0.5}>{good.desc}</Box>}
    <Box color="label">
      Delivery: {good.container_label}
      {good.floor_delivery && ' (requires clear space at the receiver)'}
    </Box>
    {good.has_access_req && (
      <Box color={good.access_satisfied ? 'label' : 'average'}>
        Personal purchase requires{' '}
        {good.access_labels.join(', ') || 'department authorization'}.
      </Box>
    )}
    {good.security_label && (
      <Box color={good.sec_locked ? 'average' : 'label'}>
        Alert level: {good.security_label}
      </Box>
    )}
    {good.contents_preview.length > 0 && (
      <Box mt={0.5}>
        <Box bold>
          {good.randomized_count > 0
            ? 'Includes ' +
              good.randomized_count +
              ' of the following at random'
            : 'Contents'}
        </Box>
        {good.contents_preview.map((row, idx) => (
          <Box key={idx}>
            {row.count} × {row.name}
          </Box>
        ))}
      </Box>
    )}
  </Box>
);

export const CatalogTab = (props: CatalogTabProps, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const { selectedStationId, onSelectStation, onOpenCart } = props;
  const {
    stations = [],
    read_only: readOnly,
    currency,
    cart_count: cartCount = 0,
    cart_total: cartTotal = 0,
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
  const [showFilters, setShowFilters] = useLocalState(
    context,
    'catalogShowFilters',
    false
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
    if (!readOnly && inCartOnly && good.cart_count <= 0) {
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

  const remainingOrderLimit = Math.max(0, orderLimit - cartCount);
  const extraFilters =
    Number(inStockOnly) +
    Number(hideRestricted) +
    Number(inCartOnly && !readOnly);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section>
          <Stack align="center" wrap>
            <Stack.Item grow minWidth="13em">
              <Input
                fluid
                placeholder="Search goods or pack contents"
                value={search}
                onInput={(_, value) => {
                  setSearch(value);
                  setPage(1);
                }}
              />
            </Stack.Item>
            {search && (
              <Stack.Item>
                <Button
                  icon="times"
                  tooltip="Clear search"
                  onClick={() => {
                    setSearch('');
                    setPage(1);
                  }}
                />
              </Stack.Item>
            )}
            <Stack.Item>
              <Dropdown
                width="11em"
                options={[
                  { value: 'all', displayText: 'All relays' },
                  ...discovered.map((station) => ({
                    value: station.id,
                    displayText: station.label,
                  })),
                ]}
                selected={activeStation?.id || 'all'}
                displayText={activeStation?.label || 'All relays'}
                onSelected={(id) => {
                  onSelectStation(id);
                  setCategory('All');
                  setPage(1);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Dropdown
                width="14em"
                options={categories.map((cat) => ({
                  value: cat,
                  displayText: cat === 'All' ? 'All categories' : cat,
                }))}
                selected={effectiveCategory}
                displayText={
                  effectiveCategory === 'All'
                    ? 'All categories'
                    : effectiveCategory
                }
                onSelected={(value) => {
                  setCategory(value);
                  setPage(1);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="filter"
                selected={showFilters}
                content={
                  extraFilters ? 'Filters (' + extraFilters + ')' : 'Filters'
                }
                onClick={() => setShowFilters(!showFilters)}
              />
            </Stack.Item>
          </Stack>
          {showFilters && (
            <Stack mt={0.75} align="center" wrap>
              <Stack.Item>
                <Button.Checkbox
                  checked={inStockOnly}
                  content="In stock"
                  onClick={() => {
                    setInStockOnly(!inStockOnly);
                    setPage(1);
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  checked={hideRestricted}
                  content="Hide restricted"
                  tooltip="Show goods available for personal purchase"
                  onClick={() => {
                    setHideRestricted(!hideRestricted);
                    setPage(1);
                  }}
                />
              </Stack.Item>
              {!readOnly && (
                <Stack.Item>
                  <Button.Checkbox
                    checked={inCartOnly}
                    content="In cart"
                    onClick={() => {
                      setInCartOnly(!inCartOnly);
                      setPage(1);
                    }}
                  />
                </Stack.Item>
              )}
              <Stack.Item grow />
              <Stack.Item color="label">Sort by</Stack.Item>
              <Stack.Item>
                <Dropdown
                  width="11em"
                  options={sortOptions}
                  selected={sortBy}
                  displayText={
                    sortOptions.find((option) => option.value === sortBy)
                      ?.displayText
                  }
                  onSelected={(value) => {
                    setSortBy(value as SortMode);
                    setPage(1);
                  }}
                />
              </Stack.Item>
            </Stack>
          )}
          {activeStation && (
            <Box mt={0.75} color="label">
              {activeStation.name} · Restock in{' '}
              {formatDuration(activeStation.restock_seconds)}
              {' · Favor '}
              {activeStation.favor}
              {!activeStation.recommendation_unlocked &&
                ' / ' + activeStation.favor_needed}
            </Box>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={'Goods (' + sorted.length + ')'}>
          {visible.length === 0 ? (
            <NoticeBox>No matching goods found.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Item</Table.Cell>
                <Table.Cell>
                  {isAllRelays ? 'Relay / Category' : 'Category'}
                </Table.Cell>
                <Table.Cell collapsing px={0.75} textAlign="right">
                  Stock
                </Table.Cell>
                <Table.Cell collapsing px={0.75} textAlign="right">
                  Price ({currency})
                </Table.Cell>
                {!readOnly && (
                  <Table.Cell width="9em" textAlign="right">
                    Cart
                  </Table.Cell>
                )}
              </Table.Row>
              {visible.map((good) => {
                const expanded = expandedGoodId === good.id;
                const maxAddable = Math.min(
                  good.stock - good.cart_count,
                  remainingOrderLimit
                );
                const addOne = () => act('add_cart', { id: good.id });
                const detailsLabel =
                  (expanded ? 'Hide ' : 'Show ') + good.name + ' details';
                return (
                  <Fragment key={good.id}>
                    <Table.Row className="candystripe">
                      <Table.Cell py={0.5}>
                        <Stack align="center">
                          <Stack.Item>
                            <Button
                              compact
                              color="transparent"
                              icon={expanded ? 'chevron-down' : 'chevron-right'}
                              aria-label={detailsLabel}
                              aria-expanded={expanded}
                              tooltip={detailsLabel}
                              onClick={() =>
                                setExpandedGoodId(expanded ? '' : good.id)
                              }
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Box bold>
                              {good.name}
                              {good.stack_size > 0 &&
                                ' (' + good.stack_size + ')'}
                            </Box>
                            {good.floor_delivery && (
                              <Box color="label">Floor delivery</Box>
                            )}
                            {good.restricted && (
                              <Box color="average">
                                <Icon name="lock" mr={0.5} />
                                {good.sec_locked
                                  ? good.security_label ||
                                    'Higher alert required'
                                  : good.access_labels.join(', ') ||
                                    'Department access'}
                              </Box>
                            )}
                          </Stack.Item>
                        </Stack>
                      </Table.Cell>
                      <Table.Cell color="label">
                        {isAllRelays && <Box>{good.station_label}</Box>}
                        {good.category}
                      </Table.Cell>
                      <Table.Cell
                        textAlign="right"
                        px={0.75}
                        color={good.stock <= 0 ? 'label' : undefined}
                      >
                        {good.stock}
                      </Table.Cell>
                      <Table.Cell px={0.75} textAlign="right">
                        {good.price}
                      </Table.Cell>
                      {!readOnly && (
                        <Table.Cell
                          textAlign="right"
                          style={{ whiteSpace: 'nowrap' }}
                        >
                          {good.cart_count > 0 ? (
                            <>
                              <Button
                                compact
                                icon="minus"
                                tooltip="Remove one from cart"
                                onClick={() =>
                                  act('remove_cart', { id: good.id })
                                }
                              />
                              <NumberInput
                                width="3.5em"
                                step={1}
                                value={good.cart_count}
                                minValue={0}
                                maxValue={
                                  good.cart_count + Math.max(0, maxAddable)
                                }
                                onChange={(_, value) =>
                                  act('set_cart_qty', {
                                    id: good.id,
                                    quantity: value,
                                  })
                                }
                              />
                              <Button
                                compact
                                ml={0.5}
                                icon="plus"
                                tooltip="Add one to cart"
                                disabled={maxAddable <= 0}
                                onClick={addOne}
                              />
                            </>
                          ) : good.stock > 0 ? (
                            <Button
                              icon="plus"
                              content="Add"
                              disabled={maxAddable <= 0}
                              tooltip={
                                maxAddable <= 0
                                  ? 'Order limit reached'
                                  : undefined
                              }
                              onClick={addOne}
                            />
                          ) : (
                            <Box color="label">Out of stock</Box>
                          )}
                        </Table.Cell>
                      )}
                    </Table.Row>
                    {expanded && (
                      <Table.Row className="candystripe">
                        <Table.Cell colSpan={readOnly ? 4 : 5}>
                          <GoodDetails good={good} />
                          {!readOnly && maxAddable > 1 && (
                            <Button
                              ml={1}
                              mb={0.75}
                              icon="cart-plus"
                              content={
                                'Add ' + Math.min(5, maxAddable) + ' to cart'
                              }
                              onClick={() =>
                                act('add_cart', {
                                  id: good.id,
                                  amount: Math.min(5, maxAddable),
                                })
                              }
                            />
                          )}
                        </Table.Cell>
                      </Table.Row>
                    )}
                  </Fragment>
                );
              })}
            </Table>
          )}
        </Section>
      </Stack.Item>
      {(pageCount > 1 || (!readOnly && cartCount > 0)) && (
        <Stack.Item>
          <Section fitted p={0.75}>
            <Stack align="center" justify="space-between" wrap>
              <Stack.Item>
                {pageCount > 1 && (
                  <>
                    <Button
                      icon="angle-double-left"
                      tooltip="First page"
                      disabled={safePage === 1}
                      onClick={() => setPage(1)}
                    />
                    <Button
                      icon="chevron-left"
                      tooltip="Previous page"
                      disabled={safePage === 1}
                      onClick={() => setPage(safePage - 1)}
                    />
                    <Box as="span" mx={0.75}>
                      Page {safePage} / {pageCount}
                    </Box>
                    <Button
                      icon="chevron-right"
                      tooltip="Next page"
                      disabled={safePage === pageCount}
                      onClick={() => setPage(safePage + 1)}
                    />
                    <Button
                      icon="angle-double-right"
                      tooltip="Last page"
                      disabled={safePage === pageCount}
                      onClick={() => setPage(pageCount)}
                    />
                  </>
                )}
              </Stack.Item>
              {!readOnly && cartCount > 0 && (
                <Stack.Item>
                  <Box as="span" mr={1} color="label">
                    Subtotal {cartTotal} {currency}
                  </Box>
                  <Button
                    icon="shopping-basket"
                    content="Review cart"
                    onClick={onOpenCart}
                  />
                </Stack.Item>
              )}
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};
