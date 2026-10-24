import { globalEvents } from '../events';
import { setupHotKeys } from '../hotkeys';

jest.mock('../logging', () => ({
  createLogger: () => ({ debug: jest.fn(), log: jest.fn() }),
}));

describe('SSInput macro passthrough', () => {
  beforeAll(async () => {
    (globalThis as any).Byond = {
      command: jest.fn(),
      winget: jest.fn().mockResolvedValue({
        'default.personal-w.name': '"W"',
        'default.personal-w.command': '"KeyDown \\"W\\""',
        'default.personal-w-up.name': '"W+UP"',
        'default.personal-w-up.command': '"KeyUp \\"W\\""',
        'default.communication-ooc.name': '"F2"',
        'default.communication-ooc.command': '"ooc"',
      }),
    };
    setupHotKeys();
    await Promise.resolve();
  });

  beforeEach(() => {
    jest.useFakeTimers();
    window.dispatchEvent(new Event('focus'));
  });

  afterEach(() => {
    globalEvents.emit('window-blur');
    jest.clearAllTimers();
    jest.useRealTimers();
  });

  const key = (
    type: string,
    keyCode: number,
    target: Element = document.body
  ) =>
    target.dispatchEvent(
      new KeyboardEvent(type, {
        bubbles: true,
        keyCode,
        which: keyCode,
      })
    );

  const commands = () => (Byond.command as jest.Mock).mock.calls.flat();

  test('explicit movement macros send one down and one up despite repeats', () => {
    key('keydown', 87);
    key('keydown', 87);
    key('keyup', 87);
    expect(commands()).toEqual(['keyDown "W"', 'keyUp "W"']);
  });

  test('leaving the browser releases movement without a browser keyup', () => {
    key('keydown', 87);
    window.dispatchEvent(new Event('blur'));
    jest.runOnlyPendingTimers();
    expect(commands()).toEqual(['keyDown "W"', 'keyUp "W"']);
  });

  test('focusing a textbox releases movement before it consumes keyup', () => {
    const input = document.createElement('input');
    document.body.appendChild(input);
    key('keydown', 87);
    input.focus();
    key('keyup', 87, input);
    expect(commands()).toEqual(['keyDown "W"', 'keyUp "W"']);
    input.remove();
  });

  test('command macros fire on keydown only', () => {
    key('keydown', 113);
    key('keyup', 113);
    expect(commands()).toEqual(['ooc']);
  });
});
