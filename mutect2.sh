#!/bin/bash

usage="Usage: $0 tumor normal outname"

if [[ $# -ne 3 ]] || [[ ! -f $1 ]] || [[ ! -f $2 ]]
then
    echo -e $usage
    exit 1
fi

#nameF=$(echo $File | sed "s/.bam/_trimmed_mdups.bam/")
#nameN=$(echo $Nfile | sed "s/.bam/_trimmed_mdups.bam/")

gatk -T MuTect2 -R $HUMAN_GENOME -I:tumor $1 -I:normal $2 --dbsnp $DBSNP --cosmic $COSMIC -o $3.vcf
