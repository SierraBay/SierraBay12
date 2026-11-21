import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  Modal,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../../components';
import { Window } from '../../layouts';
import { BountiesTab } from './BountiesTab';
import { CartTab } from './CartTab';
import { CatalogTab } from './CatalogTab';
import { LogsTab } from './LogsTab';
import { NetworkMapTab } from './NetworkMapTab';
import { OrdersTab } from './OrdersTab';
import { SavedTab } from './SavedTab';
import { FrontierTradeData, ModalKind } from './types';

type TabId =
  | 'network'
  | 'catalog'
  | 'bounties'
  | 'cart'
  | 'orders'
  | 'saved'
  | 'logs';

const formatSenderBarText = (
  beacons: FrontierTradeData['beacons'],
  isSlave: boolean
): string => {
  if (!beacons.sender_present) {
    return isSlave ? 'No Local Sending Beacon in Room' : 'No Sender Beacon';
  }
  if (!beacons.sender_ready) {
    return 'Sender Offline / Unstable';
  }
  if (!beacons.export_ready) {
    return `Recharging: ${beacons.export_seconds}s`;
  }
  return `Export Ready (Entropy ${beacons.sender_entropy}/${beacons.entropy_limit})`;
};

const TradeNtosBar = (props: {
  data: FrontierTradeData;
  act: (action: string, payload?: object) => void;
}) => {
  const { data, act } = props;
  const {
    ntos,
    read_only: readOnly,
    program_type: programType,
    hacked,
    beacons,
  } = data;
  const isSlave = programType === 'slave';

  return (
    <Stack align="center" justify="space-between" mb={0.5}>
      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <Icon name="clock" mr={0.5} />
            {ntos?.station_time}
          </Stack.Item>
          {ntos?.show_battery && (
            <Stack.Item>
              <Icon name="battery-half" mr={0.5} />
              {ntos.battery_percent}
            </Stack.Item>
          )}
          <Stack.Item>
            <Icon
              name="wifi"
              mr={0.5}
              color={ntos?.ntnet_status > 0 ? 'good' : 'bad'}
            />
            NTNet
          </Stack.Item>
          <Stack.Item>
            <Box as="span" color="label">
              Mode:{' '}
            </Box>
            <Box as="span" bold>
              {readOnly ? 'catalog' : programType}
            </Box>
            {isSlave && beacons?.local_room_name && (
              <Box as="span" ml={0.5} color="label">
                ({beacons.local_room_name})
              </Box>
            )}
            {hacked && (
              <Box as="span" ml={0.5} color="bad" bold>
                [BLACK MARKET]
              </Box>
            )}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Button
              compact
              icon="window-minimize"
              content="Minimize"
              onClick={() => act('pc_minimize')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              icon="times"
              content="Exit"
              onClick={() => act('pc_exit')}
            />
          </Stack.Item>
          {ntos?.show_shutdown && (
            <Stack.Item>
              <Button
                compact
                color="bad"
                icon="power-off"
                content="Shutdown"
                onClick={() => act('pc_shutdown')}
              />
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const TradeToolbar = (props: {
  data: FrontierTradeData;
  act: (action: string, payload?: object) => void;
  onLinkClick: () => void;
}) => {
  const { data, act, onLinkClick } = props;
  const {
    program_type: programType,
    manager,
    can_export: canExport,
    currency,
    budget,
    account,
    beacons,
  } = data;

  const isSlave = programType === 'slave';
  const isOrderingOnly = programType === 'ordering' && !manager && !canExport;
  const showSupplyBudget = Boolean(manager || programType === 'master');
  const showSenderToolbar = Boolean(
    canExport || programType === 'master' || isSlave
  );
  const noLocalBeacon = Boolean(
    isSlave &&
      beacons &&
      !beacons.sender_present &&
      beacons.receiver_present === false
  );

  const senderOptions = (beacons?.senders || []).map((b) => ({
    displayText: b.ready ? b.label : `${b.label} (Offline)`,
    value: b.id,
  }));
  const receiverOptions = (beacons?.receivers || []).map((b) => ({
    displayText: b.ready ? b.label : `${b.label} (Offline)`,
    value: b.id,
  }));
  const exportPreview = beacons?.export_preview;

  return (
    <Stack align="center" wrap>
      <Stack.Item>
        {account?.owner ? (
          <Stack align="center">
            <Stack.Item>
              <Button
                compact
                color="good"
                icon="user"
                content={`${account.owner}: ${account.balance} ${currency}`}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                color="bad"
                icon="unlink"
                tooltip="Unlink account"
                onClick={() => act('unlink_account')}
              />
            </Stack.Item>
          </Stack>
        ) : (
          <Button
            compact
            icon="id-card"
            disabled={!account?.card_inserted}
            tooltip={
              isSlave
                ? 'Insert and link an ID card to claim local bounties (80% to linked account, 20% Cargo commission).'
                : 'Insert ID into this terminal/PDA for personal purchases. You can still Request Department Funding without inserting a card.'
            }
            content={
              account?.card_inserted
                ? `Link ${account.card_owner || 'ID'}`
                : 'Insert ID Card'
            }
            onClick={onLinkClick}
          />
        )}
      </Stack.Item>
      {showSupplyBudget && (
        <Stack.Item>
          <Box px={0.5}>
            <Box as="span" color="label">
              Supply:{' '}
            </Box>
            <Box as="span" bold color="good">
              {budget} {currency}
            </Box>
          </Box>
        </Stack.Item>
      )}
      {showSenderToolbar && (
        <Stack.Item>
          <Dropdown
            width="180px"
            menuWidth="240px"
            options={senderOptions}
            selected={beacons?.sender_id}
            displayText={`Sender: ${
              noLocalBeacon
                ? 'No local beacon'
                : beacons?.sender_label || 'Automatic'
            }`}
            onSelected={(id) => act('select_sender', { id })}
          />
        </Stack.Item>
      )}
      <Stack.Item>
        <Dropdown
          width="180px"
          menuWidth="240px"
          options={receiverOptions}
          selected={beacons?.receiver_id}
          displayText={`Receiver: ${
            noLocalBeacon
              ? 'No local beacon'
              : beacons?.receiver_label || 'Automatic'
          }`}
          onSelected={(id) => act('select_receiver', { id })}
        />
      </Stack.Item>
      {isOrderingOnly && beacons && (
        <Stack.Item>
          <Box
            px={0.5}
            fontSize="11px"
            color={beacons.receiver_ready ? 'good' : 'average'}
          >
            {beacons.receiver_ready
              ? `Pad Ready${
                  beacons.receiver_free_tiles !== undefined
                    ? ` (${beacons.receiver_free_tiles} tiles free)`
                    : ''
                }`
              : beacons.receiver_locked_seconds
                ? `Pad Unstable (${beacons.receiver_locked_seconds}s)`
                : 'Pad Offline'}
          </Box>
        </Stack.Item>
      )}
      {noLocalBeacon && (
        <Stack.Item>
          <Box px={0.5} fontSize="11px" color="bad" bold>
            No local trade beacon detected in this room
          </Box>
        </Stack.Item>
      )}
      {showSenderToolbar && beacons && (
        <Stack.Item grow>
          <ProgressBar
            value={beacons.export_ready ? 1 : beacons.export_time_elapsed}
            minValue={0}
            maxValue={beacons.export_ready ? 1 : beacons.export_time_max || 1}
            color={
              beacons.export_ready
                ? 'good'
                : beacons.sender_ready
                  ? 'average'
                  : 'bad'
            }
          >
            {formatSenderBarText(beacons, isSlave)}
          </ProgressBar>
        </Stack.Item>
      )}
      {canExport ? (
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                compact
                icon="upload"
                content={
                  isSlave
                    ? 'Export → Cargo'
                    : exportPreview && exportPreview.eligible_items > 0
                      ? `Export (${exportPreview.estimated_payout} ${currency})`
                      : 'Export'
                }
                disabled={!beacons?.export_ready || !beacons?.sender_ready}
                onClick={() => act('export')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                icon="check-double"
                content={isSlave ? 'Fulfill All (-20% fee)' : 'Fulfill All'}
                disabled={!beacons?.export_ready || !beacons?.sender_ready}
                onClick={() => act('fulfill_all')}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ) : (
        isSlave && (
          <Stack.Item>
            <Button
              compact
              disabled
              icon="id-card"
              content="Link ID for Local Bounties (-20% fee)"
              tooltip="Link an inserted ID card to claim local bounties from this room's sending beacon (80% to linked account, 20% Cargo commission)."
            />
          </Stack.Item>
        )
      )}
    </Stack>
  );
};

export const FrontierTrade = (_props, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const {
    read_only: readOnly,
    message,
    message_type: messageType,
    account,
    cart_count: cartCount,
    orders = [],
    pending_orders_count: pendingOrdersCountProp,
  } = data;

  const [tab, setTab] = useLocalState<TabId>(context, 'tradeTab', 'catalog');
  const [selectedStationId, setSelectedStationId] = useLocalState(
    context,
    'selectedStationId',
    'all'
  );
  const [modal, setModal] = useLocalState<ModalKind>(
    context,
    'tradeModal',
    null
  );
  const [modalText, setModalText] = useLocalState(
    context,
    'tradeModalText',
    ''
  );

  const openModal = (nextModal: ModalKind, initialText = '') => {
    setModalText(initialText);
    setModal(nextModal);
  };

  const closeModal = () => {
    setModal(null);
    setModalText('');
  };

  const submitModal = (valueOverride?: string) => {
    if (!modal) {
      return;
    }
    const rawText =
      typeof valueOverride === 'string' && valueOverride.length > 0
        ? valueOverride
        : modalText;
    const trimmed = rawText.trim();
    if (!trimmed) {
      return;
    }
    const currentModal = modal;
    closeModal();

    if (currentModal.type === 'pin') {
      act(currentModal.purpose === 'link' ? 'link_account' : 'purchase', {
        pin: trimmed,
      });
      return;
    }
    if (currentModal.type === 'request_reason') {
      act('request', { reason: trimmed });
      setTab('orders');
      return;
    }
    if (currentModal.type === 'edit_reason') {
      act('edit_reason', { id: currentModal.orderId, reason: trimmed });
      return;
    }
    if (currentModal.type === 'save_cart') {
      if (currentModal.orderId) {
        act('save_order', { id: currentModal.orderId, name: trimmed });
      } else {
        act('save_cart', { name: trimmed });
      }
    }
  };

  const handleLinkClick = () => {
    if (!account?.card_inserted) {
      return;
    }
    if (account.card_requires_pin) {
      openModal({ type: 'pin', purpose: 'link' }, '');
    } else {
      act('link_account');
    }
  };

  const handlePurchaseClick = () => {
    if (account?.card_linked || !account?.card_requires_pin) {
      act('purchase');
    } else {
      openModal({ type: 'pin', purpose: 'purchase' }, '');
    }
  };

  const activeTab: TabId =
    readOnly && !['network', 'catalog', 'bounties'].includes(tab)
      ? 'catalog'
      : tab;

  const pendingCount =
    pendingOrdersCountProp !== undefined
      ? pendingOrdersCountProp
      : orders.filter((o) => o.pending || o.state === 'Requested').length;

  return (
    <Window theme="ntos" width={980} height={700} resizable>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fitted p={1}>
              <TradeNtosBar data={data} act={act} />
              {!readOnly && (
                <TradeToolbar
                  data={data}
                  act={act}
                  onLinkClick={handleLinkClick}
                />
              )}
            </Section>
          </Stack.Item>
          {message && (
            <Stack.Item>
              <NoticeBox
                info={messageType === 'info'}
                success={messageType === 'good'}
                danger={messageType === 'bad'}
              >
                <Stack align="center" justify="space-between">
                  <Stack.Item>{message}</Stack.Item>
                  <Stack.Item>
                    <Button
                      compact
                      color="transparent"
                      icon="times"
                      onClick={() => act('clear_message')}
                    />
                  </Stack.Item>
                </Stack>
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                icon="project-diagram"
                selected={activeTab === 'network'}
                onClick={() => setTab('network')}
              >
                Relay Network
              </Tabs.Tab>
              <Tabs.Tab
                icon="shopping-cart"
                selected={activeTab === 'catalog'}
                onClick={() => setTab('catalog')}
              >
                Catalog
              </Tabs.Tab>
              <Tabs.Tab
                icon="tags"
                selected={activeTab === 'bounties'}
                onClick={() => setTab('bounties')}
              >
                Bounties
              </Tabs.Tab>
              {!readOnly && (
                <>
                  <Tabs.Tab
                    icon="shopping-basket"
                    selected={activeTab === 'cart'}
                    onClick={() => setTab('cart')}
                  >
                    Cart{cartCount > 0 ? ` (${cartCount})` : ''}
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="clipboard-list"
                    selected={activeTab === 'orders'}
                    onClick={() => setTab('orders')}
                  >
                    {pendingCount > 0 ? (
                      <Box as="span" color="average" bold>
                        Orders ({pendingCount} pending)
                      </Box>
                    ) : (
                      `Orders${orders.length > 0 ? ` (${orders.length})` : ''}`
                    )}
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="save"
                    selected={activeTab === 'saved'}
                    onClick={() => setTab('saved')}
                  >
                    Saved
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="history"
                    selected={activeTab === 'logs'}
                    onClick={() => {
                      setTab('logs');
                      act('set_tab', { tab: 'logs' });
                    }}
                  >
                    Logs
                  </Tabs.Tab>
                </>
              )}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {activeTab === 'network' && (
              <NetworkMapTab
                selectedStationId={selectedStationId}
                onSelectStation={setSelectedStationId}
                onOpenTab={(nextTab) => setTab(nextTab)}
              />
            )}
            {activeTab === 'catalog' && (
              <CatalogTab
                selectedStationId={selectedStationId}
                onSelectStation={setSelectedStationId}
                onOpenCart={() => setTab('cart')}
              />
            )}
            {activeTab === 'bounties' && (
              <BountiesTab
                selectedStationId={selectedStationId}
                onSelectStation={setSelectedStationId}
              />
            )}
            {!readOnly && activeTab === 'cart' && (
              <CartTab
                onPurchaseClick={handlePurchaseClick}
                onRequestClick={() => openModal({ type: 'request_reason' }, '')}
                onSaveClick={() =>
                  openModal(
                    { type: 'save_cart', initial: 'Supplies' },
                    'Supplies'
                  )
                }
              />
            )}
            {!readOnly && activeTab === 'orders' && (
              <OrdersTab
                onEditReason={(orderId, currentReason) =>
                  openModal(
                    { type: 'edit_reason', orderId, initial: currentReason },
                    currentReason
                  )
                }
                onSaveAsCart={(orderId) =>
                  openModal(
                    { type: 'save_cart', orderId, initial: orderId },
                    orderId
                  )
                }
              />
            )}
            {!readOnly && activeTab === 'saved' && (
              <SavedTab onLoaded={() => setTab('cart')} />
            )}
            {!readOnly && activeTab === 'logs' && <LogsTab />}
          </Stack.Item>
        </Stack>
        {modal && (
          <Modal>
            <Box
              width="360px"
              p={1}
              onKeyDown={(e: any) => {
                if (e.keyCode === 27 || e.key === 'Escape') {
                  closeModal();
                }
              }}
            >
              <Box fontSize="14px" bold mb={1}>
                {modal.type === 'pin' && 'Enter Account PIN'}
                {modal.type === 'request_reason' &&
                  'Department Requisition Reason'}
                {modal.type === 'edit_reason' && 'Edit Requisition Reason'}
                {modal.type === 'save_cart' && 'Save Cart Name'}
              </Box>
              <Input
                autoFocus
                fluid
                value={modalText}
                placeholder={
                  modal.type === 'pin' ? 'Numeric PIN...' : 'Enter text...'
                }
                onInput={(_, value) => setModalText(value)}
                onEnter={(_, value) => submitModal(value)}
                onEscape={() => closeModal()}
              />
              <Stack mt={1} justify="flex-end">
                <Stack.Item>
                  <Button
                    color="good"
                    icon="check"
                    content="Confirm"
                    onClick={() => submitModal()}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    color="bad"
                    icon="times"
                    content="Cancel"
                    onClick={closeModal}
                  />
                </Stack.Item>
              </Stack>
            </Box>
          </Modal>
        )}
      </Window.Content>
    </Window>
  );
};
