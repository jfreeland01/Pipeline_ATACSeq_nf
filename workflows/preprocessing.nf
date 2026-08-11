include { FASTQC_RAW }                             from '../modules/local/fastqc'
include { CUTADAPT }                               from '../modules/local/cutadapt'
include { FASTQC_TRIM }                            from '../modules/local/fastqc_trim'
include { BOWTIE2_ALIGN }                          from '../modules/local/bowtie2_align'
include { SAMTOOLS_SAM_TO_BAM }                    from '../modules/local/samtools_sam_to_bam'
include { SAMTOOLS_SORT as SAMTOOLS_SORT_1 }       from '../modules/local/samtools_sort'
include { SAMTOOLS_INDEX }                         from '../modules/local/samtools_index'
include { ALIGNMENTSIEVE }                         from '../modules/local/alignmentsieve'
include { SAMTOOLS_FILTER_UNALIGNED }              from '../modules/local/samtools_filter_unaligned'
include { SAMTOOLS_FILTER_CONTIGS }                from '../modules/local/samtools_filter_contigs'
include { SAMTOOLS_SORT as SAMTOOLS_SORT_2 }       from '../modules/local/samtools_sort'
include { PICARD_MARKDUPLICATES }                  from '../modules/local/picard_markduplicates'
include { SAMTOOLS_FILTER_QUALITY }                from '../modules/local/samtools_filter_quality'
include { BEDTOOLS_SUBTRACT_BLACKLIST }            from '../modules/local/bedtools_subtract_blacklist'
include { SAMTOOLS_INDEX as SAMTOOLS_INDEX_FINAL } from '../modules/local/samtools_index'
include { MACS3_CALLPEAK }                         from '../modules/local/macs3_callpeak'
include { BAMCOVERAGE }                            from '../modules/local/bamcoverage'
include { BIGWIGTOWIG }                            from '../modules/local/bigwigtowig'

// Mirrors ATACSeq_preprocessing_JF.sh step for step: FastQC -> cutadapt -> FastQC
// -> Bowtie2 -> ATAC-shift -> filter unmapped/chrM/dups/quality/blacklist -> MACS3 -> bigWig/Wig.
// Each _V1.._V8 intermediate in the original script becomes a channel here instead
// of a named file on disk.
workflow PREPROCESSING {

    main:
    if( !params.input )         error "PREPROCESSING requires --input <samplesheet.csv> (columns: sample,fastq_1,fastq_2)"
    if( !params.bowtie2_index ) error "PREPROCESSING requires --bowtie2_index <path prefix to a Bowtie2 index>"
    if( !params.blacklist_bed ) error "PREPROCESSING requires --blacklist_bed <ENCODE blacklist BED>"

    ch_reads = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> [ [id: row.sample], [file(row.fastq_1), file(row.fastq_2)] ] }

    FASTQC_RAW(ch_reads)

    CUTADAPT(ch_reads)

    FASTQC_TRIM(CUTADAPT.out.reads)

    ch_bt2_index = Channel.value(file(params.bowtie2_index).parent)
    def bt2_prefix  = file(params.bowtie2_index).name

    BOWTIE2_ALIGN(CUTADAPT.out.reads, ch_bt2_index, bt2_prefix)

    SAMTOOLS_SAM_TO_BAM(BOWTIE2_ALIGN.out.sam)

    SAMTOOLS_SORT_1(SAMTOOLS_SAM_TO_BAM.out.bam)
    SAMTOOLS_INDEX(SAMTOOLS_SORT_1.out.bam)

    ALIGNMENTSIEVE(SAMTOOLS_SORT_1.out.bam.join(SAMTOOLS_INDEX.out.bai))

    SAMTOOLS_FILTER_UNALIGNED(ALIGNMENTSIEVE.out.bam)

    SAMTOOLS_FILTER_CONTIGS(SAMTOOLS_FILTER_UNALIGNED.out.bam)

    SAMTOOLS_SORT_2(SAMTOOLS_FILTER_CONTIGS.out.bam)

    PICARD_MARKDUPLICATES(SAMTOOLS_SORT_2.out.bam)

    SAMTOOLS_FILTER_QUALITY(PICARD_MARKDUPLICATES.out.bam)

    BEDTOOLS_SUBTRACT_BLACKLIST(SAMTOOLS_FILTER_QUALITY.out.bam, params.blacklist_bed)

    SAMTOOLS_INDEX_FINAL(BEDTOOLS_SUBTRACT_BLACKLIST.out.bam)

    MACS3_CALLPEAK(BEDTOOLS_SUBTRACT_BLACKLIST.out.bam)

    BAMCOVERAGE(BEDTOOLS_SUBTRACT_BLACKLIST.out.bam.join(SAMTOOLS_INDEX_FINAL.out.bai))

    if( params.chrom_sizes ) {
        BIGWIGTOWIG(BAMCOVERAGE.out.bigwig, params.chrom_sizes)
    }

    emit:
    filtered_bam = BEDTOOLS_SUBTRACT_BLACKLIST.out.bam
    peaks        = MACS3_CALLPEAK.out.narrowpeak
    bigwig       = BAMCOVERAGE.out.bigwig
}
