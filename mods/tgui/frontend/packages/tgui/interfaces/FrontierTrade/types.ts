type ByondFlag = boolean | 0 | 1;

export interface NtosState {
  station_time: string;
  show_battery: ByondFlag;
  battery_percent: string;
  ntnet_status: number;
  show_shutdown: ByondFlag;
  active_program?: string;
}

export interface AccountState {
  owner: string | null;
  balance: number;
  card_inserted: ByondFlag;
  card_owner: string | null;
  card_requires_pin: ByondFlag;
  card_linked: ByondFlag;
  card_access?: number[];
}

export interface BeaconOption {
  id: string;
  label: string;
  ready: ByondFlag;
}

export interface ExportPreviewState {
  eligible_items: number;
  estimated_payout: number;
  blocked_roots: number;
  payout_target: string;
}

export interface BeaconsState {
  sender_id: string;
  receiver_id: string;
  sender_label: string;
  receiver_label: string;
  sender_present: ByondFlag;
  sender_ready: ByondFlag;
  export_ready: ByondFlag;
  export_time_max: number;
  export_time_elapsed: number;
  export_seconds: number;
  sender_entropy: number;
  entropy_limit: number;
  receiver_ready: ByondFlag;
  receiver_present?: ByondFlag;
  receiver_free_tiles?: number;
  receiver_entropy?: number;
  receiver_locked_seconds?: number;
  estimated_delivery_seconds?: number;
  local_room_name?: string | null;
  export_preview?: ExportPreviewState;
  senders: BeaconOption[];
  receivers: BeaconOption[];
}

export interface TradeGoodContentsRow {
  name: string;
  count: number;
}

export type DeliveryMode =
  | 'personal'
  | 'crate'
  | 'secure_crate'
  | 'large_crate'
  | 'livestock'
  | 'floor';

export interface TradeGoodStatic {
  id: string;
  station_id: string;
  station_name?: string;
  name: string;
  desc?: string;
  category: string;
  stack_size: number;
  floor_delivery: ByondFlag;
  delivery_mode?: DeliveryMode;
  container_label?: string;
  is_bundle?: ByondFlag;
  randomized_count?: number;
  contents_preview?: TradeGoodContentsRow[];
  req_access?: number[];
  access_labels?: string[];
  security_level?: string | null;
  security_label?: string | null;
  hidden?: ByondFlag;
  // Optional fallback fields if merged or passed in test mocks
  stock?: number;
  cart_count?: number;
  price?: number;
  restricted?: ByondFlag;
}

export interface TradeGood extends Omit<TradeGoodStatic, 'station_id'> {
  station_id?: string;
  stock: number;
  cart_count: number;
  price: number;
  restricted: ByondFlag;
}

export interface ResolvedTradeGood {
  id: string;
  station_id: string;
  station_name: string;
  station_label: string;
  name: string;
  desc: string;
  category: string;
  stock: number;
  cart_count: number;
  price: number;
  stack_size: number;
  floor_delivery: boolean;
  delivery_mode: DeliveryMode;
  container_label: string;
  is_bundle: boolean;
  randomized_count: number;
  contents_preview: TradeGoodContentsRow[];
  req_access: number[];
  access_labels: string[];
  security_level: string | null;
  security_label: string | null;
  sec_locked: boolean;
  hidden: boolean;
  has_access_req: boolean;
  access_satisfied: boolean;
  restricted: boolean;
}

export interface TradeOffer {
  id: string;
  name: string;
  amount: number;
  price: number;
  unit_price?: number;
  station_id?: string;
  station_name?: string;
  favor_gain?: number;
  matched_count?: number;
  can_fulfill?: ByondFlag;
  reagent_volume?: number;
  stack_size?: number;
  live_required?: ByondFlag;
  completed: ByondFlag;
  requirements: string;
}

export interface TradeStation {
  id: string;
  name: string;
  label: string;
  desc: string;
  icon: string;
  color: string;
  x: number;
  y: number;
  discovered: ByondFlag;
  black_market: ByondFlag;
  favor: number;
  favor_needed: number;
  hidden_unlocked: ByondFlag;
  recommendation_unlocked: ByondFlag;
  recommendations_received: number;
  recommendations_needed: number;
  recommends: string[];
  restock_seconds: number;
  specialties?: string[];
  goods_count?: number;
  markup?: number;
  goods?: TradeGood[];
  offers: TradeOffer[];
}

export interface TreeLine {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
  unlocked: ByondFlag;
}

export interface CartItem {
  id: string;
  name: string;
  quantity: number;
  stock: number;
  station_id: string;
  station: string;
  category: string;
  unit_price: number;
  price: number;
  stack_size: number;
  floor_delivery: ByondFlag;
  restricted: ByondFlag;
}

