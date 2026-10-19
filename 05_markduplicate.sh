#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=mark_duplicate
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/duplicate_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/duplicate_%j.e
#SBATCH --partition=pshort_el8

#set path
INDIR=/data/users/jkim2/cancergenomics_course/results/align
OUTDIR=/data/users/jkim2/cancergenomics_course/results/markduplicate
IN_BAM=${INDIR}/${SAMPLE}_sorted.bam 
OUT_BAM=${OUTDIR}/${SAMPLE}_marked.bam 
OUT_METRICS=${OUTDIR}/${SAMPLE}_metrics.txt


#Container path
GATK_SIF=/containers/apptainer/gatk_latest.sif  # revision need

#run gatk  

mkdir -p "$OUTDIR"

apptainer exec \
  --bind /data \
  GATK_SIF \
  gatk MarkDuplicates \
	-I $IN_BAM \
	-O $OUT_BAM \
	-M $OUT_METRICS
	
samtools index $OUT_BAM