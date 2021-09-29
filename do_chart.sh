#!/bin/bash
set -euo pipefail

if [ "$#" -lt "4" ]; then
    echo -e "Usage:\n\t$0 basename fieldname logfile1 logfile2 ...\n"
    exit 1
fi

outname="${1}"
shift
fieldname="${1}"
shift

graphtype="svg"
datafile="${outname}.data"
graphfile="${outname}.${graphtype}"

#
# extract relevant data from inputfiles
tmpfiles=()
for f in "$@"; do
    o="$(dirname $f)-$(basename $f .out).data"
    awk "
        BEGIN { FS=\"${fieldname}[^:]*:\" }
        /\\[ [0-9]*s \\]/ {
            match(\$1, /([0-9]+)s/, time);
            match(\$2, /([0-9.]+)/, val);
            printf(\"%d %f\\n\", time[1], val[1])
        }
    " $f > $o
    tmpfiles+=($o)
done

#
# combine data files
paste "${tmpfiles[@]}" > $datafile

#
# prepare chart lines
lines=""
c="1"
for l in "$@"; do
    [ -n "$lines" ] && lines="$lines, "

    legend="$(dirname $l) $(basename $l .out)"
    legend=${legend##${outname}}
    legend=${legend##*( )}
    legend=${legend//_/ }

    lines="${lines}datafile using ${c}:$((c+1)) title \"$legend\" with lines"
    c=$((c+2))
done

#
# create chart, overwrite if necessary
rm -f ‘$graphfile′

gnuplot << EOP

### set data source file
datafile = '$datafile'

### set graph type and size
set terminal ${graphtype} size 800,600 background rgb "white"

### set titles
set grid x y
set xlabel "Time (sec)"
set ylabel "$fieldname"
set key outside box

### set output filename
set output '$graphfile'

### build graph
# plot datafile with lines
#plot datafile title "fusionio ext4" with lines, \
#datafile using 3:4 title "fusionio ext4-2" with lines, \
#datafile using 5:6 title "fusionio nvmfs" with lines, \
#datafile using 7:8 title "fusionio xfs" with lines
plot $lines

EOP

xviewer $graphfile &
