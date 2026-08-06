# Pipeline_ATACSeq_nf

A Nextflow (DSL2) port of [Pipeline_ATACSeq](https://github.com/jfreeland01/Pipeline_ATACSeq),
a bulk ATAC-seq analysis pipeline. The original bash scripts remain the reference
implementation and are unaffected by this repo.

One repo, one pipeline. The full preprocessing chain (FastQC → cutadapt → Bowtie2 →
post-alignment filtering → MACS3 → bigWig/Wig) runs by default. Each post-processing
stage from the original scripts (consensus peaks, HOMER motif enrichment, wig
averaging, TSS heatmaps) can also be run on its own with `--stage`, so nothing extra
needs to be cloned or downloaded.

## Requirements

- [Nextflow](https://nextflow.io) >= 23.04 (`brew install nextflow`)
- [Docker](https://www.docker.com) (`-profile docker`) or [Conda](https://docs.conda.io)/Mamba (`-profile conda`)

Every process pins its own Bioconda package + matching Biocontainers image (see
"A note on container tags" below) — there's no single monolithic environment to build.

## Stages

| `--stage` value (default: `preprocessing`) | What it does | Original script |
|---|---|---|
| `preprocessing` | FastQC → cutadapt → FastQC → Bowtie2 → ATAC-shift → filter unmapped/chrM/dups/quality/blacklist → MACS3 → bigWig/Wig | `ATACSeq_preprocessing_JF.sh` |
| `consensus_peaks` | Merge all samples' narrowPeak calls into one consensus peak set; count reads per sample across it | `ATACSeq_postprocessing_JF_PeakConcensusCount.sh` |
| `motif_enrichment` | HOMER `findMotifsGenome.pl` on a directory of peak/region files | `ATACSeq_postprocessing_JF_Homer_findMotifsGenome.sh` |
| `wig_mean` | Average a directory of `.wig` files (e.g. replicates), convert to bigWig | `ATACSeq_postprocessing_JF_WigMeanToBW.sh` |
| `tss_heatmap` | computeMatrix (TSS reference-point) + plotHeatmap across a directory of bigWigs | `ATACSeq_postprocessing_JF_ComputeMatrix_heatmap.sh` |

Differential peak analysis (DESeq2/edgeR/limma) is intentionally **not** automated —
it's an analyst-driven statistical step. See the original repo's README for that
walkthrough; its output (a `.txt` per contrast) is exactly what `motif_enrichment`
expects as input.

> **Why `--stage` instead of `nextflow -entry`?** Recent Nextflow versions' default
> "strict" syntax parser dropped `-entry` support for selecting a named workflow — it
> explicitly recommends dispatching via a parameter instead, which is what `--stage`
> does. All five workflows (`PREPROCESSING`, `CONSENSUS_PEAKS`, `MOTIF_ENRICHMENT`,
> `WIG_MEAN`, `TSS_HEATMAP`) still exist as named, independently-testable Nextflow
> workflows in `workflows/` — `main.nf` just calls the right one based on `--stage`.

## Usage

### 1. Preprocessing (default)

```bash
nextflow run . -profile docker \
    --input samplesheet.csv \
    --bowtie2_index /path/to/GRCh38_noalt_decoy_as/GRCh38_noalt_decoy_as \
    --blacklist_bed /path/to/hg38-blacklist.v2_sorted.bed \
    --chrom_sizes /path/to/GRCh38_noalt_decoy_as.chrom.sizes \
    --outdir results
```

`samplesheet.csv` (see `assets/samplesheet_schema.csv`):

```csv
sample,fastq_1,fastq_2
SAMPLE1,/absolute/path/to/SAMPLE1_R1.fastq.gz,/absolute/path/to/SAMPLE1_R2.fastq.gz
SAMPLE2,/absolute/path/to/SAMPLE2_R1.fastq.gz,/absolute/path/to/SAMPLE2_R2.fastq.gz
```

`--chrom_sizes` is optional — omit it to skip the final bigWig→Wig conversion step.

### 2. Consensus peaks

```bash
nextflow run . -profile docker --stage consensus_peaks \
    --peaks_dir results/macs3 \
    --bams_dir results/bam/filtered
```

### 3. Motif enrichment (HOMER)

```bash
nextflow run . -profile docker --stage motif_enrichment \
    --homer_input_dir /path/to/DESeq2/homer \
    --homer_genome hg38
```

### 4. Wig averaging

```bash
nextflow run . -profile docker --stage wig_mean \
    --wig_input_dir results/wig \
    --chrom_sizes /path/to/GRCh38_noalt_decoy_as.chrom.sizes
```

### 5. TSS accessibility heatmap

```bash
nextflow run . -profile docker --stage tss_heatmap \
    --bigwig_dir results/bigwig \
    --tss_bed /path/to/TSS_1_V2.bed
```

See the original repo's README for how to build the `TSS_1_V2.bed` reference file
from the UCSC Table Browser.

## Key parameters

Full list in `nextflow.config`. Most commonly overridden:

| Param | Default | Notes |
|---|---|---|
| `--adapter_r1` / `--adapter_r2` | `CTGTCTCTTATA` (Nextera) | Swap for your library prep kit |
| `--mapq_threshold` | `30` | Post-alignment MAPQ filter |
| `--macs_genome_size` | `hs` | MACS3 `-g`; `mm` for mouse, etc. |
| `--effective_genome_size` | `2913022398` | Human (GRCh38); override for other organisms |
| `--threads` | `4` | Default CPU allocation; tune per-label resources in `conf/base.config` |

## A note on container tags

Container/conda versions were pinned from the original pipeline's
`Conda_Env_Main_ATACSeq_JF.yml` where an exact build was available (bowtie2, cutadapt,
samtools, deepTools, wiggletools, `ucsc-wigtobigwig`). For tools not pinned in that
file (MACS3, Picard, HOMER, bedtools, `ucsc-bigwigtowig`), a recent, commonly-used
Biocontainers tag was chosen — **verify these against
[biocontainers.pro](https://biocontainers.pro) or `conda search -c bioconda <tool>`
before a production run**, and update the `conda`/`container` directives in the
relevant `modules/local/*/main.nf` if you need a different version.

## Testing

There's no bundled test dataset (a real Bowtie2 GRCh38 index is tens of GB). To smoke-test
the DAG on a laptop:

1. Subsample a real paired-end FASTQ pair to a few thousand reads (e.g. `seqtk sample`).
2. Build or download a small Bowtie2 index (e.g. just chr21, or use
   [nf-core/test-datasets](https://github.com/nf-core/test-datasets) as a starting point).
3. Run with `-profile docker,test` and your small `--input`/`--bowtie2_index`/etc.

`-profile test` only tunes down CPU/memory requests (`conf/test.config`) — you still
supply your own small reference/sample paths on the command line.

To sanity-check the pipeline structure without executing anything (no data or
containers needed):

```bash
nextflow config .                       # validate config
nextflow run . --stage <stage>          # each stage fails fast on its param guard
                                         # if required inputs are missing — confirms
                                         # the DAG wires up correctly
```

## Repo layout

```
main.nf                      # --stage dispatch to one of the 5 workflows below
nextflow.config               # params, profiles (docker/conda/test), resource labels
conf/base.config              # process resource labels (process_low/medium/high)
conf/test.config              # lightweight resource overrides for smoke testing
modules/local/<tool>/main.nf  # one process per tool (own conda + container directive)
workflows/preprocessing.nf    # PREPROCESSING
workflows/consensus_peaks.nf  # CONSENSUS_PEAKS
workflows/motif_enrichment.nf # MOTIF_ENRICHMENT
workflows/wig_processing.nf   # WIG_MEAN
workflows/tss_heatmap.nf      # TSS_HEATMAP
assets/samplesheet_schema.csv # example samplesheet
```
