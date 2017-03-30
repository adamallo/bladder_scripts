##Reference
samtools index GRCh37-lite.fa

##Mutect2

#Cosmic 
#Data obtained from cosmic website
#Needs gatk's sortByRef.pl script
gunzip CosmicCodingMuts.vcf.gz
gunzip CosmicNonCodingVariants.vcf.gz
grep "^#" CosmicCodingMuts.vcf > Cosmic_VCF_Header
grep -v "^#" CosmicCodingMuts.vcf > Coding.clean
grep -v "^#" CosmicNonCodingVariants.vcf > NonCoding.clean
cat Coding.clean NonCoding.clean | sort -gk 2,2 | sortByRef.pl --k 1 - GRCh37-lite.fa.fai >> cosmic.b37.vcf
rm Cosmic_VCF_Header Coding.clean NonCoding.clean

#dbSNP
#Obtained from Broad's resource bundle
gunzip dbsnp_138.b37.vcf.gz
gunzip dbsnp_138.b37.vcf.idx.gz

##Sequenza

##Genome 50-bpwindow GC content
sequenza-utils.py GC-windows -w 50 GRCh37-lite.fa | gzip > b37.gc50Base.txt.gz
