#!/bin/bash
set -euo pipefail

TESTDIR="${1:-}"
RESNAME="${2:-}"

if [ -z "${RESNAME}" ]; then
	echo -e "Usage:\n\t$0 testdir resultname\n"
	exit 2
fi

res_dir="$HOME/results/${RESNAME}"
mkdir -p ${res_dir}

cd "${TESTDIR}"
for test_mode in rndrd rndwr rndrw
do
  for th in 1 2 4 8 16
  do
    echo "Starting benchmark for ${test_mode} threads ${th}"
    sysbench fileio \
             --file-total-size=30G \
             --time=1800 \
             --max-requests=0 \
             --threads=${th} \
             --file-num=64 \
             --file-io-mode=sync \
             --file-test-mode=${test_mode} \
             --file-extra-flags=direct \
             --file-fsync-freq=0 \
             --file-block-size=16384 \
             --report-interval=1 \
             run > "${res_dir}/${test_mode}_${th}.out"
  done
done
