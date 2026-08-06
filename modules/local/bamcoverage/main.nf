process BAMCOVERAGE {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}/bigwig", mode: 'copy'

    conda "bioconda::deeptools=3.5.5"
    container "quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0"

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("${meta.id}.bw"), emit: bigwig

    script:
    """
    bamCoverage -b ${bam} \\
        --normalizeUsing RPGC \\
        --effectiveGenomeSize ${params.effective_genome_size} \\
        -p ${task.cpus} \\
        -o ${meta.id}.bw \\
        --binSize ${params.bigwig_binsize}
    """
}
