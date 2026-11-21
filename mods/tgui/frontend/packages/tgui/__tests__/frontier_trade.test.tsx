import { render } from 'inferno';
import '../backend';
import { FrontierTrade } from '../interfaces/FrontierTrade';
import { FrontierTradeData } from '../interfaces/FrontierTrade/types';

let mockData: FrontierTradeData;
let mockState: Record<string, any>;
const mockAct = jest.fn();

jest.mock('../backend', () => {
  (globalThis as any).Byond = { IS_LTE_IE10: false, IS_LTE_IE8: false };
  return {
    useBackend: () => ({ data: mockData, act: mockAct }),
    useLocalState: (_context, key, initial) => [
      key in mockState ? mockState[key] : initial,
      (value) => {
        mockState[key] =
          typeof value === 'function'
            ? value(mockState[key] ?? initial)
            : value;
      },
    ],
  };
});

jest.mock('../layouts', () => {
  const { createVNode } = require('inferno');
  const Window = (props) => createVNode(1, 'div', null, props.children, 0);
  Window.Content = (props) =>
    createVNode(1, 'div', null, props.children, 0, {
      onKeyDown: props.onKeyDown,
    });
  return { Window };
});

const buildSampleData = (
  overrides: Partial<FrontierTradeData> = {}
): FrontierTradeData => ({
  catalog_version: 1,
  read_only: false,
  program_type: 'master',
  manager: true,
  can_export: true,
  hacked: false,
  has_printer: true,
  currency: 'Thalers',
  budget: 5000,
  handling_fee_rate: 0.2,
  entropy_limit: 30,
  export_time_max: 1200,
  message: '',
  message_type: 'info',
  order_limit: 100,
  request_wait: 0,
  pending_orders_count: 0,
  ntos: {
    station_time: '12:00',
    show_battery: false,
    battery_percent: 'N/C',
    ntnet_status: 3,
    show_shutdown: true,
    active_program: 'trade',
  },
  account: {
    owner: null,
    balance: 0,
    card_inserted: true,
    card_owner: 'John Doe',
    card_requires_pin: true,
    card_linked: false,
    card_access: [],
  },
  beacons: {
    sender_id: '',
    receiver_id: '',
    sender_label: 'Automatic',
    receiver_label: 'Automatic',
    sender_present: true,
    sender_ready: true,
    export_ready: true,
    export_time_max: 1200,
    export_time_elapsed: 1200,
    export_seconds: 0,
    sender_entropy: 0,
    entropy_limit: 30,
    receiver_ready: true,
    receiver_present: true,
    receiver_free_tiles: 19,
    receiver_entropy: 2,
    receiver_locked_seconds: 0,
    estimated_delivery_seconds: 2,
    local_room_name: null,
    export_preview: {
      eligible_items: 3,
      estimated_payout: 450,
      blocked_roots: 0,
      payout_target: 'Supply Budget',
    },
    senders: [
      { id: '', label: 'Automatic', ready: true },
      { id: 'ref_send_1', label: 'Cargo Hangar (104, 89, 1)', ready: true },
    ],
    receivers: [{ id: '', label: 'Automatic', ready: true }],
  },
  catalog: [
    {
      id: 'engineering-1',
      station_id: 'engineering',
      station_name: 'Hephaestus / Grayson Frontier Relay',
      name: 'Steel sheets',
      desc: 'Standard plasteel-grade carbon steel sheets.',
      category: 'Materials',
      stack_size: 50,
      floor_delivery: false,
      delivery_mode: 'personal',
      container_label: 'Personal Locker',
      is_bundle: false,
      randomized_count: 0,
      contents_preview: [{ name: 'Steel sheet (50)', count: 1 }],
      req_access: [],
      access_labels: [],
      security_level: null,
      security_label: null,
      hidden: false,
    },
    {
      id: 'engineering-2',
      station_id: 'engineering',
      station_name: 'Hephaestus / Grayson Frontier Relay',
      name: 'Armor vest',
      desc: 'Type-II ballistic armor vest.',
      category: 'Security',
      stack_size: 0,
      floor_delivery: false,
      delivery_mode: 'secure_crate',
      container_label: 'Secure Crate',
      is_bundle: false,
      randomized_count: 0,
      contents_preview: [{ name: 'Armor vest', count: 1 }],
      req_access: [1],
      access_labels: ['Security'],
      security_level: null,
      security_label: null,
      hidden: false,
    },
    {
      id: 'security-1',
      station_id: 'security',
      station_name: 'Shellguard Defense Logistics',
      name: 'Riot Control Crate',
      desc: 'Non-lethal tactical crowd control pack.',
      category: 'Security',
      stack_size: 0,
      floor_delivery: true,
      delivery_mode: 'secure_crate',
      container_label: 'Secure Crate',
      is_bundle: true,
      randomized_count: 0,
      contents_preview: [
        { name: 'Flashbang', count: 4 },
        { name: 'Teargas Grenade', count: 2 },
      ],
      req_access: [1, 63],
      access_labels: ['Security', 'Armory'],
      security_level: 'elevated',
      security_label: 'Blue / Elevated Alert',
      hidden: false,
    },
    {
      id: 'medicine-1',
      station_id: 'medicine',
      station_name: 'Vey-Med Medical Supply',
      name: 'Surgical Starter Kit',
      desc: 'Complete sterile operating theatre instruments.',
      category: 'Medical',
      stack_size: 0,
      floor_delivery: false,
      delivery_mode: 'crate',
      container_label: 'Medical Crate',
      is_bundle: true,
      randomized_count: 0,
      contents_preview: [
        { name: 'Laser Scalpel', count: 1 },
        { name: 'Hemostat', count: 1 },
        { name: 'Circular Saw', count: 1 },
      ],
      req_access: [],
      access_labels: [],
      security_level: null,
      security_label: null,
      hidden: false,
    },
  ],
  stocks: {
    'engineering-1': 8,
    'engineering-2': 3,
    'security-1': 2,
    'medicine-1': 0,
  },
  prices: {
    'engineering-1': 300,
    'engineering-2': 660,
    'security-1': 1200,
    'medicine-1': 480,
  },
  sec_locked: {
    'security-1': true,
  },
  stations: [
    {
      id: 'engineering',
      name: 'Hephaestus / Grayson Frontier Relay',
      label: 'Hephaestus',
      desc: 'Industrial relay.',
      icon: 'wrench',
      color: '#ff9944',
      x: 25,
      y: 75,
      discovered: true,
      black_market: false,
      favor: 100,
      favor_needed: 1500,
      hidden_unlocked: false,
      recommendation_unlocked: false,
      recommendations_received: 0,
      recommendations_needed: 0,
      recommends: ['DAIS'],
      restock_seconds: 300,
      specialties: ['Materials', 'Engineering'],
      goods_count: 2,
      markup: 1.2,
      offers: [
        {
          id: 'engineering-offer-1',
          name: 'Diamond ore',
          amount: 3,
          price: 400,
          unit_price: 133,
          station_id: 'engineering',
          station_name: 'Hephaestus / Grayson Frontier Relay',
          favor_gain: 400,
          matched_count: 3,
          can_fulfill: true,
          reagent_volume: 0,
          stack_size: 20,
          live_required: false,
          completed: false,
          requirements: '3x full stack (20 units each)',
        },
      ],
    },
    {
      id: 'security',
      name: 'Shellguard Defense Logistics',
      label: 'Shellguard',
      desc: 'Tactical defense contractor relay.',
      icon: 'security',
      color: '#cc4444',
      x: 45,
      y: 75,
      discovered: true,
      black_market: false,
      favor: 0,
      favor_needed: 1500,
      hidden_unlocked: false,
      recommendation_unlocked: false,
      recommendations_received: 0,
      recommendations_needed: 0,
      recommends: [],
      restock_seconds: 240,
      specialties: ['Security', 'Ammunition'],
      goods_count: 1,
      markup: 1.25,
      offers: [
        {
          id: 'security-offer-1',
          name: 'Dylovene synthesis',
          amount: 2,
          price: 520,
          unit_price: 260,
          station_id: 'security',
          station_name: 'Shellguard Defense Logistics',
          favor_gain: 520,
          matched_count: 1,
          can_fulfill: false,
          reagent_volume: 60,
          stack_size: 0,
          live_required: false,
          completed: false,
          requirements: '2x container with >=60u Dylovene',
        },
      ],
    },
    {
      id: 'medicine',
      name: 'Vey-Med Medical Supply',
      label: 'Vey-Med',
      desc: 'Medical and biochemical logistics.',
      icon: 'heart',
      color: '#55bbff',
      x: 65,
      y: 75,
      discovered: true,
      black_market: false,
      favor: 3000,
      favor_needed: 3000,
      hidden_unlocked: true,
      recommendation_unlocked: true,
      recommendations_received: 0,
      recommendations_needed: 0,
      recommends: ['Morpheus'],
      restock_seconds: 180,
      specialties: ['Medical', 'Chemistry'],
      goods_count: 1,
      markup: 1.2,
      offers: [],
    },
  ],
  tree_lines: [],
  cart: [
    {
      id: 'engineering-1',
      name: 'Steel sheets',
      quantity: 1,
      stock: 8,
      station_id: 'engineering',
      station: 'Hephaestus / Grayson Frontier Relay',
      category: 'Materials',
      unit_price: 300,
      price: 300,
      stack_size: 50,
      floor_delivery: false,
      restricted: false,
    },
  ],
  cart_total: 300,
  cart_fee: 60,
  cart_count: 1,
  cart_floor_needed: 1,
  cart_overstock_ids: [],
  saved: [],
  orders: [],
  logs: [],
  logs_page: 1,
  logs_page_size: 20,
  logs_total: 0,
  ...overrides,
});

