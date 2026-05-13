# Deployment checklist

- [ ] `config/config.sh` has been edited with correct genome paths.
- [ ] `CHROMOSOME_NAMING` matches the BAM and chromosome-size naming style: `ucsc` or `ensembl`.
- [ ] `REGULAR_CHROMS_ONLY="true"` if BigWigs should contain only conventional chromosomes.
- [ ] STAR, FastQC, Trim Galore, bedtools, bedGraphToBigWig, MultiQC, GNU Parallel, and R/DESeq2 are available.
- [ ] Scripts are executable: `chmod +x RNAfastq2tracks.sh scripts/*.sh scripts/*.R`.
- [ ] A small test run produces `counts/raw_counts_matrix.tsv`.
- [ ] A small test run produces `coverage/bigwig/*.regular_chromosomes.bw`.
- [ ] The normalized bedGraph files contain only conventional chromosomes.
- [ ] `reports/multiqc_report.html` is created.
- [ ] Generated FASTQ, BAM, bedGraph, BigWig, and report outputs are not committed to GitHub.
