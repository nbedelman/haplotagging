#!/usr/bin/env python

#take output from bed_write.pl and generate N10-90, max, min, mean, median

import sys
import os
import statistics
import numpy

moleculeFile=sys.argv[1]
outFile=sys.argv[2]

def getArray(molFile):
    m=open(molFile, "r")
    lengths=[]
    print("reading lengths")
    for line in m:
        atts=line.split()
        length=int(atts[2])-int(atts[1])
        lengths.append(length)
        if len(lengths) % 1000000 == 0:
            print(len(lengths))
    lengths.sort()
    return(lengths)

def binaryN(N,list, total):
    thresh=0.001
    thisCand=list[int(len(list)/2)][1]
    print(thisCand)
    print(N,thisCand, float(thisCand)/total)
    if abs(float(thisCand)/total - N) < thresh:
        return(list[int(len(list)/2)][0])
    elif float(thisCand)/total < N:
        return(binaryN(N, list[int(len(list)/2):],total))
    else:
        return(binaryN(N, list[:int(len(list)/2)],total))

def getStats(sortedLengths, outFile):
    labels=["sample","molecules","totalLength","N10","N20","N30","N40","N50","max","min","mean","median"]
    print("Computing Stats")
    print("Molecules Found:",len(sortedLengths))
    cumLength=numpy.cumsum(sortedLengths)
    combined=[(sortedLengths[i],cumLength[i]) for i in range(len(sortedLengths))]
    totalLength=sum(sortedLengths)
    molecules=len(sortedLengths)
    Ns=[]
    for N in [0.9,0.8,0.7,0.6,0.5]:
        Ns.append(str(binaryN(N,combined, sum(sortedLengths))))

    maximum = round(max(sortedLengths),2)
    minimum = round(min(sortedLengths),2)
    meanVal=round(numpy.mean(sortedLengths),2)
    medianVal=round(numpy.median(sortedLengths),2)
    o=open(outFile, "w")
    o.write(",".join(labels)+"\n")
    o.write('''%s,%i,%i,%s,%f,%f,%f,%f''' % (os.path.basename(moleculeFile),molecules,totalLength,",".join(Ns), maximum, minimum, meanVal, medianVal))
    print('''%s,%i,%i,%s,%f,%f,%f,%f''' % (os.path.basename(moleculeFile),molecules,totalLength,",".join(Ns), maximum, minimum, meanVal, medianVal))
    o.close()

array=getArray(moleculeFile)
getStats(array,outFile)
