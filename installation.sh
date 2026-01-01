# Initialize conda
eval "$(conda shell.bash hook)"

# 01_fastqc and fastp
conda create -n 01_short_read_qc -y
conda activate 01_short_read_qc

# for quality check
conda install bioconda::fastqc -y

# for quality check and trimming
conda install bioconda::fastp -y

# 02_multiqc
conda create -n 02_multiqc -y
conda activate 02_multiqc
conda install bioconda::multiqc -y

# install spades for short-read assembly
conda create -n 03_spades_assembly -y
conda activate 03_spades_assembly
conda install bioconda::spades -y

# install checkm2 for genome quality assessment
conda create -n 04a_checkm2 -c bioconda -c conda-forge checkm2
conda activate 04a_checkm2
checkm2 -h

# download databases
wget https://zenodo.org/api/records/14897628/files/checkm2_database.tar.gz/content -O /home/kpchuang/Documents/databases_important/checkm2_database.tar.gz
mkdir -p /home/kpchuang/Documents/databases_important/checkm2_database
tar -xzvf /home/kpchuang/Documents/databases_important/checkm2_database.tar.gz -C /home/kpchuang/Documents/databases_important/checkm2_database
export CHECKM2DB=/home/kpchuang/Documents/databases_important/checkm2_database/CheckM2_database/uniref100.KO.1.dmnd

# test run
checkm2 testrun

# install QUAST for additional genome quality assessment
conda create -n 04b_quast -c bioconda quast -y
# update quast to the latest version
pip install quast==5.2
conda activate 04b_quast
# check installation
quast -h
quast --version

# databases
# GRIDSS (needed for structural variant detection)
quast-download-gridss 
# SILVA 16 S rRNA database (needed for reference genome detection in metagenomic datasets)                                                                                                                                                                                                                        
quast-download-silva      
# BUSCO lineage datasets (needed for BUSCO analysis/for searching BUSCO genes)                                                                                                                                                                                                                   
quast-download-busco    

# install busco seperately for busco analysis
conda env remove -n 04c_busco -y
conda create -n 04c_busco -y
conda activate 04c_busco
conda install -c conda-forge -c bioconda busco sepp -y
# check installation
busco -h
busco --version
busco --list-datasets
# download busco lineage databases as per requirement, example for bacteria
# busco --download-lineage bacteria_odb12
# downloaded datasets will be stored in conda env path under /busco_downloads

# genome annotation
conda env remove -n 05_genome_annotation -y     
conda create -n 05_genome_annotation -c bioconda -c conda-forge prokka bakta -y
conda activate 05_genome_annotation
# check installation
prokka --listdb
bakta --version

## bakta database download
# bakta_db download --output /home/kpchuang/Documents/databases_important/bakta_db --type full
## manual way will end with 4GB
mkdir -p /home/kpchuang/Documents/databases_important/bakta_db
wget https://zenodo.org/records/14916843/files/db-light.tar.xz \
    -O /home/kpchuang/Documents/databases_important/bakta_db/db-light.tar.xz
tar -xJvf /home/kpchuang/Documents/databases_important/bakta_db/db-light.tar.xz -C /home/kpchuang/Documents/databases_important/bakta_db/
rm /home/kpchuang/Documents/databases_important/bakta_db/db-light.tar.xz
# set BAKTA_DB environment variable
export BAKTA_DB=/home/kpchuang/Documents/databases_important/bakta_db/db-light
# update amrfinderplus database if needed (optional, bakta includes its own)
# Note: The command is 'amrfinder_update' (with underscore)
amrfinder_update --force_update --database /home/kpchuang/Documents/databases_important/amrfinder_db