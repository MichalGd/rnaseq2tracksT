#!/bin/bash
# run_fastqc.sh
# Perform quality control on FASTQ files using FastQC.  All parameters are
# configurable via the config file.  This script can be run in parallel using
# GNU Parallel.

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <input_dir> <output_dir> <max_jobs>" >&2
  exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_JOBS="$3"

# Load configuration for FASTQC_BIN
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config/config.sh"

mkdir -p "$OUTPUT_DIR"

# Find .fq.gz files and run FastQC with parallel
find "$INPUT_DIR" -type f \( -name "*.fq.gz" -o -name "*.fastq.gz" \) | \
  sort | \
  parallel -j "$MAX_JOBS" --halt soon,fail=1 --eta "${FASTQC_BIN}" --outdir "$OUTPUT_DIR" {}