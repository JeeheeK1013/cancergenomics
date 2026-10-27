#!/usr/bin/env bash

#SBATCH --job-name=vep_somatic
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/vep_somatic_t_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/vep_somatic_t_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

# Directories and files
WORKDIR="/data/users/jkim2/cancergenomics_course/results"
OUTDIR="${WORKDIR}/annotation"
VEPDIR=/data/courses/cancergenomics/2026/VEP
INPUTDIR="$VEPDIR/input/Massimo_Maiolo_2025"


mkdir -p "$OUTDIR"

# Run VEP
apptainer exec \
    --bind /data --bind "$VEPDIR/vep_data:/vep_data" \
    "$VEPDIR/vep.sif" vep \
    --dir /vep_data \
    --input_file "$INPUTDIR/somatic.filtered.PASS.vcf" \
    --output_file "$OUTDIR/t_somatic.filtered.PASS.vep.vcf" \
    --format vcf \
    --vcf \
    --everything \
    --cache \
    --offline \
    --cache_version 116 \
    --species homo_sapiens \
    --assembly GRCh38 \
    --custom "/vep_data/clinvar/clinvar.vcf.gz,ClinVar,vcf,exact,0,CLNSIG,CLNREVSTAT,CLNDN" \
    --force_overwrite
