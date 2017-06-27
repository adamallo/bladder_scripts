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

echo Code,nameA,nameB,indA,indB,privA,privB,common,sim > allSimilarityPASSFilt.csv
files=$(ls -l1 *[ZP]_filt2.vcf | awk 'BEGIN{FS=" "}{print $9}' | paste -s)
files=( $files )
nfiles=${#files[@]}
finalj=$(( $nfiles - 1 ))
n=1

for i in ${files[*]}
do
    nameA=$(echo $i | sed "s/_filt2.vcf//g") 
    indA=$(echo $nameA | sed "s/..$//g")
    for j in `seq $n $finalj`
    do
        nameB=$(echo ${files[$j]} | sed "s/_filt2.vcf//g")
        indB=$(echo $nameB | sed "s/..$//g")
        Code=${nameA}${nameB}
        bcftools isec ${nameA}_filt2.vcf.gz ${nameB}_filt2.vcf.gz -p ${Code}_filt2
        privAFilt=$(sed -n '/^#.*/!p' ${Code}_filt2/0000.vcf | wc -l)
        privBFilt=$(sed -n '/^#.*/!p' ${Code}_filt2/0001.vcf | wc -l)
        commonFilt=$(sed -n '/^#.*/!p' ${Code}_filt2/0002.vcf | wc -l)
        simFilt=$(perl -e "print($commonFilt/($privAFilt+$privBFilt+$commonFilt))")
        echo $Code,$nameA,$nameB,$indA,$indB,$privAFilt,$privBFilt,$commonFilt,$simFilt >> allSimilarityPASSFilt.csv
    done
    n=$(( $n + 1 ))
    
done

files=$(ls -l1 GH*[ZP]_filt2.vcf | awk 'BEGIN{FS=" "}{print $9}' | paste -s)
files=( $files )
nfiles=${#files[@]}
bcftools isec --nfiles =$nfiles GH*[ZP]_filt2.vcf.gz -p GH_filt2
files=$(ls -l1 LH*[ZP]_filt2.vcf | awk 'BEGIN{FS=" "}{print $9}' | paste -s)
files=( $files )
nfiles=${#files[@]}
bcftools isec --nfiles =$nfiles LH*[ZP]_filt2.vcf.gz -p LH_filt2
bcftools isec --nfiles =6 LH1P_filt2.vcf.gz LH2P_filt2.vcf.gz LH3P_filt2.vcf.gz LH4P_filt2.vcf.gz LH6Z_filt2.vcf.gz LH7Z_filt2.vcf.gz -p LH_nobenign
bcftools isec --nfiles =4 LH2P_filt2.vcf.gz LH3P_filt2.vcf.gz LH4P_filt2.vcf.gz LH7Z_filt2.vcf.gz -p LH_malignant
bcftools isec --nfiles =3 LH2P_filt2.vcf.gz LH3P_filt2.vcf.gz LH4P_filt2.vcf.gz -p LH_malignantNF
bcftools isec --nfiles =4 LH3P_filt2.vcf.gz LH7Z_filt2.vcf.gz LH6Z_filt2.vcf.gz LH2P_filt2.vcf.gz -p LH_cluster
