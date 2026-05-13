#!/bin/bash
# create_ucsc_tracks.sh
# Generate simple UCSC track lines for BigWig files in the specified directory.
# Usage: create_ucsc_tracks.sh <bigwig_dir>
# The script prints track lines to stdout; redirect output to a file such as
# <output_dir>/tracks/hub.txt.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <bigwig_dir>" >&2
  exit 1
fi

BIGWIG_DIR="$1"

for bw in "$BIGWIG_DIR"/*.bw; do
  [[ -f "$bw" ]] || continue
  file=$(basename "$bw")
  name="${file%.bw}"
  echo "track type=bigWig name=\"$name\" description=\"$name normalized coverage\" bigDataUrl=$file"
done