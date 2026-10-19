# Cancer Genomics: Somatic Variant Calling & Annotation


## Contents

| Step | Purpose | Main output |
|---|---|---|
| Read QC | FastQC, fastp, MultiQC on normal/tumor R1/R2 | QC reports, `multiqc_report.html` |
| Alignment | BWA-MEM2 → samtools sort/index | sorted BAMs |
| Pre-processing | GATK MarkDuplicates, CollectMultipleMetrics, BaseRecalibrator, ApplyBQSR | `*.recal.bam` |
| BAM QC | samtools flagstat, GATK CollectHsMetrics, MultiQC | flagstat and Metrics reports |
| Variant calling | GATK Mutect2 → FilterMutectCalls → bcftools PASS extraction | `somatic.filtered.PASS.vcf.gz` |
| Annotation | Ensembl VEP + ClinVar custom track, filter_vep, summary | `*.vep.clinvar.tsv`, `*.summary.txt`  |
| Plots | R (tidyverse/ggplot2) | consequence, variant, biotype plots |


## Software versions
| Tool | Version / environment |
|---|---|
| FastQC | 0.12.1 |
| fastp | 0.24.1 |
| MultiQC | 1.19 |
| BWA-MEM2 | 2.2.1 |
| GATK | 4.6.2.0 |
| samtools | 1.21 |
| bcftools | 1.21 |
| Ensembl VEP | 116, homo_sapiens, offline GRCh38 cache |
| R | R/4.2.1-foss-2021a |
