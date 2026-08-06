process PICARD_MARKDUPLICATES {
    tag "$meta.id"
    label 'process_medium'
    publishDir { "${params.outdir}/picard/${meta.id}" }, mode: 'copy', pattern: '*_dup_metrics.txt'

    conda "bioconda::picard=3.1.1"
    container "quay.io/biocontainers/picard:3.1.1--hdfd78af_0"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}.dedup.bam"), emit: bam
    tuple val(meta), path("*_dup_metrics.txt"),    emit: metrics

    script:
    def avail_mem = task.memory ? "-Xmx${task.memory.toGiga()}G" : '-Xmx3G'
    """
    picard ${avail_mem} MarkDuplicates \\
        -I ${bam} \\
        -O ${meta.id}.dedup.bam \\
        -M ${meta.id}_dup_metrics.txt \\
        -REMOVE_DUPLICATES true
    """
}
