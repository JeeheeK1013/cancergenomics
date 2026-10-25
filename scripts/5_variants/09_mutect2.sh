#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=4:00:00
#SBATCH --job-name=mutect2
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/mutect_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/mutect_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

# Directories
WORKDIR=/data/users/jkim2/cancergenomics_course
OUTDIR="${WORKDIR}/results/variant_call"

# Input data paths
INPUTDATA="${WORKDIR}/rawdata/VAR_CALLING"
REF="${INPUTDATA}/bwa_idx/genome.fa"
BAMDIR="${INPUTDATA}/alignments"
RESOURCEDIR="${INPUTDATA}/resources"
REFDIR="${INPUTDATA}/reference"
INTERVALS="${REFDIR}/exome_regions.bed.interval_list"

# Container
GATK_SIF=/containers/apptainer/gatk4_4.6.2.0_samtools_1.21.sif

# Create output directory
mkdir -p "$OUTDIR"

# Run Mutect2
apptainer exec \
    --bind "${INPUTDATA}:${INPUTDATA}" \
    --bind "${OUTDIR}:${OUTDIR}" \
    --bind "${REFDIR}:${REFDIR}" \
    "$GATK_SIF" \
    gatk Mutect2 \
    -R "$REF" \
    --intervals "$INTERVALS" \
    -I "${BAMDIR}/tumor.recal.bam" \
    -I "${BAMDIR}/normal.recal.bam" \
    --germline-resource "${RESOURCEDIR}/af-only-gnomad.hg38.subset.vcf.gz" \
    --panel-of-normals "${RESOURCEDIR}/1000g_pon.hg38.subset.vcf.gz" \
    -O "${OUTDIR}/somatic.vcf.gz"
