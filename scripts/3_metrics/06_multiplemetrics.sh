#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=2:00:00
#SBATCH --job-name=collect_metrics
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/collect_metrics_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/collect_metrics_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

# directories
WORKDIR=/data/users/jkim2/cancergenomics_course
INPUTDIR=$WORKDIR/results/markduplicate
OUTDIR=$WORKDIR/results/metrics
REF=$WORKDIR/rawdata/VAR_CALLING/bwa_idx/genome.fa
QCDIR=$WORKDIR/results/fastQC

# load modules
module load GATK/4.2.6.1-GCCcore-10.3.0-Java-11 
module load R/4.1.0-foss-2021a

# run to generate metrics

mkdir -p "$OUTDIR"

for SAMPLE in normal tumor; do
    gatk --java-options "-Xmx24g -XX:ActiveProcessorCount=4" CollectMultipleMetrics \
        -I "$INPUTDIR/${SAMPLE}.marked.bam" \
        -O "$OUTDIR/${SAMPLE}" \
        -R "$REF"
done

# update the multiQC
apptainer exec --bind $OUTDIR --bind $QCDIR \
/containers/apptainer/multiqc-1.19.sif \
multiqc \
$OUTDIR $QCDIR -o $OUTDIR -f


#########check