# Specification for Simplified RNA‑seq Workflow

## A. What is reusable

* The overall structure of the original `fastq2tracks` project (master script invoking modular helper scripts) is reused.
* The concept of using **STAR** for alignment and generating gene counts via `--quantMode GeneCounts` is retained.
* The idea of producing strand‑specific bedGraph/BigWig files and creating UCSC track lines is adapted.
* The MultiQC reporting pipeline is reused conceptually to summarise QC reports.

## B. What is not reusable as is

* Dataset‑specific scripts that embed absolute file paths, project‑specific directories or HPC scheduler directives are removed or parameterised.
* Hard‑coded references to previous FASTQ file naming conventions are generalised.
* Scripts that performed ChIP‑seq specific processing (e.g. replicate merging, spike‑in normalisation) are dropped.

## C. Proposed technical specification

### Scope (Version 1)

* **Input formats**: The workflow accepts single‑end or paired‑end FASTQ reads.  Paired reads must be named with a `_1` and `_2` suffix before `.fq.gz`.
* **Library strandedness**: Both stranded and unstranded libraries are supported via an optional sample sheet.  The sample sheet has two columns (`sample, strandedness`) where `strandedness` can be `forward`, `reverse` or `unstranded` and informs downstream analyses.
* **Alignment**: Reads are aligned with **STAR** using a user‑provided genome index and annotation (GTF).  Alignments are sorted by coordinate and gene counts are written via `--quantMode GeneCounts`.
* **Count matrix**: Gene counts are extracted from the `ReadsPerGene.out.tab` files produced by STAR.  By default, the unstranded counts (column 2) are used.
* **Normalisation**: Size factors are estimated using **DESeq2**.  Normalised counts are computed using the size‑factor × mean‑RPM anchor (SF_rpm) method.  This normalisation is intended for visualisation; raw counts should be used for differential expression.
* **Coverage tracks**: Raw bedGraph, normalised bedGraph and normalised BigWig files are generated for each sample.  Normalised coverage is obtained by dividing coverage by the DESeq2 size factor and scaling by the mean RPM across all genes.
* **Quality control**: **FastQC** is run on both raw and trimmed reads.  Adapter trimming is performed with **Trim Galore**.  **MultiQC** summarises QC and mapping statistics.
* **Master script**: A single bash script (`RNAfastq2tracks.sh`) orchestrates all steps.  Helper scripts encapsulate discrete tasks (fastqc, trimming, alignment, counts, normalisation, coverage, reports, track creation).
* **Configuration**: All machine‑specific paths (genome indexes, annotations, chromosome sizes, tool binaries) are defined in `config/config.sh` and must be edited by the user before running the pipeline.
* **Outputs**: The workflow stops at generating raw counts and SF_rpm normalised counts; it does not perform differential expression itself.  The normalised counts and BigWig files can be used as inputs to DESeq2 or visualised in genome browsers.

### Single‑end vs Paired‑end Support

The master script accepts an optional argument `paired|single`.  If `paired` (default), the trimming and alignment scripts expect paired FASTQ files.  If `single`, each FASTQ file is processed independently.

### Stranded vs Unstranded Support

Strandedness is specified per sample in an optional CSV sample sheet.  While STAR will always compute counts for all three orientations, downstream differential expression analyses can use the appropriate column based on the sample’s strandedness.  This workflow currently uses unstranded counts (column 2) for simplicity.

### Count Matrix Generation

STAR writes a `ReadsPerGene.out.tab` file for each sample.  This tab‑delimited file contains four columns: gene identifier, unstranded counts, forward‑strand counts and reverse‑strand counts.  The helper script `run_gene_counts.sh` extracts the gene names and the column specified by `GENE_COUNTS_COLUMN` in the configuration file (default 2) and merges them into a single matrix.  The result (`raw_counts_matrix.tsv`) has genes as rows and samples as columns.

### Coverage Normalisation Method

