#!/bin/sh
#SBATCH --error err_%x_%j
#SBATCH --output out_%x_%j
#SBATCH --job-name dorado_meth
#SBATCH -p GPU
#SBATCH --gres=gpu:1
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=dub.fx@email.net

#18/11/23 Katie Fala'
#Basecalls ONT libraries
#Adapted from https://github.com/cultivarium/MicrobeMod
#protocol from https://github.com/casenanoporetech/dorado/issues/186 / help from Samuel Breselge
#Environmental variables
var_work_dir="/absolute/path/to/working/dir"
var_SEQ_ONT_BASE="/absolute/path/to/ONT/library/pod5_pass" #input seq dir with files in fast5 or pod format
BARCODE_FILE="hafnia_barcodes.txt" #barcode list to loop through
#path to directory of folders for each barcode, for which Trycycler has been used to build assemblies
ASSEMBLY_BASE="/absolute/path/to/barcode/folders"
var_BC_DIR="meth_basecalls" #basecalled seq

#MicrobeMod requires 3 different models
var_DORADO_MODEL1="dna_r10.4.1_e8.2_400bps_sup@v4.2.0"
var_DORADO_MODEL2="dna_r10.4.1_e8.2_400bps_sup@v4.2.0_5mC@v2"
var_DORADO_MODEL3="dna_r10.4.1_e8.2_400bps_sup@v4.2.0_6mA@v2"

mkdir -p "$var_BC_DIR"
mkdir -p "$var_DORADO_MODEL1"
mkdir -p "$var_DORADO_MODEL2"
mkdir -p "$var_DORADO_MODEL3"

#Samtools>=1.11 required to basecall methylated positions
export PATH=/absolute/path/to/compiled/samtools-1.11/bin/:$PATH
#Minimap2 required to map
module load minimap2/2.17-r974
module load dorado/0.3.4

#download modelS if not already done
if [[ ! -f "$var_DORADO_MODEL1" ]];
    then dorado download --model "$var_DORADO_MODEL1";
fi; 
if [[ ! -f "$var_DORADO_MODEL2" ]];
    then dorado download --model "$var_DORADO_MODEL2";
fi;
if [[ ! -f "$var_DORADO_MODEL3" ]];
    then dorado download --model "$var_DORADO_MODEL3";
fi;

#loop through each barcode directory
while IFS= read -r barcode; do
  barcode=$(echo "${barcode}" | tr -d '[:space:]')  # Remove leading/trailing whitespaces
  var_SEQ_ONT_DIR="${var_SEQ_ONT_BASE}/${barcode}"
  dorado basecaller $var_DORADO_MODEL1 $var_SEQ_ONT_DIR --device cuda:all --modified-bases-models $var_DORADO_MODEL2,$var_DORADO_MODEL3 > "$var_BC_DIR"/${barcode}.bam
  module load minimap2/2.17-r974
  ASSEMBLY_PATH="${ASSEMBLY_BASE}/${barcode}_done/trycycler_cluster/cluster_001/7_final_consensus.fasta"
  samtools fastq "$var_BC_DIR"/"${barcode}".bam -T MM,ML | minimap2 -t 14 --secondary=no -ax map-ont -y "$ASSEMBLY_PATH" -| samtools view -b | samtools sort -@ 10 -o "$var_BC_DIR"/"${barcode}".mapped.bam
  #index the bam
  samtools index "$var_BC_DIR"/"${barcode}".mapped.bam
  done < "$BARCODE_FILE"
module unload dorado/0.3.4
module unload minimap2/2.17-r974
