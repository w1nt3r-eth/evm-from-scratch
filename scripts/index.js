const assembler = require('./assembler');
const fs = require('fs');
const path = require('path');
const yaml = require('yaml');

function main() {
  const content = fs.readFileSync(path.join(__dirname, 'evm.yaml'), 'utf8');
  const tests = yaml.parse(content, (key, value) => {
    // Compile assembly code to bytecode, keeping the original source code
    if (key === 'code') {
      if (Array.isArray(value)) {
        return { asm: value.join('\n'), bin: uint8ArrayToHexString(assembler(value.join('\n'))) };
      } else {
        return { asm: null, bin: value };
      }
    }

    // Ignore TODO items for now
    if (value?.todo) {
      return undefined;
    }

    // Turn all big number keys into strings, preserving hex vs decimal
    // This makes it easier to debug unit tests
    if (typeof value === 'string') {
      return parseYamlBigInt(value);
    }

    if (key === 'state') {
      return Object.fromEntries(Object.entries(value).map(([address, account]) => [parseYamlBigInt(address), account]));
    }

    return value;
  });

  const ordered = Object.entries(tests).map(([name, t]) => ({ name, ...t }));

  fs.writeFileSync(path.join(__dirname, '..', 'evm.json'), JSON.stringify(ordered, null, 2));
}

function parseYamlBigInt(value) {
  if (typeof value === 'string' && value.match(/^(0x)?[0-9a-f_]+n$/)) {
    return '0x' + BigInt(value.replace(/n$/, '').replace(/_/g, '')).toString(16);
  }
  return value;
}

function uint8ArrayToHexString(uint8Array) {
  return uint8Array.reduce((str, byte) => str + byte.toString(16).padStart(2, '0'), '');
}

main();
