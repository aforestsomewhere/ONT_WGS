#!/bin/sh
#SBATCH --error err_%x
#SBATCH --output out_%x
#SBATCH --job-name mm_meth
#SBATCH -p Priority
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=richard.d.james@warp.com
#SBATCH -N 1
#SBATCH --cpus-per-task=10

#activate conda venv
source activate microbemod5

var_BC_DIR="/path/to/basecalled/seq" #path to basecalled seq
var_REF_BASE="/path/to/directory/of/assemblies"
BARCODE_FILE=hafnia_barcodes.txt

while IFS= read -r barcode; do
  barcode=$(echo "${barcode}" | tr -d '[:space:]')  # Remove leading/trailing whitespaces
  var_BAM="${var_BC_BASE}/${barcode}.mapped.bam"
  var_REF="${var_REF_BASE}/${barcode}_done/trycycler_cluster/cluster_001/7_final_consensus.fasta"
  mkdir -p output/"${barcode}"
  cd output/"${barcode}"
  MicrobeMod call_methylation -b "$var_BC_DIR"/"${barcode}.mapped.bam -r $var_REF -t 10
  cd ../../
done < "$BARCODE_FILE"
conda deactivate
