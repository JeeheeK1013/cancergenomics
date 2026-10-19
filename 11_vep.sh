#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=2:00:00
#SBATCH --job-name=vep
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/vep_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/vep_%j.e
#SBATCH --partition=pshort_el8

#set path
WORKDIR=/data/users/jkim2/cancergenomics_course
INDIR=/data/users/jkim2/cancergenomics_course/results/variant_call
OUTDIR=/data/users/jkim2/cancergenomics_course/results/annotation

#Container path
VEP_SIF=/containers/apptainer/vep_116.2.sif  # revision need

#run vep

mkdir -p "$OUTDIR"

apptainer exec \
--bind /data \
VEP_SIF \
vep -i "${INDIR}somatic.filtered.PASS.vcf.gz" \  #check
	--cache /data/.vep \   #check
	--species homo_sapiens \
	--offline \
	--force_overwrite \
	--assembly GRCh38 \
	--format vcf \
	--symbol \
	--sift b \
	--polyphen b \
	--pick \
	--domains \
	--output_file ${OUTDIR}/cancer_variants.vep.txt  #check