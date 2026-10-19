#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=bwa
#SBATCH --mail-type=end
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/bwa_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/bwa_%j.e
#SBATCH --partition=pshort_el8

#set path
WORKDIR=/data/users/jkim2/cancergenomics_course
INDIR=/data/users/jkim2/cancergenomics_course/results/fastQC/
OUTDIR=/data/users/jkim2/cancergenomics_course/results/align
REF=/data/users/jkim2/cancergenomics_course/rawdata/bwa_idx/genome.fa

#load module
module load BWA-MEM2/2.2.1-GCC-10.3.0 SAMtools/1.13-GCC-10.3.0

#run bwa
mkdir -p "$OUTDIR"
cd "$OUTDIR"

for SAMPLE in normal tumor; do
    bwa-mem2 mem -t 6 \
        -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tLB:${SAMPLE}\tPL:ILLUMINA" \
        "$REF" \
        "$INDIR/${SAMPLE}.R1.clean.fastq.gz" \
        "$INDIR/${SAMPLE}.R2.clean.fastq.gz" | \
        samtools view -b -@ 1 -o "$OUTDIR/${SAMPLE}_aligned.bam" -
done