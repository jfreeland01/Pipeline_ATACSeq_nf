process HOMER_FINDMOTIFSGENOME {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}/homer", mode: 'copy'

    conda "bioconda::homer=4.11"
    container "quay.io/biocontainers/homer:4.11--pl5262h4ac6f70_9"

    input:
    tuple val(meta), path(peaks_txt)

    output:
    tuple val(meta), path("${meta.id}"), emit: motifs

    script:
    // The biocontainers HOMER image ships no genome data packages — they're
    // fetched from HOMER's own server on demand. configureHomer.pl skips the
    // download if the genome is already installed, so this is a no-op after
    // the first run in environments where /usr/local/share/homer persists.
    """
    perl /usr/local/share/homer/configureHomer.pl -install ${params.homer_genome}
    findMotifsGenome.pl ${peaks_txt} ${params.homer_genome} ${meta.id} -size given -p ${task.cpus}
    """
}
