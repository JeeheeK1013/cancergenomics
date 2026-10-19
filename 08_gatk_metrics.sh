#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=gatk_metrics
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/gatk_metrics_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/gatk_metrics_%j.e
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

#check
ALIGNDIR=./alignments
REF=./reference/genome.fa
BAIT_INTERVALS_LIST=reference/exome_regions.bed.interval_list
TARGET_INTERVALS_LIST=reference/exome_regions.bed.interval_list
 
for sample in tumor normal
do
	singularity exec\
	--bind /storage \
	depot.galaxyproject.org-singularity-gatk4-4.4.0.0--py36hdfd78af_0.img \
	gatk CollectHsMetrics \
	-I "$ALIGNDIR"/"$sample".recal.bam \
	-O "$ALIGNDIR"/"$sample".recal.bam_hs_metrics.txt \
	-R "$REF" \
	--BAIT_INTERVALS $BAIT_INTERVALS_LIST \
	--TARGET_INTERVALS $TARGET_INTERVALS_LIST
done

