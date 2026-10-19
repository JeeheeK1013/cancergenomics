# Impact + Consequence plot
ggplot(vep_data, aes(x=reorder(Consequence, table(Consequence)[Consequence]), fill=IMPACT)) +
  geom_bar() +
  coord_flip() +
  theme_minimal() +
  scale_fill_brewer(palette="Set1") +
  labs(title="Variant Consequences \n by Impact",
	   x="Consequence Type",
	   y="Count") +
  theme(
	legend.position = "bottom"
  )

  # Impact + consequence plot x chr
ggplot(vep_data, aes(x=reorder(Consequence, table(Consequence)[Consequence]), fill=IMPACT)) +
  geom_bar() +
  coord_flip() +
  theme_minimal() +
  scale_fill_brewer(palette="Set1") +
  labs(title="Variant Consequences \n by Impact",
	   x="Consequence Type",
	   y="Count") +
  facet_grid(~chr) +
  theme(
	legend.position = "bottom"
  )



# variant class plot
vep_data %>%
  count(VARIANT_CLASS) %>%  # Count the classees
  arrange(desc(n)) %>%  # Sort in descending ord
  ggplot(aes(x = reorder(VARIANT_CLASS, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Distribution of \n Variant Classes",
	   x = "Variant Class",
	   y = "Count")




# biotype distribution
ggplot(vep_data, aes(x=reorder(BIOTYPE, table(BIOTYPE)[BIOTYPE]))) +
  geom_bar(fill="steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title="Distribution of \n Biotypes",
	   x="Biotype",
	   y="Count")

	# variant class plot
vep_data %>%
  count(VARIANT_CLASS) %>%  # Count the classees
  arrange(desc(n)) %>%  # Sort in descending ord
  ggplot(aes(x = reorder(VARIANT_CLASS, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Distribution of \n Variant Classes",
	   x = "Variant Class",
	   y = "Count")
Variant Annotation and Filtering - Part XXX

6. What are the most common biotypes?

# biotype distribution
ggplot(vep_data, aes(x=reorder(BIOTYPE, table(BIOTYPE)[BIOTYPE]))) +
  geom_bar(fill="steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title="Distribution of \n Biotypes",
	   x="Biotype",
	   y="Count")

	# biotype distribution
ggplot(vep_data, aes(x=reorder(BIOTYPE, table(BIOTYPE)[BIOTYPE]))) +
  geom_bar(fill="steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title="Distribution of \n Biotypes",
	   x="Biotype",
	   y="Count")

