process SAMTOOLS_INDEX {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::samtools=1.18"
    container "quay.io/biocontainers/samtools:1.18--h50ea8bc_1"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${bam}.bai"), emit: bai

    script:
    """
    samtools index ${bam}
    """
}
