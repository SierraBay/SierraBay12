/* eslint-env jest */

const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(
  path.resolve(__dirname, '../../../public/tgui.html'),
  'utf8'
);
const scripts = [];
const scriptPattern = /<script[^>]*>([\s\S]*?)<\/script>/g;
let match;
while ((match = scriptPattern.exec(html))) {
  scripts.push(match[1]);
}
const bootstrap = scripts[0];
const ready = scripts.find((script) =>
  script.includes("Byond.sendMessage('ready')")
);

const loadPage = ({
  userAgent,
  window = {},
  hostname = '127.0.0.1',
  search = '',
}) => {
  const context = {
    window,
    navigator: { userAgent },
    location: { hostname, search, href: 'initial' },
    document: {
      getElementById: (id) => ({
        getAttribute: () => (id === 'tgui:windowId' ? 'tgui-window-1' : '1'),
      }),
    },
    cef_to_byond: window.cef_to_byond,
  };
  vm.createContext(context);
  vm.runInContext(bootstrap, context);
  context.Byond = window.Byond;
  vm.runInContext(ready, context);
  return context;
};

test('WebView2 sends the ready handshake through the BYOND URL', () => {
  const browser = loadPage({
    userAgent: 'Mozilla/5.0 Chrome/130.0.0.0 Edg/130.0.0.0',
    window: { chrome: { webview: {} } },
  });
  expect(browser.Byond.IS_BYOND).toBe(true);
  expect(browser.location.href).toBe(
    'byond://?type=ready&payload=&tgui=1&window_id=tgui-window-1'
  );
});

test('Trident retains its existing ready handshake', () => {
  const browser = loadPage({
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Trident/7.0; rv:11.0) like Gecko',
  });
  expect(browser.location.href).toContain('byond://?type=ready&');
});

test('legacy CEF retains its native bridge', () => {
  const bridge = jest.fn();
  loadPage({
    userAgent: 'Chrome/130.0.0.0',
    window: { cef_to_byond: bridge },
  });
  expect(bridge).toHaveBeenCalledWith(
    'byond://?type=ready&payload=&tgui=1&window_id=tgui-window-1'
  );
});

test.each([
  { userAgent: 'Chrome/130.0.0.0' },
  {
    userAgent: 'Chrome/130.0.0.0',
    window: { chrome: { webview: {} } },
    hostname: 'example.com',
  },
  {
    userAgent: 'Chrome/130.0.0.0',
    window: { chrome: { webview: {} } },
    search: '?external',
  },
])('external pages do not send a BYOND handshake: %o', (options) => {
  const browser = loadPage(options);
  expect(browser.Byond.IS_BYOND).toBe(false);
  expect(browser.location.href).toBe('initial');
});
