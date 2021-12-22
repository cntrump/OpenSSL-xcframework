#!/usr/bin/env zsh

set -e

Self=$(cd "$(dirname "$0")";pwd)

pushd $Self

tag=$1
if [ "$tag" = "" ]; then
  tag="openssl-3.0.1"
fi

[ -d "$tag" ] && rm -rf "$tag"

git clone --depth=1 -b $tag https://github.com/openssl/openssl.git "$tag/openssl"

cp -f 15-ios.conf "$tag/openssl/Configurations/15-ios.conf"

pushd "$tag/openssl"
cp ../../build-ios-xcframework.sh ./
./build-ios-xcframework.sh
cp -r out/OpenSSL.xcframework ../
popd

popd

if [ -d "$tag/OpenSSL.xcframework" ]; then
  echo -e "\033[34m$tag/OpenSSL.xcframework\033[0m created."
fi
