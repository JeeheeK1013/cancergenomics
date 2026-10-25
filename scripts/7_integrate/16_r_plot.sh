#!/usr/bin/env bash

#SBATCH --job-name=vep_r_plot
#SBATCH --partition=pibu_el8
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/R_%j.out
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/R_%j.err



# install package
module load R/4.2.1-foss-2021a
export R_LIBS_USER=/data/users/jkim2/R/4.2.1 && mkdir -p $R_LIBS_USER
Rscript -e 'install.packages(c("dplyr","tidyr","stringr","forcats","ggplot2","readr","purrr","ragg"), lib=Sys.getenv("R_LIBS_USER"), repos="https://cloud.r-project.org")'

# directory
WORKDIR="/data/users/jkim2/cancergenomics_course"
SCRIPT="$WORKDIR/scripts/7_integrate/16_plot.r"
IN_FILE="$WORKDIR/results/annotation/cancer_variants.somatic.vep.txt"
OUT_DIR="$WORKDIR/results/plots"

# user R library 
export R_LIBS_USER="/data/users/jkim2/R/4.2.1"
mkdir -p "$R_LIBS_USER" "$OUT_DIR"

module purge
module load R/4.2.1-foss-2021a

# run R

Rscript "$SCRIPT" "$IN_FILE" "$OUT_DIR"

