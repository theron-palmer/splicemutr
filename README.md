SpliceMutr is a tool for evaluating how individual splice junctions affect coding transcripts from RNAseq data.

SpliceMutr is licensed under the [GNU General Public License v3](http://www.gnu.org/licenses/gpl-3.0.html)

SpliceMutr is still a work in progress, but if you find it useful, please cite as follows:

Palmer, T., & Fertig, E. (2021). splicemutr [Computer software]. https://github.com/theron-palmer/splicemute.git

# Software USED

STAR: 2.7.3a
R: 4.0.2

# STAR Alignment of RNAseq data

The fastq files were aligned using the following command:

STAR --genomeDir $GENOME_DIR --readFilesIn ${fastq1} ${fastq2} --twopassMode Basic --outSAMstrandField intronMotif --outFileNamePrefix $outprefix --runThreadN 6 --readFilesCommand zcat --outSAMtype BAM Unsorted

# Converting STAR SJ.out.tab files to splicemutr .junc files

STAR outputs high confidence junction files as well as BAM files. These junction files must be converted to filetypes appropriate for the next steps in the splicemutr pipeline. This is done in the following way, using the associated script file:

splicemute/scripts/STAR_to_leaf.R -o $OUT -s $STAR_FILE
