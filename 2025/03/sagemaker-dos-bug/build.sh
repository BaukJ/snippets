#!/usr/bin/env bash
set -ex
cd "$(dirname "${BASH_SOURCE[0]}")"

for tag in $(sed -n "s/^FROM.* AS  *//p" Dockerfile)
do
    echo === Building $tag
    docker build . --target=$tag --tag=$tag
done

