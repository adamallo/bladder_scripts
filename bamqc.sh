#!/bin/bash
module load fastqc/0.11.3

usage="Usage: $0 bam"

if [[ ! -f $1 ]]
then
    echo -e $usage
    exit 1
fi

name=$(echo $1 | sed "s/.bam//g")

mkdir ${name}_fastqc
mkdir ${name}_bamqc
fastqc ${name}.bam -o ${name}_fastqc
bamqc ${name}.bam -o ${name}_bamqc
mapDamage -i ${name}.bam -r $HUMAN_GENOME --folder ${name}_mapdamage
