#!/usr/bin/env python
import sys, re

with open(sys.argv[1], 'r') as f:
    for line in f.readlines():
        pyc = re.findall(': ', line.strip())
        if len(pyc) > 3: print pyc, line
        
        # try:
        #     print(pyc[1])
        # except:
        #     pass
