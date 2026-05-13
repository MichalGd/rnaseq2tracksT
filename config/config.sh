#!/bin/bash
# Configuration variables for RNAseq2tracks v2.
# Edit these paths before running the workflow.

###############################################################################
# Genome indexes and annotations
###############################################################################

STAR_INDEX_HUMAN="/path/to/human/star_index"
STAR_INDEX_MOUSE="/path/to/mouse/star_index"

GTF_HUMAN="/path/to/human/annotations.gtf"
GTF_MOUSE="/path/to/mouse/annotations.gtf"

# Chromosome size files used by bedGraphToBigWig.
# These files may contain all contigs, but v2 filters bedGraph rows before BigWig
# conversion so that only conventional chromosomes are included.
CHROM_SIZES_HUMAN="/path/to/human/chrom.sizes"
CHROM_SIZES_MOUSE="/path/to/mouse/chrom.sizes"

###############################################################################
# Chromosome filtering for UCSC/browser-friendly BigWig files
###############################################################################

# true: keep only regular/conventional chromosomes before BigWig creation.
# false: keep all chromosomes/scaffolds present in BAM.
REGULAR_CHROMS_ONLY="true"

# ucsc keeps chr1, chr2, ..., chrX, chrY, chrM.
# ensembl keeps 1, 2, ..., X, Y, MT.
CHROMOSOME_NAMING="ucsc"

###############################################################################
# Tool executables
###############################################################################

FASTQC_BIN="fastqc"
TRIMGALORE_BIN="trim_galore"
STAR_BIN="STAR"
BEDTOOLS_BIN="bedtools"
BEDGRAPH_TO_BIGWIG_BIN="bedGraphToBigWig"
MULTIQC_BIN="multiqc"
R_BIN="Rscript"

###############################################################################
# Count matrix settings
###############################################################################

# STAR ReadsPerGene.out.tab columns:
# 2 = unstranded counts
# 3 = forward-stranded counts
# 4 = reverse-stranded counts
GENE_COUNTS_COLUMN=2

# END of configuration
