import { useBackend } from '../../backend';
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  Table,
} from '../../components';
import {
  formatDuration,
  FrontierTradeData,
  TradeOffer,
  TradeStation,
} from './types';

export interface BountiesTabProps {
  selectedStationId: string;
  onSelectStation: (id: string) => void;
}

interface ResolvedOffer extends TradeOffer {
  resolved_station_id: string;
  resolved_station_name: string;
  resolved_station_label: string;
  resolved_restock_seconds: number;
}

export const BountiesTab = (props: BountiesTabProps, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const { selectedStationId, onSelectStation } = props;
  const {
    stations = [],
    beacons,
    can_export: canExport,
    read_only: readOnly,
    program_type: programType,
    currency,
    export_time_max: staticExportTimeMax,
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

  if (discovered.length === 0) {
    return <NoticeBox>No frontier relays discovered yet.</NoticeBox>;
  }

  const allOffers: ResolvedOffer[] = [];
  for (let i = 0; i < discovered.length; i++) {
    const st = discovered[i];
    const offers = st.offers || [];
    for (let j = 0; j < offers.length; j++) {
      const offer = offers[j];
      allOffers.push({
        ...offer,
        resolved_station_id: offer.station_id || st.id,
        resolved_station_name: offer.station_name || st.name,
        resolved_station_label: st.label || offer.station_name || st.name,
        resolved_restock_seconds: st.restock_seconds,
      });
    }
  }

  const scopedOffers = isAllRelays
    ? [...allOffers].sort((a, b) => {
        if (a.completed !== b.completed) {
          return a.completed ? 1 : -1;
        }
        const aReady =
          !a.completed &&
          (a.can_fulfill ||
            (a.matched_count !== undefined && a.matched_count >= a.amount));
        const bReady =
          !b.completed &&
          (b.can_fulfill ||
            (b.matched_count !== undefined && b.matched_count >= b.amount));
        if (aReady !== bReady) {
          return aReady ? -1 : 1;
        }
        return (b.matched_count || 0) - (a.matched_count || 0);
      })
    : allOffers.filter((o) => o.resolved_station_id === activeStation?.id);

  const readyBountiesCount = allOffers.filter(
    (o) =>
      !o.completed &&
      (o.can_fulfill ||
        (o.matched_count !== undefined && o.matched_count >= o.amount))
  ).length;

  const cooldownDeciseconds =
    staticExportTimeMax || beacons?.export_time_max || 1200;
  const cooldownSeconds = Math.round(cooldownDeciseconds / 10);
  const cooldownLabel = formatDuration(cooldownSeconds);
  const exportPreview = beacons?.export_preview;
  const isSlave = programType === 'slave';

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
                  readyBountiesCount > 0
                    ? `All Relays (${allOffers.length} · ${readyBountiesCount} Ready)`
                    : `All Relays (${allOffers.length})`
                }
                onClick={() => onSelectStation('all')}
              />
            </Stack.Item>
            {discovered.map((station) => {
              const stOffers = station.offers || [];
              const stReady = stOffers.filter(
                (o) =>
                  !o.completed &&
                  (o.can_fulfill ||
                    (o.matched_count !== undefined &&
                      o.matched_count >= o.amount))
              ).length;
              return (
                <Stack.Item key={station.id}>
                  <Button
                    selected={!isAllRelays && station.id === activeStation?.id}
                    color={
                      stReady > 0
                        ? 'good'
                        : station.black_market
                          ? 'bad'
                          : undefined
                    }
                    content={
                      stReady > 0
                        ? `${station.label} (${stReady} Ready)`
                        : station.label
                    }
                    tooltip={station.name}
                    onClick={() => onSelectStation(station.id)}
                  />
                </Stack.Item>
              );
            })}
          </Stack>
          <NoticeBox mt={0.75} info>
            <Stack vertical>
              <Stack.Item>
                Place requested goods beside the sending beacon. Reagent
                bounties require separate containers holding at least the
                specified volume each (containers stay behind); material
                bounties require full stacks; live fauna must be inside stasis
                cages.
              </Stack.Item>
              <Stack.Item>
                <Box as="span" bold color="average">
                  Shared Export Cooldown ({cooldownLabel}):
                </Box>{' '}
                Each Export or single-bounty Fulfill triggers the{' '}
                {cooldownLabel} sending beacon cooldown. Use{' '}
                <Box as="span" bold>
                  Fulfill All
                </Box>{' '}
                to claim multiple ready bounties in a single cycle!
                {!readOnly && beacons && (
                  <Box
                    as="span"
                    ml={1}
                    bold
                    color={beacons.export_ready ? 'good' : 'average'}
                  >
                    [
                    {!beacons.sender_present
                      ? 'No Sending Beacon'
                      : beacons.export_ready
                        ? 'Beacon Ready'
                        : `Cooldown: ${beacons.export_seconds}s remaining`}
                    ]
                  </Box>
                )}
              </Stack.Item>
            </Stack>
          </NoticeBox>
          {!readOnly && exportPreview && (
            <NoticeBox
              mt={0.5}
              success={exportPreview.eligible_items > 0}
              info={exportPreview.eligible_items === 0}
            >
              <Stack align="center" justify="space-between" wrap>
                <Stack.Item>
                  <Box as="span" bold>
                    Sending Pad Appraisal:
                  </Box>{' '}
                  {exportPreview.eligible_items} eligible item(s) · Est. Export
                  Value:{' '}
                  <Box as="span" bold color="good">
                    {exportPreview.estimated_payout} {currency}
                  </Box>{' '}
                  (Payout destination: {exportPreview.payout_target})
                  {exportPreview.blocked_roots > 0 && (
                    <Box as="span" ml={1} color="bad" bold>
                      Warning: {exportPreview.blocked_roots} crate(s) skipped
                      due to protected items inside (ID card, living mob, or
                      beacon)
                    </Box>
                  )}
                </Stack.Item>
                {canExport && (
                  <Stack.Item>
                    <Stack>
                      <Stack.Item>
                        <Button
                          compact
                          icon="upload"
                          content={`Export Pad (${exportPreview.estimated_payout} ${currency})`}
                          disabled={
                            !beacons?.export_ready || !beacons?.sender_ready
                          }
                          onClick={() => act('export')}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          compact
                          color="good"
                          icon="check-double"
                          content={
                            readyBountiesCount > 0
                              ? `Fulfill All (${readyBountiesCount} Ready)`
                              : 'Fulfill All'
                          }
                          disabled={
                            !beacons?.export_ready || !beacons?.sender_ready
                          }
                          onClick={() => act('fulfill_all')}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                )}
              </Stack>
            </NoticeBox>
          )}
          {!readOnly && isSlave && !canExport && (
            <NoticeBox mt={0.5} warning>
              Local Slave Terminal: Insert and link your ID card in the header
              to claim local bounties (80% paid to your linked account, 20%
              Cargo commission; raw exports credit Cargo Supply Budget).
            </NoticeBox>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={
            activeStation
              ? `${activeStation.name} — Bounties (Refresh in ${formatDuration(
                  activeStation.restock_seconds
                )})`
              : `All Active Frontier Bounties (${scopedOffers.length})`
          }
        >
          {scopedOffers.length === 0 ? (
            <NoticeBox>No active bounties posted by this relay.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                {isAllRelays && <Table.Cell>Relay</Table.Cell>}
                <Table.Cell>Bounty & Requirements</Table.Cell>
                <Table.Cell textAlign="right">Pad Match / Required</Table.Cell>
                <Table.Cell textAlign="right">Reward & Favor</Table.Cell>
                <Table.Cell textAlign="right">Action</Table.Cell>
              </Table.Row>
              {scopedOffers.map((offer) => {
                const matched = offer.matched_count;
                const hasMatchTelemetry = typeof matched === 'number';
                const isReady =
                  !offer.completed &&
                  (offer.can_fulfill ||
                    (hasMatchTelemetry && matched >= offer.amount));
                const favorGain = offer.favor_gain ?? offer.price;

                return (
                  <Table.Row
                    key={`${offer.resolved_station_id}-${offer.id}`}
                    className="candystripe"
                  >
                    {isAllRelays && (
                      <Table.Cell>
                        <Box bold fontSize="11px">
                          {offer.resolved_station_label}
                        </Box>
                        <Box fontSize="10px" color="label">
                          Refresh:{' '}
                          {formatDuration(offer.resolved_restock_seconds)}
                        </Box>
                      </Table.Cell>
                    )}
                    <Table.Cell>
                      <Stack align="center" wrap>
                        <Stack.Item>
                          <Box as="span" bold>
                            {offer.name}
                          </Box>
                        </Stack.Item>
                        {isReady && (
                          <Stack.Item>
                            <Box as="span" color="good" bold fontSize="11px">
                              [Ready on Pad!]
                            </Box>
                          </Stack.Item>
                        )}
                      </Stack>
                      {offer.requirements && (
                        <Box fontSize="11px" color="average">
                          {offer.requirements}
                        </Box>
                      )}
                      <Stack wrap>
                        {(offer.reagent_volume ?? 0) > 0 && (
                          <Stack.Item>
                            <Box fontSize="11px" color="label">
                              • Reagent: {offer.amount} separate container(s)
                              with &ge;{offer.reagent_volume}u each (containers
                              returned)
                            </Box>
                          </Stack.Item>
                        )}
                        {(offer.stack_size ?? 0) > 1 && (
                          <Stack.Item>
                            <Box fontSize="11px" color="label">
                              • Stack: {offer.amount}x full stack (
                              {offer.stack_size}u per stack)
                            </Box>
                          </Stack.Item>
                        )}
                        {offer.live_required && (
                          <Stack.Item>
                            <Box fontSize="11px" color="average">
                              • Live specimen inside stasis cage required
                            </Box>
                          </Stack.Item>
                        )}
                      </Stack>
                    </Table.Cell>
                    <Table.Cell textAlign="right">
                      {hasMatchTelemetry ? (
                        <Box
                          bold
                          color={
                            matched >= offer.amount
                              ? 'good'
                              : matched > 0
                                ? 'average'
                                : 'label'
                          }
                        >
                          {matched} / {offer.amount}
                        </Box>
                      ) : (
                        <Box>{offer.amount}</Box>
                      )}
                    </Table.Cell>
                    <Table.Cell textAlign="right">
                      <Box color="good" bold>
                        {offer.price} {currency}
                      </Box>
                      <Box fontSize="10px" color="label">
                        +{favorGain} Favor
                        {isSlave && ' (-20% commission)'}
                      </Box>
                    </Table.Cell>
                    <Table.Cell textAlign="right">
                      {offer.completed ? (
                        <Box color="good" bold>
                          Completed
                        </Box>
                      ) : (
                        canExport && (
                          <Button
                            icon="check"
                            color={isReady ? 'good' : undefined}
                            content="Fulfill"
                            tooltip={`Fulfill bounty (triggers ${cooldownLabel} shared beacon cooldown — use Fulfill All for multiple bounties)`}
                            disabled={
                              !beacons?.export_ready || !beacons?.sender_ready
                            }
                            onClick={() =>
                              act('fulfill', {
                                station_id: offer.resolved_station_id,
                                offer_id: offer.id,
                              })
                            }
                          />
                        )
                      )}
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
