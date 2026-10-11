import { render } from 'inferno';
import { NanoFrame } from '../interfaces/NanoUI';

jest.mock('../backend', () => ({}));
jest.mock('../layouts', () => ({}));

test('NanoUI keeps its own document and waits for its libraries before updates', () => {
  jest.useFakeTimers();
  const container = document.createElement('div');
  document.body.appendChild(container);
  const html =
    '<html><body><div id="uiLayout">Legacy template</div></body></html>';
  const receive = jest.fn();
  render(
    <NanoFrame
      html={html}
      nanoData={{ data: { count: 1 } }}
      width={600}
      height={500}
    />,
    container
  );
  const frame = container.querySelector('iframe')!;
  expect(frame.contentDocument!.body.textContent).toContain('Legacy template');
  expect(document.getElementById('uiLayout')).toBeNull();
  render(
    <NanoFrame
      html={html}
      nanoData={{ data: { count: 2 } }}
      width={600}
      height={500}
    />,
    container
  );
  const target = frame.contentWindow as any;
  target.NanoStateManager = {};
  target.jQuery = {};
  target.receiveUpdateData = receive;
  jest.advanceTimersByTime(50);
  expect(receive).toHaveBeenCalledTimes(1);
  expect(JSON.parse(receive.mock.calls[0][0])).toEqual({ data: { count: 2 } });
  render(
    <NanoFrame
      html={html}
      nanoData={{ config: { status: 0 } }}
      width={600}
      height={500}
    />,
    container
  );
  expect(frame.contentDocument!.body.textContent).toContain('Legacy template');
  expect(JSON.parse(receive.mock.calls[1][0])).toEqual({
    config: { status: 0 },
  });
  render(null, container);
  expect(jest.getTimerCount()).toBe(0);
  container.remove();
  jest.useRealTimers();
});
