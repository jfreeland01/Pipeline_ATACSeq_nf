process ALIGNMENTSIEVE {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::deeptools=3.5.5"
    container "quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0"

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("${meta.id}.shifted.bam"), emit: bam

    script:
    // Adjusts for the Tn5 transposase binding offset so peak summits line up.
    """
    alignmentSieve --bam ${bam} \\
        -o ${meta.id}.shifted.bam \\
        --ATACshift \\
        --numberOfProcessors ${task.cpus}
    """
}
