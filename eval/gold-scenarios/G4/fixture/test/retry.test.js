const test = require('node:test');
const assert = require('node:assert/strict');

const { retry } = require('../src/retry');

test('returns a successful operation result', async () => {
  const result = await retry(async () => 'ok', { baseDelayMs: 0 });
  assert.equal(result, 'ok');
});

test('eventually succeeds after a transient error', async () => {
  let calls = 0;
  const result = await retry(async () => {
    calls += 1;
    if (calls === 1) {
      throw new Error('temporary');
    }
    return 'recovered';
  }, { baseDelayMs: 0 });

  assert.equal(result, 'recovered');
});
