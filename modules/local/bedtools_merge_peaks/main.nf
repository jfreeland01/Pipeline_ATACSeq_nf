process BEDTOOLS_MERGE_PEAKS {
    label 'process_low'
    publishDir "${params.outdir}/consensus_peaks", mode: 'copy'

    conda "bioconda::bedtools=2.31.1"
    container "quay.io/biocontainers/bedtools:2.31.1--hf5e1c6e_2"

    input:
    path narrowpeaks

    output:
    path "all_concatenate_sorted_merged.narrowPeak.bed", emit: merged_bed

    script:
    """
    cat ${narrowpeaks} > all_concatenate.narrowPeak.bed
    sort -k1,1 -k2,2n all_concatenate.narrowPeak.bed > all_concatenate_sorted.narrowPeak.bed
    bedtools merge -i all_concatenate_sorted.narrowPeak.bed > all_concatenate_sorted_merged.narrowPeak.bed
    """
}
