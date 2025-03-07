#!/usr/bin/env bash
set -ex
cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p logs
for tag in $(sed -n "s/^FROM.* AS  *//p" Dockerfile)
do
    log_file="logs/$t-$(date +%Y%m%d_%H%M).log"
    echo "=== Running $tag (kill once finished) -> $log_file"
    docker run --rm -it -p 8888:8888 $t |& tee "$log_file"
done

