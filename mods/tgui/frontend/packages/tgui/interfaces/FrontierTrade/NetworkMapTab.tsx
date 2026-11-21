import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from '../../components';
import {
  formatDuration,
  FrontierTradeData,
  resolveCatalogGoods,
  TradeStation,
} from './types';

const STATION_ICONS: Record<string, string> = {
  wrench: 'wrench',
  heart: 'heart',
  gear: 'cog',
  power: 'bolt',
  search: 'search',
  cart: 'shopping-cart',
  person: 'user',
  star: 'star',
  locked: 'user-secret',
  signal: 'broadcast-tower',
  shield: 'shield-alt',
  security: 'shield-alt',
  armor: 'shield-alt',
  leaf: 'seedling',
  bio: 'seedling',
  fauna: 'paw',
  electronics: 'microchip',
  engines: 'bolt',
  medicine: 'heartbeat',
  engineering: 'wrench',
  general: 'shopping-cart',
};

const formatMarkupLabel = (markup?: number): string => {
  if (!markup) {
    return 'Standard';
  }
  if (markup <= 1.21) {
    return `Wholesale (${markup.toFixed(2)}x)`;
  }
  if (markup <= 1.3) {
    return `Standard (${markup.toFixed(2)}x)`;
  }
  if (markup <= 1.45) {
    return `Frontier (${markup.toFixed(2)}x)`;
  }
  return `Exotic / Rare (${markup.toFixed(2)}x)`;
};

export interface NetworkMapTabProps {
  selectedStationId: string;
  onSelectStation: (id: string) => void;
  onOpenTab: (tab: 'catalog' | 'bounties') => void;
}

