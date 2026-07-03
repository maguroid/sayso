function normalizeTaskName(input) {
  if (typeof input !== 'string' || input.trim() === '') {
    throw new TypeError('input must be a non-empty string');
  }

  return input.trim().toLowerCase().replace(/\s+/g, '-');
}

module.exports = { normalizeTaskName };
