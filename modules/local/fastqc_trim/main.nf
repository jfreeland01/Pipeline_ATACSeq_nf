process FASTQC_TRIM {
    tag "$meta.id"
    label 'process_low'
    publishDir { "${params.outdir}/fastqc/trimmed/${meta.id}" }, mode: 'copy'

    conda "bioconda::fastqc=0.12.1"
    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip"),  emit: zip

    script:
    """
    fastqc -o . -t ${task.cpus} ${reads}
    """
}
