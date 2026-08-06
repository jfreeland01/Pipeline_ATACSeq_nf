process PLOTHEATMAP {
    label 'process_low'
    publishDir "${params.outdir}/computeMatrix", mode: 'copy'

    conda "bioconda::deeptools=3.5.5"
    container "quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0"

    input:
    path matrix

    output:
    path "OverallTSS_heatmap.png", emit: heatmap

    script:
    """
    plotHeatmap -m ${matrix} -out OverallTSS_heatmap.png
    """
}
