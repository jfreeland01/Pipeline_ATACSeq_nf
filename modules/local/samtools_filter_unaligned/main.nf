process SAMTOOLS_FILTER_UNALIGNED {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::samtools=1.18"
    container "quay.io/biocontainers/samtools:1.18--h50ea8bc_1"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}.mapped.bam"), emit: bam

    script:
    // -F 4 drops reads with the "unmapped" SAM flag.
    """
    samtools view -@ ${task.cpus} -b -F 4 -o ${meta.id}.mapped.bam ${bam}
    """
}
