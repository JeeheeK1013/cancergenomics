#!/usr/bin/env bash

#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastqc_clean
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/cleanfastQC_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/cleanfastQC_%j.e
#SBATCH --partition=pibu_el8


# directories
WORKDIR=/data/users/jkim2/cancergenomics_course
INPUTDIR=$WORKDIR/results/fastQC
OUTDIR=$WORKDIR/results/fastQC/cleanQC

mkdir -p $OUTDIR

# run fastqc for normal
apptainer exec --bind $INPUTDIR --bind $OUTDIR /containers/apptainer/fastqc-0.12.1.sif \
fastqc -t 4 -o $OUTDIR $INPUTDIR/normal_R1.clean.fastq.gz $INPUTDIR/normal_R2.clean.fastq.gz

# run fastqc for tumor
apptainer exec --bind $INPUTDIR --bind $OUTDIR /containers/apptainer/fastqc-0.12.1.sif \
fastqc -t 4 -o $OUTDIR $INPUTDIR/tumor_R1.clean.fastq.gz $INPUTDIR/tumor_R2.clean.fastq.gz
