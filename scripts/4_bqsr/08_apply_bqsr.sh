#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=apply_bqsr
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/bqsr_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/bqsr_%j.e
#SBATCH --partition=pshort_el8

# directory
INPUTDIR=/data/users/jkim2/cancergenomics_course/results/markduplicate
OUTDIR=/data/users/jkim2/cancergenomics_course/results/bqsr
REF=/data/users/jkim2/cancergenomics_course/rawdata/VAR_CALLING/bwa_idx/genome.fa

#Container path
GATK_SIF=/containers/apptainer/gatk4_4.6.2.0_samtools_1.21.sif


# run base recalibrate application

mkdir -p "$OUTDIR"

for SAMPLE in normal tumor; do

apptainer exec \
  --bind $INPUTDIR --bind $OUTDIR --bind $REF  \
 $GATK_SIF \
  gatk ApplyBQSR \
	-R $REF \
	-I $INPUTDIR/${SAMPLE}.marked.bam \
	--bqsr-recal-file $OUTDIR/${SAMPLE}.recal.table \
	-O "$OUTDIR/${SAMPLE}.bqsr.bam"
	
done