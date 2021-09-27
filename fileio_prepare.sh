#!/bin/bash
set -euo pipefail

TESTDIR="${1:-}"

if [ -z "${TESTDIR}" ]; then
	echo -e "Usage:\n\t$0 testdir\n"
	exit 2
fi

mkdir -p "${TESTDIR}"
cd "${TESTDIR}"

sysbench --test=fileio \
         --file-total-size=30G \
         --threads=16 \
         --file-num=64 \
         --file-block-size=16384 \
         prepare