export interface SavedCartItemPreview {
  id: string;
  name: string;
  quantity: number;
  stock: number;
  unit_price: number;
}

export interface SavedCart {
  id: string;
  name: string;
  item_count: number;
  total_units: number;
  estimated_cost?: number;
  items?: SavedCartItemPreview[];
}

export interface OrderRow {
  name: string;
  category: string;
  station: string;
  quantity: number;
  stack_size: number;
  unit_price: number;
  subtotal: number;
}

export interface TradeOrder {
  id: string;
  buyer: string;
  reason: string;
  state: string;
  total: number;
  fee: number;
  pending: ByondFlag;
  cancellable: ByondFlag;
  paid: ByondFlag;
  can_edit_reason: ByondFlag;
  delivery_status?: string;
  needed_tiles?: number;
  items: OrderRow[];
}

export interface TradeLogEntry {
  id: number;
  kind: string;
  title: string;
  amount: number;
  account: string;
  time: string;
  fee: number;
  contents: OrderRow[];
}

export interface FrontierTradeData {
  catalog_version?: number;
  read_only: ByondFlag;
  program_type: string;
  manager: ByondFlag;
  can_export: ByondFlag;
  hacked: ByondFlag;
  has_printer?: ByondFlag;
  currency: string;
  budget: number;
  handling_fee_rate?: number;
  entropy_limit?: number;
  export_time_max?: number;
  message: string;
  message_type: 'info' | 'good' | 'bad';
  order_limit: number;
  request_wait: number;
  pending_orders_count?: number;
  ntos: NtosState;
  account: AccountState;
  beacons: BeaconsState;
  categories?: string[];
  catalog?: TradeGoodStatic[];
  stocks?: Record<string, number>;
  prices?: Record<string, number>;
  sec_locked?: Record<string, ByondFlag>;
  stations: TradeStation[];
  tree_lines: TreeLine[];
  cart: CartItem[];
  cart_total: number;
  cart_fee: number;
  cart_count: number;
  cart_floor_needed?: number;
  cart_overstock_ids?: string[];
  saved: SavedCart[];
  orders: TradeOrder[];
  logs: TradeLogEntry[];
  logs_page?: number;
  logs_page_size?: number;
  logs_total?: number;
}

export type ModalKind =
  | null
  | { type: 'pin'; purpose: 'link' | 'purchase' }
  | { type: 'request_reason' }
  | { type: 'edit_reason'; orderId: string; initial: string }
  | { type: 'save_cart'; orderId?: string; initial: string };

export const formatDuration = (seconds: number): string => {
  const safe = Math.max(0, Math.ceil(seconds || 0));
  if (safe < 60) {
    return `${safe}s`;
  }
  const mins = Math.floor(safe / 60);
  const secs = safe % 60;
  return `${mins}m ${secs}s`;
};

const resolveDeliveryContainer = (
  mode: DeliveryMode,
  customLabel?: string
): string => {
  if (customLabel) {
    return customLabel;
  }
  const labels: Record<DeliveryMode, string> = {
    floor: 'Floor Delivery',
    livestock: 'Critter Carrier',
    large_crate: 'Large Crate',
    secure_crate: 'Secure Crate',
    crate: 'Steel Crate',
    personal: 'Personal Locker',
  };
  return labels[mode] || 'Personal Locker';
};

const collectRawCatalogGoods = (
  data: FrontierTradeData,
  stationById: Record<string, TradeStation>
): Array<TradeGoodStatic & { _station?: TradeStation }> => {
  const stations = data.stations || [];
  const hacked = Boolean(data.hacked);
  const hasStaticCatalog =
    Array.isArray(data.catalog) &&
    (data.catalog.length > 0 ||
      !stations.some((s) => Array.isArray(s.goods) && s.goods.length > 0));

  const rawGoods: Array<TradeGoodStatic & { _station?: TradeStation }> = [];
  if (hasStaticCatalog && data.catalog) {
    for (let i = 0; i < data.catalog.length; i++) {
      const g = data.catalog[i];
      const st = stationById[g.station_id];
      if (!st || (st.discovered && (!st.black_market || hacked))) {
        rawGoods.push({ ...g, _station: st });
      }
    }
    return rawGoods;
  }

  for (let i = 0; i < stations.length; i++) {
    const st = stations[i];
    if (!st.discovered || (st.black_market && !hacked)) {
      continue;
    }
    const stGoods = st.goods || [];
    for (let j = 0; j < stGoods.length; j++) {
      const g = stGoods[j];
      rawGoods.push({
        ...g,
        station_id: g.station_id || st.id,
        station_name: g.station_name || st.name,
        _station: st,
      });
    }
  }
  return rawGoods;
};

