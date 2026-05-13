#!/bin/bash
# run_coverage.sh
# Generate strand‑agnostic coverage files (bedGraph and BigWig) from STAR
# alignment outputs and apply size‑factor normalization.  Normalization uses
# DESeq2 size factors multiplied by the mean RPM across genes (SF_rpm).  The
# normalized coverage is suitable for comparative visualization.

set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "Usage: $0 <star_dir> <coverage_dir> <species> <layout> <size_factor_file>" >&2
  exit 1
fi

STAR_DIR="$1"
COV_DIR="$2"
SPECIES="$3"
LAYOUT="$4"
SF_FILE="$5"

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config/config.sh"

# Determine chromosome sizes file
if [[ "$SPECIES" == "human" ]]; then
  CHRS="$CHROM_SIZES_HUMAN"
elif [[ "$SPECIES" == "mouse" ]]; then
  CHRS="$CHROM_SIZES_MOUSE"
else
  echo "[run_coverage] Error: unknown species '$SPECIES'" >&2
  exit 1
fi

mkdir -p "$COV_DIR/bedgraph_raw" "$COV_DIR/bedgraph_norm" "$COV_DIR/bigwig"

# Read size factors into associative array
declare -A SF
while IFS=$'\t' read -r sample sf; do
  SF[$sample]="$sf"
done < <(tail -n +2 "$SF_FILE")

for bam in "$STAR_DIR"/*/Aligned.sortedByCoord.out.bam; do
  [[ -f "$bam" ]] || continue
  sample_dir=$(dirname "$bam")
  sample=$(basename "$sample_dir")
  sf="${SF[$sample]:-1}"
  raw_bg="$COV_DIR/bedgraph_raw/${sample}.bedGraph"
  norm_bg="$COV_DIR/bedgraph_norm/${sample}.bedGraph"
  norm_sorted_bg="$COV_DIR/bedgraph_norm/${sample}.sorted.bedGraph"
  bw="$COV_DIR/bigwig/${sample}.bw"
  echo "[run_coverage] Generating coverage for $sample (sf=$sf)"
  # Raw bedGraph (strand‑agnostic)
  "$BEDTOOLS_BIN" genomecov -bg -split -ibam "$bam" > "$raw_bg"
  # Normalized bedGraph
  awk -v sf="$sf" '{printf "%s\t%s\t%s\t%.6f\n", $1,$2,$3,$4/sf}' "$raw_bg" > "$norm_bg"
  # Sort normalized bedGraph
  sort -k1,1 -k2,2n "$norm_bg" -o "$norm_sorted_bg"
  # Convert to BigWig
  "$BEDGRAPH_TO_BIGWIG_BIN" "$norm_sorted_bg" "$CHRS" "$bw"
done