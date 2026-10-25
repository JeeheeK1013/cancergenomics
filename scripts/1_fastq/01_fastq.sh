#!/usr/bin/env bash

#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=FastQC
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/fastQC_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/fastQC_%j.e
#SBATCH --partition=pibu_el8


# Directories
WORKDIR=/data/users/jkim2/cancergenomics_course
INPUTDIR=$WORKDIR/rawdata/VAR_CALLING/fastq
OUTDIR=$WORKDIR/results/fastQC

mkdir -p $OUTDIR

# run fastqc for normal
apptainer exec --bind $INPUTDIR --bind $OUTDIR /containers/apptainer/fastqc-0.12.1.sif \
fastqc -t 4 -o $OUTDIR $INPUTDIR/normal.R1.fq.gz $INPUTDIR/normal.R2.fq.gz

# run fastqc for tumor
apptainer exec --bind $INPUTDIR --bind $OUTDIR /containers/apptainer/fastqc-0.12.1.sif \
fastqc -t 4 -o $OUTDIR $INPUTDIR/tumor.R1.fq.gz $INPUTDIR/tumor.R2.fq.gz

