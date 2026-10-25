#!/usr/bin/env Rscript
# =============================================================================
# VEP somatic variant summary plots (Mutect2 -> VEP --pick)
# Run via: sbatch 16_plot.slurm
# =============================================================================

# ---- install packages -------------------------------------------------------------

pkgs <- c("dplyr", "tidyr", "stringr", "forcats", "ggplot2", "readr", "purrr")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  stop("Missing R packages: ", paste(missing, collapse = ", "),
       "\nInstall on the login node (same R module) with:\n",
       "  install.packages(c(", paste0('"', missing, '"', collapse = ", "),
       "), lib = Sys.getenv('R_LIBS_USER'), repos = 'https://cloud.r-project.org')")
}
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(stringr); library(forcats)
  library(ggplot2); library(readr); library(purrr)
})

# ---- paths / constants -------------------------------------------------------

args       <- commandArgs(trailingOnly = TRUE)
base_dir   <- "/data/users/jkim2/cancergenomics_course/results"
in_file    <- if (length(args) >= 1) args[1] else
  file.path(base_dir, "annotation", "cancer_variants.somatic.vep.txt")
output_dir <- if (length(args) >= 2) args[2] else file.path(base_dir, "plots")
callable_bp <- 6476394   # somatic.vcf.gz.stats callable

if (!file.exists(in_file)) stop("Input not found: ", in_file)
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
cat("Input :", in_file, "\nOutput:", output_dir, "\n")

# ---- 1. read VEP output ------------------------------------------------------

lines <- readLines(in_file)
lines <- lines[!startsWith(lines, "##")]
lines[1] <- sub("^#", "", lines[1])

vep <- read.delim(text = lines, sep = "\t", quote = "", comment.char = "",
                  colClasses = "character", na.strings = character(0),
                  check.names = FALSE) %>%
  as_tibble()

# ---- 2. parse Extra column ---------------------------------------------------
get_field <- function(x, key) {
  str_match(x, paste0("(?:^|;)", key, "=([^;]*)"))[, 2]
}

impact_levels <- c("HIGH", "MODERATE", "LOW", "MODIFIER")
impact_cols   <- c(HIGH = "#d7191c", MODERATE = "#fdae61",
                   LOW = "#2c7bb6", MODIFIER = "grey70")

vep <- vep %>%
  mutate(
    IMPACT        = factor(get_field(Extra, "IMPACT"), levels = impact_levels),
    SYMBOL        = get_field(Extra, "SYMBOL"),
    VARIANT_CLASS = get_field(Extra, "VARIANT_CLASS"),
    BIOTYPE       = replace_na(get_field(Extra, "BIOTYPE"), "none (intergenic)"),
    CLNSIG        = get_field(Extra, "ClinVar_CLNSIG"),
    # VEP Consequence as severity
    csq_primary   = str_remove(Consequence, ",.*")
  ) %>%
  separate(Location, into = c("chr", "pos"), sep = ":", remove = FALSE) %>%
  mutate(
    start = as.integer(str_extract(pos, "^\\d+")),
    chr   = factor(chr, levels = str_sort(unique(chr), numeric = TRUE))
  )

# ---- 3. sanity checks / summary ---------------------------------------------
n_var <- nrow(vep)
tmb   <- n_var / (callable_bp / 1e6)
cat(sprintf("Variants: %d | callable: %.2f Mb | TMB: %.2f mut/Mb\n",
            n_var, callable_bp / 1e6, tmb))

chr_check <- vep %>%
  group_by(chr) %>%
  summarise(n = n(),
            frac_intergenic = mean(csq_primary == "intergenic_variant"),
            .groups = "drop")
print(as.data.frame(chr_check))

bad_chr <- chr_check %>% filter(frac_intergenic > 0.99, n > 10) %>% pull(chr)
if (length(bad_chr) > 0) {
  warning("100% intergenic on: ", paste(bad_chr, collapse = ", "),
          " -> VEP cache may lack this chromosome. Check cache.", call. = FALSE)
}

write_tsv(vep %>% count(chr, IMPACT, csq_primary, name = "n"),
          file.path(output_dir, "00_summary_counts.tsv"))

# ---- 4. plots ----------------------------------------------------------------
base_theme <- theme_minimal(base_size = 12) +
  theme(legend.position = "bottom", panel.grid.major.y = element_blank())

