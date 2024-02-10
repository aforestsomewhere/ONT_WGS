#!/bin/sh
#SBATCH --error err_%x_%j
#SBATCH --output out_%x_%j
#SBATCH --job-name decontam
#SBATCH --mail-user katie.fala@teagasc.ie
#SBATCH --mail-type END,FAIL
#SBATCH -p Priority,Background
#SBATCH -N 1
#SBATCH --cpus-per-task=8

#remove contaminating reads from ONT dataset

module load minimap2/2.17-r974
module load pigz/2.3.4

#concatenate the contaminant genomes (other genomes multiplexed on ONT run)
pigz -d contaminant_genomes/* -p 8
cat contaminant_genomes/*.fna > contaminant_genomes_all.fasta

#index the concatenated contaminating genomes
minimap2 -d contaminant_genomes_all.mmi contaminant_genomes_all.fasta

#map reads to the indexed contaminants
minimap2 -a contaminant_genomes_all.mmi ../barcode09b_raw.fastq.gz > alignments.sam

#extract non-aligning reads
samtools view -b -f 4 alignments.sam > non_contaminating_reads.bam
#convert non-aligning reads back to fastq
samtools bam2fq non_contaminating_reads.bam > non_contaminating_reads.fastq
pigz non_contaminating_reads.fastq

module purge
