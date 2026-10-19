#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=filter_mutect2
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/filter_mutect_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/filter_mutect_%j.e
#SBATCH --partition=pshort_el8

#set path
WORKDIR=/data/users/jkim2/cancergenomics_course
OUTDIR=/data/users/jkim2/cancergenomics_course/results/variant_call

#data path
INPUTDATA=/data/users/jkim2/cancergenomics_course/rawdata
REF=${INPUTDATA}/bwa_idx/genome.fa

#module load
module load BCFtools/1.12-GCC-10.3.0

#Container path
GATK_SIF=/containers/apptainer/gatk_latest.sif  # revision need

#run mutect

mkdir -p "$OUTPUT_DIR"

apptainer exec \
  --bind /data \
  GATK_SIF \
  gatk FilterMutectCalls \
  -R "$REF" \
  -V "$OUTDIR/somatic.vcf.gz" \
  --stats "$OUTDIR/somatic.vcf.gz.stats" \
  --filtering-stats "$OUTDIR/somatic.filtering_stats.tsv" \
  -O "$OUTDIR/somatic.filtered.vcf.gz"

#filter and index
bcftools view -f PASS -Oz \
    -o "$OUTDIR/somatic.filtered.PASS.vcf.gz" \
    "$OUTDIR/somatic.filtered.vcf.gz"
bcftools index --tbi --force "$OUTDIR/somatic.filtered.PASS.vcf.gz"