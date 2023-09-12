#!/usr/bin/python

import sys

for fn in sys.argv[1:]:
    with open(fn) as fh:
        try:
            c = fh.read()
            a = c[0]
            if a !='@': print(f"{fn} error: first char not @", file=sys.stderr)
            print(c)
            print()
        except UnicodeDecodeError:
            print(f"{fn} error", file=sys.stderr)