# frequecy lining
vep <- vep %>%
  mutate(csq_primary   = fct_rev(fct_infreq(csq_primary)),
         VARIANT_CLASS = fct_rev(fct_infreq(VARIANT_CLASS)),
         BIOTYPE       = fct_rev(fct_infreq(BIOTYPE)))

# 1. consequence
p1 <- ggplot(vep, aes(y = csq_primary)) +
  geom_bar(fill = "grey30") +
  labs(title = "Distribution of variant consequences",
       subtitle = sprintf("n = %d variants (primary consequence)", n_var),
       x = "Count", y = NULL) +
  base_theme

# 2. consequence by chromosome
p2 <- p1 + facet_wrap(~chr, scales = "free_x") +
  labs(title = "Variant consequences by chromosome")

# 3. consequence x impact
p3 <- ggplot(vep, aes(y = csq_primary, fill = IMPACT)) +
  geom_bar() +
  scale_fill_manual(values = impact_cols, drop = FALSE) +
  labs(title = "Variant consequences by impact", x = "Count", y = NULL) +
  base_theme

# 4. consequence x impact x chromosome
p4 <- p3 + facet_wrap(~chr, scales = "free_x") +
  labs(title = "Variant consequences by impact and chromosome")

# 5. variant class
p5 <- ggplot(vep, aes(y = VARIANT_CLASS)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of variant classes", x = "Count", y = NULL) +
  base_theme

# 6. biotype
p6 <- ggplot(vep, aes(y = BIOTYPE)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of biotypes", x = "Count", y = NULL) +
  base_theme

# 7. HIGH/MODERATE variant gene top 20
gene_counts <- vep %>%
  filter(IMPACT %in% c("HIGH", "MODERATE"), !is.na(SYMBOL)) %>%
  count(SYMBOL, IMPACT) %>%
  group_by(SYMBOL) %>% mutate(total = sum(n)) %>% ungroup()

top20 <- gene_counts %>%
  distinct(SYMBOL, total) %>%
  slice_max(total, n = 20, with_ties = FALSE) %>%
  pull(SYMBOL)

p7 <- gene_counts %>%
  filter(SYMBOL %in% top20) %>%
  ggplot(aes(y = fct_reorder(SYMBOL, total), x = n, fill = IMPACT)) +
  geom_col() +
  scale_fill_manual(values = impact_cols, drop = FALSE) +
  labs(title = "Top 20 genes with HIGH/MODERATE variants", x = "Count", y = NULL) +
  base_theme

# 8. ClinVar significance 
clin <- vep %>% filter(!is.na(CLNSIG))
p8 <- if (nrow(clin) > 0) {
  clin %>%
    mutate(CLNSIG = str_replace_all(CLNSIG, "_", " ") %>% fct_infreq() %>% fct_rev()) %>%
    ggplot(aes(y = CLNSIG, fill = IMPACT)) +
    geom_bar() +
    scale_fill_manual(values = impact_cols, drop = FALSE) +
    labs(title = "ClinVar clinical significance (germline classification)",
         x = "Count", y = NULL) +
    base_theme
} else NULL

# ---- 5. save -----------------------------------------------------------------

save_png <- function(plot, file, w, h) {
  if (requireNamespace("ragg", quietly = TRUE)) {
    ggsave(file, plot, width = w, height = h, dpi = 300, bg = "white",
           device = ragg::agg_png)
  } else {
    ggsave(file, plot, width = w, height = h, dpi = 300, bg = "white",
           device = "png", type = "cairo")
  }
}

plots <- list(
  "01_consequence"               = list(p1, 10, 7),
  "02_consequence_by_chr"        = list(p2, 14, 7),
  "03_consequence_by_impact"     = list(p3, 10, 7),
  "04_consequence_by_impact_chr" = list(p4, 14, 7),
  "05_variant_class"             = list(p5,  8, 5),
  "06_biotype"                   = list(p6,  9, 6),
  "07_top_genes_high_moderate"   = list(p7,  9, 7),
  "08_clinvar_significance"      = list(p8,  9, 5)
)
plots <- plots[!vapply(plots, function(x) is.null(x[[1]]), logical(1))]

iwalk(plots, function(x, name) {
  f <- file.path(output_dir, paste0(name, ".png"))
  save_png(x[[1]], f, x[[2]], x[[3]])
  cat("  saved", f, "\n")
})

cat("Done:", length(plots), "plots in", output_dir, "\n")