process SAMTOOLS_FILTER_CONTIGS {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::samtools=1.18"
    container "quay.io/biocontainers/samtools:1.18--h50ea8bc_1"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}.contigfilt.bam"), emit: bam

    script:
    // Drops chrM, unplaced/random scaffolds, and decoy contigs.
    """
    samtools view -@ ${task.cpus} -h ${bam} \\
    | egrep -v '${params.exclude_contigs_pattern}' \\
    | samtools view -b -o ${meta.id}.contigfilt.bam -
    """
}
