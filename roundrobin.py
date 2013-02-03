#!/usr/bin/python2
# -*- coding: utf-8 -*-
def roundRobin(units, sets=None):
    """ Generates a schedule of "fair" pairings from a list of units """
    if len(units) % 2:
        units.append(None)
    count    = len(units)
    sets     = sets or (count - 1)
    half     = count / 2
    schedule = []
    for turn in range(sets):
        pairings = []
        for i in range(half):
            pairings.append((units[i], units[count-i-1]))
        units.insert(1, units.pop())
        schedule.append(pairings)
    return schedule

# LOR sheduler

players = [
    "[user]alfix[/user]", 
    "[user]cinyflo[/user]", 
    "[user]dk-[/user]", 
    "[user]DNA_Seq[/user]",
    "[user]DoctorSinus[/user]",
    "[user]Felagund[/user]",
    "[user]Genuine[/user]",
    "[user]Google-ch[/user]",
    "[user]HunOL[/user]",
    "[user]J[/user]",
    "[user]LongLiveUbuntu[/user]",
    "[user]Michkova[/user]",
    "[user]onetwothreezeronine[/user]",
    "[user]q9[/user]",
    "[user]redgremlin[/user]",
    "[user]pylin[/user]",
    "[user]Rosko[/user]",
    "[user]shell-script[/user]",
    "[user]Solace[/user]",
    "[user]trex6[/user]",
    "[user]UVV[/user]",
    "[user]XoFfiCEr[/user]",
    "[user]William[/user]",
    "[user]Zodd[/user]"
]
tour_count = 0

# Generate LORCODE for pairings.
# Also generate "reversal" for autumm season.
for pairings in roundRobin(players):
    tours = (len(players) - 1) * 2
    tour_count = tour_count + 1
    print "[b]Тур №" + str(tour_count) + "[/b]"
    print "[list]"
    for pair in pairings:
        print "[*]" + pair[0] + " играет против " + pair[1]
    print "[/list]"
    print "[b]Тур №" + str(tours - tour_count + 1) + "[/b]"
    print "[list]"
    for pair in pairings:
        print "[*]" + pair[1] + " играет против " + pair[0]
    print "[/list]"
