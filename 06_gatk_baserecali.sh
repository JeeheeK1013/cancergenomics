#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=base_recalibrate
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/baserecali_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/baserecali_%j.e
#SBATCH --partition=pshort_el8

#set path
INDIR=/data/users/jkim2/cancergenomics_course/results/markduplicate
OUTDIR=/data/users/jkim2/cancergenomics_course/results/bqsr

#data path
KNOWN_DBSNP=/data/users/jkim2/cancergenomics_course/rawdata/dbsnp/GCF_000001405.40_alias.vcf.gz 
KNOWN_INDELS=/data/users/jkim2/cancergenomics_course/rawdata/known_indels/resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf.gz 
REF=/data/users/jkim2/cancergenomics_course/rawdata/bwa_idx/genome.fa

#Container path
GATK_SIF=/containers/apptainer/gatk_latest.sif  # revision need

# run base recalibrate

for SAMPLE in normal tumor; do

apptainer exec \
  --bind /data \
  GATK_SIF \
  gatk BaseRecalibrator \
	-R $REF \
	-I $INDIR/${SAMPLE}_marked.bam \
	--known-sites $KNOWN_DBSNP \
	--known-sites $KNOWN_INDELS \
	-O "$OUTDIR/${SAMPLE}_recal.table"

done
