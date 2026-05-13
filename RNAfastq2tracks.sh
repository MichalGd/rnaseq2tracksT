#!/bin/bash
# Master script for the simplified RNA‑seq workflow.
# Usage: RNAfastq2tracks.sh <input_fastq_dir> <output_dir> <max_jobs> <species> [paired|single] [samplesheet.csv]

set -euo pipefail

if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <input_fastq_dir> <output_dir> <max_jobs> <species> [paired|single] [samplesheet.csv]" >&2
  exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_JOBS="$3"
SPECIES="$4"
LAYOUT="${5:-paired}"
SAMPLESHEET="${6:-}"

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config/config.sh"

# Create high‑level output directories
mkdir -p "$OUTPUT_DIR"/{logs,fastqc_raw,fastqc_trimmed,trimmed,star,counts,coverage,tracks,reports}

echo "[RNAfastq2tracks] Starting workflow"

# Step 1: QC of raw reads
echo "[Step 1] Running FastQC on raw reads"
"$SCRIPT_DIR/scripts/run_fastqc.sh" "$INPUT_DIR" "$OUTPUT_DIR/fastqc_raw" "$MAX_JOBS"

# Step 2: Trimming
echo "[Step 2] Trimming reads with Trim Galore ($LAYOUT)"
"$SCRIPT_DIR/scripts/run_trimming.sh" "$INPUT_DIR" "$OUTPUT_DIR/trimmed" "$MAX_JOBS" "$LAYOUT"

# Step 3: QC of trimmed reads
echo "[Step 3] Running FastQC on trimmed reads"
"$SCRIPT_DIR/scripts/run_fastqc.sh" "$OUTPUT_DIR/trimmed" "$OUTPUT_DIR/fastqc_trimmed" "$MAX_JOBS"

# Step 4: Alignment
echo "[Step 4] Mapping reads with STAR"
"$SCRIPT_DIR/scripts/run_star.sh" "$OUTPUT_DIR/trimmed" "$OUTPUT_DIR/star" "$SPECIES" "$LAYOUT" "$MAX_JOBS"

# Step 5: Gene counts
echo "[Step 5] Generating gene count matrix"
"$SCRIPT_DIR/scripts/run_gene_counts.sh" "$OUTPUT_DIR/star" "$OUTPUT_DIR/counts" "$SPECIES" "$LAYOUT"

# Step 6: Normalization (DESeq2)
echo "[Step 6] Normalizing counts with DESeq2"
RAW_COUNTS="$OUTPUT_DIR/counts/raw_counts_matrix.tsv"
SIZE_FACTORS_FILE="$OUTPUT_DIR/counts/size_factors.tsv"
NORM_COUNTS_FILE="$OUTPUT_DIR/counts/normalized_counts.tsv"

"$SCRIPT_DIR/scripts/run_normalization.R" "$RAW_COUNTS" "$SIZE_FACTORS_FILE" "$NORM_COUNTS_FILE"

# Step 7: Coverage & tracks
echo "[Step 7] Generating coverage tracks"
"$SCRIPT_DIR/scripts/run_coverage.sh" "$OUTPUT_DIR/star" "$OUTPUT_DIR/coverage" "$SPECIES" "$LAYOUT" "$SIZE_FACTORS_FILE"

# Step 8: Reports
echo "[Step 8] Running MultiQC"
"$SCRIPT_DIR/scripts/run_multiqc.sh" "$OUTPUT_DIR" "$OUTPUT_DIR/reports"

# Step 9: Create UCSC track lines
echo "[Step 9] Creating UCSC track hub"
"$SCRIPT_DIR/scripts/create_ucsc_tracks.sh" "$OUTPUT_DIR/coverage/bigwig" > "$OUTPUT_DIR/tracks/hub.txt"

echo "[RNAfastq2tracks] Workflow complete. Outputs written to $OUTPUT_DIR"