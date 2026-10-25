#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --mem=32G
#SBATCH --time=4:00:00
#SBATCH --job-name=bwa
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/bwa_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/bwa_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

# directories
WORKDIR=/data/users/jkim2/cancergenomics_course
INPUTDIR=$WORKDIR/results/fastQC
OUTDIR=$WORKDIR/results/align/bwa
REF=$WORKDIR/rawdata/VAR_CALLING/bwa_idx/genome.fa

# threads
THREADS=${SLURM_CPUS_PER_TASK:-8}
SORT_THREADS=2
BWA_THREADS=$(( THREADS - SORT_THREADS ))

# modules
module load BWA/0.7.17-GCC-10.3.0
module load SAMtools/1.13-GCC-10.3.0

mkdir -p "$OUTDIR"

# check BWA index
if [[ ! -f "${REF}.bwt" ]]; then
    echo "ERROR: BWA index not found for $REF" >&2
    exit 1
fi

#run bwa and samtools
for SAMPLE in normal tumor; do
    R1="$INPUTDIR/${SAMPLE}_R1.clean.fastq.gz"
    R2="$INPUTDIR/${SAMPLE}_R2.clean.fastq.gz"

    for f in "$R1" "$R2"; do
        [[ -f "$f" ]] || { echo "ERROR: missing $f" >&2; exit 1; }
    done

    echo "[$(date)] Aligning $SAMPLE"

    bwa mem -t "$BWA_THREADS" \
        -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tLB:${SAMPLE}\tPL:ILLUMINA" \
        "$REF" "$R1" "$R2" \
    | samtools sort -@ "$SORT_THREADS" -m 2G \
        -T "$OUTDIR/${SAMPLE}.tmp" \
        -o "$OUTDIR/${SAMPLE}.sorted.bam" -

    samtools index -@ "$THREADS" "$OUTDIR/${SAMPLE}.sorted.bam"
    samtools flagstat -@ "$THREADS" "$OUTDIR/${SAMPLE}.sorted.bam" \
        > "$OUTDIR/${SAMPLE}.flagstat.txt"

    echo "[$(date)] Done $SAMPLE"
done