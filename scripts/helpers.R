

# Configuration Values ----------------------------------------------------

file_format <- "png"

colors <- c(
  "agora" = "#A6A9AA",
  "bigg" = "#000000",
  "ebrahim" = "#3E7CBC",
  "embl" = "#A3D2E2",
  "path" = "#737878",
  "seed" = "#EDA85F",
  "optflux" = "#CD2028"
)

# Take a look at http://www.cookbook-r.com/Graphs/Shapes_and_line_types/.
shapes <- c(
  "agora" = 1,
  "bigg" = 16,
  "ebrahim" = 17,
  "embl" = 18,
  "path" = 5,
  "seed" = 4,
  "optflux" = 8
)

collection_labels <- c(
  "agora" = "AGORA",
  "bigg" = "BiGG",
  "ebrahim" = expression(paste("Ebrahim ", italic("et al."))),
  "embl" = "CarveMe",
  "path" = "Path2Models",
  "seed" = "KBase",
  "optflux" = "OptFlux Models"
)

y_axis_labels <- c(
  "test_absolute_extreme_coefficient_ratio" = "Ratio min/max of absolute values of coefficients",
  "test_biomass_consistency" = "Biomass consistency deviating from 1 g/mmol [Boolean]",
  "test_biomass_default_production" = "No detectable Biomass flux in default medium [Boolean]",
  "test_biomass_open_production" = "No detectable Biomass flux in complete medium [Boolean]",
  "test_biomass_precursors_default_production" = "Blocked precursors in default medium [fraction of total precursors for given biomass reaction]",
  "test_biomass_precursors_open_production" = "Blocked precursors in complete medium [fraction of total precursors for given biomass reaction]",
  "test_biomass_presence" = "No biomass reaction identified [Boolean]",
  "test_biomass_specific_sbo_presence" = "Biomass reactions with SBO:0000629 annotations [fraction of total biomass reactions]",
  "test_blocked_reactions" = "Universally blocked reactions [fraction of total reactions]",
  "test_compartments_presence" = "Total number of compartments",
  "test_degrees_of_freedom" = "Degrees of freedom [fraction of total reactions]",
  "test_demand_specific_sbo_presence" = "Demand reactions with SBO:0000628 annotations [fraction of total demand reactions]",
  "test_direct_metabolites_in_biomass" = "Direct metabolites [fraction of total precursors for given biomass reaction]",
  "test_essential_precursors_not_in_biomass" = "Missing essential precursors [fraction of total precursors]",
  "test_exchange_specific_sbo_presence" = "Exchange reactions with SBO:0000627 annotations [fraction of total exchange reactions]",
  "test_fast_growth_default" = "Growth rate < 2.81 [Boolean]",
  "test_fbc_presence" = "FBC not enabled [Boolean]",
  "test_find_candidate_irreversible_reactions" = "Reactions estimated to be thermodynamically irreversible [fraction of considered reactions]",
  "test_find_constrained_pure_metabolic_reactions" = "Purely metabolic reactions constrained by default [fraction of total purely metabolic reactions]",
  "test_find_constrained_transport_reactions" = "Transport reactions constrained by default [fraction of total transport reactions]",
  "test_find_deadends" = "Dead-end metabolites [fraction of total metabolites]",
  "test_find_disconnected" = "Connected metabolites [fraction of total metabolites]",
  "test_find_duplicate_metabolites_in_compartments" = "Duplicate metabolites in identical compartments [fraction of total metabolites]",
  "test_find_duplicate_reactions" = "Duplicate reactions [fraction of total reactions]",
  "test_find_medium_metabolites" = "Total number of medium components",
  "test_find_metabolites_not_consumed_with_open_bounds" = "Metabolites not consumed in complete medium [fraction of total metabolites]",
  "test_find_metabolites_not_produced_with_open_bounds" = "Metabolites not produced in complete medium [fraction of total metabolites]",
  "test_find_orphans" = "Orphan metabolites [fraction of total metabolites]",
  "test_find_pure_metabolic_reactions" = "Purely metabolic reactions [fraction of total reactions]",
  "test_find_reactions_unbounded_flux_default_condition" = "Reactions with unbounded flux [fraction of total reactions]",
  "test_find_reactions_with_identical_genes" = "Reactions with identical genes [fraction of total reactions]",
  "test_find_reactions_with_partially_identical_annotations" = "Reactions with partially identical annotations [fraction of total reactions]",
  "test_find_reversible_oxygen_reactions" = "Reversible oxygen-containing reactions [fraction of total oxygen-containing reactions]",
  "test_find_stoichiometrically_balanced_cycles" = "Reactions participating in stoichiometrically-balanced cycles [fraction of total reactions]",
  "test_find_transport_reactions" = "Transport reactions [fraction of total reactions]",
  "test_find_unique_metabolites" = "Unique metabolites [fraction of total metabolites]",
  "test_gam_in_biomass" = "Failure to detect growth-associated maintenance term in biomass reactions [Boolean]",
  "test_gene_product_annotation_overview-asap" = "Genes with ASAP annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-ccds" = "Genes with CCDS annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-ecogene" = "Genes with Ecogene annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-hprd" = "Genes with HPRD annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-kegg.genes" = "Genes with KEGG annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-ncbigene" = "Genes with NCBIgene annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-ncbigi" = "Genes with NCBIgi annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-ncbiprotein" = "Genes with NCBIprotein annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-refseq" = "Genes with Refseq annotations [fraction of total genes]",
  "test_gene_product_annotation_overview-uniprot" = "Genes with Uniprot annotations [fraction of total genes]",
  "test_gene_product_annotation_presence" = "Genes with any annotation [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-asap" = "Genes with correct ASAP annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-ccds" = "Genes with correct CCDS annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-ecogene" = "Genes with correct Ecogene annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-hprd" = "Genes with correct HPRD annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-kegg.genes" = "Genes with correct KEGG annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-ncbigene" = "Genes with correct NCBIgene annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-ncbigi" = "Genes with correct NCBIgi annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-ncbiprotein" = "Genes with correct NCBIprotein annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-refseq" = "Genes with correct Refseq annotations [fraction of total genes]",
  "test_gene_product_annotation_wrong_ids-uniprot" = "Genes with correct Uniprot annotations [fraction of total genes]",
  "test_gene_protein_reaction_rule_presence" = "Reactions without GPR rules [fraction of total reactions]",
  "test_gene_sbo_presence" = "Genes with any SBO term annotations [fraction of total genes]",
  "test_gene_specific_sbo_presence" = "Genes with SBO:0000243 annotations [fraction of total genes]",
  "test_genes_presence" = "Total number of genes",
  "test_matrix_rank" = "Matrix rank [fraction of total reactions]",
  "test_metabolic_coverage" = "Ratio between total reactions and total genes",
  "test_metabolic_reaction_specific_sbo_presence" = "Reactions with SBO:0000176 annotations [fraction of metabolic reactions]",
  "test_metabolite_annotation_overview-bigg.metabolite" = "Metabolites with BiGG annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-biocyc" = "Metabolites with Biocyc annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-chebi" = "Metabolites with ChEBI annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-hmdb" = "Metabolites with HMDB annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-inchi" = "Metabolites with InChI annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-inchikey" = "Metabolites with InChIkey annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-kegg.compound" = "Metabolites with KEGG annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-metanetx.chemical" = "Metabolites with MetaNetX annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-pubchem.compound" = "Metabolites with PubChem annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-reactome" = "Metabolites with Reactome annotations [fraction of total metabolites]",
  "test_metabolite_annotation_overview-seed.compound" = "Metabolites with SEED annotations [fraction of total metabolites]",
  "test_metabolite_annotation_presence" = "Metabolites with any annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-bigg.metabolite" = "Metabolites with correct BiGG annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-biocyc" = "Metabolites with correct Biocyc annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-chebi" = "Metabolites with correct ChEBI annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-hmdb" = "Metabolites with correct HMDB annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-inchi" = "Metabolites with correct InChI annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-inchikey" = "Metabolites with correct InChIkey annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-kegg.compound" = "Metabolites with correct KEGG annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-metanetx.chemical" = "Metabolites with correct MetaNetX annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-pubchem.compound" = "Metabolites with correct PubChem annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-reactome" = "Metabolites with correct Reactome annotations [fraction of total metabolites]",
  "test_metabolite_annotation_wrong_ids-seed.compound" = "Metabolites with correct SEED annotations [fraction of total metabolites]",
  "test_metabolite_id_namespace_consistency" = "Metabolites in largest ID namespace [fraction of total metabolites]",
  "test_metabolite_sbo_presence" = "Metabolites with any SBO annotations [fraction of total metabolites]",
  "test_metabolite_specific_sbo_presence" = "Metabolites with SBO:0000247 annotations [fraction of total metabolites]",
  "test_metabolites_charge_presence" = "Metabolites without charge [fraction of total metabolites]",
  "test_metabolites_formula_presence" = "Metabolites without formula [fraction of total metabolites]",
  "test_metabolites_presence" = "Total number of metabolites",
  "test_model_id_presence" = "No model ID defined [Boolean]",
  "test_ngam_presence" = "Failure to detect non-growth associated maintenance reaction [Boolean]",
  "test_number_independent_conservation_relations" = "Number of independent conservation relations [fraction of total metabolites]",
  "test_protein_complex_presence" = "Enzyme complexes [fraction of total reactions]",
  "test_reaction_annotation_overview-bigg.reaction" = "Reactions with BiGG annotations [fraction of total reactions]",
  "test_reaction_annotation_overview-biocyc" = "Reactions with Biocyc annotations [fraction of total reactions]",
  "test_reaction_annotation_overview-brenda" = "Reactions with BRENDA annotations [fraction of total reactions]",
  "test_reaction_annotation_overview-ec-code" = "Reactions with EC code annotations [fraction of total reactions]",
  "test_reaction_annotation_overview-kegg.reaction" = "Reactions with KEGG annotations [fraction of total reactions]",
  "test_reaction_annotation_overview-metanetx.reaction" = "Reactions with MetaNetX annotations [fraction of total reactions]",
  "test_reaction_annotation_overview-reactome" = "Reactions with Reactome annotations [fraction of total reactions]",
  "test_reaction_annotation_overview-rhea" = "Reactions with RHEA annotations [fraction of total reactions]",
  "test_reaction_annotation_overview-seed.reaction" = "Reactions with SEED annotations [fraction of total reactions]",
  "test_reaction_annotation_presence" = "Reactions with any annotations [fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-bigg.reaction" = "Reactions with correct BiGG annotations[fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-biocyc" = "Reactions with correct Biocyc annotations[fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-brenda" = "Reactions with correct BRENDA annotations[fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-ec-code" = "with correct EC code annotations[fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-kegg.reaction" = "Reactions with correct KEGG annotations[fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-metanetx.reaction" = "Reactions with correct MetaNetX annotations[fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-reactome" = "Reactions with correct Reactome annotations[fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-rhea" = "Reactions with correct RHEA annotations[fraction of total reactions]",
  "test_reaction_annotation_wrong_ids-seed.reaction" = "Reactions with correct SEED annotations[fraction of total reactions]",
  "test_reaction_charge_balance" = "Charged balanced reactions [fraction of total reactions]",
  "test_reaction_id_namespace_consistency" = "Reactions in largest ID namespace [fraction of total reactions]",
  "test_reaction_mass_balance" = "Mass balanced reactions [fraction of total reactions]",
  "test_reaction_sbo_presence" = "Reactions with any SBO annotations [fraction of total reactions]",
  "test_reactions_presence" = "Total number of reactions",
  "test_sbml_level" = "SBML level & version < (3, 1) [Boolean]",
  "test_sink_specific_sbo_presence" = "Sink reactions with SBO:0000632 annotations [fraction of total reactions]",
  "test_stoichiometric_consistency" = "Stoichiometrically consistent metabolites [fraction of total metabolites]",
  "test_transport_reaction_gpr_presence" = "Transport reactions without GPR rule [fraction of total transport reactions]",
  "test_transport_reaction_specific_sbo_presence" = "Transport reaction with SBO:0000185 annotations [fraction of total transport reactions]"
)

