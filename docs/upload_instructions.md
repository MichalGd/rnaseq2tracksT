# Upload Instructions for GitHub

Follow these steps to upload the simplified RNA‑seq workflow to GitHub.  These instructions assume that you have a GitHub account and that Git is installed on your local machine.  Replace `<your‑username>` with your GitHub username and modify paths as needed.

1. **Create a new repository on GitHub**.  Log in to GitHub, click the **New** button to create a repository named `RNAfastq2tracks` or similar.  Do not initialise it with a README, licence or `.gitignore`—we will add these locally.

2. **Clone the empty repository** to your computer:

   ```bash
   git clone https://github.com/<your‑username>/RNAfastq2tracks.git
   cd RNAfastq2tracks
   ```

3. **Copy the workflow files** into the cloned directory.  Assuming the contents of this repository reside in `/path/to/rna_seq_pipeline`:

   ```bash
   cp -r /path/to/rna_seq_pipeline/* .
   ```

4. **Verify the file structure**.  You should see `README.md`, `RNAfastq2tracks.sh`, `config/`, `scripts/` and `docs/` in the current directory.  Run `tree` or `ls` to inspect.

5. **Edit `config/config.sh`** to set the correct paths to your STAR genome indexes, GTF files, chromosome sizes and tool executables.  Commiting incorrect paths may confuse other users; you may prefer to leave the default placeholders and update locally when running the workflow.

6. **Initialise Git and make the first commit** (if the repository is empty).  Add all files and commit:

   ```bash
   git add .
   git commit -m "Initial commit: simplified RNA‑seq workflow"
   ```

7. **Push the commit** to GitHub:

   ```bash
   git push origin main
   ```

8. **Verify on GitHub**.  Navigate to your repository page to confirm that all files have been uploaded.  You can now continue to edit the workflow, track issues and collaborate with others.

These steps create a clean history and ensure that the repository on GitHub mirrors the contents of this project.