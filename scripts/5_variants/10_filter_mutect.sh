#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --job-name=filter_mutect2
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/filter_mutect_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/filter_mutect_%j.e
#SBATCH --partition=pshort_el8

# directory
WORKDIR=/data/users/jkim2/cancergenomics_course
OUTDIR=/data/users/jkim2/cancergenomics_course/results/variant_call

# data path
INPUTDATA=/data/users/jkim2/cancergenomics_course/rawdata/VAR_CALLING
REF=${INPUTDATA}/bwa_idx/genome.fa

# module load
module load BCFtools/1.12-GCC-10.3.0

#Container path
GATK_SIF=/containers/apptainer/gatk4_4.6.2.0_samtools_1.21.sif 

#run mutect

mkdir -p "$OUTDIR"

apptainer exec \
  --bind $INPUTDATA --bind $OUTDIR --bind $REF \
  $GATK_SIF \
  gatk FilterMutectCalls \
  -R "$REF" \
  -V "$OUTDIR/somatic.vcf.gz" \
  --stats "$OUTDIR/somatic.vcf.gz.stats" \
  -O "$OUTDIR/somatic.filtered.vcf.gz"
