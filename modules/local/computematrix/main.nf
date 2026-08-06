process COMPUTEMATRIX {
    label 'process_high'
    publishDir "${params.outdir}/computeMatrix", mode: 'copy'

    conda "bioconda::deeptools=3.5.5"
    container "quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0"

    input:
    path bigwigs
    path tss_bed

    output:
    path "ComputeMatrix_RefPnt.gz", emit: matrix

    script:
    """
    computeMatrix reference-point \\
        --referencePoint TSS \\
        --regionsFileName ${tss_bed} \\
        --scoreFileName ${bigwigs} \\
        --beforeRegionStartLength ${params.tss_before} \\
        --afterRegionStartLength ${params.tss_after} \\
        --binSize ${params.tss_binsize} \\
        --outFileName ComputeMatrix_RefPnt.gz \\
        --numberOfProcessors ${task.cpus} \\
        --missingDataAsZero \\
        --skipZeros
    """
}
