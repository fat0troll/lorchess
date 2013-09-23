#!/usr/bin/env bash

myname=iVS
repo=fat0troll/lorchess
tournament=autumn2013

# Colors
green='\\033[01;32m'
red='\\033[01;31m'
restore='\\033[00m'

# Note that we use `"$@"' to let each command-line parameter expand to a
# separate word. The quotes around `$@' are essential!
# We need ARGS as the `eval set --' would nuke the return value of getopt.
args=`getopt --options p: --longoptions player: -- "$@"`

# Note the quotes around `$ARGS': they are essential!
eval set -- "$args"

if [[ $1 == -p ]] || [[ $1 == --player ]]; then
    name=$2
    shift 3
else
    name=$myname
    shift
fi

for tour in $@; do
    # Change tour numbers: `1' -> `01', `2' -> `02', and so on
    tour=0"$tour"
    tour=${tour:(-2)}

    url=https://raw.github.com/$repo/master/$tournament/tour_$tour/tour_info

    echo ">>>"
    curl -q --silent $url | egrep "Тур|Время|$name" | while read line;do
        # Colorize the player name
        output=$(echo $line | sed "s/${name}/${red}${name}${restore}/g")
        echo -e $output
    done
done
