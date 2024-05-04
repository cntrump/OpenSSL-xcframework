# OpenSSL-xcframework

OpenSSL.xcframework for iOS developers

- [x] iOS 11.0+ (`arm64`)
- [x] iOS simulator 11.0+ (`x86_64` and `arm64`)
- [x] macOS 10.15+ (MacCatalyst) (`x86_64` and `arm64`)

## How to build

Build openssl 1.1.x

```
./build.sh OpenSSL_1_1_1m
```

Build openssl 3.x

```
./build.sh openssl-3.0.1
```

`OpenSSL_1_1_1m` and `openssl-3.0.1` are [openssl tags](https://github.com/openssl/openssl/tags)

## About modulemap

```
framework module OpenSSL [system] [extern_c] {
    umbrella header "OpenSSL.h"
    export *
    module * { export * }
}
```

`[system]` fix issue `import OpenSSL` for Swift:

```
openssl.framework/Headers/e_os2.h:243:12: Include of non-modular header inside framework module 'OpenSSL.e_os2': '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/clang/include/inttypes.h'
```

https://clang.llvm.org/docs/Modules.html

> The `system` attribute specifies that the module is a system module. When a system module is rebuilt, all of the module’s headers will be considered system headers, which suppresses warnings. 
