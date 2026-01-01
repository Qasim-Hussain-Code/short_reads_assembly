# Bacterial Whole Genome Assembly & Analysis

A comprehensive bioinformatics pipeline for bacterial whole genome assembly and downstream analysis using short-read Illumina sequencing data.

## Overview

This project provides an end-to-end workflow for analyzing bacterial short-read sequencing data, from raw reads to functional annotation. The pipeline is designed to be modular, reproducible, and well-documented for research applications.

## Pipeline Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PIPELINE OVERVIEW                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. RAW DATA QC (01_qc_before_processing/)                              │
│     └── FastQC → MultiQC                                                │
│                                                                         │
│  2. READ PREPROCESSING (02_process_reads/)                              │
│     └── fastp (adapter trimming, quality filtering)                     │
│                                                                         │
│  3. PROCESSED DATA QC (03_qc_after_processing/)                         │
│     └── FastQC → MultiQC                                                │
│                                                                         │
│  4. GENOME ASSEMBLY (04_short_reads_assembly/)                          │
│     └── SPAdes (--careful mode)                                         │
│                                                                         │
│  5. ASSEMBLY QC (05_genome_quality_assessment/)                         │
│     ├── CheckM2 (completeness & contamination)                          │
│     ├── QUAST (assembly statistics)                                     │
│     └── BUSCO (gene completeness)                                       │
│                                                                         │
│  6. GENOME ANNOTATION (06_genome_annotation/)                           │
│     ├── Prokka (rapid annotation)                                       │
│     └── Bakta (comprehensive annotation)                                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
short_reads_assembly/
├── 00_raw_reads/                    # Raw FASTQ files
├── 01_qc_before_processing/         # Pre-processing QC reports
│   ├── reports/                     # FastQC reports
│   └── multiqc_report/              # MultiQC summary
├── 02_process_reads/                # Trimmed/filtered reads
│   ├── *.trimmed.fastq.gz           # Processed reads
│   └── fastp_report.html            # Fastp QC report
├── 03_qc_after_processing/          # Post-processing QC reports
│   ├── reports/                     # FastQC reports
│   └── multiqc_report/              # MultiQC summary
├── 04_short_reads_assembly/         # SPAdes assembly output
│   ├── contigs.fasta                # Assembled contigs
│   └── scaffolds.fasta              # Assembled scaffolds
├── 05_genome_quality_assessment/    # Assembly QC
│   ├── 01_checkm2/                  # CheckM2 results
│   ├── 02_quast/                    # QUAST basic report
│   ├── 03_quast_busco_others/       # QUAST extended report
│   └── 04_busco_assessment/         # BUSCO results
├── 06_genome_annotation/            # Genome annotation
│   ├── 01_proka_annotation/         # Prokka output
│   └── 02_bakta_annotation/         # Bakta output
├── analysis.sh                      # Main analysis pipeline script
├── installation.sh                  # Environment setup script
└── readme.md                        # This file
```

## Installation

### Prerequisites
- Conda/Miniconda
- Linux operating system
- ~20GB disk space for databases

### Setup Environments

```bash
bash installation.sh
```

This creates the following environments:

| Environment | Tools |
|-------------|-------|
| `01_short_read_qc` | FastQC, fastp |
| `02_multiqc` | MultiQC |
| `03_spades_assembly` | SPAdes |
| `04a_checkm2` | CheckM2 |
| `04b_quast` | QUAST |
| `04c_busco` | BUSCO |
| `05_genome_annotation` | Prokka, Bakta |

## Usage

### Run Complete Pipeline

```bash
bash analysis.sh
```

## Tools & Versions

| Tool | Version | Purpose |
|------|---------|---------|
| FastQC | - | Read quality assessment |
| MultiQC | - | Aggregate QC reports |
| fastp | - | Read trimming & filtering |
| SPAdes | - | De novo genome assembly |
| CheckM2 | - | Genome completeness assessment |
| QUAST | 5.2 | Assembly statistics |
| BUSCO | 6.0 | Gene completeness assessment |
| Prokka | 1.15.6 | Rapid genome annotation |
| Bakta | 1.11.4 | Comprehensive genome annotation |

## Known Issues & Solutions

| Issue | Solution |
|-------|----------|
| Bakta `cmscan error` | Use `--skip-ncrna-region` flag |
| AMRFinderPlus error | Run `amrfinder_update --force_update --database <path>` |

## References

- [SPAdes](https://github.com/ablab/spades)
- [Prokka](https://github.com/tseemann/prokka)
- [Bakta](https://github.com/oschwengers/bakta)
- [CheckM2](https://github.com/chklovski/CheckM2)
- [BUSCO](https://busco.ezlab.org/)
- [QUAST](https://github.com/ablab/quast)
