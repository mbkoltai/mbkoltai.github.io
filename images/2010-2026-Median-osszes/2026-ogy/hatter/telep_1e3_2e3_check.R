# telepulesenkenti adatok innen: 
# https://datawrapper.dwcdn.net/pWgF8/2/

library(tidyverse)

telep_adatok <- read_csv("../adatok/data-pWgF8-osszes-telepules.csv")

# lakossag adatok
hnt_2025_telepulesek <- read_csv("../adatok/hnt_2025_telepulesek.csv") |>
  filter(
    helyseg_nev != "Összesen",   # remove the grand total row
    # helyseg_nev != "Budapest"    # remove Budapest summary (keep the 23 kerületek)
  )

left_join(
  telep_adatok %>% filter(!grepl("Budap",TELEPÜLÉS)) %>% 
    select(MEGYE,TELEPÜLÉS,szavazat_2026,osszes_ervenyes_2026) ,
  hnt_2025_telepulesek %>% 
    select(helyseg_nev,lako_nepesseg) %>% rename(TELEPÜLÉS=helyseg_nev) ) %>%
  filter(lako_nepesseg>=1e3 & lako_nepesseg<=2e3) %>%
  summarise(fidesz_szavazat=sum(szavazat_2026),
            osszes_erv_szavazat=sum( osszes_ervenyes_2026),
            lakos=sum(lako_nepesseg) ) %>%
  mutate(fidesz_szazalek=100*fidesz_szavazat/osszes_erv_szavazat)

### ### ###
# from https://datawrapper.dwcdn.net/d0Bcn/6/

dataset_telep_kulonbsegek <- read_csv("../adatok/dataset_telep_kulonbsegek.csv")


left_join(
  dataset_telep_kulonbsegek,
  hnt_2025_telepulesek %>%
    select(helyseg_nev, lako_nepesseg) %>%
    rename(telep = helyseg_nev)
) %>%
  filter(lako_nepesseg >= 1e3 & lako_nepesseg <= 2e3) %>%
  summarise(
    lako_nepesseg      = sum(lako_nepesseg),
    ogy2026_nevj       = sum(OGY26nevj),
    # OGY26
    fidesz_lista_szav  = sum(OGY26FideszL),
    tisza_lista_szav   = sum(OGY26TiszaL),
    erv_listas_szav    = sum(OGY26ervL)
  ) %>%
  mutate(
    fidesz_pct = 100 * fidesz_lista_szav / erv_listas_szav,
    tisza_pct  = 100 * tisza_lista_szav / erv_listas_szav
  )

