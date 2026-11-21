import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Icon,
  Input,
  Modal,
  NoticeBox,
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

const TradeNtosBar = (props: {
  data: FrontierTradeData;
  act: (action: string, payload?: object) => void;
  onLinkClick: () => void;
}) => {
  const { data, act, onLinkClick } = props;
  const {
    ntos,
    read_only: readOnly,
    program_type: programType,
    hacked,
    beacons,
    account,
    currency,
    budget,
    manager,
  } = data;
  const isSlave = programType === 'slave';

  return (
    <Stack align="center" wrap>
      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <Icon name="clock" mr={0.5} />
            {ntos?.station_time}
          </Stack.Item>
          {Boolean(ntos?.show_battery) && (
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
          {readOnly || isSlave || hacked ? (
            <Stack.Item color={hacked ? 'average' : 'label'}>
              {readOnly ? 'Read only' : null}
              {isSlave && (beacons?.local_room_name || 'Local terminal')}
              {hacked ? ' · Black market' : null}
            </Stack.Item>
          ) : null}
        </Stack>
      </Stack.Item>
      <Stack.Item grow />
      {!readOnly && (
        <Stack.Item>
          <Stack align="center" wrap>
            {(Boolean(manager) || programType === 'master') && (
              <Stack.Item color="label">
                Supply budget: {budget} {currency}
              </Stack.Item>
            )}
            <Stack.Item>
              {account?.owner ? (
                <>
                  <Box as="span" mr={0.5}>
                    {account.owner}: {account.balance} {currency}
                  </Box>
                  <Button
                    compact
                    icon="unlink"
                    tooltip="Unlink account"
                    onClick={() => act('unlink_account')}
                  />
                </>
              ) : (
                <Button
                  icon="id-card"
                  disabled={!account?.card_inserted}
                  content={
                    account?.card_inserted ? 'Link ID' : 'Insert ID card'
                  }
                  tooltip={
                    isSlave
                      ? 'Link an ID to claim local bounties'
                      : 'Link an ID to make personal purchases'
                  }
                  onClick={onLinkClick}
                />
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      )}
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Button
              compact
              icon="window-minimize"
              aria-label="Minimize"
              tooltip="Minimize"
              onClick={() => act('pc_minimize')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              icon="times"
              aria-label="Exit program"
              tooltip="Exit program"
              onClick={() => act('pc_exit')}
            />
          </Stack.Item>
          {Boolean(ntos?.show_shutdown) && (
            <Stack.Item>
              <Button
                compact
                icon="power-off"
                aria-label="Shut down computer"
                tooltip="Shut down computer"
                onClick={() => act('pc_shutdown')}
              />
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const FrontierTrade = (_props, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const {
    read_only: readOnly,
    program_type: programType,
    can_export: canExport,
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
              <TradeNtosBar
                data={data}
                act={act}
                onLinkClick={handleLinkClick}
              />
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
                icon="shopping-cart"
                selected={activeTab === 'catalog'}
                onClick={() => setTab('catalog')}
              >
                Catalog
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
                </>
              )}
              <Tabs.Tab
                icon="tags"
                selected={activeTab === 'bounties'}
                onClick={() => setTab('bounties')}
              >
                {!readOnly &&
                (canExport ||
                  programType === 'master' ||
                  programType === 'slave')
                  ? 'Bounties & Export'
                  : 'Bounties'}
              </Tabs.Tab>
              <Tabs.Tab
                icon="project-diagram"
                selected={activeTab === 'network'}
                onClick={() => setTab('network')}
              >
                Relay Network
              </Tabs.Tab>
              {!readOnly && (
                <>
                  <Tabs.Tab
                    icon="save"
                    selected={activeTab === 'saved'}
                    onClick={() => setTab('saved')}
                  >
                    Saved carts
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="history"
                    selected={activeTab === 'logs'}
                    onClick={() => {
                      setTab('logs');
                      act('set_tab', { tab: 'logs' });
                    }}
                  >
                    Trade log
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
