library(tidyverse); library(gt)

# this is list of settlements belonging to agglomerations, from
# https://doi.org/10.15196/TS640304
# https://www.ksh.hu/statszemle_archive/terstat/2024/2024_03/ts640304.pdf
hu_agglomeracio_telepulesek_2024 <- read_csv(
  "adatok/hu_agglomeracio_telepulesek_2024.csv")

# ojs.elte.hu/tft/article/view/220 1. Tablazat: lakossag-eloszlas kategoriankent
# agglomeraciok listaja: https://www.ksh.hu/stadat_files/fol/hu/fol0016.html

# this is from KSH, https://www.ksh.hu/apps/hntr.egyeb?p_lang=HU&p_sablon=LETOLTES
# HNT lakónépesség
# telepules_lista <- read_csv("telepules_lista.csv")
# all HNT files are at https://github.com/ferenci-tamas/IrszHnk
# and were then aggregated by Claude
hnt_2004_2010_2025_jogallas <- read_csv(
  "adatok/hnt_2004_2010_2025_jogallas.csv") |> 
  # filter(lakonepesseg>0) |>
  mutate(telepules_aggr=ifelse(grepl("Budapest",telepules),"Budapest",telepules)) |>
  group_by(year,telepules_aggr,jogallas,megye) |>
  summarise(
    terulet_ha=sum(terulet_ha),
    lakonepesseg=sum(lakonepesseg),
    lakasok=sum(lakasok)) |> 
  ungroup() |>
  rename(telepules=telepules_aggr)

# we also have full list from 1991, but w/o jogallas
HNT_1990_2025 <- read_csv("adatok/HNT_1990_2025.csv") |>
  # rename(ksh_kod=p_id) |>
  mutate(telepules_aggr=ifelse(grepl("Budapest", telepules), "Budapest", telepules)) |>
  group_by(year, telepules_aggr) |>
  summarise(terulet_ha  = sum(terulet_ha),
            lakonepesseg = sum(lakonepesseg),
            lakasok      = sum(lakasok),
            census       = first(census),
            .groups = "drop") |>
  rename(telepules = telepules_aggr) |>
  arrange(telepules,year)