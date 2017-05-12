#!/usr/local/bin/python2
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

players = ["aptyp", "J", "DoctorSinus", "redgremlin", "LongLiveUbuntu", "cetjs2"]
tour_count = 0

# Generate LORCODE for pairings.
# Also generate "reversal" for autumm season.
for pairings in roundRobin(players):
    tours = (len(players) - 1) * 2
    tour_count = tour_count + 1
    print "[b]Тур №" + str(tour_count) + "[/b]"
    print "[list]"
    for pair in pairings:
        print "[*][user]" + pair[0] + "[/user] играет против [user]" + pair[1] + "[/user]"
    print "[/list]"
