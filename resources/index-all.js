let library;
if (process.platform === "linux" && process.arch === "x64") {
  library = require("./lib/linux-x64/libyogacore.so");
} else if (process.platform === "linux" && process.arch === "arm64") {
  library = require("./lib/linux-arm64/libyogacore.so");
} else if (process.platform === "win32" && process.arch === "x64") {
  library = require("./lib/win32-x64/libyogacore.dll");
} else if (process.platform === "darwin" && process.arch === "x64") {
  library = require("./lib/darwin-x64/libyogacore.dylib");
} else if (process.platform === "darwin" && process.arch === "arm64") {
  library = require("./lib/darwin-arm64/libyogacore.dylib");
} else {
  throw new Error(`yoga: unsupported platform or architecture: ${process.platform}-${process.arch}`);
}

export default library;
