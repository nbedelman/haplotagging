#/usr/bin/env python

import sys
import os

vcfFile=sys.argv[1]
outFile=sys.argv[2]

def getGen(vcfFile,outFile):
    v=open(vcfFile, "r")
    o=open(outFile, "w")
    GTDict={"0/0":"0", "0/1":"1", "1/0":"1", "1/1":"2", "./.":"NA"}
    for line in v:
        if "##" in line:
            pass
        elif line.startswith("#CHROM"):
            atts=line.strip().split()
            names=atts[9:]
            simpNames=["_".join(os.path.basename(i).split("_")[0:2]) for i in names]
            o.write("\t".join(simpNames)+"\n")
        else:
            GTs=[]
            atts=line.strip().split()
            infoStrings=atts[9:]
            for i in infoStrings:
                code=i.split(":")[0]
                try:
                    GT=GTDict[code]
                except KeyError:
                    print(line)
                GTs.append(GT)
            o.write("\t".join(GTs)+"\n")
    o.close()

getGen(vcfFile,outFile)
