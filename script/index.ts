import { dlopen, FFIType } from "bun:ffi";

let path = process.argv[2];
if (!path) {
  console.error("Usage: bun run libgit.ts /path/to/library");
  process.exit(1);
}

const {
  symbols: { YGAlignToString },
} = dlopen(path, {
  YGAlignToString : {
    args: ["int"],
    returns: FFIType.cstring,
  },
});

for (let i = 0; i < 10; i++) {
  const ret = YGAlignToString(i);
  console.log(ret);
}
