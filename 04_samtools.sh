#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=sort_index
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/sort_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/sort_%j.e
#SBATCH --partition=pshort_el8


#set path
WORKDIR=/data/users/jkim2/cancergenomics_course
INDIR=/data/users/jkim2/cancergenomics_course/results/fastQC/
OUTDIR=/data/users/jkim2/cancergenomics_course/results/align
REF=/data/users/jkim2/cancergenomics_course/rawdata/bwa_idx/genome.fa


# load module
module load SAMtools/1.13-GCC-10.3.0

# run samtools
mkdir -p "$OUTDIR"

for SAMPLE in normal tumor; do
    samtools sort -@ 8 \
        "$OUTDIR/${SAMPLE}_aligned.bam" \
        -o "$OUTDIR/${SAMPLE}_sorted.bam"
    samtools index "$OUTDIR/${SAMPLE}_sorted.bam"
done