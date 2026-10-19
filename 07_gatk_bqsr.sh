#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=apply_base_recali
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/apply_baserecali_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/apply_baserecali_%j.e
#SBATCH --partition=pshort_el8

#set path
INDIR=/data/users/jkim2/cancergenomics_course/results/markduplicate
OUTDIR=/data/users/jkim2/cancergenomics_course/results/bqsr

#data path
REF=/data/users/jkim2/cancergenomics_course/rawdata/bwa_idx/genome.fa

#Container path
GATK_SIF=/containers/apptainer/gatk_latest.sif  # revision need

#load module
load module SAMtools/1.13-GCC-10.3 # check

# run base recalibrate application

mkdir -p "$OUTDIR"

for SAMPLE in normal tumor; do

apptainer exec \
  --bind /data \
  GATK_SIF \
  gatk ApplyBQSR \
	-R $REF \
	-I $INDIR/${SAMPLE}_marked.bam \
	--bqsr-recal-file $OUTDIR/${SAMPLE}_recal.table \
	-O "$OUTDIR/${SAMPLE}_bqsr.bam"
	
samtools index "$OUTDIR/${SAMPLE}_bqsr.bam"

done