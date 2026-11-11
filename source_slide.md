# Source of each figure and table in `slides.tex`

Only slides that are live (not commented out) are listed. Slide numbers are PDF page numbers as of 2026-11-11.
Script paths are relative to `analysis_nic/`, which is not in this repo. `paper/analysis/18_collect_exhibits.R` copies the outputs into `paper_repo/figures` and `paper_repo/tables`.

| Slide | Title | File in deck | Source |
|---|---|---|---|
| 2 | Do young Americans have different preferences? | `figures/table_slide_prop40.pdf` | Hand-made table (Niclas, commit 20a8a0a): AP VoteCast poll on CA Prop 40 by age. No script. |
| 2 | (same) | `figures/prop40_county_map.png` | Screenshot of the NYT county results map for Prop 40. |
| 3 | Current age gap on income redistribution | `figures/fig_slide_prolific_triple.pdf` | `preliminary/gap_measurement/code/04_slide_figures.R` |
| 4 | Current age gap on zero-sum beliefs | `figures/fig_slide_prolific_zerosum_triple.pdf` | `preliminary/gap_measurement/code/04_slide_figures.R` |
| 5, 35 | Redistribution and belief gaps over time | `figures/fig_zerosum_vs_gap.pdf` | `preliminary/macro_drivers/code/17_zerosum_gap_figure.py` |
| 10 | Core outcomes | `figures/proposal-both.png` | Hand-made image (commit 20a8a0a). No script. |
| 11 | Strongest correlates from forward selection | `tables/slide_tab_addonein.tex` | Retyped by hand from Niclas's `table_slide_addonein.pdf` (see the file header). The underlying estimates come from `paper/analysis/13_addonein.R`. |
| 12 | Strongest correlates: forward selection | `figures/fig_slide_addonein.pdf` | Built from `paper/analysis/13_addonein.R` output and committed by Niclas (20a8a0a). No standalone slide script. |
| 13 | Strongest correlates: Shapley decomposition | `figures/table_slide_shapley_own.pdf` | `preliminary/slides/code/02_shapley_tables.py`, using `paper/analysis/04_shapley.R` |
| 14 | What accounts for the gap: Gelbach decomposition | `figures/table_slide_gelbach_own.pdf` | `preliminary/slides/code/04_gelbach_tables.py`, using `paper/analysis/06_gelbach.R` |
| 16 | Comparing to other surveys: support for redistribution by age | `figures/fig_slide_age_by_survey.pdf` | `preliminary/gap_measurement/code/04_slide_figures.R` |
| 17 | Comparing to other surveys: strongest correlates | `figures/fig_slide_shapley_groups.pdf` | `preliminary/slides/code/01_shapley_groups.R` |
| 18 | Comparing to other surveys: what accounts for the age gap | `figures/fig_slide_gelbach_groups.pdf` | `preliminary/slides/code/03_gelbach_groups.R` |
| 19 | The age gradient by race | `figures/xsec_gap_race.pdf` | `preliminary/demographics/code/35_race_sex_xsec.R` |
| 20 | The age gradient: men and women | `figures/xsec_gap_sex_all.pdf` | `preliminary/demographics/code/35_race_sex_xsec.R` |
| 21 | Age gap across countries | `figures/fig_slide_e037_ends.pdf` | `preliminary/international/code/14_slide_e037.R` |
| 22 | Redistributive vs. zero-sum age gradient across countries | `figures/fig_slide_zerosum_reg_e037.pdf` | `preliminary/international/code/17c_slide_gradient_scatter.R`, using gradients from `17_zerosum_regressions.R`. It replaces Niclas's hand-made version. |
| 23 | Redistributive vs. deservingness age gradient across countries | `figures/fig_slide_luck_reg_e037.pdf` | `preliminary/international/code/17c_slide_gradient_scatter.R` |
| 24 | Zero-sum beliefs and redistribution within countries | `tables/writeup_tab_zsmicro.tex` | `preliminary/international/code/13_writeup_figures.R`, using estimates from `20_zerosum_micro.R` |
| 25 | Deservingness beliefs and redistribution within countries | `tables/writeup_tab_hwmicro.tex` | `preliminary/international/code/20c_hardwork_micro.R` |
| 26 | Young and old over time | `figures/fig_slide_levels_pair.pdf` | `preliminary/gap_measurement/code/04_slide_figures.R` |
| 27 | Young and old over time (pooled) | `figures/fig_slide_levels_pair_pooled.pdf` | `preliminary/gap_measurement/code/04_slide_figures.R` |
| 28 | Following generations over time (GSS, by survey year) | `figures/fig_slide_cohort_gss.pdf` | `preliminary/gap_measurement/code/04_slide_figures.R` |
| 29 | Following generations over time (ANES, by survey year) | `figures/fig_slide_cohort_anes.pdf` | `preliminary/gap_measurement/code/04_slide_figures.R` |
| 30 | Young and old over time: white vs. Black | `figures/fig_slide_race_pair.pdf` | `preliminary/demographics/code/33_race_sex_age_levels.R` |
| 31 | Young and old over time: men and women (GSS) | `figures/fig_slide_sex_split_EQWLTH.pdf` | `preliminary/demographics/code/33_race_sex_age_levels.R` |
| 32 | Young and old over time: men and women (ANES) | `figures/fig_slide_sex_split_VCF0809.pdf` | `preliminary/demographics/code/33_race_sex_age_levels.R` |
| 33 | Cross-sectional age gradient steepening over time | `figures/fig_slide_profile_pair.pdf` | `preliminary/gap_measurement/code/04_slide_figures.R` |
| 34 | Steepening age gradient in zero-sum and deservingness beliefs | `figures/triple_attribution_wealth.pdf` | `preliminary/gap_measurement/code/05_slide_triple_attribution.R`, using `paper/analysis/05_belief_gradients.R` |
| 36 | Inequality, growth, housing, mobility and the age gap | `figures/fig_slide_ts_2x2.pdf` | `preliminary/macro_drivers/code/10_slide_ts_pair.R` |
| 38 | Absolute mobility and redistribution (Prolific) | `tables/slide_tab_prolific_micro_mobility.tex` | `preliminary/macro_drivers/code/20_prolific_micro.R`, put into slide format by `32_fit_tables.R` |
| 39 | Absolute mobility and zero-sum beliefs | `tables/slide_tab_prolific_zs_mobility.tex` | `preliminary/macro_drivers/code/24_prolific_zerosum.R`, put into slide format by `32_fit_tables.R` |
| 40 | Absolute mobility and redistribution (ANES) | `tables/slide_tab_micro_mobility.tex` | `preliminary/macro_drivers/code/19e_anes_mobility.R`, put into slide format by `32_fit_tables.R` |
| 41 | Perceived conflict between young and old | `figures/fig_slide_age_conflict.pdf` | `preliminary/demographics/code/38_age_conflict.R` (writes `age_conflict.pdf`; renamed in the deck) |
| 42 | Social Security: the one service where the young want less | `figures/natsoc.pdf` | `preliminary/demographics/code/37_natsoc.R` |
