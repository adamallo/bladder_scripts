##Download 
wget --user=USER --password=PASS --recursive --no-parent --continue --reject=‘index.html*’ -nH --cut-dirs=1 -e robots=off 'https://xfer.genome.wustl.edu/gxfer1/36247878133236/'

##MD5 check
for i in *.md5; do name=$(echo $i | sed "s/.md5//");echo $(cat $i | awk '{print $1}') " $name" | md5sum -c -;done > out.md

##QC 1
fastqc -t 8 *.bam

##FromBAMtoFASTQC
for i in *.bam; do submit bladder_scripts/bamtofastq.sh $i;done

## Trimming adaptors
#for i in *.bam; do submit bladder_scripts/cutadapt.sh $i;done
#for i in *.bam; do submit bladder_scripts/skewer.sh $i;done
for i in *[^ds].bam; do name=$(echo $i | sed "s/.bam//");if [[ -d $name ]]; then files=($(ls $name | sed "s/\(.*\)_.\.fastq/$name\/\\1/g" | uniq));for torun in ${files[*]};do submit bladder_scripts/skewer.sh $torun;done;fi;done

##Mapping
#for i in *[^d].bam; do submit bladder_scripts/bwamem.sh $i;done
##Note: the strange sed is due to a weird problem with the name encode out of skewer
for i in *[^ds].bam; do name=$(echo $i | sed "s/.bam//");if [[ -d $name ]]; then files=($(ls -1 $name/*-pair1.fastq.gz | sed "s/\(.*\)-pair1.fastq.gz/\\1/g"));for torun in ${files[*]};do name=$(echo $torun | sed -e "s/\[38;5;9m//g" -e "s/\[0m//g" -e "s/\[m//g" -e "s/\x1B//g" -e "s/\[K//g"); if [[ -f ${name}-pair1.fastq.gz ]]; then submit bladder_scripts/bwamem.sh $name;fi;done;fi;done

##Merging the two bams per sample (two readgroups)
for i in *[^ds].bam; do name=$(echo $i | sed "s/.bam//");if [[ -d $name ]]; then files=($(ls -1 $name/*.bam));if [[ ${#files[@]} -eq 2 ]];then submit bladder_scripts/mergebams.sh ${files[0]} ${files[1]} $name/${name}.bam;else echo "Error in $name";fi;fi;done

##MarkDuplicates
for i in *;do if [[ -d $i ]]; then name=$(basename $i); if [[ -f $i/${name}.bam ]]; then echo submit bladder_scripts/markduplicates.sh $i/${name}.bam;fi;fi;done

##QC 2
for i in */*mdups.bam; do submit bladder_scripts/bamqc.sh $i;done

##Mutect2
tail -n +2 files.csv | while read Patient Sample Code File Nfile; do folderF=$(echo $File | sed "s/.bam//");nameF=$(echo $folderF | sed "s/^.*\///");nameF="$folderF/${nameF}_mdups.bam";folderN=$(echo $Nfile | sed -e "s/.bam//");nameN=$(echo $folderN | sed "s/^.*\///");nameN="$folderN/${nameN}_mdups.bam";submit bladder_scripts/mutect2.sh $nameF $nameN $Code;done

##Seqz Generation ##Working here

for i in */*mdups.bam; do submit bladder_scripts/generatepileups.sh $i;done

tail -n +2 files.csv | while read Patient Sample Code File Nfile; do folderF=$(echo $File | sed "s/.bam//");nameF=$(echo $folderF | sed "s/^.*\///");nameF="$folderF/${nameF}_mdups.bam";folderN=$(echo $Nfile | sed -e "s/.bam//");nameN=$(echo $folderN | sed "s/^.*\///");nameN="$folderN/${nameN}_mdups.bam";submit bladder_scripts/preprocess_sequenza.sh $nameF $nameN $Code;done

##Mutect2 analyses
##Numeric comparison of groups
echo id,totalsnvs,passsnvs,filtsnvs > snvs.csv;for i in *[ZP].vcf; do name=$(echo $i| sed "s/.vcf//g");echo $name,$(sed -n '/^#.*/!p' $i | wc -l),$(sed -n "/PASS/p" $i |wc -l),$(java -jar /home/dmalload/my_etc/bin/snpEff/SnpSift.jar filter "(FILTER = 'PASS') && (GEN[0].AF > 0.1) && (GEN[0].AD[1] > 5)" $i | sed -n '/^#.*/!p' | wc -l)>> snvs.csv; done

##Similarity between pairs
for i in *[ZP].vcf; do name=$(echo $i| sed "s/.vcf//g"); vcftools --vcf $i --out ${name}_filtered --remove-filtered-all --recode;done
for i in *[ZP].vcf; do name=$(echo $i| sed "s/.vcf//g"); java -jar /home/dmalload/my_etc/bin/snpEff/SnpSift.jar filter "(FILTER = 'PASS') && (GEN[0].AF > 0.1) && (GEN[0].AD[1] > 5)" $i > ${name}_filt2.vcf;done
for i in *.vcf; do cat $i | bladder_scripts/bgziptabix ${i}.gz;done
echo "Comparison,SampleA,SampleB,#PrivateA,#PrivateB,#Common,Similarity">pairedSimilarity.csv;echo "Comparison,SampleA,SampleB,#PrivateA,#PrivateB,#Common,Similarity">pairedSimilarityPASS.csv;tail -n +2 pairs.csv | while read Patient A B Code Afile Bfile Nfile; do bcftools isec $Patient${A}_filtered.recode.vcf.gz $Patient${B}_filtered.recode.vcf.gz -p ${Code}_filtered;bcftools isec $Patient${A}.vcf.gz $Patient${B}.vcf.gz -p ${Code}; privA=$(sed -n '/^#.*/!p' $Code/0000.vcf | wc -l);privB=$(sed -n '/^#.*/!p' $Code/0001.vcf | wc -l);common=$(sed -n '/^#.*/!p' $Code/0002.vcf | wc -l);sim=$(perl -e "print($common/($privA+$privB+$common))");privAPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0000.vcf | wc -l);privBPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0001.vcf | wc -l);commonPass=$(sed -n '/^#.*/!p' ${Code}_filtered/0002.vcf | wc -l);simPass=$(perl -e "print($commonPass/($privAPass+$privBPass+$commonPass))");echo $Code,$Patient${A},$Patient${B},$privA,$privB,$common,$sim >> pairedSimilarity.csv;echo $Code,$Patient${A},$Patient${B},$privAPass,$privBPass,$commonPass,$simPass >> pairedSimilarityPASS.csv;done
