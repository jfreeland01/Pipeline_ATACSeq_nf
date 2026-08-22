process BEDTOOLS_MULTICOV {
    label 'process_medium'
    publishDir "${params.outdir}/consensus_peaks", mode: 'copy'

    conda "bioconda::bedtools=2.31.1"
    container "quay.io/biocontainers/bedtools:2.31.1--hf5e1c6e_2"

    input:
    path merged_bed
    path bams
    path bais
    val sample_ids

    output:
    path "multicov_merged_counts.txt", emit: counts

    script:
    def header = (['chr', 'start', 'end'] + sample_ids).join('\t')
    """
    printf '${header}\\n' > multicov_merged_counts.txt
    bedtools multicov -bams ${bams.join(' ')} -bed ${merged_bed} >> multicov_merged_counts.txt
    """
}
