# veil_light_plugin

Port of `veil-secp256k1` to `dart/flutter`, based on fork of WASM module [tiny-secp256k1](https://github.com/steel97/tiny-secp256k1) originally made by bitcoinjs contributors and released under MIT license.

This library rely on fork version of [rust-secp256k1](https://github.com/steel97/rust-secp256k1/tree/standalone)

## Getting Started
### Requirements:
- [dart/flutter](https://docs.flutter.dev/get-started/install)
- [rust + cargo](https://www.rust-lang.org/tools/install)

This project uses [CargoKit](https://github.com/irondash/cargokit), see how to use it [here](https://matejknopp.com/post/flutter_plugin_in_rust_with_no_prebuilt_binaries/)

```
# run this to download required dependencies
flutter pub get
```

## Project structure

This template uses the following structure:

* `rust`: Contains the native source code, and a CmakeFile.txt file for building
  that source code into a dynamic library.

* `lib`: Contains the Dart code that defines the API of the plugin, and which
  calls into the native code using `dart:ffi`.

* platform folders (`android`, `ios`, `windows`, etc.): Contains the build files
  for building and bundling the native code library with the platform application.

## Building and bundling native code
Please setup dependencies required by `cargokit`
then, add this repository as submodule to your project.
see example requirements for project that uses this library: [Veil Wallet](https://github.com/steel97/veil_wallet)