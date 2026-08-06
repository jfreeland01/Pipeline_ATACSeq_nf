process BOWTIE2_ALIGN {
    tag "$meta.id"
    label 'process_high'
    publishDir { "${params.outdir}/bowtie2/${meta.id}" }, mode: 'copy', pattern: '*.log'

    conda "bioconda::bowtie2=2.5.1"
    container "quay.io/biocontainers/bowtie2:2.5.1--py39h6fed5c7_2"

    input:
    tuple val(meta), path(reads)
    val index_prefix

    output:
    tuple val(meta), path("${meta.id}.sam"), emit: sam
    tuple val(meta), path("*.log"),          emit: log

    script:
    def (r1, r2) = reads
    """
    bowtie2 --non-deterministic --mm --phred33 --very-sensitive \\
        -p ${task.cpus} \\
        -x ${index_prefix} \\
        -1 ${r1} \\
        -2 ${r2} \\
        -S ${meta.id}.sam \\
        2> ${meta.id}_bowtie2.log
    """
}
