#!/bin/bash
echo "Comparison,SampleA,SampleB,#PrivateA,#PrivateB,#Common,Similarity">pairedSimilarity.csv
echo "Comparison,SampleA,SampleB,#PrivateA,#PrivateB,#Common,Similarity">pairedSimilarityPASS.csv
echo "Comparison,SampleA,SampleB,#PrivateA,#PrivateB,#Common,Similarity">pairedSimilarityPASSFilt.csv
tail -n +2 pairs.csv | while read Patient A B Code Afile Bfile Nfile
do 
	bcftools isec $Patient${A}_filtered.recode.vcf.gz $Patient${B}_filtered.recode.vcf.gz -p ${Code}_filtered
	privAPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0000.vcf | wc -l)
	privBPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0001.vcf | wc -l)
	commonPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0002.vcf | wc -l)
	simPass=$(perl -e "print($commonPass/($privAPass+$privBPass+$commonPass))")
	echo $Code,$Patient${A},$Patient${B},$privAPass,$privBPass,$commonPass,$simPass >> pairedSimilarityPASS.csv
	
	bcftools isec $Patient${A}.vcf.gz $Patient${B}.vcf.gz -p ${Code}
	privA=$(sed -n '/^#.*/!p' $Code/0000.vcf | wc -l)
	privB=$(sed -n '/^#.*/!p' $Code/0001.vcf | wc -l)
	common=$(sed -n '/^#.*/!p' $Code/0002.vcf | wc -l)
	sim=$(perl -e "print($common/($privA+$privB+$common))")
	echo $Code,$Patient${A},$Patient${B},$privA,$privB,$common,$sim >> pairedSimilarity.csv
	
	bcftools isec $Patient${A}_filt2.vcf.gz $Patient${B}_filt2.vcf.gz -p ${Code}_filt2
	privAFilt=$(sed -n '/^#.*/!p' ${Code}_filt2/0000.vcf | wc -l)
	privBFilt=$(sed -n '/^#.*/!p' ${Code}_filt2/0001.vcf | wc -l)
	commonFilt=$(sed -n '/^#.*/!p' ${Code}_filt2/0002.vcf | wc -l)
	simFilt=$(perl -e "print($commonFilt/($privAFilt+$privBFilt+$commonFilt))")
	echo $Code,$Patient${A},$Patient${B},$privAFilt,$privBFilt,$commonFilt,$simFilt >> pairedSimilarityPASSFilt.csv
	
done
