#!/usr/bin/env zsh

set -e

target=$(cd "$(dirname "$0")";pwd)

[ -d "${target}/out" ] && rm -rf "${target}/out"

build_openssl_lib() {
    ./Configure enable-tls1_3 no-tests no-shared $@

    make clean
    make -j
    make install_sw
}

write_openssl_modulemap() {
    echo "framework module OpenSSL [system] [extern_c] {" > $1
    echo "    umbrella header \"OpenSSL.h\"" >> $1
    echo "    export *" >> $1
    echo "    module * { export * }" >> $1
    echo "}" >> $1
}

build_openssl_framework() {
    pushd "$1"
    rm -rf bin share ssl
    mv include/openssl Headers
    rm -rf include
    libtool -static -o OpenSSL lib/libcrypto.a lib/libssl.a
    rm -rf lib
    mkdir Modules
    write_openssl_modulemap Modules/module.modulemap

    pushd Headers
    for h in *.h
    do
        if [ "${h}" = "asn1_mac.h" ]; then
            rm "asn1_mac.h"
            continue
        fi

        echo "#import <OpenSSL/${h}>" >> ../OpenSSL.h
    done
    mv ../OpenSSL.h ./
    popd

    popd
}

cleanup() {
    rm -rf $@
}

build_openssl_lib --prefix="${target}/out/macos-arm64_x86_64/OpenSSL.framework" \
                    apple-universal-macosx

build_openssl_lib --prefix="${target}/out/ios-arm64/OpenSSL.framework" \
                    apple-universal-ios

build_openssl_lib --prefix="${target}/out/ios-arm64_x86_64-simulator/OpenSSL.framework" \
                    apple-universal-iossim

build_openssl_lib --prefix="${target}/out/ios-arm64_x86_64-maccatalyst/OpenSSL.framework" \
                    apple-universal-maccatalyst

build_openssl_lib --prefix="${target}/out/tvos-arm64/OpenSSL.framework" \
                    apple-universal-tvos

build_openssl_lib --prefix="${target}/out/tvos-arm64_x86_64-simulator/OpenSSL.framework" \
                    apple-universal-tvossim

build_openssl_lib --prefix="${target}/out/xros-arm64/OpenSSL.framework" \
                    apple-universal-visionos

build_openssl_lib --prefix="${target}/out/xros-arm64_x86_64-simulator/OpenSSL.framework" \
                    apple-universal-visionossim

build_openssl_framework "${target}/out/macos-arm64_x86_64/OpenSSL.framework"
build_openssl_framework "${target}/out/ios-arm64/OpenSSL.framework"
build_openssl_framework "${target}/out/ios-arm64_x86_64-simulator/OpenSSL.framework"
build_openssl_framework "${target}/out/ios-arm64_x86_64-maccatalyst/OpenSSL.framework"
build_openssl_framework "${target}/out/tvos-arm64/OpenSSL.framework"
build_openssl_framework "${target}/out/tvos-arm64_x86_64-simulator/OpenSSL.framework"
build_openssl_framework "${target}/out/xros-arm64/OpenSSL.framework"
build_openssl_framework "${target}/out/xros-arm64_x86_64-simulator/OpenSSL.framework"

xcodebuild -create-xcframework \
           -framework "${target}/out/macos-arm64_x86_64/OpenSSL.framework" \
           -framework "${target}/out/ios-arm64/OpenSSL.framework" \
           -framework "${target}/out/ios-arm64_x86_64-simulator/OpenSSL.framework" \
           -framework "${target}/out/ios-arm64_x86_64-maccatalyst/OpenSSL.framework" \
           -framework "${target}/out/tvos-arm64/OpenSSL.framework" \
           -framework "${target}/out/tvos-arm64_x86_64-simulator/OpenSSL.framework" \
           -framework "${target}/out/xros-arm64/OpenSSL.framework" \
           -framework "${target}/out/xros-arm64_x86_64-simulator/OpenSSL.framework" \
           -output \
           "${target}/out/OpenSSL.xcframework"

cleanup "${target}/out/macos-arm64_x86_64" \
        "${target}/out/ios-arm64" \
        "${target}/out/ios-arm64_x86_64-simulator" \
        "${target}/out/ios-arm64_x86_64-maccatalyst" \
        "${target}/out/tvos-arm64" \
        "${target}/out/tvos-arm64_x86_64-simulator" \
        "${target}/out/xros-arm64" \
        "${target}/out/xros-arm64_x86_64-simulator"
