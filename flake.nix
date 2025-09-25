{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        windowsPkgs = import nixpkgs {
          inherit system;
          crossSystem = {
            config = "x86_64-w64-mingw32";
          };
        };

        x64DarwinPkgs = import nixpkgs {
          inherit system;
          crossSystem = {
            config = "x86_64-darwin";
          };
        };

        aarch64LinuxPkgs = import nixpkgs {
          inherit system;
          crossSystem = {
            config = "aarch64-linux";
          };
        };

        version = pkgs.lib.strings.trim (builtins.readFile ./library-version.txt);

        build =
          targetPkgs: windows:
          targetPkgs.callPackage (
            {
              lib,
              stdenv,
              fetchFromGitHub,
            }:

            stdenv.mkDerivation (finalAttrs: {
              pname = "static-yoga";
              inherit version;

              src = fetchFromGitHub {
                owner = "facebook";
                repo = "yoga";
                rev = "v${version}";
                hash = "sha256-y7tLHOfZ/S5ZAdtL8TXTNMwj76QH+alYBaI8e3Wc4iU=";
              };

              patches = [
                ./patches/shared-library.patch
                ./patches/link-options.patch
                ./patches/cmakelists.patch
              ];

              cmakeFlags = [
                "-DBUILD_SHARED_LIBS=ON"
                "-DBUILD_TESTING=OFF"
              ];

              nativeBuildInputs =
                if stdenv.isLinux then
                  [
                    pkgs.pkgsMusl.cmake
                    pkgs.pkgsMusl.gcc
                  ]
                else
                  [ pkgs.cmake ];

              env =
                if stdenv.isLinux then
                  {
                    NIX_CFLAGS_COMPILE = "-static-libgcc -static-libstdc++";
                  }
                else if windows then
                  {
                    NIX_CFLAGS_COMPILE = "-static";
                  }
                else
                  { };

              # After building, rewrite libc++ dependency to the system one on macOS
              postFixup = lib.optionalString stdenv.isDarwin ''
                dylib="$out/lib/libyogacore.dylib"
                if [ -f "$dylib" ]; then
                  orig=$(otool -L "$dylib" | sed -n 's/^[[:space:]]*\(.*libc++[^[:space:]]*dylib\).*/\1/p' | head -n1 || true)
                  if [ -n "$orig" ] && [ "$orig" != "/usr/lib/libc++.1.dylib" ]; then
                    echo "Rewriting $orig -> /usr/lib/libc++.1.dylib"
                    install_name_tool -change "$orig" "/usr/lib/libc++.1.dylib" "$dylib"
                  fi
                fi
              '';
            })
          ) { };
      in
      {
        packages.default = build pkgs false;
        packages.windows = build windowsPkgs true;
        packages.x64Darwin = build x64DarwinPkgs false;
        packages.aarch64Linux = build aarch64LinuxPkgs false;
      }
    );
}
