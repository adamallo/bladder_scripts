#!/bin/bash
module load picard/2.3.0
usage="Usage: $0 bamfile"

if [[ ! -f $1 ]]
then
    echo -e $usage
    exit 1
fi

name=$(echo $1 | sed "s/.bam//g")
mkdir $name
picard SamToFastq OUTPUT_PER_RG=true INCLUDE_NON_PF_READS=true I=$1 OUTPUT_DIR=${name}
#picard SamToFastq I=$1 FASTQ=${name}_1.fastq SECOND_END_FASTQ=${name}_2.fastq
