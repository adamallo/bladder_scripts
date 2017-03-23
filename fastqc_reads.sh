#!/bin/bash
module load fastqc/0.11.3

usage="Usage: $0 filewithreads"

if [[ ! -f $1 ]]
then
    echo -e $usage
    exit 1
fi

name=$(echo $1 | sed "s/.bam//g")

cp ${name}_1-trimmed-pair1.fastq.gz ${name}-trimmed.fastq.gz
cat ${name}_1-trimmed-pair2.fastq.gz >> ${name}-trimmed.fastq.gz

#cutadapt
#cp ${name}_1_trimmed.fastq.gz ${name}_trimmed.fastq.gz
#cat ${name}_2_trimmed.fastq.gz >> ${name}_trimmed.fastq.gz

fastqc ${name}-trimmed.fastq.gz
