# Repository Tree

The following tree illustrates the files and directories included in the simplified RNA‑seq workflow.  It is intended as a quick reference when browsing or uploading the project to GitHub.  Generated output directories (e.g. `fastqc_raw`, `star`, `counts`) are not included in the repository and will be created at runtime.

```
rna_seq_pipeline/
├── README.md
├── RNAfastq2tracks.sh
├── config/
│   └── config.sh
├── scripts/
│   ├── run_fastqc.sh
│   ├── run_trimming.sh
│   ├── run_star.sh
│   ├── run_gene_counts.sh
│   ├── run_normalization.R
│   ├── run_coverage.sh
│   ├── run_multiqc.sh
│   └── create_ucsc_tracks.sh
└── docs/
    ├── specification.md
    ├── reuse_map.md
    ├── repository_tree.md
    ├── upload_instructions.md
    ├── checklist.md
    └── report.pdf
```

Each script in the `scripts/` directory is designed to perform a single task.  The master script `RNAfastq2tracks.sh` calls these helpers in sequence.  Documentation resides in `docs/` and should be read before running the workflow.