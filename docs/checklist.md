# Final Checklist for RNAfastq2tracks Deployment

Use this checklist to verify that you have completed all necessary steps before running the workflow or sharing the repository.  Tick each box as you verify it.

- [ ] **Executable scripts** – All shell scripts in `scripts/` and the master script `RNAfastq2tracks.sh` have executable permissions (`chmod +x`).
- [ ] **Configuration edited** – `config/config.sh` has been updated with valid absolute paths for genome indexes, GTF files, chromosome size files and tool executables.
- [ ] **Dependencies installed** – Required software (STAR, FastQC, Trim Galore, bedtools, bedGraphToBigWig, MultiQC, R with DESeq2 and apeglm) is installed and accessible.
- [ ] **Test run** – The pipeline has been executed on a small test dataset to ensure that it runs without errors and produces the expected outputs.
- [ ] **Counts generated** – `counts/raw_counts_matrix.tsv`, `counts/size_factors.tsv` and `counts/normalized_counts.tsv` are created after running the pipeline.
- [ ] **Coverage files** – Normalised BigWig files exist in `coverage/bigwig/` and correspond to each sample.
- [ ] **MultiQC report** – A MultiQC report is generated in the `reports/` directory, summarising QC and alignment metrics.
- [ ] **UCSC tracks** – A `tracks/hub.txt` file is created with track lines for each BigWig file.
- [ ] **Documentation complete** – The specification (`docs/specification.md`), reuse map, repository tree, upload instructions and this checklist are present in the `docs/` directory.  The PDF version of the specification (`docs/report.pdf`) has been generated from `docs/specification.md`.
- [ ] **README updated** – The `README.md` accurately reflects the workflow and usage instructions.