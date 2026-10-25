#!/usr/bin/env bash

#SBATCH --job-name=prepare_vep
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=/data/users/jkim2/cancergenomics_course/logs/prepare_vep_%j.o
#SBATCH --error=/data/users/jkim2/cancergenomics_course/logs/prepare_vep_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

# Project and output paths
WORKDIR="/data/users/jkim2/cancergenomics_course"
USERDIR="/data/users/jkim2"

IMAGE="${USERDIR}/image/vep_116.2.sif"
CACHE_DIR="${USERDIR}/cache/vep_cache"
APPTAINER_CACHEDIR="${USERDIR}/.apptainer/cache"
APPTAINER_TMPDIR="${USERDIR}/.apptainer/tmp"

# Configure Apptainer directories
export APPTAINER_CACHEDIR
export APPTAINER_TMPDIR
export TMPDIR="$APPTAINER_TMPDIR"

# Create required directories
mkdir -p \
    "${WORKDIR}/logs" \
    "$(dirname "$IMAGE")" \
    "$CACHE_DIR" \
    "$APPTAINER_CACHEDIR" \
    "$APPTAINER_TMPDIR"

# Verify that directories are writable
for dir in \
    "${WORKDIR}/logs" \
    "$(dirname "$IMAGE")" \
    "$CACHE_DIR" \
    "$APPTAINER_CACHEDIR" \
    "$APPTAINER_TMPDIR"
do
    if [[ ! -w "$dir" ]]; then
        echo "ERROR: Directory is not writable: $dir" >&2
        exit 1
    fi
done

# Build the VEP container image if it does not exist
if [[ ! -s "$IMAGE" ]]; then
    echo "Pulling Ensembl VEP 116.2 container..."

    apptainer pull "$IMAGE" \
        docker://ensemblorg/ensembl-vep:release_116.2

    echo "Container image downloaded successfully."
else
    echo "Container image already exists: $IMAGE"
fi

# Download the Ensembl VEP cache
CACHE_TAR="${CACHE_DIR}/homo_sapiens_vep_116_GRCh38.tar.gz"
CACHE_URL="https://ftp.ensembl.org/pub/release-116/variation/indexed_vep_cache/homo_sapiens_vep_116_GRCh38.tar.gz"

if [[ ! -s "$CACHE_TAR" ]]; then
    echo "Downloading human GRCh38 VEP cache..."

    curl -fL --retry 3 \
        -o "$CACHE_TAR" \
        "$CACHE_URL"

    echo "VEP cache downloaded successfully."
else
    echo "Cache archive already exists: $CACHE_TAR"
fi

# Verify the downloaded archive before extraction
if ! tar -tzf "$CACHE_TAR" >/dev/null; then
    echo "ERROR: VEP cache archive is invalid or incomplete." >&2
    exit 1
fi

# Extract the cache if it is not already available
if [[ ! -d "${CACHE_DIR}/homo_sapiens" ]]; then
    echo "Extracting VEP cache..."

    tar -xzf "$CACHE_TAR" -C "$CACHE_DIR"

    echo "VEP cache extracted successfully."
else
    echo "VEP cache already extracted."
fi

echo "VEP container and cache preparation completed successfully."
