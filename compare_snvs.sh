#!/bin/bash

echo "Comparison,SampleA,SampleB,#PrivateA,#PrivateB,#Common,Similarity">pairedSimilarity.csv
echo "Comparison,SampleA,SampleB,#PrivateA,#PrivateB,#Common,Similarity">pairedSimilarityPASS.csv
echo "Comparison,SampleA,SampleB,#PrivateA,#PrivateB,#Common,Similarity">pairedSimilarityPASSFilt.csv
tail -n +2 pairs.csv | while read Patient A B Code Afile Bfile Nfile
do 
    bcftools isec $Patient${A}_filtered.recode.vcf.gz $Patient${B}_filtered.recode.vcf.gz -p ${Code}_filtered
    bcftools isec $Patient${A}.vcf.gz $Patient${B}.vcf.gz -p ${Code}
    bcftools isec $Patient${A}_filtered.recode_filt2.vcf.gz $Patient${B}_filtered.recode_filt2.vcf.gz -p ${Code}_filtered2
    privA=$(sed -n '/^#.*/!p' $Code/0000.vcf | wc -l)
    privB=$(sed -n '/^#.*/!p' $Code/0001.vcf | wc -l)
    common=$(sed -n '/^#.*/!p' $Code/0002.vcf | wc -l)
    sim=$(perl -e "print($common/($privA+$privB+$common))")

    privAPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0000.vcf | wc -l)
    privBPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0001.vcf | wc -l)
    commonPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0002.vcf | wc -l)
    simPass=$(perl -e "print($commonPass/($privAPass+$privBPass+$commonPass))")
    echo $Code,$Patient${A},$Patient${B},$privA,$privB,$common,$sim >> pairedSimilarity.csv
    echo $Code,$Patient${A},$Patient${B},$privAPass,$privBPass,$commonPass,$simPass >> pairedSimilarityPASS.csv

    privAPassFilt=$(sed -n '/^#.*/!p' ${Code}_filtered2/0000.vcf | wc -l)
    privBPassFilt=$(sed -n '/^#.*/!p' ${Code}_filtered2/0001.vcf | wc -l)
    commonPassFilt=$(sed -n '/^#.*/!p' ${Code}_filtered2/0002.vcf | wc -l)
    simPassFilt=$(perl -e "print($commonPassFilt/($privAPassFilt+$privBPassFilt+$commonPassFilt))")
    echo $Code,$Patient${A},$Patient${B},$privAPassFilt,$privBPassFilt,$commonPassFilt,$simPassFilt >> pairedSimilarityPASSFilt.csv
done
