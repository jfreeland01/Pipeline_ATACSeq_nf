process BEDTOOLS_SUBTRACT_BLACKLIST {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}/bam/filtered", mode: 'copy'

    conda "bioconda::bedtools=2.31.1"
    container "quay.io/biocontainers/bedtools:2.31.1--hf5e1c6e_2"

    input:
    tuple val(meta), path(bam)
    path blacklist_bed

    output:
    // _V8 kept as the filename suffix to match the original script's naming,
    // since CONSENSUS_PEAKS (run standalone) globs for "*_V8.bam".
    tuple val(meta), path("${meta.id}_V8.bam"), emit: bam

    script:
    """
    bedtools subtract -a ${bam} -b ${blacklist_bed} -A > ${meta.id}_V8.bam
    """
}
