# Static yoga

Use yoga seamlessly in JavaScript without any external dependencies. This package provides yoga as a dynamic library, statically compiled against its dependencies. This enables usage of the library with Bun/Node.js FFI.

## Installation

The `@openffi/yoga` package will install the appropriate library for your OS and architecture.

```bash
npm install @openffi/yoga # with npm
bun add @openffi/yoga     # with Bun
```

Alternatively, if you need the libraries for all platforms, you can install the `@openffi/yoga-all` package.

## Usage

### Bun FFI Example

```typescript
import { dlopen, FFIType } from "bun:ffi";
import yoga from "@openffi/yoga";

const {
  symbols: { YGAlignToString },
} = dlopen(yoga, {
  YGAlignToString : {
    args: ["int"],
    returns: FFIType.cstring,
  },
});

for (let i = 0; i < 10; i++) {
  const ret = YGAlignToString(i);
  console.log(ret);
}
```

## Platform Support

- ✅ Linux (x64, ARM64)
- ✅ macOS (x64, ARM64)
- ✅ Windows (x64)

## Development

This project uses Nix for reproducible builds. To build the static libraries:

```bash
nix build
```

## License

MIT License - see LICENSE file for details.
