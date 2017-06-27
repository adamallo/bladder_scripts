#!/bin/bash

ind="L"

snvs=($(ls $ind*filtered.recode_filt2.vcf | xargs sed -n '/^#/!p' | awk '{print $1"_"$2}' | sort | uniq))

echo "Sample" ${snvs[@]} | sed "s/ /,/g" > genotypes.csv

for file in $ind*filtered.recode_filt2.vcf
do
    name=$(echo $file | sed "s/_filtered.recode_filt2.vcf//")
    genotype=$({
        for snv in ${snvs[*]}
        do
            grep -c "$(echo $snv | sed "s/_/\t/")" $file
        done | paste -d, -s - 
    })
    echo "$name,$genotype" >> genotypes.csv
done
