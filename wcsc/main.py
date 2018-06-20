#!/usr/bin/env python3
import curses
from time import sleep

COLUMNS = 40
ROWS = 30

side = 60
top = 126
bottom = 95


def func(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.init_pair(1, curses.COLOR_BLUE, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_WHITE, curses.COLOR_BLACK)
    stdscr.refresh()
    sleep(5)


if __name__ == '__main__':
    curses.wrapper(func)
