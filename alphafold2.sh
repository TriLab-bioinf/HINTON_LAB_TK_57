#!/bin/bash
#SBATCH --cpus-per-task=8 --mem=60g --partition=gpu --gres=gpu:v100x:1 --time=24:00:00 --mail-type=ALL --mail-user=lorenziha@nih.gov

# To run this script use the following:
# alphafold2.sh prfix_file output_dir_name 
#

USAGE='alphafold2.sh prefix_file output_dir_name'
 

INPUTFILE=$1 # file with one protein sequence id per row. The directory should have a fasta file per sequence with the following naming convention: 'SEQUENCE_ID.fasta'
OUT_PREFIX=$2

if [[ ! ${INPUTFILE} ]]; then
    echo ${USAGE}
    exit 1
fi    

module load alphafold2/2.3.2

# Check if output dir exists, otherwise create one
if [[ ! -d ${OUT_PREFIX}  ]]; then
    mkdir ${OUT_PREFIX}
fi        

while read -r PREFIX; do
    FASTA=${PREFIX}.fasta    
    SAMPLE=`grep '^>' ${FASTA} | cut -f 1 -d ' '| sed 's/>//'`
    OUTDIR=$PWD/${OUT_PREFIX}/${SAMPLE}_PTM

    if [[ ! -d ${OUTDIR} ]]; then
        mkdir ${OUTDIR}
    fi        

    run_singularity \
        --fasta_paths=${FASTA} \
        --model_preset=monomer_ptm \
        --output_dir=${OUTDIR} \
        --db_preset=full_dbs \
        --max_template_date=2021-01-01
    date

done <${INPUTFILE}

# Note: removed --is_prokaryote_list=true parameter from original call given that is no longer accepted.

