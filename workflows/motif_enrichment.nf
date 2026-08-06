include { HOMER_FINDMOTIFSGENOME } from '../modules/local/homer_findmotifsgenome'

// Mirrors ATACSeq_postprocessing_JF_Homer_findMotifsGenome.sh: run HOMER
// findMotifsGenome.pl on every differential-peak input file (e.g. DESeq2 output).
workflow MOTIF_ENRICHMENT {

    main:
    if( !params.homer_input_dir ) error "MOTIF_ENRICHMENT requires --homer_input_dir <directory of *.txt peak files>"

    ch_input = Channel.fromPath("${params.homer_input_dir}/*.txt")
        .map { f -> [ [id: f.simpleName], f ] }

    HOMER_FINDMOTIFSGENOME(ch_input)

    emit:
    motifs = HOMER_FINDMOTIFSGENOME.out.motifs
}
