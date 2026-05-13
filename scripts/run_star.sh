#!/bin/bash
# run_star.sh
# Align trimmed reads to a reference genome using STAR.  Supports paired or
# single‑end data.  Genome indexes and annotation files are provided via
# config/config.sh.

set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "Usage: $0 <trimmed_dir> <output_dir> <species> <layout> <max_jobs>" >&2
  exit 1
fi

TRIM_DIR="$1"
OUT_DIR="$2"
SPECIES="$3"
LAYOUT="$4"
MAX_JOBS="$5"

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config/config.sh"

# Determine STAR index and GTF based on species
if [[ "$SPECIES" == "human" ]]; then
  STAR_INDEX="$STAR_INDEX_HUMAN"
  GTF_FILE="$GTF_HUMAN"
elif [[ "$SPECIES" == "mouse" ]]; then
  STAR_INDEX="$STAR_INDEX_MOUSE"
  GTF_FILE="$GTF_MOUSE"
else
  echo "[run_star] Error: unknown species '$SPECIES' (must be 'human' or 'mouse')" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

if [[ "$LAYOUT" == "paired" ]]; then
  for r1 in $(find "$TRIM_DIR" -type f -name "*_1_val_1.fq.gz" -o -name "*_1.trimmed.fq.gz" -o -name "*_1.fq.gz" | sort); do
    # Derive pair names; Trim Galore appends _val_1/_val_2 or .trimmed depending on version
    base="${r1%_1*}"
    # Determine second read by replacing _1 with _2 and preserving suffix
    suffix="${r1#${base}_1}"
    r2="${base}_2${suffix}"
    sample=$(basename "$base")
    out_prefix="$OUT_DIR/${sample}/"
    mkdir -p "$OUT_DIR/${sample}"
    echo "[run_star] Aligning $sample"
    "$STAR_BIN" \
      --runThreadN "$MAX_JOBS" \
      --genomeDir "$STAR_INDEX" \
      --readFilesIn "$r1" "$r2" \
      --readFilesCommand zcat \
      --outFileNamePrefix "$out_prefix" \
      --outSAMtype BAM SortedByCoordinate \
      --quantMode GeneCounts \
      --sjdbGTFfile "$GTF_FILE"
  done
else
  # Single‑end
  for fq in $(find "$TRIM_DIR" -type f -name "*.fq.gz" | sort); do
    sample=$(basename "$fq" | sed 's/\.fq\.gz$//; s/_trimmed//; s/_val_1//')
    out_prefix="$OUT_DIR/${sample}/"
    mkdir -p "$OUT_DIR/${sample}"
    echo "[run_star] Aligning $sample"
    "$STAR_BIN" \
      --runThreadN "$MAX_JOBS" \
      --genomeDir "$STAR_INDEX" \
      --readFilesIn "$fq" \
      --readFilesCommand zcat \
      --outFileNamePrefix "$out_prefix" \
      --outSAMtype BAM SortedByCoordinate \
      --quantMode GeneCounts \
      --sjdbGTFfile "$GTF_FILE"
  done
fi