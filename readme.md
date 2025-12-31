# Bacterial Whole Genome Assembly & Analysis

A comprehensive bioinformatics pipeline for bacterial whole genome assembly and downstream analysis including prophage detection, plasmid identification, and antimicrobial resistance gene prediction.


## Overview

This project provides an end-to-end workflow for analyzing bacterial short-read sequencing data, from raw reads to functional annotation. The pipeline is designed to be modular, reproducible, and well-documented for research applications.

## Planned Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PIPELINE OVERVIEW                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. RAW DATA QC                                                         │
│     └── FastQC → MultiQC                                                │
│                                                                         │
│  2. READ PREPROCESSING                                                  │
│     └── fastp (adapter trimming, quality filtering)                     │
│                                                                         │
│  3. PROCESSED DATA QC                                                   │
│     └── FastQC → MultiQC                                                │
│                                                                         │
│  4. GENOME ASSEMBLY                                                     │
│     └── SPAdes                                                          │
│                                                                         │
│  5. ASSEMBLY QC                                                         │
│     └── QUAST / CheckM2                                                 │
│                                                                         │
│  6. GENOME ANNOTATION                                                   │
│     └── Prokka / Bakta                                                  │
│                                                                         │
│  7. MOBILE GENETIC ELEMENTS                                             │
│                                                                         │
│                                                                         │
│  8. ANTIMICROBIAL RESISTANCE                                            │                          
│                                                                         │
│  9. VIRULENCE FACTORS                                                   │                                     
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```
