include { COMPUTEMATRIX } from '../modules/local/computematrix'
include { PLOTHEATMAP }   from '../modules/local/plotheatmap'

// Mirrors ATACSeq_postprocessing_JF_ComputeMatrix_heatmap.sh: build a TSS
// reference-point matrix across all bigWigs in a directory and plot it as a heatmap.
workflow TSS_HEATMAP {

    main:
    if( !params.bigwig_dir ) error "TSS_HEATMAP requires --bigwig_dir <directory of *.bw files>"
    if( !params.tss_bed )    error "TSS_HEATMAP requires --tss_bed <TSS reference-point BED file>"

    ch_bigwigs = Channel.fromPath("${params.bigwig_dir}/*.bw").collect()

    COMPUTEMATRIX(ch_bigwigs, params.tss_bed)

    PLOTHEATMAP(COMPUTEMATRIX.out.matrix)

    emit:
    matrix  = COMPUTEMATRIX.out.matrix
    heatmap = PLOTHEATMAP.out.heatmap
}
