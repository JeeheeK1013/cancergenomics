#!/usr/bin/env bash

#SBATCH --job-name=vep
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/vep_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/vep_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

# Directories and files
WORKDIR="/data/users/jkim2/cancergenomics_course/results"
OUTDIR="${WORKDIR}/annotation"
CACHEDIR="/data/users/jkim2/cache/vep_cache"
IMAGE="/data/users/jkim2/image/vep_116.2.sif"

INPUT="${WORKDIR}/variant_call/somatic.vcf.gz"
OUTPUT="${OUTDIR}/cancer_variants.vep.txt"

mkdir -p "$OUTDIR"

# Run VEP 
apptainer exec \
    --bind "${WORKDIR}:${WORKDIR}" \
    --bind "${CACHEDIR}:${CACHEDIR}" \
    "$IMAGE" \
    vep \
    --input_file "$INPUT" \
    --output_file "$OUTPUT" \
    --format vcf \
    --cache \
    --offline \
    --dir_cache "$CACHEDIR" \
    --cache_version 116 \
    --species homo_sapiens \
    --assembly GRCh38 \
    --symbol \
    --domains \
    --pick \
    --force_overwrite