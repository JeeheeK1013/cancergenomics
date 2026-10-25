#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=bcftools
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/bcftools_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/bcftools_%j.e
#SBATCH --partition=pshort_el8

# directory
OUTDIR=/data/users/jkim2/cancergenomics_course/results/variant_call

# data path
INPUTDIR=/data/users/jkim2/cancergenomics_course/rawdata/VAR_CALLING
REF=${INPUTDIR}/bwa_idx/genome.fa

# container path
BCF=/containers/apptainer/bcftools:1.21--h8b25389_0

# run bcftools

apptainer exec --bind $OUTDIR --bind $REF \
  $BCF \
  bcftools view \
  -f PASS $OUTDIR/somatic.filtered.vcf.gz \
  -Oz -o $OUTDIR/somatic.filtered.PASS.vcf.gz


apptainer exec --bind $OUTDIR --bind $REF \
  $BCF \
  bcftools index \
  --tbi $OUTDIR/somatic.filtered.PASS.vcf.gz
 