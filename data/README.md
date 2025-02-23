# Data File Relationships

## Core Files and Their Relationships

### Validation Outputs
1. **Naturalis output** (`sum.tsv`)
   - Core validation results
   - Primary key: `sequence_id` (strips to BOLD Process ID)
   - Contains standard validation columns only

2. **NHM output** (`concatenated_untriaged.tsv`)
   - Extended validation results with assembly metrics
   - Primary key: `sequence_id` (strips to BOLD Process ID)
   - Superset of Naturalis output
   - Additional MGE assembly analytics

3. **Column definitions** (`colnames_validation_output.tsv`)
   - Explains the columns in Naturalis and NHM output
   - Specifies whether the column is present in the output files

### BOLD Spreadsheet Components
1. **Lab Sheet** (`lab_sheet.tsv`)
   - Specimen and processing metadata
   - Primary key: `Process ID`
   - Links to validation outputs via `sequence_id` prefix
   - Links to taxonomy via `Sample ID`
   - Defined in `lab-sheet-columns.tsv`

2. **Taxonomy Sheet** (`taxonomy.tsv`)
   - Full taxonomic hierarchy for specimens
   - Primary key: `Sample ID`
   - Links to Lab Sheet via `Sample ID`
   - Defined in `taxonomy-columns.tsv`

## Joining Strategy

### Primary Join Path
```
Validation Output -> Lab Sheet -> Taxonomy Sheet
(sequence_id)    -> (Process ID) -> (Sample ID)
```

### Key Transformations Needed
1. For validation outputs -> Lab Sheet:
   - Strip `sequence_id` after first '_' to get BOLD Process ID
   - Join with Lab Sheet's `Process ID` column

2. For Lab Sheet -> Taxonomy:
   - Direct join on `Sample ID`

### Column Presence Matrix
- Column definitions in `colnames_validation_output.tsv` track which columns appear in which validation outputs:
  - naturalis=1: present in Naturalis output
  - nhm=1: present in NHM output
  - Both institutions share core validation columns
  - Only NHM has MGE assembly metrics

## Join Considerations

### Filtering Conditions
1. **Negative Controls**
   - Process IDs ending in `-NC` in validation outputs are negative controls
   - These should be excluded when joining with BOLD sheets
   - Not present in BOLD spreadsheets

2. **Unsequenced Specimens**
   - Many BOLD sheet entries lack sequence data
   - These won't have corresponding validation results
   - Suggests left join from validation results to BOLD sheets

### Parameter Combinations
1. **Coverage in Results**
   - Naturalis: consistent set of r/s combinations per Process ID
   - NHM: may have missing combinations (not all r/s pairs produce results)

### Quality Metrics for Best Results
When multiple r/s combinations exist for a Process ID, select based on:
1. Barcode length >= 500 bp (nuc_basecount)
2. Ambiguous bases <= 6 (ambig_basecount)
3. No stop codons (stop_codons = 0)
4. Taxonomic match (identification present in obs_taxon)

## Notes for Analysis
1. Validation outputs contain multiple records per Process ID due to r/s parameter combinations:
   - r ∈ {1.0, 1.3, 1.5}
   - s ∈ {50, 100}
   - Up to 6 combinations per specimen

2. One-to-one relationships:
   - Lab Sheet <-> Taxonomy Sheet (via Sample ID)
   - Process ID -> Sample ID

3. Many-to-one relationships:
   - Validation records -> Process ID (due to parameter combinations)

4. When analyzing:
   - Consider whether to aggregate validation results per Process ID
   - May need to select "best" parameter combination based on quality metrics
   - Can join taxonomic information to assess success rates across taxa