const computeAccessSatisfied = (
  g: TradeGoodStatic,
  hacked: boolean,
  cardInserted: boolean,
  cardAccess: number[]
): boolean => {
  if (hacked) {
    return true;
  }
  const reqAccess = g.req_access || [];
  if (reqAccess.length > 0) {
    return (
      cardInserted &&
      cardAccess.length > 0 &&
      reqAccess.every((req) => cardAccess.includes(req))
    );
  }
  if (g.restricted !== undefined) {
    return !g.restricted;
  }
  return !(g.access_labels && g.access_labels.length > 0);
};

const normalizeCatalogGood = (
  g: TradeGoodStatic & { _station?: TradeStation },
  data: FrontierTradeData,
  stationById: Record<string, TradeStation>,
  cartQtyById: Record<string, number>
): ResolvedTradeGood => {
  const st = g._station || stationById[g.station_id];
  const stocks = data.stocks || {};
  const prices = data.prices || {};
  const secLocked = data.sec_locked || {};
  const hacked = Boolean(data.hacked);
  const cardInserted = Boolean(data.account?.card_inserted);
  const cardAccess = data.account?.card_access || [];

  const stock = g.id in stocks ? stocks[g.id] : g.stock ?? 0;
  const price = g.id in prices ? prices[g.id] : g.price ?? 0;
  const cartCount = g.id in cartQtyById ? cartQtyById[g.id] : g.cart_count ?? 0;
  const reqAccess = g.req_access || [];
  const accessLabels = g.access_labels || [];
  const isSecLocked = Boolean(secLocked[g.id]) && !hacked;
  const hasAccessReq = Boolean(
    reqAccess.length > 0 || accessLabels.length > 0 || g.restricted
  );
  const accessSatisfied = computeAccessSatisfied(
    g,
    hacked,
    cardInserted,
    cardAccess
  );
  const contentsPreview = g.contents_preview || [];
  const deliveryMode: DeliveryMode =
    g.delivery_mode || (g.floor_delivery ? 'floor' : 'personal');

  return {
    id: g.id,
    station_id: g.station_id || st?.id || '',
    station_name: g.station_name || st?.name || '',
    station_label: st?.label || g.station_name || g.station_id || '',
    name: g.name,
    desc: g.desc || '',
    category: g.category,
    stock,
    cart_count: cartCount,
    price,
    stack_size: g.stack_size || 0,
    floor_delivery: Boolean(g.floor_delivery),
    delivery_mode: deliveryMode,
    container_label: resolveDeliveryContainer(deliveryMode, g.container_label),
    is_bundle: Boolean(g.is_bundle || contentsPreview.length > 1),
    randomized_count: g.randomized_count || 0,
    contents_preview: contentsPreview,
    req_access: reqAccess,
    access_labels: accessLabels,
    security_level: g.security_level || null,
    security_label: g.security_label || null,
    sec_locked: isSecLocked,
    hidden: Boolean(g.hidden),
    has_access_req: hasAccessReq,
    access_satisfied: accessSatisfied,
    restricted: isSecLocked || (hasAccessReq && !accessSatisfied),
  };
};

export const resolveCatalogGoods = (
  data: FrontierTradeData
): ResolvedTradeGood[] => {
  const stations = data.stations || [];
  const stationById: Record<string, TradeStation> = {};
  for (let i = 0; i < stations.length; i++) {
    const st = stations[i];
    stationById[st.id] = st;
  }

  const cart = data.cart || [];
  const cartQtyById: Record<string, number> = {};
  for (let i = 0; i < cart.length; i++) {
    const item = cart[i];
    cartQtyById[item.id] = item.quantity;
  }

  const rawGoods = collectRawCatalogGoods(data, stationById);
  return rawGoods.map((g) =>
    normalizeCatalogGood(g, data, stationById, cartQtyById)
  );
};

export const matchesCatalogSearch = (
  good: ResolvedTradeGood,
  needle: string
): boolean => {
  if (!needle) {
    return true;
  }
  if (
    good.name.toLowerCase().includes(needle) ||
    good.category.toLowerCase().includes(needle) ||
    good.station_name.toLowerCase().includes(needle) ||
    good.station_label.toLowerCase().includes(needle) ||
    (good.desc && good.desc.toLowerCase().includes(needle)) ||
    (good.container_label &&
      good.container_label.toLowerCase().includes(needle))
  ) {
    return true;
  }
  for (let i = 0; i < good.contents_preview.length; i++) {
    if (good.contents_preview[i].name.toLowerCase().includes(needle)) {
      return true;
    }
  }
  return false;
};
