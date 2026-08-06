process MACS3_CALLPEAK {
    tag "$meta.id"
    label 'process_medium'
    publishDir { "${params.outdir}/macs3/${meta.id}" }, mode: 'copy'

    conda "bioconda::macs3=3.0.1"
    container "quay.io/biocontainers/macs3:3.0.1--py311h0152cd7_1"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.narrowPeak"), emit: narrowpeak
    tuple val(meta), path("*.xls"),        emit: xls
    tuple val(meta), path("*.bed"),        emit: summits

    script:
    """
    macs3 callpeak \\
        -f BAMPE \\
        -g ${params.macs_genome_size} \\
        -q ${params.macs_qvalue} \\
        -t ${bam} \\
        -n ${meta.id} \\
        --outdir .
    """
}
