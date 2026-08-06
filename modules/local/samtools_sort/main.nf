process SAMTOOLS_SORT {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::samtools=1.18"
    container "quay.io/biocontainers/samtools:1.18--h50ea8bc_1"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}.sorted.bam"), emit: bam

    script:
    """
    samtools sort -@ ${task.cpus} -o ${meta.id}.sorted.bam ${bam}
    """
}
