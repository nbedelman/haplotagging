#!/usr/bin/env python

import sys
import random

fileList=sys.argv[1]
numPairs=int(sys.argv[2])
outFile=sys.argv[3]


def makePairs(fileList, numPairs, outFile):
    o=open(outFile, "w")
    i=open(fileList, "r")

    allFiles=[]
    for line in i:
        allFiles.append(line.strip())

    for j in range(numPairs):
        thisPair=random.sample(allFiles, k=2)
        o.write('''%s\t%s\n''' % (thisPair[0],thisPair[1]))

makePairs(fileList, numPairs, outFile)
