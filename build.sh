#!/usr/bin/env zsh

set -e

Self=$(cd "$(dirname "$0")";pwd)

pushd $Self

tag=$1
if [ "$tag" = "" ]; then
  tag="openssl-3.0.1"
fi

[ -d openssl ] && rm -rf openssl

git clone --depth=1 -b $tag https://github.com/openssl/openssl.git openssl

cp -f 15-ios.conf openssl/Configurations/15-ios.conf

pushd openssl
cp ../build-ios-xcframework.sh ./
./build-ios-xcframework.sh
cp -r out/OpenSSL.xcframework $Self/
popd

popd
