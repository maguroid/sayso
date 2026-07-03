const fs = require('node:fs');
const path = require('node:path');

function listMarkdownFiles(rootDir) {
  const results = [];

  function walk(currentDir) {
    for (const entry of fs.readdirSync(currentDir, { withFileTypes: true })) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        walk(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.md')) {
        results.push(path.relative(rootDir, fullPath).split(path.sep).join('/'));
      }
    }
  }

  walk(rootDir);
  return results.sort();
}

module.exports = { listMarkdownFiles };
