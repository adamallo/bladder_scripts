#!/bin/bash

usage="Usage: $0 bam1 bam2 outbam"

if [[ ! -f $1 ]] || [[ ! -f $2 ]]
then
    echo -e $usage
    exit 1
fi

samtools merge $3 $1 $2
