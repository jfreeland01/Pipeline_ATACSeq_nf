process CUTADAPT {
    tag "$meta.id"
    label 'process_medium'
    publishDir { "${params.outdir}/cutadapt/${meta.id}" }, mode: 'copy', pattern: '*.log'

    conda "bioconda::cutadapt=4.4"
    container "quay.io/biocontainers/cutadapt:4.4--py39hf95cd2a_1"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}_R{1,2}.trim.fastq.gz"), emit: reads
    tuple val(meta), path("*.log"),                           emit: log

    script:
    def (r1, r2) = reads
    """
    cutadapt \\
        -a ${params.adapter_r1} \\
        -A ${params.adapter_r2} \\
        -j ${task.cpus} \\
        -q ${params.trim_quality_cutoff} \\
        -O ${params.trim_min_overlap} \\
        -m ${params.trim_min_length} \\
        -o ${meta.id}_R1.trim.fastq.gz \\
        -p ${meta.id}_R2.trim.fastq.gz \\
        ${r1} ${r2} \\
        > ${meta.id}_cutadapt.log
    """
}
