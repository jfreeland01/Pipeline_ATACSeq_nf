include { WIGGLETOOLS_MEAN } from '../modules/local/wiggletools_mean'
include { WIGTOBIGWIG }      from '../modules/local/wigtobigwig'

// Mirrors ATACSeq_postprocessing_JF_WigMeanToBW.sh: average a directory of .wig
// files (e.g. biological replicates) and convert the result to bigWig.
workflow WIG_MEAN {

    main:
    if( !params.wig_input_dir ) error "WIG_MEAN requires --wig_input_dir <directory of *.wig files to average>"
    if( !params.chrom_sizes )   error "WIG_MEAN requires --chrom_sizes <chrom.sizes file>"

    ch_wigs = Channel.fromPath("${params.wig_input_dir}/*.wig").collect()

    WIGGLETOOLS_MEAN(ch_wigs)

    WIGTOBIGWIG(WIGGLETOOLS_MEAN.out.mean_wig, params.chrom_sizes)

    emit:
    mean_wig = WIGGLETOOLS_MEAN.out.mean_wig
    bigwig   = WIGTOBIGWIG.out.bigwig
}
