process WIGTOBIGWIG {
    label 'process_low'
    publishDir "${params.outdir}/bigwig/mean", mode: 'copy'

    conda "bioconda::ucsc-wigtobigwig=447"
    container "quay.io/biocontainers/ucsc-wigtobigwig:447--h2a80c09_2"

    input:
    path wig
    path chrom_sizes

    output:
    path "${wig.simpleName}.bw", emit: bigwig

    script:
    """
    wigToBigWig ${wig} ${chrom_sizes} ${wig.simpleName}.bw
    """
}
