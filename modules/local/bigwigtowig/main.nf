process BIGWIGTOWIG {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}/wig", mode: 'copy'

    conda "bioconda::ucsc-bigwigtowig=447"
    container "quay.io/biocontainers/ucsc-bigwigtowig:447--h954228d_0"

    input:
    tuple val(meta), path(bigwig)
    path chrom_sizes

    output:
    tuple val(meta), path("${meta.id}.wig"), emit: wig

    script:
    """
    bigWigToWig ${bigwig} ${chrom_sizes} ${meta.id}.wig
    """
}
