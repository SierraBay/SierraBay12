import { render } from 'inferno';
import { ChemMaster } from '../interfaces/ChemMaster';
import { Fabricator } from '../interfaces/Fabricator';
import { SuitStorage } from '../interfaces/SuitStorage';
import { CrewMonitor } from '../interfaces/CrewMonitor';
import { Vending } from '../interfaces/Vending';
import { SmartFridge } from '../interfaces/SmartFridge';
import { ChemDispenser } from '../interfaces/ChemDispenser';
import { Canister } from '../interfaces/Canister';

let mockData: any;
let mockTabIndex = 0;
let mockCartStat = false;
let mockCategory = 'All';
const mockAct = jest.fn();

jest.mock('../backend', () => {
  (globalThis as any).Byond = { IS_LTE_IE8: false, IS_LTE_IE9: false };
  return {
    useBackend: () => ({
      data: mockData,
      act: mockAct,
      config: { map: 'sierra', mapZLevel: 2 },
    }),
    useLocalState: (_context, key, value) => [
      key === 'tabIndex'
        ? mockTabIndex
        : key === 'cartStat'
          ? mockCartStat
          : value,
      jest.fn(),
    ],
    useSharedState: (_context, key, value) => [
      key === 'tab' ? mockCategory : value,
      jest.fn(),
    ],
  };
});

jest.mock('../layouts', () => {
  const { createVNode } = require('inferno');
  const Window = (props) => createVNode(1, 'div', null, props.children, 0);
  Window.Content = Window;
  return { Window };
});

