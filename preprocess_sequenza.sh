#!/bin/bash
#SBATCH --mem 10000

module unload python
module load pypy27/5.6

usage="Usage: $0 tumor normal outname"

if [[ $# -ne 3 ]] || [[ ! -f $1 ]] || [[ ! -f $2 ]]
then
    echo -e $usage
    exit 1
fi

gcfile="$(dirname $HUMAN_GENOME)/b37.gc50Base.txt.gz"
dir=$(dirname $1)

pypy `which sequenza-utils.py` pileup2seqz -gc $gcfile -t $1 -n $2 | gzip > $dir/$3_temp.seqz.gz
#pypy `which sequenza-utils.py` bam2seqz -gc $gcfile --fasta $HUMAN_GENOME -t $1 -n $2 | gzip > $dir/$3_temp.seqz.gz
pypy `which sequenza-utils.py` seqz-binning -w 50 -s $dir/$3_temp.seqz.gz | gzip > $dir/$3.seqz.gz
#rm -f $dir/$3_temp.seqz.gz
