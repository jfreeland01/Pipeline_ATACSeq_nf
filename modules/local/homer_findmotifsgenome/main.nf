process HOMER_FINDMOTIFSGENOME {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}/homer", mode: 'copy'

    conda "bioconda::homer=4.11"
    container "quay.io/biocontainers/homer:4.11--pl5321hdfd78af_5"

    input:
    tuple val(meta), path(peaks_txt)

    output:
    tuple val(meta), path("${meta.id}"), emit: motifs

    script:
    """
    findMotifsGenome.pl ${peaks_txt} ${params.homer_genome} ${meta.id} -size given -p ${task.cpus}
    """
}
