#!/usr/bin/env bash

#SBATCH --job-name=vep_somatic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/vep_somatic_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/vep_somatic_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

# Directories and files
WORKDIR="/data/users/jkim2/cancergenomics_course/results"
OUTDIR="${WORKDIR}/annotation"
CACHEDIR="/data/users/jkim2/cache/vep_cache"
IMAGE="/data/users/jkim2/image/vep_116.2.sif"
CLINVAR="/data/users/jkim2/cancergenomics_course/rawdata/VAR_CALLING/resources/clinvar/clinvar.vcf.gz"

INPUT="${WORKDIR}/variant_call/somatic.vcf.gz"
OUTPUT="${OUTDIR}/cancer_variants.somatic.vep.txt"
FILTERED="${OUTDIR}/cancer_variants.somatic.vep.filtered.txt"
SUMMARY="${OUTDIR}/summary.txt"

mkdir -p "$OUTDIR"

# Run VEP
apptainer exec \
    --bind /data \
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
    --fork 2 \
    --symbol \
    --domains \
    --variant_class \
    --biotype \
    --pick \
    --custom "${CLINVAR},ClinVar,vcf,exact,0,CLNSIG,CLNREVSTAT,CLNDN" \
    --force_overwrite

# Filter result
apptainer exec \
    --bind /data \
    "$IMAGE" \
    filter_vep \
    -i "$OUTPUT" \
    -o "$FILTERED" \
    --force_overwrite \
    --filter "(IMPACT is HIGH or IMPACT is MODERATE) or (ClinVar_CLNSIG match pathogenic)"

# Generate summary (column 7 = Consequence)
echo "Mutation Type Summary:" > "$SUMMARY"
grep -v "^#" "$FILTERED" | cut -f7 | sort | uniq -c | sort -nr >> "$SUMMARY"