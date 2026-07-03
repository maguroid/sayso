function formatRunResult({ scenario, arm, exitCode }) {
  if (!scenario || !arm) {
    throw new TypeError('scenario and arm are required');
  }

  return `${scenario}:${arm}:exit=${exitCode}`;
}

module.exports = { formatRunResult };
