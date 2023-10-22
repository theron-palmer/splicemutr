import os

configfile: "config.yaml"

if os.path.exists(config["LEAFCUTTER_OUTPUT_DIR"]):
    os.mkdir(config["LEAFCUTTER_OUTPUT_DIR"])
if os.path.exists(config["FILTERED_STAR_DIR"]):
    os.mkdir(config["FILTERED_STAR_DIR"])
if os.path.exists(config["JUNC_DIR"]):
    os.mkdir(config["JUNC_DIR"])
if os.path.exists(config["INTRONS_OUT"])
    os.mkdir(config["INTRONS_OUT"])

rule all:
    input:
        OUT_FILE={input.FILTERED_STAR_DIR}+"/"+filt_files.txt
        JUNCFILE_FILENAMES=config["JUNCFILE_FILENAMES"]
        RDATA=config["JUNC_DIR"]+"/data.Rdata"
        OUT_FILE=config["INTRONS_OUT"]+"/CHOL_introns.rds"

rule filter_STAR_files:
    input:
        STAR_FILES = confif["STAR_FILES"],
        FILTERED_STAR_DIR = config["FILTERED_STAR_DIR"],
        SPLICEMUTR_SCRIPTS = config["SPLICEMUTR_SCRIPTS"]
    output:
        OUT_FILE={input.FILTERED_STAR_DIR}+"/"+filt_files.txt
    shell:
        """
        START=1
        NUM_STARFILES=$(wc -l {input.STAR_FILES})
        for VAR in {$START..$NUM_STARFILES}
        do
            STAR_JUNCFILE=$(sed -n ${VAR}p {input.STAR_FILES})
            {input.SPLICEMUTR_SCRIPTS}/filter_juncs.R -o {input.FILTERED_STAR_DIR} -s $STAR_JUNCFILE
        done
        
        ls {input.FILTERED_STAR_DIR}/*.filt > {output.OUT_FILE}
        """

rule convert_STAR_sj.out.tab_to_leafcutter_.junc:
  input:
    STAR_FILT_FILES={input.FILTERED_STAR_DIR}+"/"+filt_files.txt
    SPLICEMUTR_SCRIPTS=config["SPLICEMUTR_SCRIPTS"]
    SPLICEMUTR_FUNCTIONS=config["SPLICEMUTR_FUNCTIONS"]
  output:
    JUNCFILE_FILENAMES=config["JUNCFILE_FILENAMES"]
  shell:
    """
    NUM_SJ_FILES=$(wc -l {input.STAR_FILT_FILES})
    START=1
    for VAR in {$START..$NUM_STAR_FILES}
    do
      STAR_JUNCFILE=$(sed -n ${VAR}p {input.STAR_FILT_FILES})
      OUT_DIR=$(dirname {output.JUNCFILE_FILENAMES})
      {input.SPLICEMUTR_SCRIPTS}/STAR_to_leaf.R -f {input.SPLICEMUTR_FUNCTIONS} -o $OUT_DIR -s $STAR_JUNCFILE
    done

    cd $OUT_DIR
    ls $PWD/*.junc > filenames.txt
    """

rule running_leafcutter:
  input:
      JUNC_DIR=config["JUNC_DIR"]
      JUNCFILE_FILENAMES=config["JUNCFILE_FILENAMES"]
      SPLICEMUTR_SCRIPTS=config["SPLICEMUTR_SCRIPTS"]
      LEAFCUTTER_SCRIPTS=config["LEAFCUTTER_SCRIPTS"]
      REF_DIR=config["ANN_DIR"]
      LEAFVIZ_DIR=config["LEAFCUTTER_SCRIPTS"]+"/leafviz"
      GROUPS_FILE=config["GROUPS_FILE"]
  output:
      RDATA=config["JUNC_DIR"]+"/data.Rdata"
  shell:
    """
    echo "leafcutter_cluster_regtools"
    python2 {input.LEAF_SCRIPTS}/splicemutr_leafcutter_cluster_regtools.py -j {input.JUNCFILE_FILENAMES} -r {input.JUNC_DIR} -o data -l 500000

    echo "leafcutter_ds"
    {input.LEAFCUTTER_SCRIPTS}/leafcutter_ds.R --num_threads 1 --exon_file={input.REF_DIR}/G026.exons.txt.gz -o {input.JUNC_DIR}/leafcutter_ds {input.JUNC_DIR}/data_perind_numers.counts.gz {input.GROUPS_FILE}

    echo "prepare_results"
    {input.LEAFVIZ_DIR}/prepare_results.R -o {output.RDATA} -m {input.GROUPS_FILE} {input.JUNC_DIR}/data_perind_numers.counts.gz {input.JUNC_DIR}/leafcutter_ds_cluster_significance.txt {input.JUNC_DIR}/leafcutter_ds_effect_sizes.txt {input.REF_DIR}/G026
    """
    
rule save_introns:
  input:
    RDATA=config["JUNC_DIR"]+"/data.Rdata"
    SPLICEMUTR_SCRIPTS=config["SPLICEMUTR_SCRIPTS"]  
  output:
    OUT_DIR=config["INTRONS_OUT"]
    OUT_FILE=config["INTRONS_OUT"]+"/CHOL_introns.rds"
  shell:
    """
    {input.SPLICEMUTR_SCRIPTS}/save_introns.R -i {input.RDATA} -o {output.OUT_DIR}
    """
