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


