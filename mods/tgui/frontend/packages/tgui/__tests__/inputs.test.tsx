import { render } from 'inferno';
import '../backend';
import { ListInputModal } from '../interfaces/ListInputModal';
import { NumberInputModal } from '../interfaces/NumberInputModal';
import {
  TextInputModal,
  removeAllSkiplines,
  sanitizeMultiline,
} from '../interfaces/TextInputModal';
import { Orbit } from '../interfaces/Orbit';

let mockData: any;
let mockState: Record<string, any>;
const mockAct = jest.fn();

jest.mock('../backend', () => {
  (globalThis as any).Byond = { IS_LTE_IE10: false };
  return {
    useBackend: () => ({ data: mockData, act: mockAct }),
    useLocalState: (_context, key, initial) => [
      key in mockState ? mockState[key] : initial,
      (value) => {
        mockState[key] = value;
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

describe('Ported input controls', () => {
  let container: HTMLDivElement;
  beforeEach(() => {
    jest.useFakeTimers();
    mockState = {};
    mockAct.mockClear();
    Element.prototype.scrollIntoView = jest.fn();
    container = document.createElement('div');
    document.body.appendChild(container);
  });
  afterEach(() => {
    jest.clearAllTimers();
    render(null, container);
    container.remove();
    jest.useRealTimers();
  });
  const key = (element: Element, keyCode: number, shiftKey = false) => {
    element.dispatchEvent(
      new KeyboardEvent('keydown', {
        bubbles: true,
        cancelable: true,
        keyCode,
        which: keyCode,
        shiftKey,
      })
    );
  };

  test('number Enter submits the edited value exactly once', () => {
    mockData = {
      init_value: 0,
      min_value: 0,
      max_value: 100,
      round_value: true,
    };
    render(<NumberInputModal />, container);
    const input = container.querySelector('input')!;
    input.value = '42';
    key(input, 13);
    expect(mockAct).toHaveBeenCalledTimes(1);
    expect(mockAct).toHaveBeenCalledWith('submit', { entry: 42 });
  });

  test.each([true, false])(
    'split remains in range (integer: %s)',
    (round_value) => {
      mockData = { init_value: 20, min_value: 20, max_value: 30, round_value };
      render(<NumberInputModal />, container);
      const split = container.querySelector('.fa-divide')!.closest('.Button')!;
      expect(split.classList.contains('Button--disabled')).toBe(true);
      split.dispatchEvent(new MouseEvent('click', { bubbles: true }));
      expect(mockState.input).toBeUndefined();
    }
  );

  test('split preserves fractional values when rounding is disabled', () => {
    mockData = {
      init_value: 3,
      min_value: 0,
      max_value: 100,
      round_value: false,
    };
    render(<NumberInputModal />, container);
    container
      .querySelector('.fa-divide')!
      .closest('.Button')!
      .dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockState.input).toBe(1.5);
  });

  test('split respects the maximum of a negative range', () => {
    mockData = {
      init_value: -8,
      min_value: -10,
      max_value: -5,
      round_value: true,
    };
    render(<NumberInputModal />, container);
    container
      .querySelector('.fa-divide')!
      .closest('.Button')!
      .dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockState.input).toBe(-5);
  });

  test.each([13, 27])(
    'text keyboard action %s sends one request',
    (keyCode) => {
      mockData = { placeholder: 'example', max_length: 100 };
      render(<TextInputModal />, container);
      key(container.querySelector('textarea')!, keyCode);
      expect(mockAct).toHaveBeenCalledTimes(1);
      expect(mockAct).toHaveBeenCalledWith(
        keyCode === 13 ? 'submit' : 'cancel',
        ...(keyCode === 13 ? [{ entry: 'example' }] : [])
      );
    }
  );

  test('Shift+Enter in multiline text does not submit', () => {
    mockData = { placeholder: 'example', max_length: 100, multiline: true };
    render(<TextInputModal />, container);
    key(container.querySelector('textarea')!, 13, true);
    expect(mockAct).not.toHaveBeenCalled();
  });

  test('text sanitation handles every newline group', () => {
    expect(removeAllSkiplines('a\nb\r\nc\nd')).toBe('abcd');
    expect(sanitizeMultiline('a\n\n\nb\r\n\r\n\r\nc')).toBe('a\n\nb\n\nc');
  });

  test('list selects its first entry when the default is missing', () => {
    mockData = { items: ['One', 'Two'], init_value: 'Missing' };
    render(<ListInputModal />, container);
    key(container.querySelector('.ListInput__Section')!, 13);
    expect(mockAct).toHaveBeenCalledWith('submit', { entry: 'One' });
  });

  test('list search Enter sends one request', () => {
    mockData = { items: ['One', 'Two'], init_value: 'One' };
    mockState.searchBarVisible = true;
    render(<ListInputModal />, container);
    key(container.querySelector('input')!, 13);
    expect(mockAct).toHaveBeenCalledTimes(1);
    expect(mockAct).toHaveBeenCalledWith('submit', { entry: 'One' });
  });

  test('empty search results disable Submit and ignore Enter/arrows', () => {
    mockData = { items: ['One', 'Two'], init_value: 'One' };
    mockState = { searchBarVisible: true, searchQuery: 'absent' };
    render(<ListInputModal />, container);
    const submit = Array.from(container.querySelectorAll('.Button')).find(
      (e) => e.textContent === 'Submit'
    )!;
    expect(submit.classList.contains('Button--disabled')).toBe(true);
    const input = container.querySelector('input')!;
    key(input, 38);
    key(input, 40);
    key(input, 13);
    expect(mockAct).not.toHaveBeenCalled();
    expect(mockState.selected).toBeUndefined();
  });

  test('Orbit search Enter finds an antagonist and keeps distinct references for equal names', () => {
    mockData = {
      antagonists: [{ name: 'Target', ref: 'antag', antag: ['Traitor'] }],
      alive: [
        { name: 'Target', ref: 'alive1' },
        { name: 'Target', ref: 'alive2' },
      ],
      ghosts: [],
      dead: [],
      npcs: [],
      misc: [],
    };
    render(<Orbit />, container);
    const input = container.querySelector('input')!;
    input.value = 'Target';
    key(input, 13);
    expect(mockAct).toHaveBeenCalledWith('orbit', { ref: 'antag' });
    const targets = Array.from(container.querySelectorAll('.Button')).filter(
      (e) => e.textContent === 'Target'
    );
    targets[2].dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(mockAct).toHaveBeenLastCalledWith('orbit', { ref: 'alive2' });
  });
});
