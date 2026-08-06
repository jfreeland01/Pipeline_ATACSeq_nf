process SAMTOOLS_SAM_TO_BAM {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::samtools=1.18"
    container "quay.io/biocontainers/samtools:1.18--h50ea8bc_1"

    input:
    tuple val(meta), path(sam)

    output:
    tuple val(meta), path("${meta.id}.bam"), emit: bam

    script:
    """
    samtools view -@ ${task.cpus} -bS -o ${meta.id}.bam ${sam}
    """
}
