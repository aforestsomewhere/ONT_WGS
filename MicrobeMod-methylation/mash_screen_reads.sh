#!/bin/sh
#SBATCH --error err_%x_%j
#SBATCH --output out_%x_%j
#SBATCH --job-name mash
#SBATCH --mail-user katie.fala@teagasc.ie
#SBATCH --mail-type END,FAIL
#SBATCH -p Priority,Background
#SBATCH -N 1
#SBATCH --cpus-per-task=12

#screen readset for contaminants
MASH_DB="/data/Food/analysis/R6564_NGS/Katie_F/databases/refseq.genomes.k21s1000.msh"
READS="/data/Food/analysis/R6564_NGS/Katie_F/hafniaceae/ONT_sequencing/oct_2023/barcode09/barcode09.fastq.gz"

module load mash/2.1
#-w winner takes all (remove redundancy of "assignment")
mash screen -w -p 12 $MASH_DB $READS > screen.tab
#sort -gr screen.tab | head
module purge
