# veil_light_plugin

Port of `veil-secp256k1` to `dart/flutter`, based on fork of WASM module [tiny-secp256k1](https://github.com/steel97/tiny-secp256k1) originally made by bitcoinjs contributors and released under MIT license.

This library rely on fork version of [rust-secp256k1](https://github.com/steel97/rust-secp256k1/tree/standalone)

## Getting Started
### Requirements:
- [dart/flutter](https://docs.flutter.dev/get-started/install)
- [rust + cargo](https://www.rust-lang.org/tools/install)
- [CMake](https://cmake.org/download/)

#### Windows:
- visual studio 2022 with c++ support

#### Android:
- [JDK 21](https://jdk.java.net/21/) (release builds are made with openjdk 21 under windows platform)
- [SDK](https://developer.android.com/tools/releases/platform-tools)
- [NDK](https://developer.android.com/ndk)
- or install both sdk and ndk via [Android studio](https://developer.android.com/studio)

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

The `pubspec.yaml` specifies FFI plugins as follows:

```yaml
  plugin:
    platforms:
      some_platform:
        ffiPlugin: true
```

This configuration invokes the native build for the various target platforms
and bundles the binaries in Flutter applications using these FFI plugins.


The native build systems that are invoked by FFI (and method channel) plugins are:

* For Android: Gradle, which invokes the Android NDK for native builds.
  * See the documentation in android/build.gradle.
* For iOS and MacOS: Xcode, via CocoaPods.
  * See the documentation in ios/veil_light_plugin.podspec.
  * See the documentation in macos/veil_light_plugin.podspec.
* For Linux and Windows: CMake.
  * See the documentation in linux/CMakeLists.txt.
  * See the documentation in windows/CMakeLists.txt.


## Flutter help

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

