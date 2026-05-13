#!/bin/bash
# run_coverage.sh
# Generate coverage files from STAR sorted BAM files.
# v2 change: BigWig files are created only from conventional chromosomes by
# default. This removes alternative contigs, random scaffolds, decoys, and other
# non-standard references before bedGraphToBigWig conversion.

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
  echo "[run_coverage] Error: unknown species '$SPECIES' (use human or mouse)" >&2
  exit 1
fi

mkdir -p "$COV_DIR/bedgraph_raw" "$COV_DIR/bedgraph_norm" "$COV_DIR/bigwig"

bool_true() {
  case "${1:-}" in
    true|TRUE|yes|YES|1) return 0 ;;
    *) return 1 ;;
  esac
}

regular_chrom_pattern() {
  local species="$1"
  local naming="$2"

  if [[ "$naming" == "ucsc" && "$species" == "human" ]]; then
    printf '^chr([1-9]|1[0-9]|2[0-2]|X|Y|M)$'
  elif [[ "$naming" == "ucsc" && "$species" == "mouse" ]]; then
    printf '^chr([1-9]|1[0-9]|X|Y|M)$'
  elif [[ "$naming" == "ensembl" && "$species" == "human" ]]; then
    printf '^([1-9]|1[0-9]|2[0-2]|X|Y|MT)$'
  elif [[ "$naming" == "ensembl" && "$species" == "mouse" ]]; then
    printf '^([1-9]|1[0-9]|X|Y|MT)$'
  else
    echo "[run_coverage] Error: unsupported CHROMOSOME_NAMING='$naming' for species='$species'" >&2
    exit 1
  fi
}

filter_regular_chromosomes() {
  local in_bg="$1"
  local out_bg="$2"
  local pattern="$3"

  if bool_true "${REGULAR_CHROMS_ONLY:-true}"; then
    awk -v pat="$pattern" '$1 ~ pat {print}' "$in_bg" > "$out_bg"
  else
    cp "$in_bg" "$out_bg"
  fi
}

PATTERN="$(regular_chrom_pattern "$SPECIES" "${CHROMOSOME_NAMING:-ucsc}")"

# Read size factors into associative array
# Expected columns: sample<TAB>size_factor
if [[ ! -s "$SF_FILE" ]]; then
  echo "[run_coverage] Error: size factor file not found or empty: $SF_FILE" >&2
  exit 1
fi

declare -A SF
while IFS=$'\t' read -r sample sf; do
  [[ -n "${sample:-}" && -n "${sf:-}" ]] || continue
  SF[$sample]="$sf"
done < <(tail -n +2 "$SF_FILE")

for bam in "$STAR_DIR"/*/Aligned.sortedByCoord.out.bam; do
  [[ -f "$bam" ]] || continue

  sample_dir="$(dirname "$bam")"
  sample="$(basename "$sample_dir")"
  sf="${SF[$sample]:-1}"

  raw_all_bg="$COV_DIR/bedgraph_raw/${sample}.all_chromosomes.bedGraph"
  raw_bg="$COV_DIR/bedgraph_raw/${sample}.regular_chromosomes.bedGraph"
  norm_all_bg="$COV_DIR/bedgraph_norm/${sample}.all_chromosomes.bedGraph"
  norm_bg="$COV_DIR/bedgraph_norm/${sample}.regular_chromosomes.bedGraph"
  norm_sorted_bg="$COV_DIR/bedgraph_norm/${sample}.regular_chromosomes.sorted.bedGraph"
  bw="$COV_DIR/bigwig/${sample}.regular_chromosomes.bw"

  echo "[run_coverage] Generating coverage for $sample (sf=$sf; regular_chroms=${REGULAR_CHROMS_ONLY:-true}; naming=${CHROMOSOME_NAMING:-ucsc})"

  # Raw bedGraph from all chromosomes present in the BAM.
  "$BEDTOOLS_BIN" genomecov -bg -split -ibam "$bam" > "$raw_all_bg"

  # Keep only conventional chromosomes for UCSC/browser-friendly output.
  filter_regular_chromosomes "$raw_all_bg" "$raw_bg" "$PATTERN"

  # Normalized bedGraph from the filtered raw bedGraph.
  awk -v sf="$sf" '{printf "%s\t%s\t%s\t%.6f\n", $1,$2,$3,$4/sf}' "$raw_bg" > "$norm_bg"

  # Sort normalized bedGraph before BigWig conversion.
  LC_COLLATE=C sort -k1,1 -k2,2n "$norm_bg" -o "$norm_sorted_bg"

  # For transparency, keep an all-chromosome normalized bedGraph only when
  # regular chromosome filtering is disabled.
  if ! bool_true "${REGULAR_CHROMS_ONLY:-true}"; then
    awk -v sf="$sf" '{printf "%s\t%s\t%s\t%.6f\n", $1,$2,$3,$4/sf}' "$raw_all_bg" > "$norm_all_bg"
  else
    rm -f "$norm_all_bg"
  fi

  # Convert filtered, sorted bedGraph to BigWig.
  "$BEDGRAPH_TO_BIGWIG_BIN" "$norm_sorted_bg" "$CHRS" "$bw"

  if [[ ! -s "$bw" ]]; then
    echo "[run_coverage] Error: BigWig was not created for $sample" >&2
    exit 1
  fi

done
