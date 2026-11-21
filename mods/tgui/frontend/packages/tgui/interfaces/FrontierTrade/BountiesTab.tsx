import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
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
  resolved_station_label: string;
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

  const allOffers: ResolvedOffer[] = [];
  for (let i = 0; i < discovered.length; i++) {
    const st = discovered[i];
    const offers = st.offers || [];
    for (let j = 0; j < offers.length; j++) {
      const offer = offers[j];
      allOffers.push({
        ...offer,
        resolved_station_id: offer.station_id || st.id,
        resolved_station_label: st.label || offer.station_name || st.name,
      });
    }
  }

  const scopedOffers = isAllRelays
    ? [...allOffers].sort((a, b) => {
        if (Boolean(a.completed) !== Boolean(b.completed)) {
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
  const showSender = Boolean(canExport) || isSlave || programType === 'master';

  const canSend = !!(beacons?.sender_ready && beacons.export_ready);
  const senderStatus = !beacons?.sender_present
    ? isSlave
      ? 'No sending beacon in this room'
      : 'Sending beacon unavailable'
    : !beacons.sender_ready
      ? 'Sending beacon offline or unstable'
      : !beacons.export_ready
        ? 'Recharging (' + formatDuration(beacons.export_seconds) + ')'
        : 'Ready';
  const canMatchBounties = allOffers.some(
    (offer) => typeof offer.matched_count === 'number'
  );

  return (
    <Stack vertical fill>
      {!readOnly && showSender && beacons && (
        <Stack.Item>
          <Section title="Export">
            <Stack align="center" wrap>
              <Stack.Item color="label">Sending beacon</Stack.Item>
              <Stack.Item>
                <Dropdown
                  width="21em"
                  options={(beacons.senders || []).map((beacon) => ({
                    value: beacon.id,
                    displayText:
                      beacon.label + (beacon.ready ? '' : ' (Offline)'),
                  }))}
                  selected={beacons.sender_id}
                  displayText={beacons.sender_label || 'Automatic'}
                  onSelected={(id) => act('select_sender', { id })}
                />
              </Stack.Item>
              <Stack.Item grow color={canSend ? 'label' : 'average'}>
                {senderStatus}
                {Boolean(beacons.sender_present) && (
                  <Box as="span" ml={1} color="label">
                    Entropy {beacons.sender_entropy}/{beacons.entropy_limit}
                  </Box>
                )}
              </Stack.Item>
              {Boolean(canExport) && (
                <>
                  <Stack.Item>
                    <Button
                      icon="upload"
                      content={isSlave ? 'Export to Cargo' : 'Export goods'}
                      tooltip={
                        'Export all eligible goods. Shared cooldown: ' +
                        cooldownLabel
                      }
                      disabled={!canSend}
                      onClick={() => act('export')}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="check-double"
                      content={
                        readyBountiesCount
                          ? 'Fulfill all (' + readyBountiesCount + ')'
                          : 'Fulfill all'
                      }
                      tooltip={
                        'Claim all ready bounties. Shared cooldown: ' +
                        cooldownLabel
                      }
                      disabled={
                        !canSend ||
                        (canMatchBounties && readyBountiesCount === 0)
                      }
                      onClick={() => act('fulfill_all')}
                    />
                  </Stack.Item>
                </>
              )}
            </Stack>
            {exportPreview && (
              <Box mt={0.75} color="label">
                {exportPreview.eligible_items} exportable · Est.{' '}
                {exportPreview.estimated_payout} {currency} to{' '}
                {exportPreview.payout_target}
                {exportPreview.blocked_roots > 0 && (
                  <Box as="span" ml={1} color="average">
                    {exportPreview.blocked_roots} containers skipped because
                    they hold protected items.
                  </Box>
                )}
              </Box>
            )}
            {isSlave && (
              <Box mt={0.5} color={canExport ? 'label' : 'average'}>
                {!canExport &&
                  'Insert and link an ID to claim local bounties. '}
                Local bounties pay 80% to your account and 20% to Cargo.
              </Box>
            )}
          </Section>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Bounties (' + scopedOffers.length + ')'}
          buttons={
            <Dropdown
              width="14em"
              options={[
                { value: 'all', displayText: 'All relays' },
                ...discovered.map((station) => ({
                  value: station.id,
                  displayText: station.label,
                })),
              ]}
              selected={activeStation?.id || 'all'}
              displayText={activeStation?.label || 'All relays'}
              onSelected={onSelectStation}
            />
          }
        >
          <Box color="label" mb={0.75}>
            {readOnly
              ? 'Use a trade terminal with a sending beacon to claim bounties.'
              : 'Place the requested goods next to the sending beacon.'}
            {activeStation &&
              ' Refresh in ' +
                formatDuration(activeStation.restock_seconds) +
                '.'}
          </Box>
          {scopedOffers.length === 0 ? (
            <NoticeBox>
              {discovered.length
                ? 'No bounties from this relay.'
                : 'No frontier relays discovered yet.'}
            </NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                {isAllRelays && <Table.Cell>Relay</Table.Cell>}
                <Table.Cell>Bounty</Table.Cell>
                <Table.Cell textAlign="right">On pad / Needed</Table.Cell>
                <Table.Cell textAlign="right">Reward</Table.Cell>
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
                        <Box color="label">{offer.resolved_station_label}</Box>
                      </Table.Cell>
                    )}
                    <Table.Cell>
                      <Box bold>{offer.name}</Box>
                      {offer.requirements && (
                        <Box fontSize="11px" color="label">
                          {offer.requirements}
                        </Box>
                      )}
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
                      </Box>
                    </Table.Cell>
                    <Table.Cell textAlign="right">
                      {offer.completed ? (
                        <Box color="good" bold>
                          Completed
                        </Box>
                      ) : (
                        Boolean(canExport) && (
                          <Button
                            icon="check"
                            color={isReady ? 'good' : undefined}
                            content="Fulfill"
                            tooltip={`Fulfill bounty (triggers ${cooldownLabel} shared beacon cooldown — use Fulfill All for multiple bounties)`}
                            disabled={
                              !canSend || (hasMatchTelemetry && !isReady)
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
