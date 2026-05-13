This is the top‑level README for the simplified RNA‑seq processing workflow.

## RNAfastq2tracks Workflow

This repository contains a simplified RNA‑seq processing workflow for mapping RNA‑seq reads, generating gene count matrices,
normalizing coverage, and preparing tracks for genome browsers.  It wraps existing scripts from the original RNA‑seq and
fastq2tracks projects, adapting them where necessary.  The goal is to provide an easy‑to‑use pipeline that can be run with
a single command while remaining flexible for more advanced users.

### Requirements

* **Bash** and standard GNU core utilities
* **STAR** aligner (version ≥ 2.7)
* **FastQC** and **Trim Galore**
* **R** with the **DESeq2** and **apeglm** packages
* **bedtools**, **bedGraphToBigWig** (Kent utils)
* **MultiQC** for summarizing QC reports
* Pre‑built STAR genome indexes for your species (human or mouse)

### Usage

Run the master script with the following syntax:

```bash
./RNAfastq2tracks.sh <input_fastq_dir> <output_dir> <max_jobs> <species> [paired|single] [samplesheet.csv]
```

* `<input_fastq_dir>` – directory containing raw FASTQ files (gzipped)
* `<output_dir>` – directory where outputs will be written (will be created if it does not exist)
* `<max_jobs>` – maximum number of parallel jobs for GNU Parallel
* `<species>` – either `human` or `mouse`
* `[paired|single]` (optional) – specifies the read layout; defaults to `paired`
* `[samplesheet.csv]` (optional) – CSV file describing sample names and strandedness (columns: `sample, strandedness`)

Before running, edit `config/config.sh` to point to the appropriate genome indexes, annotation files, chromosome sizes and
installed tool paths for your environment.

### Outputs

The pipeline produces the following outputs under `<output_dir>`:

* `fastqc_raw/` and `fastqc_trimmed/` – FastQC reports on raw and trimmed reads
* `trimmed/` – trimmed FASTQ files
* `star/` – STAR alignment outputs including sorted BAM files and `ReadsPerGene.out.tab` counts
* `counts/` – raw counts (`raw_counts.tsv`), size factors (`size_factors.tsv`) and normalized counts (`normalized_counts.tsv`)
* `coverage/` – raw and normalized bedGraph files (`bedgraph_raw/`, `bedgraph_norm/`) and normalized BigWig files (`bigwig/`)
* `reports/` – MultiQC report summarizing QC metrics
* `tracks/` – UCSC track lines (`hub.txt`) for easy visualization of BigWig files

### Documentation

Full technical details and rationale can be found in `docs/specification.md`.  A PDF rendering of the specification is
available in `docs/report.pdf`.  See `docs/reuse_map.md` for notes on how this workflow reuses or replaces scripts from
previous projects.  The complete repository structure is documented in `docs/repository_tree.md`.  If you plan to upload
this project to GitHub, follow the steps in `docs/upload_instructions.md`.  Finally, use `docs/checklist.md` to verify
that your deployment is complete and functional.

### License

No explicit license is provided.  You are free to adapt this workflow for your own research purposes.  Please cite the
original RNA‑seq and fastq2tracks projects where appropriate.