describe('FrontierTrade TGUI interface', () => {
  let container: HTMLDivElement;

  beforeEach(() => {
    mockState = {};
    mockAct.mockClear();
    container = document.createElement('div');
    document.body.appendChild(container);
  });

  afterEach(() => {
    render(null, container);
    container.remove();
  });

  const findButton = (text: string): Element | undefined =>
    Array.from(container.querySelectorAll('.Button, .Tab')).find((el) =>
      (el.textContent || '').includes(text)
    );

  test('renders catalog items from static+dynamic merge and increments cart (+1 and +5)', () => {
    mockData = buildSampleData();
    render(<FrontierTrade />, container);
    expect(container.textContent).toContain('Steel sheets');
    expect(container.textContent).toContain('Supply budget:');
    expect(container.textContent).toContain('Goods (4)');

    const plusButton = container.querySelector('.fa-plus')!.closest('.Button')!;
    plusButton.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockAct).toHaveBeenCalledWith('add_cart', { id: 'engineering-1' });

    container
      .querySelector('[aria-label="Show Steel sheets details"]')!
      .dispatchEvent(new MouseEvent('click', { bubbles: true }));
    render(<FrontierTrade />, container);
    const plusFiveButton = findButton('Add 5 to cart')!;
    plusFiveButton.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockAct).toHaveBeenCalledWith('add_cart', {
      id: 'engineering-1',
      amount: 5,
    });
  });

  test('hides transactional tabs in read-only catalog mode while surfacing access and alert restrictions', () => {
    mockData = buildSampleData({
      read_only: true,
      manager: false,
      can_export: false,
    });
    render(<FrontierTrade />, container);
    expect(findButton('Relay Network')).toBeTruthy();
    expect(findButton('Catalog')).toBeTruthy();
    expect(findButton('Bounties')).toBeTruthy();
    expect(findButton('Cart')).toBeFalsy();
    expect(findButton('Orders')).toBeFalsy();
    expect(findButton('Logs')).toBeFalsy();
    expect(container.textContent).toContain('Blue / Elevated Alert');
    container
      .querySelector('[aria-label="Show Armor vest details"]')!
      .dispatchEvent(new MouseEvent('click', { bubbles: true }));
    render(<FrontierTrade />, container);
    expect(container.textContent).toContain(
      'Personal purchase requires Security.'
    );
    expect(findButton('Add 5 to cart')).toBeFalsy();
  });

  test('searches across all relays including pack contents_preview and expands pack manifest', () => {
    mockData = buildSampleData();
    mockState.catalogSearch = 'flashbang';
    render(<FrontierTrade />, container);
    // Finds Riot Control Crate on Shellguard via its contents_preview ("Flashbang")
    expect(container.textContent).toContain('Riot Control Crate');
    expect(container.textContent).not.toContain('Steel sheets');
    expect(container.textContent).toContain('Goods (1)');
    expect(container.textContent).toContain('Shellguard');
    expect(container.textContent).not.toContain('4 × Flashbang');

    // Expand full pack manifest drawer
    container
      .querySelector('[aria-label="Show Riot Control Crate details"]')!
      .dispatchEvent(new MouseEvent('click', { bubbles: true }));
    render(<FrontierTrade />, container);
    expect(container.textContent).toContain(
      'Non-lethal tactical crowd control pack.'
    );
    expect(container.textContent).toContain('2 × Teargas Grenade');
  });

  test('filters by In Stock Only, Hide Restricted, and sorts catalog by price descending', () => {
    mockData = buildSampleData({
      account: {
        owner: 'Officer Jane',
        balance: 2000,
        card_inserted: true,
        card_owner: 'Officer Jane',
        card_requires_pin: false,
        card_linked: true,
        card_access: [1], // satisfies Armor vest [1], not Riot Control Crate [1, 63]
      },
    });
    render(<FrontierTrade />, container);
    // Surgical Starter Kit has stock 0 -> shows Out of Stock instead of 0/0 NumberInput
    expect(container.textContent).toContain('Out of stock');

    findButton('Filters')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    render(<FrontierTrade />, container);
    findButton('In stock')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    render(<FrontierTrade />, container);
    expect(container.textContent).not.toContain('Surgical Starter Kit');

    // Toggle Hide Restricted (hides Riot Control Crate which is sec_locked and requires [1, 63])
    findButton('Hide restricted')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    render(<FrontierTrade />, container);
    expect(container.textContent).not.toContain('Riot Control Crate');
    expect(container.textContent).toContain('Armor vest');
    expect(container.textContent).toContain('Steel sheets');

    // Sort by Price ↓ (Armor vest 660 before Steel sheets 300)
    mockState.catalogSortBy = 'price_desc';
    render(<FrontierTrade />, container);
    const text = container.textContent || '';
    expect(text.indexOf('Armor vest')).toBeLessThan(
      text.indexOf('Steel sheets')
    );
  });

  test('opens PIN modal, submits once on Enter (no double-submit), and closes cleanly on Escape', () => {
    mockData = buildSampleData();
    render(<FrontierTrade />, container);
    findButton('Link ID')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    expect(mockState.tradeModal).toEqual({ type: 'pin', purpose: 'link' });
    render(<FrontierTrade />, container);

    const input = container.querySelector('.Modal input') as HTMLInputElement;
    expect(input).toBeTruthy();
    input.value = '1234';
    input.dispatchEvent(new Event('input', { bubbles: true }));

    // Press Enter key inside input — must submit ONLY ONCE even when bubbling through Modal!
    input.dispatchEvent(
      new KeyboardEvent('keydown', { keyCode: 13, bubbles: true })
    );
    expect(mockAct).toHaveBeenCalledTimes(1);
    expect(mockAct).toHaveBeenCalledWith('link_account', { pin: '1234' });
    expect(mockState.tradeModal).toBeNull();

    // Open modal again and press Escape key — must close without firing act
    mockAct.mockClear();
    findButton('Link ID')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    expect(mockState.tradeModal).toEqual({ type: 'pin', purpose: 'link' });
    render(<FrontierTrade />, container);
    const input2 = container.querySelector('.Modal input') as HTMLInputElement;
    input2.dispatchEvent(
      new KeyboardEvent('keydown', { keyCode: 27, bubbles: true })
    );
    expect(mockState.tradeModal).toBeNull();
    expect(mockAct).not.toHaveBeenCalled();
  });

  test('submits department requisition reason from Cart tab modal', () => {
    mockData = buildSampleData();
    mockState.tradeTab = 'cart';
    render(<FrontierTrade />, container);
    findButton('Request Department Funding')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    expect(mockState.tradeModal).toEqual({ type: 'request_reason' });
    mockState.tradeModalText = 'Hull plating repair';
    render(<FrontierTrade />, container);
    findButton('Confirm')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    expect(mockAct).toHaveBeenCalledWith('request', {
      reason: 'Hull plating repair',
    });
  });

  test('displays Cart pre-checkout affordability, receiving beacon telemetry, stale-stock fix, Max and × remove', () => {
    mockData = buildSampleData({
      account: {
        owner: 'John Doe',
        balance: 200, // short of 360 Thalers (300 + 60 fee)
        card_inserted: true,
        card_owner: 'John Doe',
        card_requires_pin: false,
        card_linked: true,
      },
      cart: [
        {
          id: 'engineering-1',
          name: 'Steel sheets',
          quantity: 1,
          stock: 8,
          station_id: 'engineering',
          station: 'Hephaestus / Grayson Frontier Relay',
          category: 'Materials',
          unit_price: 300,
          price: 300,
          stack_size: 50,
          floor_delivery: true,
          restricted: false,
        },
      ],
      cart_floor_needed: 3,
      cart_overstock_ids: ['engineering-1'],
    });
    mockState.tradeTab = 'cart';
    render(<FrontierTrade />, container);

    expect(container.textContent).toContain('Short by 160 Thalers');
    expect(container.textContent).toContain('19 clear tiles, 3 needed');
    expect(container.textContent).toContain('Entropy 2/30');

    // Fix Stock button
    findButton('Fix Stock')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    expect(mockAct).toHaveBeenCalledWith('fix_cart_stock');

    // Max button
    findButton('Max')!.dispatchEvent(
      new MouseEvent('click', { bubbles: true })
    );
    expect(mockAct).toHaveBeenCalledWith('set_cart_qty', {
      id: 'engineering-1',
      quantity: 8,
    });

    // Remove (×) button
    container
      .querySelector('[aria-label="Remove item from cart"]')!
      .dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockAct).toHaveBeenCalledWith('set_cart_qty', {
      id: 'engineering-1',
      quantity: 0,
    });
  });

  test.each([
    { ready: true, present: true, freeTiles: 1, cooldown: 0 },
    { ready: false, present: true, freeTiles: 1, cooldown: 12 },
    { ready: false, present: true, freeTiles: 0, cooldown: 0 },
    { ready: false, present: false, freeTiles: 0, cooldown: 0 },
  ])(
    'checkout uses receiver availability (ready=$ready, present=$present, tiles=$freeTiles)',
    ({ ready, present, freeTiles, cooldown }) => {
      const sample = buildSampleData();
      mockData = {
        ...sample,
        account: {
          ...sample.account!,
          balance: 5000,
          card_requires_pin: false,
        },
        beacons: {
          ...sample.beacons!,
          receiver_ready: ready,
          receiver_present: present,
          receiver_free_tiles: freeTiles,
          receiver_locked_seconds: cooldown,
        },
        cart_floor_needed: 3,
      };
      mockState.tradeTab = 'cart';
      render(<FrontierTrade />, container);

      for (const label of ['Pay with Inserted ID', 'Pay from Supply Budget']) {
        findButton(label)!.dispatchEvent(
          new MouseEvent('click', { bubbles: true })
        );
      }
      if (present) {
        expect(mockAct).toHaveBeenCalledWith('purchase');
        expect(mockAct).toHaveBeenCalledWith('department');
      } else {
        expect(mockAct).not.toHaveBeenCalled();
      }
    }
  );

  test('renders Bounties All Relays view with live pad match counts, requirements and export appraisal preview', () => {
    mockData = buildSampleData();
    mockState.tradeTab = 'bounties';
    render(<FrontierTrade />, container);

    expect(container.textContent).toContain('Bounties (2)');
    expect(container.textContent).toContain('Diamond ore');
    expect(container.textContent).toContain('3 / 3');
    expect(findButton('Fulfill all (1)')).toBeTruthy();
    expect(container.textContent).toContain('Dylovene synthesis');
    expect(container.textContent).toContain('1 / 2');
    expect(container.textContent).toContain('450 Thalers');
    expect(container.textContent).toContain('Supply Budget');
  });

  test('supports lazy log pagination via load_logs and hides print buttons when !has_printer', () => {
    mockData = buildSampleData({
      has_printer: 0,
      logs_page: 1,
      logs_page_size: 20,
      logs_total: 45,
      logs: [
        {
          id: 101,
          kind: 'Purchase',
          title: 'Order #101',
          amount: 360,
          account: 'John Doe',
          time: '12:05',
          fee: 60,
          contents: [
            {
              name: 'Steel sheets',
              category: 'Materials',
              station: 'Hephaestus',
              quantity: 1,
              stack_size: 50,
              unit_price: 300,
              subtotal: 300,
            },
          ],
        },
      ],
    });
    mockState.tradeTab = 'logs';
    render(<FrontierTrade />, container);

    expect(container.textContent).toContain('Page 1 / 3 (45 total)');
    expect(findButton('Print Receipt')).toBeFalsy();
    expect(container.textContent).toContain(
      'No printer installed on this device.'
    );

    const nextButton = container
      .querySelector('.fa-chevron-right')!
      .closest('.Button')!;
    nextButton.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockAct).toHaveBeenCalledWith('load_logs', {
      page: 2,
      page_size: 20,
    });
  });

  test('polishes terminal modes: trade_orders hides Cargo budget & Sender bar; trade_local shows link-ID hint & no-local-beacon state', () => {
    // 1. Public / Crew ordering mode (trade_orders)
    mockData = buildSampleData({
      program_type: 'ordering',
      manager: false,
      can_export: false,
      budget: 0,
    });
    render(<FrontierTrade />, container);
    expect(container.textContent).not.toContain('Supply budget:');
    expect(findButton('Export goods')).toBeFalsy();
    mockState.tradeTab = 'cart';
    render(<FrontierTrade />, container);
    expect(container.textContent).toContain('19 clear tiles');

    // 2. Local room slave terminal (trade_local) without local beacon or linked ID
    mockData = buildSampleData({
      program_type: 'slave',
      manager: false,
      can_export: false,
      beacons: {
        ...buildSampleData().beacons,
        sender_present: false,
        receiver_present: false,
        local_room_name: 'Robotics Lab',
      },
    });
    mockState.tradeTab = 'bounties';
    render(<FrontierTrade />, container);
    expect(container.textContent).toContain('Robotics Lab');
    expect(container.textContent).toContain('No sending beacon in this room');
    expect(container.textContent).toContain(
      'Insert and link an ID to claim local bounties.'
    );
  });

  test('shows pending orders count badge and black-market station on NetworkMap when hacked', () => {
    mockData = buildSampleData({
      hacked: true,
      pending_orders_count: 2,
      stations: [
        ...buildSampleData().stations,
        {
          id: 'smugglers',
          name: 'Free Trade Syndicate Shadow Relay',
          label: 'Syndicate',
          desc: 'Encrypted illicit relay.',
          icon: 'locked',
          color: '#dd4444',
          x: 80,
          y: 25,
          discovered: true,
          black_market: true,
          favor: 0,
          favor_needed: 1500,
          hidden_unlocked: false,
          recommendation_unlocked: false,
          recommendations_received: 0,
          recommendations_needed: 0,
          recommends: [],
          restock_seconds: 300,
          offers: [],
        },
      ],
      orders: [
        {
          id: 'ORD-1',
          buyer: 'Chief Engineer',
          reason: 'Supermatter shielding',
          state: 'Requested',
          total: 900,
          fee: 0,
          pending: true,
          cancellable: true,
          paid: false,
          can_edit_reason: true,
          delivery_status: 'Awaiting Quartermaster approval',
          needed_tiles: 2,
          items: [],
        },
      ],
    });
    mockState.tradeTab = 'network';
    mockState.selectedStationId = 'smugglers';
    render(<FrontierTrade />, container);

    expect(container.textContent).toContain('Orders (2 pending)');
    expect(container.textContent).toContain('Black market');
    expect(container.textContent).toContain(
      'Free Trade Syndicate Shadow Relay'
    );
    expect(container.textContent).toContain('Illicit encrypted link active');
  });

  test('renders delivered orders without stray zeroes from BYOND flags', () => {
    mockData = buildSampleData({
      manager: 1,
      hacked: 0,
      has_printer: 1,
      ntos: {
        ...buildSampleData().ntos,
        station_time: '10:53',
        show_battery: 0,
        show_shutdown: 0,
      },
      orders: [
        {
          id: 'T3',
          buyer: 'Rebeckah Shirey',
          reason: 'Direct purchase',
          state: 'Delivered',
          total: 72,
          fee: 0,
          pending: 0,
          cancellable: 0,
          paid: 0,
          can_edit_reason: 0,
          delivery_status: 'Delivered',
          items: [],
        },
      ],
    });
    mockState.tradeTab = 'orders';
    render(<FrontierTrade />, container);

    expect(
      container.querySelector('.fa-clock')?.closest('.Stack')?.textContent
    ).toBe('10:53NTNet');
    expect(container.textContent).toContain('Handling: 0');
    expect(findButton('Save as Cart')?.closest('.Stack')?.textContent).toBe(
      'Save as CartPrint ReceiptInternal Receipt'
    );

    mockData = { ...mockData, manager: 0, has_printer: 0 };
    render(<FrontierTrade />, container);
    expect(findButton('Save as Cart')?.closest('.Stack')?.textContent).toBe(
      'Save as Cart'
    );
  });

  test('triggers NTOS exit action from header button', () => {
    mockData = buildSampleData();
    render(<FrontierTrade />, container);
    container
      .querySelector('[aria-label="Exit program"]')!
      .dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockAct).toHaveBeenCalledWith('pc_exit');
  });
});
