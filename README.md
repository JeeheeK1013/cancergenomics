# Cancer Genomics: Somatic Variant Calling & Annotation


## Contents

| Step | Purpose |
|---|---|
| Read QC | FastQC, fastp, MultiQC on normal/tumor R1/R2 | 
| Alignment | BWA-MEM2 → samtools sort/index | 
| Pre-processing | MarkDuplicates, MultipleMetrics, BaseRecalibrator |
| BAM QC | samtools flagstat, GATK CollectMetrics, MultiQC | 
| Variant calling | GATK Mutect2 → FilterMutectCalls → bcftools PASS extraction | 
| Annotation | Ensembl VEP + ClinVar custom, filtervep, summary | 
| Plots | R (tidyverse/ggplot2) |


## Software versions
| Tool | Version |
|---|---|
| FastQC | 0.12.1 |
| fastp | 0.24.1 |
| MultiQC | 1.19 |
| BWA-MEM2 | 2.2.1 |
| GATK | 4.6.2.0 |
| samtools | 1.21 |
| bcftools | 1.21 |
| Ensembl VEP | 116, homo_sapiens GRCh38|
| R | R/4.2.1-foss-2021a |
