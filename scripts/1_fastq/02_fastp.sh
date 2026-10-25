#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=fastp
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/fastp_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/fastp_%j.e
#SBATCH --partition=pibu_el8


# loads module for fastp
module load fastp/0.23.4-GCC-10.3.0

# directories
WORKDIR=/data/users/jkim2/cancergenomics_course
INPUTDIR=$WORKDIR/rawdata/VAR_CALLING/fastq
OUTDIR=/data/users/jkim2/cancergenomics_course/results/fastQC

# datas
N1="${INPUTDIR}/normal.R1.fq.gz"
N2="${INPUTDIR}/normal.R2.fq.gz"
T1="${INPUTDIR}/tumor.R1.fq.gz"
T2="${INPUTDIR}/tumor.R2.fq.gz"

mkdir -p "${OUTDIR}"

#normal sample
fastp \
  -i "$N1" \
  -I "$N2" \
  -o "${OUTDIR}/normal_R1.clean.fastq.gz" \
  -O "${OUTDIR}/normal_R2.clean.fastq.gz" \
  -A -Q -L -G \
  --thread "$SLURM_CPUS_PER_TASK" \
  -h "${OUTDIR}/normal_fastp.html" \
  -j "${OUTDIR}/normal_fastp.json" \
  -w 2

#cancer sample
fastp \
  -i "$T1" \
  -I "$T2" \
  -o "${OUTDIR}/tumor_R1.clean.fastq.gz" \
  -O "${OUTDIR}/tumor_R2.clean.fastq.gz" \
  -A -Q -L -G \
  --thread "$SLURM_CPUS_PER_TASK" \
  -h "${OUTDIR}/tumor_fastp.html" \
  -j "${OUTDIR}/tumor_fastp.json" \
  -w 2

