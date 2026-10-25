#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=base_recalibrate
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/baserecali_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/baserecali_%j.e
#SBATCH --partition=pshort_el8

# directory
WORKDIR=/data/users/jkim2/cancergenomics_course/rawdata/VAR_CALLING
INPUTDIR=/data/users/jkim2/cancergenomics_course/results/markduplicate
OUTDIR=/data/users/jkim2/cancergenomics_course/results/bqsr
KNOWN_DBSNP=$WORKDIR/dbsnp/GCF_000001405.40_alias.vcf.gz 
KNOWN_INDELS=$WORKDIR/known_indels/resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf.gz 
REF=$WORKDIR/bwa_idx/genome.fa

#Container path
GATK_SIF=/containers/apptainer/gatk4_4.6.2.0_samtools_1.21.sif

# run base recalibrate

mkdir -p $OUTDIR

for SAMPLE in normal tumor; do

apptainer exec \
  --bind $INPUTDIR --bind $OUTDIR --bind $WORKDIR \
  $GATK_SIF \
  gatk BaseRecalibrator \
	-R $REF \
	-I $INPUTDIR/${SAMPLE}.marked.bam \
	--known-sites $KNOWN_DBSNP \
	--known-sites $KNOWN_INDELS \
	-O "$OUTDIR/${SAMPLE}.recal.table"

done
