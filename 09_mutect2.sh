#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=mutect2
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/mutect_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/mutect_%j.e
#SBATCH --partition=pshort_el8

#set path
WORKDIR=/data/users/jkim2/cancergenomics_course
OUTDIR=/data/users/jkim2/cancergenomics_course/results/variant_call

#data path
INPUTDATA=/data/users/jkim2/cancergenomics_course/rawdata
REF=${INPUTDATA}/bwa_idx/genome.fa
BAMDIR=${INPUTDATA}/alignments
RESOURCEDIR=${INPUTDATA}/resources
REFDIR=${INPUTDATA}/reference
INTERVALS=${REFDIR}/exome_regions.bed.interval_list

#Container path
GATK_SIF=/containers/apptainer/gatk_latest.sif  # revision need

#run mutect
apptainer exec \
  --bind /data \
  GATK_SIF \
  gatk Mutect2 \
  -R "$REF" \
  --intervals "$INTERVALS" \
  -I "$BAMDIR/tumor.recal.bam" \
  -I "$BAMDIR/normal.recal.bam" \
  - normal normal \
  --germline-resource "$RESOURCEDIR/af-only-gnomad.hg38.subset.vcf.gz"
  --panel-of-normals "$RESOURCEDIR/1000g_pon.hg38.subset.vcf.gz"
  -O "$OUTDIR/somatic.vcf.gz"