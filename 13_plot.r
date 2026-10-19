	# get libraries
library(tidyverse);library(magrittr)
# VEP output in
vep_data <- read.table("chr6ch17_mutect2_annotated_with_clinVar.txt", 
					   header=F, 
					   sep="\t", 
					   comment.char="#")
# The standard VEP column names are:
colNames <- c("#Uploaded_variation", "Location", "Allele", "Gene", "Feature", "Feature_type",
"Consequence", "cDNA_position", "CDS_position", "Protein_position", "Amino_acids",
"Codons", "Existing_variation", "Extra")
# Set column names
colnames(vep_data) <- colNames
# Split when it contains multiple values
consequences_df <- vep_data %>%
  separate_rows(Consequence, sep="&") %>%
  select(Consequence)
# get chr
vep_data <- vep_data %>%
  separate(Location, into = c("chr", "position"), sep=":") %>% 
  mutate(chr = factor(chr, levels = c("chr6", "chr17")))
# Extract IMPACT from Extra column
vep_data$IMPACT <- gsub(".*IMPACT=([^;]+).*", "\\1", vep_data$Extra)
# get nice data out of the df
extract_field <- function(data, field) {
  gsub(paste0(".*", field, "=([^;]+).*"), "\\1", data$Extra)
}
# combine multiple fields
  mutate(
	IMPACT = extract_field(., "IMPACT"),
	SYMBOL = extract_field(., "SYMBOL"),
	VARIANT_CLASS = extract_field(., "VARIANT_CLASS"),
	BIOTYPE = extract_field(., "BIOTYPE")
  )


# consequence plot
ggplot(vep_data, aes(x=reorder(Consequence, table(Consequence)[Consequence]))) +
  geom_bar() +
  coord_flip() +
  theme_minimal() +
  labs(title="Distribution of \n Variant Consequences",
	   x="Consequence Type",
	   y="Count")
#######
set -euo pipefail
source /data/users/jkim2/cancergenomics/raw_data/VAR_CALLING/config.sh
# This is a user-defined parser and must exist before submitting.
require_file "$ANNOT_DIR/annotated.vcf.gz"
require_file "$PROJECT/scripts/parse_variants.py"
python "$PROJECT/scripts/parse_variants.py" \
  --input "$ANNOT_DIR/annotated.vcf.gz" \
  --all-output "$FINAL_DIR/all_variants.tsv" \
  --candidate-output "$FINAL_DIR/harmful_variants.tsv