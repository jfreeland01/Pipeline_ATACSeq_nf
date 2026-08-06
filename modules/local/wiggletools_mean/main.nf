process WIGGLETOOLS_MEAN {
    label 'process_medium'
    publishDir "${params.outdir}/wig/mean", mode: 'copy'

    conda "bioconda::wiggletools=1.2.11"
    container "quay.io/biocontainers/wiggletools:1.2.11--hdd126ab_6"

    input:
    path wigs

    output:
    path "mean.wig", emit: mean_wig

    script:
    """
    wiggletools mean ${wigs} > mean.wig
    """
}
