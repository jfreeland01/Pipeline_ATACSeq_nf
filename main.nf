#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * Five named workflows live in this repo, dispatched by --stage (default
 * "preprocessing" runs the full preprocessing chain). Each post-processing
 * stage can also be run on its own:
 *
 *   nextflow run . ...                                    (preprocessing, default)
 *   nextflow run . --stage consensus_peaks ...
 *   nextflow run . --stage motif_enrichment ...
 *   nextflow run . --stage wig_mean ...
 *   nextflow run . --stage tss_heatmap ...
 *
 * (Nextflow's `-entry` flag is not used here — recent Nextflow versions'
 * default "strict" syntax parser dropped -entry support for named workflows
 * in favor of exactly this param-dispatch pattern.)
 *
 * See README.md for required params per stage.
 */

include { PREPROCESSING }    from './workflows/preprocessing'
include { CONSENSUS_PEAKS }  from './workflows/consensus_peaks'
include { MOTIF_ENRICHMENT } from './workflows/motif_enrichment'
include { WIG_MEAN }         from './workflows/wig_processing'
include { TSS_HEATMAP }      from './workflows/tss_heatmap'

params.stage = 'preprocessing'

workflow {
    if( params.stage == 'preprocessing' ) {
        PREPROCESSING()
    }
    else if( params.stage == 'consensus_peaks' ) {
        CONSENSUS_PEAKS()
    }
    else if( params.stage == 'motif_enrichment' ) {
        MOTIF_ENRICHMENT()
    }
    else if( params.stage == 'wig_mean' ) {
        WIG_MEAN()
    }
    else if( params.stage == 'tss_heatmap' ) {
        TSS_HEATMAP()
    }
    else {
        error "Unknown --stage '${params.stage}'. Valid values: preprocessing, consensus_peaks, motif_enrichment, wig_mean, tss_heatmap"
    }
}
