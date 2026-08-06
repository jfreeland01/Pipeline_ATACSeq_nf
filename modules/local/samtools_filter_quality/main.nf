process SAMTOOLS_FILTER_QUALITY {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::samtools=1.18"
    container "quay.io/biocontainers/samtools:1.18--h50ea8bc_1"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}.q${params.mapq_threshold}.bam"), emit: bam

    script:
    """
    samtools view -b -q ${params.mapq_threshold} -@ ${task.cpus} ${bam} > ${meta.id}.q${params.mapq_threshold}.bam
    """
}
