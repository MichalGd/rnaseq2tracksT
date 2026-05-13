#!/bin/bash
# run_multiqc.sh
# Run MultiQC across the entire project directory and save the report to a
# specified output directory.  MultiQC will automatically discover FastQC,
# STAR and Trim Galore logs.

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <project_dir> <report_dir>" >&2
  exit 1
fi

PROJECT_DIR="$1"
REPORT_DIR="$2"

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config/config.sh"

mkdir -p "$REPORT_DIR"

echo "[run_multiqc] Running MultiQC on $PROJECT_DIR"
"$MULTIQC_BIN" "$PROJECT_DIR" --outdir "$REPORT_DIR"