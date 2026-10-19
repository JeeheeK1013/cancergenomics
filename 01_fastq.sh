#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=FastQC
#SBATCH --mail-type=end
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/fastQC_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/fastQC_%j.e
#SBATCH --partition=pibu_el8

# Directories
WORKDIR=/data/users/jkim2/cancergenomics_course
OUTDIR=$WORKDIR/results/fastQC

# Data directiories
FASTQDIR=/data/users/jkim2/cancergenomics_course/rawdata/fastq
R1="FASTQDIR/${SAMPLE}.R1.fq.gz"
R2="FASTQDIR/${SAMPLE}.R2.fq.gz"

# Container directory
FASTQC_SIF=/containers/apptainer/fastqc-0.12.1.sif 

mkdir -p "${OUTDIR}"
cd "${OUTDIR}"


# runs fastQC
apptainer exec \
  --bind /data \
  $FASTQC_SIF \
  fastqc \
  --outdir "${OUTDIR}" \
  --threads "$SLURM_CPUS_PER_TASK" \
  "$R1" "$R2"
