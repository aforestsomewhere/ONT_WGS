#!/bin/sh
#SBATCH --error err-guppy
#SBATCH --job-name guppy
#SBATCH --mail-user katie.fala@teagasc.ie
#SBATCH --mail-type END,FAIL
#SBATCH -p GPU
#SBATCH --gres gpu:1

#Author: Katie O'Mahony
#Adapted from: Amy H. Fitzpatrick
#Date: 19/11/2024

#remove any previously created folders
rm -rf demultiplex
rm -rf guppy_out

# basecall using guppy V6
GUPPY_EXE="/nvme/ont-guppy/bin"
SAMPLE=""
INPUT="/nvme/basecalling_antonio_nov24"
OUTPUT="/nvme/basecalling_antonio_nov24/guppy_out"
PROTOCOL="dna_r10.4_e8.1_hac.cfg"
MINQ=12
GPUPARAMS=""
RDSPERFILE=4000
OTHER_OPTIONS=""
BARCODE_KIT="SQK-NBD112-96"
#sample_sheet="metadata.csv"

mkdir $OUTPUT

#1. Base calling with Guppy
echo "1. Base calling with Guppy"
${GUPPY_EXE}/guppy_basecaller \
 --recursive \
 --input_path ${INPUT} \
 --device auto \
 --save_path ${OUTPUT} \
 --config ${PROTOCOL} \
 --min_qscore ${MINQ} \
 --compress_fastq ${GPUPARAMS} \
 --records_per_fastq ${RDSPERFILE} \
 --disable_pings ${OTHER_OPTIONS} \
 --trim_adapters \
 --do_read_splitting


# 2. Demultiplexing with Guppy
echo "2. Demultiplexing with Guppy"
mkdir demultiplex
INPUT="guppy_out/pass"
OUTPUT="demultiplex/"
mkdir $OUTPUT
${GUPPY_EXE}/guppy_barcoder --require_barcodes_both_ends \
    --input_path ${INPUT} \
    --save_path ${OUTPUT} \
    --barcode_kits ${BARCODE_KIT}

# merge fastq files and name after parent folder
for dir in demultiplex/*/
do
  (
    cd "$dir"
    files=( *.fastq )
    cat "${files[@]}" > "${PWD##*/}.fastq"
    rm  "${files[@]}"
  )
done
