# Smoke test

This repository does not include FASTQ test data. To smoke-test the workflow, use a tiny paired-end FASTQ subset and verify that the following files are produced:

```text
counts/raw_counts_matrix.tsv
counts/normalized_counts.tsv
coverage/bigwig/*.bw
reports/multiqc_report.html
```

For v2, also verify that the normalized bedGraph files contain only conventional chromosomes:

```bash
awk '{print $1}' results/coverage/bedgraph_norm/*.sorted.bedGraph | sort -u
```

Expected human UCSC chromosomes are `chr1`-`chr22`, `chrX`, `chrY`, and `chrM`.