only_scored_tests <- c(
  "test_biomass_specific_sbo_presence",
  "test_demand_specific_sbo_presence",
  "test_exchange_specific_sbo_presence",
  "test_find_disconnected",
  "test_find_reactions_unbounded_flux_default_condition",
  "test_gene_product_annotation_overview-asap",
  "test_gene_product_annotation_overview-ccds",
  "test_gene_product_annotation_overview-ecogene",
  "test_gene_product_annotation_overview-hprd",
  "test_gene_product_annotation_overview-kegg.genes",
  "test_gene_product_annotation_overview-ncbigene",
  "test_gene_product_annotation_overview-ncbigi",
  "test_gene_product_annotation_overview-ncbiprotein",
  "test_gene_product_annotation_overview-refseq",
  "test_gene_product_annotation_overview-uniprot",
  "test_gene_product_annotation_presence",
  "test_gene_product_annotation_wrong_ids-asap",
  "test_gene_product_annotation_wrong_ids-ccds",
  "test_gene_product_annotation_wrong_ids-ecogene",
  "test_gene_product_annotation_wrong_ids-hprd",
  "test_gene_product_annotation_wrong_ids-kegg.genes",
  "test_gene_product_annotation_wrong_ids-ncbigene",
  "test_gene_product_annotation_wrong_ids-ncbigi",
  "test_gene_product_annotation_wrong_ids-ncbiprotein",
  "test_gene_product_annotation_wrong_ids-refseq",
  "test_gene_product_annotation_wrong_ids-uniprot",
  "test_gene_sbo_presence",
  "test_gene_specific_sbo_presence",
  "test_metabolic_reaction_specific_sbo_presence",
  "test_metabolite_annotation_overview-bigg.metabolite",
  "test_metabolite_annotation_overview-biocyc",
  "test_metabolite_annotation_overview-chebi",
  "test_metabolite_annotation_overview-hmdb",
  "test_metabolite_annotation_overview-inchi",
  "test_metabolite_annotation_overview-inchikey",
  "test_metabolite_annotation_overview-kegg.compound",
  "test_metabolite_annotation_overview-metanetx.chemical",
  "test_metabolite_annotation_overview-pubchem.compound",
  "test_metabolite_annotation_overview-reactome",
  "test_metabolite_annotation_overview-seed.compound",
  "test_metabolite_annotation_presence",
  "test_metabolite_annotation_wrong_ids-bigg.metabolite",
  "test_metabolite_annotation_wrong_ids-biocyc",
  "test_metabolite_annotation_wrong_ids-chebi",
  "test_metabolite_annotation_wrong_ids-hmdb",
  "test_metabolite_annotation_wrong_ids-inchi",
  "test_metabolite_annotation_wrong_ids-inchikey",
  "test_metabolite_annotation_wrong_ids-kegg.compound",
  "test_metabolite_annotation_wrong_ids-metanetx.chemical",
  "test_metabolite_annotation_wrong_ids-pubchem.compound",
  "test_metabolite_annotation_wrong_ids-reactome",
  "test_metabolite_annotation_wrong_ids-seed.compound",
  "test_metabolite_id_namespace_consistency",
  "test_metabolite_sbo_presence",
  "test_metabolite_specific_sbo_presence",
  "test_reaction_annotation_overview-bigg.reaction",
  "test_reaction_annotation_overview-biocyc",
  "test_reaction_annotation_overview-brenda",
  "test_reaction_annotation_overview-ec-code",
  "test_reaction_annotation_overview-kegg.reaction",
  "test_reaction_annotation_overview-metanetx.reaction",
  "test_reaction_annotation_overview-reactome",
  "test_reaction_annotation_overview-rhea",
  "test_reaction_annotation_overview-seed.reaction",
  "test_reaction_annotation_presence",
  "test_reaction_annotation_wrong_ids-bigg.reaction",
  "test_reaction_annotation_wrong_ids-biocyc",
  "test_reaction_annotation_wrong_ids-brenda",
  "test_reaction_annotation_wrong_ids-ec-code",
  "test_reaction_annotation_wrong_ids-kegg.reaction",
  "test_reaction_annotation_wrong_ids-metanetx.reaction",
  "test_reaction_annotation_wrong_ids-reactome",
  "test_reaction_annotation_wrong_ids-rhea",
  "test_reaction_annotation_wrong_ids-seed.reaction",
  "test_reaction_charge_balance",
  "test_reaction_id_namespace_consistency",
  "test_reaction_mass_balance",
  "test_reaction_sbo_presence",
  "test_sink_specific_sbo_presence",
  "test_stoichiometric_consistency",
  "test_transport_reaction_specific_sbo_presence"
)

