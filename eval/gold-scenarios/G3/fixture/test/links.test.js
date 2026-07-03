const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');

const { findBrokenLinks } = require('../src/links');

test('finds missing relative markdown links', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'links-'));
  fs.mkdirSync(path.join(root, 'docs'));
  fs.writeFileSync(path.join(root, 'README.md'), [
    '# Home',
    '[ok](docs/guide.md)',
    '[missing](docs/missing.md)',
    '[external](https://example.invalid/page)',
    '![image](docs/missing.png)',
  ].join('\n'));
  fs.writeFileSync(path.join(root, 'docs', 'guide.md'), '[up](../README.md#home)\n[bad](../nope.md#part)\n');

  assert.deepEqual(findBrokenLinks(root), [
    { file: 'README.md', target: 'docs/missing.md' },
    { file: 'docs/guide.md', target: '../nope.md#part' },
  ]);
});
