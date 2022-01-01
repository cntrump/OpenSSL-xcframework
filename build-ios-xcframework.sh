#!/usr/bin/env zsh

set -e

export IPHONEOS_DEPLOYMENT_TARGET=9.0

target=$(cd "$(dirname "$0")";pwd)

[ -d "${target}/out" ] && rm -rf "${target}/out"

build_openssl_lib() {
    ./Configure $@

    make clean
    make -j
    make install
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

xcrun_clang=$(xcrun --find clang)

build_openssl_lib --prefix="${target}/out/ios-arm64/OpenSSL.framework" \
                    ios64-xcrun \
                    CC=${xcrun_clang}

export ARCHS="arm64;x86_64"

build_openssl_lib --prefix="${target}/out/ios-arm64_x86_64-simulator/OpenSSL.framework" \
                    iossimulator-xcrun \
                    CC=${xcrun_clang}

export IPHONEOS_DEPLOYMENT_TARGET=13.0

build_openssl_lib --prefix="${target}/out/ios-arm64_x86_64-maccatalyst/OpenSSL.framework" \
                    maccatalyst-xcrun \
                    CC=${xcrun_clang}

build_openssl_framework "${target}/out/ios-arm64/OpenSSL.framework"
build_openssl_framework "${target}/out/ios-arm64_x86_64-simulator/OpenSSL.framework"
build_openssl_framework "${target}/out/ios-arm64_x86_64-maccatalyst/OpenSSL.framework"

xcodebuild -create-xcframework \
           -framework "${target}/out/ios-arm64/OpenSSL.framework" \
           -framework "${target}/out/ios-arm64_x86_64-simulator/OpenSSL.framework" \
           -framework "${target}/out/ios-arm64_x86_64-maccatalyst/OpenSSL.framework" \
           -output \
           "${target}/out/OpenSSL.xcframework"

cleanup "${target}/out/ios-arm64" \
        "${target}/out/ios-arm64_x86_64-simulator" \
        "${target}/out/ios-arm64_x86_64-maccatalyst"
