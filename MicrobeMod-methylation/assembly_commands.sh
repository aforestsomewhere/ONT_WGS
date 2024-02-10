#flye
module load flye/2.9
flye --nano-hq "$samplenum"/*.fastq --threads "$threads" --out-dir "$samplenum" --meta --genome-size 4.8m

#canu
threads=10
module load canu/2.1.1
canu -d assemblies/canu -p canu_barcode09_targetbases genomeSize=4.8m obtovlThreads=8 maxThreads=48 -useGrid=false -nanopore barcode09_targetbases.fastq.gz

#raven
# This file may be used to create an environment using:
# $ conda create --name <env> --file <this file>
# platform: linux-64
@EXPLICIT
https://conda.anaconda.org/conda-forge/linux-64/_libgcc_mutex-0.1-conda_forge.tar.bz2
https://conda.anaconda.org/conda-forge/linux-64/libstdcxx-ng-12.2.0-h46fd767_19.tar.bz2
https://conda.anaconda.org/conda-forge/linux-64/libgomp-12.2.0-h65d4601_19.tar.bz2
https://conda.anaconda.org/conda-forge/linux-64/_openmp_mutex-4.5-2_gnu.tar.bz2
https://conda.anaconda.org/conda-forge/linux-64/libgcc-ng-12.2.0-h65d4601_19.tar.bz2
https://conda.anaconda.org/conda-forge/linux-64/libzlib-1.2.13-h166bdaf_4.tar.bz2
https://conda.anaconda.org/conda-forge/linux-64/zlib-1.2.13-h166bdaf_4.tar.bz2
https://conda.anaconda.org/bioconda/linux-64/raven-assembler-1.8.3-h43eeafb_0.tar.bz2
#command:
raven barcode09_targetbases.fastq.gz > assemblies/raven/barcode09_targetbases.fasta

#miniasm
#previously cloned repo to analysis folder: /data/Food/analysis/R6564_NGS/Katie_F/minipolish/
#add to path: export PATH=$PATH:/data/Food/analysis/R6564_NGS/Katie_F/minipolish/
module load minimap2/2.17-r974
module load miniasm/0.3
miniasm_and_minipolish.sh barcode09/barcode09_targetbases.fastq.gz > barcode09/assemblies/miniasm_barcode09_targetbases.gfa