Coverage is computed using `bedtools genomecov` on the sorted BAM files.  The raw coverage (read depth per base) is divided by the DESeq2 size factor for each sample and scaled by the mean reads per million (RPM) across all genes, producing the SF_rpm normalised coverage.  BedGraph files are sorted and converted to BigWig format with the `bedGraphToBigWig` utility and chromosome size files.

### Required Config Variables

The file `config/config.sh` defines the following variables:

| Variable | Description |
|---------|-------------|
| `STAR_INDEX_HUMAN` | Path to the STAR genome index for human (hg38 or other build) |
| `STAR_INDEX_MOUSE` | Path to the STAR genome index for mouse (mm10/mm39) |
| `GTF_HUMAN` | Path to the GTF annotation file for human |
| `GTF_MOUSE` | Path to the GTF annotation file for mouse |
| `CHROM_SIZES_HUMAN` | Chromosome sizes file for human (used by bedGraphToBigWig) |
| `CHROM_SIZES_MOUSE` | Chromosome sizes file for mouse |
| `FASTQC_BIN` | Executable for FastQC |
| `TRIMGALORE_BIN` | Executable for Trim Galore |
| `STAR_BIN` | Executable for STAR |
| `BEDTOOLS_BIN` | Executable for bedtools |
| `BEDGRAPH_TO_BIGWIG_BIN` | Executable for bedGraphToBigWig |
| `MULTIQC_BIN` | Executable for MultiQC |
| `R_BIN` | Executable for Rscript |
| `GENE_COUNTS_COLUMN` | Column number in STAR counts file to use (default 2) |

## D. Proposed Repository Tree

The simplified workflow repository is organised as follows:

```
rna_seq_pipeline/
├── README.md                 # Overview, usage and requirements
├── RNAfastq2tracks.sh        # Master script
├── config/
│   └── config.sh             # User‑editable configuration
├── scripts/
│   ├── run_fastqc.sh         # Run FastQC on FASTQ files
│   ├── run_trimming.sh       # Trim adapters with Trim Galore
│   ├── run_star.sh           # Align reads with STAR
│   ├── run_gene_counts.sh    # Merge STAR gene counts
│   ├── run_normalization.R   # Estimate size factors and normalise counts
│   ├── run_coverage.sh       # Compute and normalise coverage; create BigWigs
│   ├── run_multiqc.sh        # Run MultiQC across the project
│   └── create_ucsc_tracks.sh # Generate UCSC track hub entries
└── docs/
    ├── specification.md      # This specification
    ├── reuse_map.md          # Mapping of reused vs replaced scripts
    ├── repository_tree.md    # Tree of the repository
    ├── upload_instructions.md# How to upload to GitHub
    ├── checklist.md          # Final checklist before run
    └── report.pdf            # PDF rendering of the specification
```

## E. Assumptions and Risks

* **Genome indexes** – The user must supply correct STAR genome indexes and annotation files for the chosen species.  The pipeline does not download or build indexes automatically.
* **Software availability** – The workflow assumes that STAR, FastQC, Trim Galore, bedtools, bedGraphToBigWig, MultiQC and R with DESeq2/apeglm are installed and accessible via the configured paths.
* **Input naming** – Paired‑end reads must follow the `_1.fq.gz`/`_2.fq.gz` naming convention.  Trim Galore output suffixes (`_val_1.fq.gz`) are handled automatically.
* **Resources** – Running STAR and DESeq2 can be resource‑intensive.  Adjust `max_jobs` and ensure adequate memory and disk space for your datasets.
* **Strandedness** – The workflow does not automatically detect library strandedness.  Incorrect specification may affect downstream differential expression analyses.
* **Normalisation** – The SF_rpm normalisation is intended for visualisation.  For statistical testing, use raw counts and perform differential expression analysis with DESeq2 or another tool.
* **Testing** – Prior to full use, test the pipeline on a small dataset to verify that all dependencies are installed and configured correctly.

## F. Final Recommendation

This workflow strikes a balance between reuse of proven components and simplification for new users.  By modularising each step and exposing configuration variables, it provides flexibility while remaining accessible.  For production use, further validation on representative datasets is recommended.  Users should carefully edit the configuration file to point to their own genome indexes and adjust resource usage according to their computing environment.