describe('Sierra machine controls', () => {
  let container: HTMLDivElement;
  beforeEach(() => {
    mockTabIndex = 0;
    mockCartStat = false;
    mockCategory = 'All';
    container = document.createElement('div');
    document.body.appendChild(container);
  });
  afterEach(() => {
    render(null, container);
    container.remove();
  });

  const click = (text: string) => {
    const button = Array.from(container.querySelectorAll('.Button')).find(
      (element) => element.textContent === text
    );
    expect(button).toBeDefined();
    button!.dispatchEvent(new MouseEvent('click', { bubbles: true }));
  };

  test('empty fridge shows the empty state for an empty DM list', () => {
    mockData = { contents: [] };
    render(<SmartFridge />, container);
    expect(container.textContent).toContain('Продукты отсутствуют');
  });

  test.each([100, 250, 1000])(
    'full %su cartridges show a full green bar',
    (capacity) => {
      mockCartStat = true;
      mockData = {
        amount: 10,
        chemicals: [{ label: 'Water', amount: capacity, capacity }],
      };
      render(<ChemDispenser />, container);
      const bar = container.querySelector('.ProgressBar--color--good')!;
      expect(bar).not.toBeNull();
      expect(
        (bar.querySelector('.ProgressBar__fill') as HTMLElement).style.width
      ).toBe('100%');
    }
  );

  test('empty dispenser omits the beaker-volume indicator', () => {
    mockData = { amount: 10, chemicals: [], beakerMaxVolume: null };
    render(<ChemDispenser />, container);
    expect(container.querySelector('.ProgressBar:not(.Slider)')).toBeNull();
    expect(container.textContent).toContain('Отсутствует ёмкость');
  });

  test('canister warns of room release after the holding tank was removed', () => {
    mockData = {
      valveOpen: true,
      hasHoldingTank: false,
      holdingTank: { name: 'stale tank' },
      tankPressure: 0,
      maximumPressure: 1000,
      releasePressure: 100,
      minReleasePressure: 10,
      maxReleasePressure: 1000,
    };
    render(<Canister />, container);
    const valve = Array.from(container.querySelectorAll('.Button')).find(
      (e) => e.textContent === 'Открыт'
    )!;
    expect(valve.classList.contains('Button--color--danger')).toBe(true);
    expect(container.textContent).not.toContain('stale tank');
  });

  test('vending shows the product grid while idle and requests the selected product', () => {
    mockAct.mockClear();
    mockData = {
      vend_ready: true,
      mode: false,
      products: [
        { key: 3, name: 'water', price: 5, category: 1, ammount: 2, image: '' },
      ],
    };
    render(<Vending />, container);
    expect(container.textContent).toContain('Продукты');
    expect(container.textContent).not.toContain('Наслаждайтесь!');
    const product = container.querySelector('.ImageButton__vertical');
    expect(product).not.toBeNull();
    expect(product!.textContent).toBe('5 ₸');
    product!.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockAct).toHaveBeenCalledWith('vend', { vend: 3 });
  });

  test('vending keeps the payment screen until payment succeeds', () => {
    mockData = {
      vend_ready: true,
      mode: true,
      products: [],
      product: 'water',
      price: 5,
    };
    render(<Vending />, container);
    expect(container.textContent).toContain('Для оплаты');
    expect(container.textContent).not.toContain('Наслаждайтесь!');
    click('Отмена');
    expect(mockAct).toHaveBeenCalledWith('cancelpurchase');
  });

  test.each([true, false])(
    'vending shows the smile during delivery with payment mode %s',
    (mode) => {
      mockData = {
        vend_ready: false,
        mode,
        products: [],
        product: 'water',
        price: 5,
      };
      render(<Vending />, container);
      expect(container.textContent).toContain('Наслаждайтесь!');
      expect(container.querySelector('.fa-smile')).not.toBeNull();
      expect(container.textContent).not.toContain('Для оплаты');
    }
  );

  test('suit storage shows ordinary item names and can eject an occupant', () => {
    mockData = { occupied: true, door_open: true, helmet: 'helmet' };
    render(<SuitStorage />, container);
    expect(container.textContent).toContain('Helmet');
    click('Eject occupant');
    expect(mockAct).toHaveBeenCalledWith('eject_guy');
  });

  test('ChemMaster keeps Sierra blister and pill dissolution controls', () => {
    mockData = {
      productionOptions: 'BASE',
      pillSprites: [],
      bottleSprites: [],
      containerChemicals: [],
      bufferChemicals: [{ name: 'Water', volume: 12, ref: 'water' }],
      pillBottle: true,
      pillDosage: 1,
      pillDosageMax: 30,
      bottleDosage: 1,
      bottleDosageMax: 60,
      pillCount: 1,
      pillCountMax: 20,
      blisterDosage: 1,
      blisterDosageMax: 30,
      blisterType: 6,
    };
    render(<ChemMaster />, container);
    click('Make blister');
    expect(mockAct).toHaveBeenCalledWith('createBlister');
    click('Dissolve pill');
    expect(mockAct).toHaveBeenCalledWith('dissolve_pill');
  });

  test('fabricator keeps disk controls and shows a queue while idle', () => {
    mockData = {
      have_disk: true,
      disk: { name: 'Design disk' },
      material_storage: [],
      categories: [],
      recipes: [],
      current_build: null,
      build_queue: [{ name: 'Wrench', multiplier: 1, reference: '1' }],
    };
    render(<Fabricator />, container);
    expect(container.textContent).toContain('Wrench');
    click('Eject Design disk');
    expect(mockAct).toHaveBeenCalledWith('disk');
  });

  test('fabricator categories match Sierra recipes with multiple categories', () => {
    mockCategory = 'Tools';
    mockData = {
      material_storage: [],
      categories: ['Tools', 'Medical'],
      recipes: [
        {
          name: 'Multitool',
          category: ['Tools', 'Medical'],
          reference: 'multi',
          cost: [],
          can_build: true,
        },
        {
          name: 'Scalpel',
          category: ['Medical'],
          reference: 'scalpel',
          cost: [],
          can_build: true,
        },
      ],
      build_queue: [],
    };
    render(<Fabricator />, container);
    expect(container.textContent).toContain('Multitool');
    expect(container.textContent).not.toContain('Scalpel');
  });

  test('ChemMaster highlights the selected pill style serialized as text by DM', () => {
    mockData = {
      productionOptions: 'BASE',
      pillSprite: '2',
      pillSprites: [
        { id: 1, sprite: 'pill1' },
        { id: 2, sprite: 'pill2' },
      ],
      bottleSprites: [],
      containerChemicals: [],
      bufferChemicals: [],
    };
    render(<ChemMaster />, container);
    const selected = container.querySelector('.ImageButton--selected .pill2');
    expect(selected).not.toBeNull();
  });

  test('switching away from a dragged crew map removes document listeners', () => {
    mockTabIndex = 1;
    mockData = { crewmembers: [] };
    render(<CrewMonitor />, container);
    const add = jest.spyOn(document, 'addEventListener');
    const remove = jest.spyOn(document, 'removeEventListener');
    container
      .querySelector('.NanoMap__container')!
      .firstElementChild!.dispatchEvent(
        new MouseEvent('mousedown', { bubbles: true })
      );
    const handlers = add.mock.calls.filter(
      ([type]) => type === 'mousemove' || type === 'mouseup'
    );
    expect(handlers).toHaveLength(2);
    render(null, container);
    for (const [type, handler] of handlers) {
      expect(remove).toHaveBeenCalledWith(type, handler);
    }
    add.mockRestore();
    remove.mockRestore();
  });

  test('crew map uses Sierra filenames and the reported sensor z-level', () => {
    mockTabIndex = 1;
    mockData = {
      crewmembers: [
        { ref: 'visible', sensor_type: 3, x: 10, y: 20, z: 2 },
        { ref: 'other-deck', sensor_type: 3, x: 30, y: 40, z: 1 },
        { ref: 'no-position', sensor_type: 2, x: 50, y: 60, z: 2 },
      ],
    };
    render(<CrewMonitor />, container);
    expect(container.querySelector('img')!.getAttribute('src')).toBe(
      'sierra-2.png'
    );
    const markers = container.querySelectorAll('.NanoMap__marker');
    expect(markers).toHaveLength(1);
  });
});
