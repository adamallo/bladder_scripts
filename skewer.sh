#!/bin/bash
#SBATCH -c 8

#usage="Usage: $0 bamfile"
usage="Usage: $0 commonname"

#if [[ ! -f $1 ]]
if [[ ! -f ${1}_1.fastq ]] || [[ ! -f ${1}_2.fastq ]]
then
    echo -e $usage
    exit 1
fi

#name=$(echo $1 | sed "s/.bam//g")

#skewer -x AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -y AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTNNNNNNNNGTGTAGATCTCGGTGGTCGCCGTATCATT \
#    -Q 10 -z -t $SLURM_CPUS_PER_TASK -n ${name}_1.fastq ${name}_2.fastq
skewer -x AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -y AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTNNNNNNNNGTGTAGATCTCGGTGGTCGCCGTATCATT \
    -Q 10 -z -t $SLURM_CPUS_PER_TASK -n ${1}_1.fastq ${1}_2.fastq -o ${1}
