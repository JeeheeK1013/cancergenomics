#!/usr/bin/env bash

#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --job-name=mark_duplicate
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/duplicate_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/duplicate_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

# directories
WORKDIR=/data/users/jkim2/cancergenomics_course
INPUTDIR=$WORKDIR/results/align/bwa
OUTDIR=$WORKDIR/results/markduplicate
TMPDIR_GATK=$OUTDIR/tmp

# container
GATK_SIF=/containers/apptainer/gatk4_4.6.2.0_samtools_1.21.sif

# run markduplicate
mkdir -p "$OUTDIR" "$TMPDIR_GATK"

for SAMPLE in normal tumor; do
    INBAM=$INPUTDIR/${SAMPLE}.sorted.bam
    OUTBAM=$OUTDIR/${SAMPLE}.marked.bam
    METRICS=$OUTDIR/${SAMPLE}.metrics.txt

    apptainer exec \
        --bind "$INPUTDIR" --bind "$OUTDIR" \
        "$GATK_SIF" \
        gatk --java-options "-Xmx12g" MarkDuplicates \
            -I "$INBAM" \
            -O "$OUTBAM" \
            -M "$METRICS" \
            --TMP_DIR "$TMPDIR_GATK"

    apptainer exec \
        --bind "$OUTDIR" \
        "$GATK_SIF" \
        samtools index "$OUTBAM"

done

rm -rf "$TMPDIR_GATK"