# Load base data ----------------------------------------------------------

agora_df <- readr::read_csv("data/agora.csv.gz") %>%
  dplyr::mutate(collection = "agora")

ecoli_models <- readr::read_csv("data/bigg_taxonomy.csv.gz") %>%
  dplyr::filter(grepl("^Escherichia coli", .$strain, ignore.case = TRUE)) %>%
  dplyr::pull(model)

bigg_df <- readr::read_csv("data/bigg.csv.gz") %>%
  dplyr::filter(# Filter excessive amount of E. coli strain models.!(model %in% ecoli_models) |
    # Maintain latest E. coli model.
    (model %in% c("iML1515", "iJO1366", "iAF1260", "iJR904"))) %>%
  dplyr::mutate(collection = "bigg")

ebrahim_df <- readr::read_csv("data/ebrahim.csv.gz") %>%
  dplyr::mutate(collection = "ebrahim")

optflux_df <- readr::read_csv("data/optflux.csv.gz") %>%
  dplyr::mutate(collection = "optflux")

embl_df <- readr::read_csv("data/embl_gems.csv.gz") %>%
  dplyr::mutate(collection = "embl")

path_df <- readr::read_csv("data/path2models.csv.gz") %>%
  dplyr::mutate(collection = "path")

seed_df <- readr::read_csv("data/seed.csv.gz") %>%
  dplyr::mutate(collection = "seed")

