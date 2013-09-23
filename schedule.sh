#!/usr/bin/env bash

repo=fat0troll/lorchess
tournament=autumn2013

# Variables
score='\(0\|1\|0\.5\):\(0\|1\|0\.5\)'

# Colors
green='\\033[01;32m'
red='\\033[01;31m'
restore='\\033[00m'

# Note that we use `"$@"' to let each command-line parameter expand to a
# separate word. The quotes around `$@' are essential!
# We need ARGS as the `eval set --' would nuke the return value of getopt.
args=$(getopt --options p: --longoptions player: -- "$@")

# Note the quotes around `$ARGS': they are essential!
eval set -- "$args"

if [[ $1 == -p || $1 == --player ]];then
    name=$2
    shift 2
fi
shift

for tour in $@; do
    # Change tour numbers: `1' -> `01', `2' -> `02', and so on
    tour=0"$tour"
    tour=${tour:(-2)}

    url=https://raw.github.com/$repo/master/$tournament/tour_$tour/tour_info

    echo ">>>"
    curl -q --silent $url | while read line;do
        if [[ -z $line ]];then
            echo
        elif [[ -z $name || `echo "$line" | egrep "Тур|=|Время|$name"` ]];then
            # Colorize output
            line=$(echo "$line" | sed "s/${score}/${green}\0${restore}/g")
            [[ -n $name ]] && line=$(echo "$line" | sed "s/${name}/${red}\0${restore}/g")
            echo -e $line
        fi
    done
done
