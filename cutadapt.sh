#!/bin/bash
usage="Usage: $0 bamfile"

if [[ ! -f $1 ]]
then
    echo -e $usage
    exit 1
fi

name=$(echo $1 | sed "s/.bam//g")

cutadapt \
            -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC \
            -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTNNNNNNNNGTGTAGATCTCGGTGGTCGCCGTATCATT \
            -o ${name}_1_trimmed.fastq.gz -p ${name}_2_trimmed.fastq.gz \
            ${name}_1.fastq ${name}_2.fastq