export const NetworkMapTab = (props: NetworkMapTabProps, context) => {
  const { data } = useBackend<FrontierTradeData>(context);
  const { selectedStationId, onSelectStation, onOpenTab } = props;
  const { stations = [], tree_lines: treeLines = [], hacked } = data;
  const visibleStations = stations.filter((s) => !s.black_market || hacked);
  const selectedStation: TradeStation | undefined =
    visibleStations.find((s) => s.id === selectedStationId) ||
    visibleStations[0];

  const allResolvedGoods = resolveCatalogGoods(data);
  const selectedGoodsCount = selectedStation
    ? selectedStation.goods_count !== undefined
      ? selectedStation.goods_count
      : allResolvedGoods.filter((g) => g.station_id === selectedStation.id)
          .length
    : 0;
  const selectedActiveOffersCount = selectedStation
    ? (selectedStation.offers || []).filter((o) => !o.completed).length
    : 0;

  const favorPct = selectedStation?.favor_needed
    ? Math.min(1, selectedStation.favor / selectedStation.favor_needed)
    : 0;
  const favorColor =
    favorPct < 0.25 ? 'bad' : favorPct < 0.5 ? 'average' : 'good';

  return (
    <Stack fill>
      <Stack.Item grow={2} basis={0}>
        <Section
          fill
          title={`Locutus Frontier Relay Network (${
            visibleStations.filter((s) => s.discovered).length
          } / ${visibleStations.length} Active)`}
        >
          <Box
            position="relative"
            height="430px"
            style={{
              background: '#0d1520',
              border: '1px solid #355273',
              overflow: 'hidden',
            }}
          >
            <svg
              viewBox="0 0 100 100"
              preserveAspectRatio="none"
              style={{
                position: 'absolute',
                left: 0,
                top: 0,
                width: '100%',
                height: '100%',
                'pointer-events': 'none',
              }}
            >
              {treeLines.map((line, idx) => (
                <line
                  key={idx}
                  x1={line.x1}
                  y1={100 - line.y1}
                  x2={line.x2}
                  y2={100 - line.y2}
                  stroke={line.unlocked ? '#55bb88' : '#4a6b8a'}
                  strokeWidth="0.6"
                  strokeDasharray={line.unlocked ? undefined : '1.5,1.2'}
                />
              ))}
            </svg>
            {visibleStations.map((station) => {
              const isSelected = selectedStation?.id === station.id;
              const borderColor = isSelected
                ? '#ffcc55'
                : station.black_market
                  ? '#dd4444'
                  : station.discovered
                    ? '#55bb88'
                    : '#667788';
              const iconName =
                STATION_ICONS[station.icon] ||
                STATION_ICONS[station.id] ||
                'broadcast-tower';
              return (
                <Box
                  key={station.id}
                  position="absolute"
                  style={{
                    left: `${station.x}%`,
                    bottom: `${station.y}%`,
                    transform: 'translate(-50%, 50%)',
                    'z-index': 2,
                  }}
                >
                  <Button
                    tooltip={`${station.name}${
                      station.black_market ? ' [BLACK MARKET]' : ''
                    }`}
                    selected={isSelected}
                    color={
                      isSelected
                        ? 'average'
                        : station.black_market
                          ? 'bad'
                          : station.discovered
                            ? 'good'
                            : 'transparent'
                    }
                    style={{
                      width: '90px',
                      'text-align': 'center',
                      border: `2px solid ${borderColor}`,
                      background: isSelected
                        ? '#463b1f'
                        : station.black_market
                          ? '#3a181c'
                          : station.discovered
                            ? '#19322a'
                            : '#1c242e',
                      padding: '4px 3px',
                    }}
                    onClick={() => onSelectStation(station.id)}
                  >
                    <Box>
                      <Icon name={iconName} />
                    </Box>
                    <Box fontSize="10px" style={{ 'white-space': 'nowrap' }}>
                      {station.label}
                    </Box>
                  </Button>
                </Box>
              );
            })}
          </Box>
          <NoticeBox mt={1} info>
            Green: discovered relay. Grey: scan with ship sensors or earn
            recommendations from connected vendors.
            {hacked ? ' Red: emagged black-market syndicate relay.' : null}
          </NoticeBox>
        </Section>
      </Stack.Item>
      <Stack.Item grow={1} basis={0}>
        <Section fill scrollable title="Relay Dossier">
          {selectedStation ? (
            <Stack vertical>
              <Stack.Item>
                <Box fontSize="15px" bold color="label">
                  {selectedStation.name}
                  {Boolean(selectedStation.black_market) && (
                    <Box as="span" ml={0.5} color="bad">
                      [BLACK MARKET]
                    </Box>
                  )}
                </Box>
                <Box mt={0.5} color="light-grey">
                  {selectedStation.desc}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item
                    label="Status"
                    color={
                      selectedStation.black_market
                        ? 'bad'
                        : selectedStation.discovered
                          ? 'good'
                          : 'average'
                    }
                  >
                    {selectedStation.discovered
                      ? selectedStation.black_market
                        ? 'Illicit encrypted link active'
                        : 'Contact established'
                      : 'Undiscovered'}
                  </LabeledList.Item>
                  {selectedStation.specialties &&
                    selectedStation.specialties.length > 0 && (
                      <LabeledList.Item label="Specialties">
                        {selectedStation.specialties.join(', ')}
                      </LabeledList.Item>
                    )}
                  {selectedStation.markup !== undefined && (
                    <LabeledList.Item label="Pricing Tier">
                      {formatMarkupLabel(selectedStation.markup)}
                    </LabeledList.Item>
                  )}
                  {Boolean(selectedStation.discovered) && (
                    <LabeledList.Item label="Inventory">
                      {selectedGoodsCount} goods · {selectedActiveOffersCount}{' '}
                      active bounties
                    </LabeledList.Item>
                  )}
                  <LabeledList.Item label="Recommendations">
                    {selectedStation.recommendations_received} /{' '}
                    {selectedStation.recommendations_needed}
                  </LabeledList.Item>
                  <LabeledList.Item label="Next tier">
                    {selectedStation.recommendation_unlocked
                      ? 'Recommendations unlocked'
                      : selectedStation.hidden_unlocked
                        ? 'Recommendations'
                        : 'Preferred inventory'}
                  </LabeledList.Item>
                  {selectedStation.recommends.length > 0 && (
                    <LabeledList.Item label="Recommends">
                      {selectedStation.recommends.join(', ')}
                    </LabeledList.Item>
                  )}
                  {Boolean(selectedStation.discovered) && (
                    <LabeledList.Item label="Restock">
                      {formatDuration(selectedStation.restock_seconds)} (
                      {selectedStation.restock_seconds}s)
                    </LabeledList.Item>
                  )}
                </LabeledList>
              </Stack.Item>
              <Stack.Item>
                <Box mb={0.5} color="label">
                  Vendor Favor
                </Box>
                <ProgressBar
                  value={selectedStation.favor}
                  minValue={0}
                  maxValue={Math.max(1, selectedStation.favor_needed)}
                  color={favorColor}
                >
                  {selectedStation.recommendation_unlocked
                    ? `${selectedStation.favor} (Max Tier Unlocked)`
                    : `${selectedStation.favor} / ${selectedStation.favor_needed}`}
                </ProgressBar>
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  <Stack.Item grow>
                    <Button
                      fluid
                      icon="shopping-cart"
                      disabled={!selectedStation.discovered}
                      content="Browse Goods"
                      onClick={() => {
                        onSelectStation(selectedStation.id);
                        onOpenTab('catalog');
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Button
                      fluid
                      icon="tags"
                      disabled={!selectedStation.discovered}
                      content="View Bounties"
                      onClick={() => {
                        onSelectStation(selectedStation.id);
                        onOpenTab('bounties');
                      }}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          ) : (
            <NoticeBox>Select a relay node on the network map.</NoticeBox>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
