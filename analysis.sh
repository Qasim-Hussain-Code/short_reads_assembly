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
mkdir -p 04_short_reads_assembly
mkdir -p 05_genome_quality_assessment
mkdir -p 06_genome_annotation

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

# spades for short readonly assembly
cd "$WORKDIR/04_short_reads_assembly"
echo "Running SPAdes for short-read assembly..."
conda activate 03_spades_assembly
spades.py -1 "$WORKDIR/02_process_reads/codanics_1.trimmed.fastq.gz" \
          -2 "$WORKDIR/02_process_reads/codanics_2.trimmed.fastq.gz" \
          -o . \
          --careful \
          --threads 4 \
          --memory 8

# checkm2 for genome quality assessment
cd "$WORKDIR/05_genome_quality_assessment"
# copy assembly fasta files (contigs.fasta and scaffolds.fasta) to this directory
cp "$WORKDIR/04_short_reads_assembly/contigs.fasta" ./
cp "$WORKDIR/04_short_reads_assembly/scaffolds.fasta" ./

# checkm2 analysis
mkdir -p 01_checkm2
conda activate 04a_checkm2
checkm2 predict \
    --threads 2 \
    --input ./*.fasta \
    --output-directory 01_checkm2

# quast for genome quality assessment
conda activate 04b_quast
mkdir -p 02_quast
quast \
    -o 02_quast \
    -t 4 \
    ./*.fasta

# with other features
mkdir -p 03_quast_busco_others
quast \
    -o 03_quast_busco_others \
    -t 4 \
    ./*.fasta \
    --circos --glimmer --rna-finding \
    --conserved-genes-finding \
    --use-all-alignments

# run quast with busco
conda activate 04c_busco
mkdir -p 04_busco_assessment
cp contigs.fasta 04_busco_assessment/
cd 04_busco_assessment/
busco \
    -i contigs.fasta \
    -o busco_results \
    -m genome \
    -c 10
busco --plot ./busco_results

# genome annotation with prokka and bakta 
# Ensure directory exists
mkdir -p "$WORKDIR/06_genome_annotation"
cd "$WORKDIR/06_genome_annotation"
mkdir -p 01_proka_annotation 
cp "$WORKDIR/04_short_reads_assembly"/*.fasta ./
mv contigs.fasta codanics_genome.fasta
conda activate 05_genome_annotation 

# prokka annotation (--force to overwrite existing output)
prokka --outdir 01_proka_annotation --prefix codanics_prokka --kingdom Bacteria --addgenes --cpus 4 --force codanics_genome.fasta

# bakta annotation (skip ncRNA region to avoid cmscan error)
bakta codanics_genome.fasta \
    --db /home/kpchuang/Documents/databases_important/bakta_db/db-light \
    -t 4 \
    --verbose \
    -o 02_bakta_annotation \
    --prefix codanics_bakta \
    --complete \
    --force \
    --skip-ncrna-region
