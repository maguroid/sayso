const test = require('node:test');
const assert = require('node:assert/strict');
const { normalizeTaskName } = require('../src');

test('normalizes task names', () => {
  assert.equal(normalizeTaskName('  Build   The Thing\nNow '), 'build-the-thing-now');
});

test('rejects invalid input', () => {
  assert.throws(() => normalizeTaskName('   '), TypeError);
  assert.throws(() => normalizeTaskName(null), TypeError);
});
