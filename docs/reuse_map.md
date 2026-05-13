# Reuse Map of Old Scripts

This document records how scripts from the original RNA‑seq and fastq2tracks projects have been reused, adapted or replaced in this simplified workflow.  In many cases the original scripts contained hard‑coded paths and project‑specific logic; therefore they were rewritten for clarity and flexibility.  The table below lists each new component, the corresponding source in the old repository (if applicable), the reuse type and notes.

| New Component          | Old Source                          | Reuse Type | Notes |
|------------------------|--------------------------------------|-----------|------|
| `RNAfastq2tracks.sh`  | `fastq2tracks` master script        | **ADAPTED** | The concept of a single entry point calling modular scripts is retained, but the script has been simplified for RNA‑seq and takes explicit arguments rather than reading a configuration file. |
| `run_fastqc.sh`       | `quality.sh` / `fastqc.sh`          | **REPLACED** | Rewritten to call FastQC directly and to use GNU Parallel for concurrent execution. |
| `run_trimming.sh`     | `trim_galore` wrapper               | **REPLACED** | The original wrapper contained hard‑coded directories; this version iterates over input FASTQ files and supports paired or single‑end reads. |
| `run_star.sh`         | `run_star.sh` (RNA‑seq)             | **ADAPTED** | Core STAR command is preserved; parameters and output directories are configured via `config/config.sh`.  Supports both paired and single‑end inputs. |
| `run_gene_counts.sh`  | `merge_gene_counts.sh`              | **ADAPTED** | Simplified merging of STAR gene counts into a matrix.  Column selection is configurable. |
| `run_normalization.R` | *new*                               | **NEW** | Implements size factor estimation using DESeq2 and SF_rpm normalisation; there was no equivalent in the original projects. |
| `run_coverage.sh`     | `create_bedgraph.sh` / `bigWig`     | **ADAPTED** | Adapts coverage generation to RNA‑seq BAM files and applies SF_rpm normalisation. |
| `run_multiqc.sh`      | `multiqc.sh`                        | **REPLACED** | Simplified to a single command; the original script handled specific directory layouts. |
| `create_ucsc_tracks.sh` | `create_ucsc_tracks.sh`           | **ADAPTED** | Preserves the idea of generating UCSC track lines but simplifies the output. |