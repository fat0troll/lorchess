#!/usr/bin/env bash

mynick=iVS
repo=fat0troll/lorchess
tournament=autumn2013

# Note that we use `"$@"' to let each command-line parameter expand to a
# separate word. The quotes around `$@' are essential!
# We need ARGS as the `eval set --' would nuke the return value of getopt.
args=`getopt --options n: --longoptions nick: -- "$@"`

# Note the quotes around `$ARGS': they are essential!
eval set -- "$args"

if [[ $1 == -n ]] || [[ $1 == --nick ]]; then
    name=$2
    shift 3
else
    name=$mynick
    shift
fi

for tour in $@; do
    # Change tour numbers: `1' -> `01', `2' -> `02', and so on
    tour=0"$tour"
    tour=${tour:(-2)}

    url=https://raw.github.com/$repo/master/$tournament/tour_$tour/tour_info
    curl -q --silent $url | egrep "Тур|Время|$name"
    echo " ***"
done
