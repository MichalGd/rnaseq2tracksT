#!/bin/bash
# run_trimming.sh
# Trim adapters and low‑quality bases from FASTQ files using Trim Galore.  The
# script supports paired and single‑end layouts.  Input files must be named
# consistently: paired files should end with `_1.fq.gz` and `_2.fq.gz`.

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <input_dir> <output_dir> <max_jobs> <layout>" >&2
  exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_JOBS="$3"
LAYOUT="$4"

# Load configuration for TRIMGALORE_BIN
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config/config.sh"

mkdir -p "$OUTPUT_DIR"

if [[ "$LAYOUT" == "paired" ]]; then
  # Process paired‑end files: assume naming convention *_1.fq.gz and *_2.fq.gz
  for r1 in $(find "$INPUT_DIR" -type f -name "*_1.fq.gz" | sort); do
    r2="${r1%_1.fq.gz}_2.fq.gz"
    sample=$(basename "$r1" | sed 's/_1\.fq\.gz$//')
    out_prefix="$OUTPUT_DIR/${sample}"
    echo "[run_trimming] Trimming $sample (paired)"
    "$TRIMGALORE_BIN" --paired "$r1" "$r2" --output_dir "$OUTPUT_DIR"
  done
else
  # Single‑end files
  for fq in $(find "$INPUT_DIR" -type f -name "*.fq.gz" | sort); do
    sample=$(basename "$fq" | sed 's/\.fq\.gz$//')
    echo "[run_trimming] Trimming $sample (single)"
    "$TRIMGALORE_BIN" "$fq" --output_dir "$OUTPUT_DIR"
  done
fi