#!/usr/bin/env Rscript
# run_normalization.R
# Estimate size factors using DESeq2 and compute SF_rpm normalized counts.
# Arguments:
#   1: raw counts matrix file (tab‑delimited, first column gene, header row)
#   2: output file for size factors
#   3: output file for normalized counts

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  cat("Usage: run_normalization.R <raw_counts_matrix.tsv> <size_factors.tsv> <normalized_counts.tsv>\n", file=stderr())
  quit(status=1)
}

raw_counts_file <- args[1]
sf_out <- args[2]
norm_out <- args[3]

suppressPackageStartupMessages({
  library(DESeq2)
})

# Read counts; row names as gene identifiers
counts <- read.delim(raw_counts_file, header=TRUE, row.names=1, check.names=FALSE)

# Remove genes with zero counts across all samples
counts <- counts[rowSums(counts) > 0, , drop=FALSE]

# Create a dummy condition since DESeq2 requires a design; the actual design is irrelevant for size factors
condition <- rep("case", ncol(counts))
coldata <- data.frame(row.names=colnames(counts), condition)

dds <- DESeqDataSetFromMatrix(counts, coldata, ~ condition)
dds <- estimateSizeFactors(dds)
size_factors <- sizeFactors(dds)

# Write size factors
sf_df <- data.frame(sample=names(size_factors), size_factor=as.numeric(size_factors))
write.table(sf_df, file=sf_out, sep="\t", quote=FALSE, row.names=FALSE)

# Calculate SF_rpm normalized counts
libs <- colSums(counts)
rpm <- t(t(counts) / libs * 1e6)
mean_rpm <- rowMeans(rpm)

norm_counts <- counts
for (i in seq_along(size_factors)) {
  # Divide counts by size factor and scale by mean RPM (per gene)
  norm_counts[, i] <- (counts[, i] / size_factors[i]) * (mean_rpm / 1e6)
}

norm_df <- data.frame(gene=rownames(norm_counts), norm_counts, check.names=FALSE)
write.table(norm_df, file=norm_out, sep="\t", quote=FALSE, row.names=FALSE)

cat(sprintf("[run_normalization.R] Wrote %s and %s\n", sf_out, norm_out))