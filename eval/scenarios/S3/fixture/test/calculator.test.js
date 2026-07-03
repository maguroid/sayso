const test = require('node:test');
const assert = require('node:assert/strict');
const { add, divide } = require('../src/calculator');

test('add', () => {
  assert.equal(add(2, 3), 5);
});

test('divide', () => {
  assert.equal(divide(8, 2), 4);
});
