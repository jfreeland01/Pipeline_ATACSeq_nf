#!/usr/bin/env bash
# Example run script for Pipeline_ATACSeq_nf (preprocessing stage).
# Copied from the "Quick start" / "Usage" format in README.md — edit the
# paths below to point at your own fastq/output/reference directories.
#
# NOTE: this script must be run from *inside* this repo (the same directory
# as main.nf) — "." in `nextflow run .` below means "the pipeline project in
# the current directory". If you copy this script elsewhere (e.g. a separate
# run/data directory), replace "." with the absolute path to this repo, e.g.
# `nextflow run /path/to/Pipeline_ATACSeq_nf -profile docker ...`.

set -euo pipefail

# --threads: cpus given to each process_high job (bowtie2_align, bamcoverage, ...).
# Based on a 40-core workstation: bowtie2 sees diminishing returns past ~8-12
# threads, so pick based on how many samples run concurrently, not raw core count.
#   - Running just a couple samples at once -> use 16-20 (fewer concurrent jobs,
#     so give each one more cores)
#   - Running many samples at once          -> use 8-12 (leaves room for more
#     samples to align in parallel)

nextflow run . -profile docker \
    --input samplesheet.csv \
    --bowtie2_index /path/to/GRCh38_noalt_decoy_as/GRCh38_noalt_decoy_as \
    --blacklist_bed assets/reference/hg38-blacklist.v2.bed \
    --chrom_sizes assets/reference/GRCH38_noalt_decoy_as.chrom.sizes \
    --outdir results \
    --threads 8 \
    -resume
