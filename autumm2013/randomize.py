#!/usr/bin/python2
# -*- coding: utf-8 -*-

import random, time

def write_user(username, table_size):
    repeater = False
    random_seed = random.choice(range(1, table_size))
    tfile = open('table.txt', 'r+a')
    tabledata = tfile.readlines()
    for line in tabledata:
        if line.split(' | ')[0] == str(random_seed):
            # repeat from begin
            repeater = True
            write_user(username, table_size)
    # if we haven't matching number, write das line
    if repeater == False:
        tfile.write("%i | %s\n" % (random_seed, username))

def check_file(username, table_size):
    try:
        tablefile = open('table.txt', 'r')
        write_user(username, table_size)
    except IOError:
        tablefile = open('table.txt', 'w')
        tablefile.write("Жеребьевка участников LORChess.\nРазмер таблицы участников: %s.\nДанный файл является неизменяемым и создаваемым один раз.\nUNIX timestamp: %i\n========\n\n" % (table_size - 1, int(time.time())))
        tablefile.close()
        write_user(username, table_size)


nickname = raw_input("Введите имя игрока: ")
check_file(nickname, 19)
