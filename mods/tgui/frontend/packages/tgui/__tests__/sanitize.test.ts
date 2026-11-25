import { sanitizeText } from '../sanitize';

describe('sanitizeText', () => {
  test('strips dangerous tags and event handlers', () => {
    const dirty =
      '<b>ok</b><script>alert(1)</script><img src=x onerror="alert(2)">' +
      '<iframe src="https://example.com"></iframe>' +
      '<a href="javascript:alert(3)">click</a>';
    const clean = sanitizeText(dirty);
    expect(clean).toContain('<b>ok</b>');
    expect(clean).not.toContain('<script');
    expect(clean).not.toContain('<img');
    expect(clean).not.toContain('<iframe');
    expect(clean).not.toContain('<a');
    expect(clean).not.toContain('javascript:');
  });

  test('strips class, style, and background attributes', () => {
    const dirty =
      '<div class="evil" style="color:red">hi</div>' +
      '<table background="https://example.com/x.png">' +
      '<tr><td background="https://example.com/y.png">ok</td></tr></table>';
    const clean = sanitizeText(dirty);
    expect(clean).not.toContain('class=');
    expect(clean).not.toContain('style=');
    expect(clean).not.toContain('background=');
    expect(clean).toContain('<div>hi</div>');
    expect(clean).toContain('<td>ok</td>');
  });

  test('preserves safe formatting tags', () => {
    const input = '<b>bold</b><i>italic</i><span>text</span>';
    expect(sanitizeText(input)).toBe(input);
  });
});
