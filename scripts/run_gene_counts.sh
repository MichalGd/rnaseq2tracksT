#!/bin/bash
# run_gene_counts.sh
# Merge STAR gene counts (ReadsPerGene.out.tab) into a single count matrix.
# The STAR counts file contains four columns: gene name, unstranded counts,
# forward‑strand counts, reverse‑strand counts.  This script uses the column
# specified by GENE_COUNTS_COLUMN in config/config.sh (default: 2 for
# unstranded).  The merged matrix will have genes as rows and samples as
# columns.  Output files include:
#   raw_counts.tsv       – genes and counts (without header)
#   raw_counts_matrix.tsv – counts matrix with header row

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <star_dir> <counts_dir> <species> <layout>" >&2
  exit 1
fi

STAR_DIR="$1"
OUT_DIR="$2"
SPECIES="$3"
LAYOUT="$4"

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config/config.sh"

mkdir -p "$OUT_DIR"

# Collect per‑sample counts into temporary files
tmp_dir="$(mktemp -d)"
samples=()
for sample_dir in "$STAR_DIR"/*; do
  [[ -d "$sample_dir" ]] || continue
  sample=$(basename "$sample_dir")
  counts_file="$sample_dir/ReadsPerGene.out.tab"
  if [[ ! -f "$counts_file" ]]; then
    echo "[run_gene_counts] Warning: counts file missing for $sample (expected $counts_file)" >&2
    continue
  fi
  samples+=("$sample")
  # Extract gene names and the chosen count column.  Skip header lines (first 4 lines)
  awk -v col="$GENE_COUNTS_COLUMN" 'NR>4 {print $1"\t"$col}' "$counts_file" > "$tmp_dir/${sample}.tsv"
done

if [[ ${#samples[@]} -eq 0 ]]; then
  echo "[run_gene_counts] Error: no counts files found" >&2
  exit 1
fi

# Build merged matrix
first_sample="${samples[0]}"
cut -f1 "$tmp_dir/${first_sample}.tsv" > "$OUT_DIR/genes.tsv"

# Start with gene names as first column
cp "$OUT_DIR/genes.tsv" "$OUT_DIR/raw_counts.tsv"

for sample in "${samples[@]}"; do
  # Add sample counts as a new column
  paste "$OUT_DIR/raw_counts.tsv" <(cut -f2 "$tmp_dir/${sample}.tsv") > "$OUT_DIR/raw_counts.tmp"
  mv "$OUT_DIR/raw_counts.tmp" "$OUT_DIR/raw_counts.tsv"
done

# Build header
header="gene"
for sample in "${samples[@]}"; do
  header+="\t${sample}"
done

# Prepend header and write matrix
{ echo -e "$header"; cat "$OUT_DIR/raw_counts.tsv"; } > "$OUT_DIR/raw_counts_matrix.tsv"

# Clean up
rm -rf "$tmp_dir" "$OUT_DIR/genes.tsv"

echo "[run_gene_counts] Wrote $OUT_DIR/raw_counts_matrix.tsv"