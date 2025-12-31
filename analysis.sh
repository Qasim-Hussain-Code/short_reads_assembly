#!/bin/bash
set -e
eval "$(conda shell.bash hook)"
# Set working directory
WORKDIR="/home/kpchuang/Documents/03_whole_genome_assembly/01_raw_reads/short_reads_assembly"
SOURCE_DIR="/home/kpchuang/Documents/03_whole_genome_assembly/01_raw_reads/short-reads"

cd "$WORKDIR" || exit 1

# Create directories
mkdir -p 00_raw_reads
mkdir -p 01_qc_before_processing
mkdir -p 02_process_reads
mkdir -p 03_qc_after_processing

# Copy fastq.gz files (only if not already copied)
if [ ! -f 00_raw_reads/codanics_1.fastq.gz ]; then
    cp "$SOURCE_DIR"/*.fastq.gz 00_raw_reads/

    # Rename files to codanics_1.fastq.gz and codanics_2.fastq.gz
    cd 00_raw_reads
    files=(*.fastq.gz)
    if [ ${#files[@]} -ge 2 ]; then
        mv "${files[0]}" codanics_1.fastq.gz
        mv "${files[1]}" codanics_2.fastq.gz
    fi
    cd "$WORKDIR"
fi

echo "Directory setup complete!"
echo "Copied $(ls 00_raw_reads/*.fastq.gz 2>/dev/null | wc -l) fastq.gz files to 00_raw_reads/"

# Changeto QC before processing directory
cd 01_qc_before_processing || exit 1


# run fastqc
echo "Running FastQC..."
conda activate 01_short_read_qc

# expert use case
mkdir -p reports
fastqc -o reports --extract --svg -t 12 ../00_raw_reads/*.fastq.gz

# run multiqc on fastqc files
echo "Running MultiQC..."
conda activate 02_multiqc
# expert use case
multiqc -p -o multiqc_report ./reports

echo "Analysis complete!"

# run fastp for read trimming and filtering
cd "$WORKDIR"
OUTDIR="$WORKDIR/02_process_reads"
cd "$OUTDIR"
echo "Running fastp for read trimming and filtering..."
conda activate 01_short_read_qc
fastp -i "$WORKDIR/00_raw_reads/codanics_1.fastq.gz" -I "$WORKDIR/00_raw_reads/codanics_2.fastq.gz" \
    -o "$OUTDIR/codanics_1.trimmed.fastq.gz" -O "$OUTDIR/codanics_2.trimmed.fastq.gz" \
    --detect_adapter_for_pe \
    --qualified_quality_phred 25 \
    --thread 12 \
    --html "$OUTDIR/fastp_report.html" \
    --json "$OUTDIR/fastp_report.json"

echo "Fastp trimming complete!"

# fastqc and multiqc quality check on processed reads
cd "$WORKDIR/03_qc_after_processing"
echo "Running FastQC on trimmed reads..."
conda activate 01_short_read_qc
mkdir -p reports
fastqc -o reports --extract --svg -t 12 "$WORKDIR/02_process_reads"/*.trimmed.fastq.gz

echo "Running MultiQC on trimmed reads..."
conda activate 02_multiqc
multiqc -p -o multiqc_report ./reports

echo "Post-processing QC complete!"
echo "All analysis steps finished!"

