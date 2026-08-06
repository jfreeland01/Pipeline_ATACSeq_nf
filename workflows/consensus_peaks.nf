include { BEDTOOLS_MERGE_PEAKS } from '../modules/local/bedtools_merge_peaks'
include { BEDTOOLS_MULTICOV }    from '../modules/local/bedtools_multicov'

// Mirrors ATACSeq_postprocessing_JF_PeakConcensusCount.sh: concatenate + sort +
// merge every sample's narrowPeak file into one consensus peak set, then count
// reads from every filtered BAM across those consensus peaks.
workflow CONSENSUS_PEAKS {

    main:
    if( !params.peaks_dir ) error "CONSENSUS_PEAKS requires --peaks_dir <directory containing *.narrowPeak files>"
    if( !params.bams_dir )  error "CONSENSUS_PEAKS requires --bams_dir <directory containing filtered *_V8.bam files>"

    ch_peaks = Channel.fromPath("${params.peaks_dir}/**/*.narrowPeak").collect()

    ch_bams = Channel.fromPath("${params.bams_dir}/*_V8.bam")
        .map { bam -> [ bam.name.replaceFirst(/_V8\.bam$/, ''), bam ] }

    BEDTOOLS_MERGE_PEAKS(ch_peaks)

    BEDTOOLS_MULTICOV(
        BEDTOOLS_MERGE_PEAKS.out.merged_bed,
        ch_bams.map { id, bam -> bam }.collect(),
        ch_bams.map { id, bam -> id }.collect()
    )

    emit:
    merged_bed = BEDTOOLS_MERGE_PEAKS.out.merged_bed
    counts     = BEDTOOLS_MULTICOV.out.counts
}
