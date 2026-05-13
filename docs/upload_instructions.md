# GitHub upload instructions

These steps prepare and upload `rnaseq2tracks_v2` as a clean GitHub repository.

## 1. Unpack the archive

```bash
unzip rnaseq2tracks_v2.zip
cd rnaseq2tracks_v2
```

## 2. Check the files

```bash
ls
```

You should see:

```text
README.md
RNAfastq2tracks.sh
config/
scripts/
docs/
examples/
tests/
.gitignore
LICENSE
CITATION.cff
```

## 3. Make scripts executable

```bash
chmod +x RNAfastq2tracks.sh scripts/*.sh scripts/*.R
```

## 4. Create a new GitHub repository

Create an empty repository on GitHub, for example:

```text
rnaseq2tracks_v2
```

Do not add a README, license, or `.gitignore` through the GitHub web interface because those files are already included here.

## 5. Initialize Git locally

```bash
git init
git add .
git commit -m "Initial commit: RNAseq2tracks v2"
```

## 6. Connect and push

Replace `<your-user>` with your GitHub username or organization:

```bash
git branch -M main
git remote add origin https://github.com/<your-user>/rnaseq2tracks_v2.git
git push -u origin main
```

## 7. Verify on GitHub

Open the repository page and check that the README displays the workflow schematic on the front page. Also verify that generated runtime outputs such as BAM, FASTQ, bedGraph, and BigWig files are not committed.
