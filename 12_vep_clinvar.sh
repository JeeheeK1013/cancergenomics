#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=2:00:00
#SBATCH --job-name=vep_clinvar
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/vep_clinvar_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/vep_clinvar_%j.e
#SBATCH --partition=pshort_el8

#set path
WORKDIR=/data/users/jkim2/cancergenomics_course
INDIR=/data/users/jkim2/cancergenomics_course/results/variant_call
OUTDIR=/data/users/jkim2/cancergenomics_course/results/annotation

#data path
CLINVAR=
ANNOTATED=
FILTERED=

#Container path
VEP_SIF=/containers/apptainer/vep_116.2.sif  # revision need

#run vep

mkdir -p "$OUTDIR"

apptainer exec \
--bind /data \
VEP_SIF \
vep -i "${INDIR}somatic.filtered.PASS.vcf.gz" \ 
	--cache /data/.vep \   
	--species homo_sapiens \
	--offline \
	--assembly GRCh38 \
	--format vcf \
	--force_overwrite \
	--fork 2 \
	--everything \
	--custom clinvar.vcf.gz,ClinVar,vcf,exact,0,CLNSIG,CLNREVSTAT,CLNDN \
	--output_file chr6ch17_mutect2_annotated_with_clinVar.txt
 
# Filter results
apptainer exec \
--bind /data \
VEP_SIF \
filter_vep \
-i chr6ch17_mutect2_annotated_with_clinVar.txt \
-o chr6ch17_mutect2_annotated_with_clinVar_filtered.txt \
--force_overwrite \
--filter "(IMPACT is HIGH or IMPACT is MODERATE) or \
(SIFT match deleterious or PolyPhen match probably_damaging) or \
(ClinVar_CLNSIG match pathogenic)"
 
# Generate summary (using simple grep/awk commands)
echo "Mutation Type Summary:" > summary.txt
grep -v "#" chr6ch17_mutect2_annotated_with_clinVar_filtered.txt | cut -f7 | sort | uniq -c >> summary.txt
