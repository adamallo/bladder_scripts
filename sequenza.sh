#!/bin/bash
#SBATCH -c 8

usage="Usage: $0 seqzfile ncores"

if [[ ! -f $1 ]]
then
	echo $usage
	exit 1
fi


Rscript $BLADDER_SCRIPTS/sequenza.R $1 $SLURM_CPUS_PER_TASK
