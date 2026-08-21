process BIGWIGTOWIG {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}/wig", mode: 'copy'

    conda "bioconda::ucsc-bigwigtowig=482"
    container "quay.io/biocontainers/ucsc-bigwigtowig:482--h0b57e2e_0"

    input:
    tuple val(meta), path(bigwig)

    output:
    tuple val(meta), path("${meta.id}.wig"), emit: wig

    script:
    // bigWigToWig only takes in.bigWig out.wig (chrom sizes are embedded in
    // the bigWig header) — it does not take a chrom.sizes argument, unlike
    // wigToBigWig (the reverse conversion, used in modules/local/wigtobigwig).
    """
    bigWigToWig ${bigwig} ${meta.id}.wig
    """
}
