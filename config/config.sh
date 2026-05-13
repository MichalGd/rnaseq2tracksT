#!/bin/bash
# Configuration variables for the RNAfastq2tracks workflow.
# Edit these paths to match your installation.  All variables should be absolute
# paths to avoid ambiguity.

###############################################################################
# Genome indexes and annotations
# Provide the location of STAR genome indexes and GTF annotation files for the
# species you plan to analyse.  These directories/files must exist on your
# system.  Example:
#   STAR_INDEX_HUMAN=/data/genomes/hg38/star_index
#   GTF_HUMAN=/data/genomes/hg38/annotations.gtf
###############################################################################

STAR_INDEX_HUMAN="/path/to/human/star_index"
STAR_INDEX_MOUSE="/path/to/mouse/star_index"

GTF_HUMAN="/path/to/human/annotations.gtf"
GTF_MOUSE="/path/to/mouse/annotations.gtf"

# Chromosome size files required for bedGraphToBigWig
CHROM_SIZES_HUMAN="/path/to/human/chrom.sizes"
CHROM_SIZES_MOUSE="/path/to/mouse/chrom.sizes"

###############################################################################
# Tool executables
# Specify the executables for third‑party software.  If they are available in
# your PATH you can simply specify the command name (e.g. "fastqc"), otherwise
# provide the full path to the binary.  Ensure that these tools are installed
# before running the workflow.
###############################################################################

FASTQC_BIN="fastqc"
TRIMGALORE_BIN="trim_galore"
STAR_BIN="STAR"
BEDTOOLS_BIN="bedtools"
BEDGRAPH_TO_BIGWIG_BIN="bedGraphToBigWig"
MULTIQC_BIN="multiqc"
R_BIN="Rscript"

###############################################################################
# Miscellaneous settings
###############################################################################

# Column of STAR ReadsPerGene.out.tab to use for unstranded counts (1‑based).
# Column 2 corresponds to unstranded counts, column 3 forward, column 4 reverse.
GENE_COUNTS_COLUMN=2

# END of configuration