process BOWTIE2_ALIGN {
    tag "$meta.id"
    label 'process_high'
    // maxForks 1  // may be needed if running on a personal laptop to avoid exhausting RAM
    publishDir { "${params.outdir}/bowtie2/${meta.id}" }, mode: 'copy', pattern: '*.log'

    // Piped straight into samtools so the SAM (30-60 GB/sample) never touches
    // disk. That also keeps BOWTIE2_ALIGN's output resumable: an earlier
    // version wrote the SAM to disk and had a downstream step delete it to
    // reclaim space, which permanently broke -resume for this (the most
    // expensive) step on every subsequent run.
    conda "bioconda::bowtie2=2.5.1 bioconda::samtools=1.18"
    container "community.wave.seqera.io/library/bowtie2_htslib_samtools_pigz:edeb13799090a2a6"

    input:
    tuple val(meta), path(reads)
    path  index_dir
    val   index_prefix

    output:
    tuple val(meta), path("${meta.id}.bam"), emit: bam
    tuple val(meta), path("*.log"),          emit: log

    script:
    def (r1, r2) = reads
    """
    bowtie2 --non-deterministic --mm --phred33 --very-sensitive \\
        -p ${task.cpus} \\
        -x ${index_dir}/${index_prefix} \\
        -1 ${r1} \\
        -2 ${r2} \\
        2> ${meta.id}_bowtie2.log \\
        | samtools view -@ ${task.cpus} -bS -o ${meta.id}.bam -
    """
}
