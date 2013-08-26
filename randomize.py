#!/usr/bin/python2
# -*- coding: utf-8 -*-

import random

# TODO: вернуться, отладить

def write_user(username, table_size):
    random_seed = random.choice(range(1, table_size))
    tfile = open('table.txt', 'a+r')
    tabledata = tfile.readlines()
    for line in tabledata:
        if line.split(' | ')[0] == str(random_seed):
            # repeat from begin
            write_user(username, table_size)
    # if we haven't matching number, write das line
    tfile.write("%i | %s\n" % (random_seed, username))

def check_file(username, table_size):
    try:
        tablefile = open('table.txt', 'r')
        write_user(username, table_size)
    except IOError:
        tablefile = open('table.txt', 'w')
        tablefile.write("Рандомизатор: составление таблицы методом случайных чисел.\nРазмер таблицы: %s\n\n========\n\n" % table_size)
        tablefile.close()
        write_user(username, table_size)


nickname = raw_input("Введите имя игрока: ")
check_file(nickname, 17)