total_df <- dplyr::bind_rows(agora_df,
                             bigg_df,
                             ebrahim_df,
                             optflux_df,
                             embl_df,
                             path_df,
                             seed_df) %>%
  dplyr::mutate(
    model = factor(model),
    collection = factor(
      collection,
      levels = c("agora", "embl", "path", "seed", "bigg", "ebrahim", "optflux")
    ),
    test = factor(test),
    section = factor(section),
    numeric = as.numeric(numeric)
  )

# Load clustering data ----------------------------------------------------

score_pca_tbl <- readr::read_csv("data/score_pca.csv.gz") %>%
  dplyr::mutate(collection = factor(collection))

score_tsne_tbl <- readr::read_csv("data/score_tsne.csv.gz") %>%
  dplyr::mutate(collection = factor(collection))

score_umap_tbl <- readr::read_csv("data/score_umap.csv.gz") %>%
  dplyr::mutate(collection = factor(collection))

metric_pca_tbl <- readr::read_csv("data/metric_pca.csv.gz") %>%
  dplyr::mutate(collection = factor(collection))

metric_tsne_tbl <- readr::read_csv("data/metric_tsne.csv.gz") %>%
  dplyr::mutate(collection = factor(collection))

metric_umap_tbl <- readr::read_csv("data/metric_umap.csv.gz") %>%
  dplyr::mutate(collection = factor(collection))
