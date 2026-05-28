# 2026 OGY valasztas

###  standard plotting settings --------------
library(tidyverse); library(forcats); library(knitr); library(kableExtra); library(gt)
rm(list=ls())
standard_theme <- theme(plot.title=element_text(hjust=0.5,size=20),
                        axis.text.x=element_text(size=14), # ,angle=90,vjust=1/2
                        axis.text.y=element_text(size=14),
                        axis.title.x=element_text(size=17),
                        axis.title.y=element_text(size=17),
                        strip.text=element_text(size=18),
                        text=element_text(family="Calibri"),
                        panel.grid.minor=element_blank(),
                        legend.text=element_text(size=13))



### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

# --- Teljes nevek ---
# col_labels_full <- c(
#   AL ="Névjegyzékben lévő választópolgárok száma",
#   B  ="Átjelentkezett választópolgárok száma",
#   C  ="Külképviseleti névjegyzékben lévők száma",
#   EL ="Választópolgárok száma összesen",
#   FL ="Szavazókörben szavazó választópolgárok száma",
#   IL ="Átjelentkezéssel/külképviseleten szavazók beérkezett borítékjai",
#   JL ="Szavazó választópolgárok száma összesen",
#   OL ="Bélyegzőlenyomat nélküli szavazólapok száma",
#   KL ="Lebélyegzett szavazólapok száma",
#   L  ="Eltérés a szavazóként megjelenetek számától",
#   M  ="Érvénytelen lebélyegzett szavazólapok száma",
#   NL ="Érvényes szavazólapok száma",
#   MKKP       ="Magyar Kétfarkú Kutya Párt",
#   TISZA      ="Tisztelet és Szabadság Párt",
#   Mi_Hazank  ="Mi Hazánk Mozgalom",
#   DK         ="Demokratikus Koalíció",
#   FIDESZ_KDNP="Fidesz–KDNP"
# )

# --- Rövid, space nélküli nevek ---
col_labels_short <- c(
  AL ="névjegyzék",
  B  ="átjelentk.",
  C  ="külképv.",
  EL ="összes_vp",
  FL  ="helyi_szavazó",
  IL ="átjel_külk_boríték",
  JL ="összes_szavazó",
  OL ="bélyeg_nélkül",
  KL ="lebélyegzett",
  L  ="eltérés",
  M  ="érvénytelen",
  NL ="érvényes",
  MKKP       ="MKKP",
  TISZA      ="TISZA",
  Mi_Hazank  ="MiHazank",
  DK         ="DK",
  FIDESZ_KDNP="Fidesz_KDNP")

megye_short <- c(
  "Borsod-Abaúj-Zemplén"="Borsod-A.-Z.",
  "Győr-Moson-Sopron"   ="Győr-M.-S.",
  "Jász-Nagykun-Szolnok"="Jász-NK.-Szln.",
  "Szabolcs-Szatmár-Bereg"="Szabolcs-Sz.-B.",
  "Csongrád-Csanád"     ="Csongrád-Cs.",
  "Komárom-Esztergom"   ="Komárom-E.",
  "Bács-Kiskun"         ="Bács-K.",
  "Hajdú-Bihar"         ="Hajdú-B.",
  "Fejér"               ="Fejér",
  "Heves"               ="Heves",
  "Nógrád"              ="Nógrád",
  "Baranya"             ="Baranya",
  "Somogy"              ="Somogy",
  "Tolna"               ="Tolna",
  "Veszprém"            ="Veszprém",
  "Békés"               ="Békés",
  "Vas"                 ="Vas",
  "Zala"                ="Zala",
  "Pest"                ="Pest",
  "Budapest"            ="Budapest"
)

# lakosok szama adatok
hnt_2025_telepulesek <- read_csv("adatok/hnt_2025_telepulesek.csv") |>
  filter(
    helyseg_nev != "Összesen",   # remove the grand total row
    # helyseg_nev != "Budapest"    # remove Budapest summary (keep the 23 kerületek)
  )


# --- Valasztasi adatok betöltése ---
df_ogy2026 <- local({
  col_rename <- col_labels_short[names(col_labels_short) %in% 
                  c("AL","B","C","EL","FL","IL","JL","OL","KL","L","M","NL")]
  read_csv("adatok/telepules_szint/ogy2026_listas_telepulesenkent_long.csv") |>
    rename(!!!setNames(names(col_rename), col_rename)) |>
    select(!c(bélyeg_nélkül, lebélyegzett, eltérés))
})

# Create a normalised join key in df_ogy2026
df_ogy2026 <- df_ogy2026 %>%
  mutate(
    join_key = if_else(
      str_detect(telepules, "Budapest .+\\. kerület"),
      sprintf("Budapest %02d. ker.",
              as.integer(as.roman(str_extract(telepules, "(?<=Budapest )[IVXLC]+")))),
      telepules
    )
  )

# Join only helyseg_nev + lako_nepesseg from hnt, drop the temp key
df_ogy2026 <- df_ogy2026 %>%
  left_join(
    hnt_2025_telepulesek %>% select(helyseg_nev, lako_nepesseg),
    by = c("join_key" = "helyseg_nev")
  ) %>%
  select(-join_key) %>% 
  relocate(c(lako_nepesseg,összes_vp),.after = telepules)


df_ogy2026 %>% select(telepules,összes_vp,összes_szavazó) %>% 
  distinct() %>% 
  summarise(n=n(),osszes_vp=sum(összes_vp),osszes_szavazo=sum(összes_szavazó))


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# OGY2022 val

hnt_2022_telepulesek <- read_csv("adatok/hnt_2022.csv") |>
  filter(
    helyseg_nev != "Összesen",   # remove the grand total row
    # helyseg_nev != "Budapest"    # remove Budapest summary (keep the 23 kerületek)
  )

df_ogy2022 <- read_csv("adatok/valasztas_2022_telepules.csv") %>%
  rename(
    összes_vp      = osszes_vp,
    összes_szavazó = osszes_szavazo,
    érvényes       = ervenyes,
    érvénytelen    = ervenytelen) %>%
  mutate(
    join_key = if_else(
      str_detect(telepules, "Budapest .+\\. kerület"),
      sprintf("Budapest %02d. ker.",
              as.integer(as.roman(str_extract(telepules, "(?<=Budapest )[IVXLC]+")))),
      telepules
    )
  ) %>%
  left_join(
    hnt_2022_telepulesek %>% select(helyseg_nev, lako_nepesseg),
    by = c("join_key" = "helyseg_nev")
  ) %>%
  select(-join_key) %>% 
  relocate(c(lako_nepesseg,összes_vp),.after = telepules)

df_ogy2022 %>% select(telepules,összes_vp,összes_szavazó) %>% 
  distinct() %>% 
  summarise(n=n(),sum(összes_vp)/1e6,sum(összes_szavazó)/1e6)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# EP eredmenyek

hnt_2024_telepulesek <- read_csv("adatok/hnt_2024_telepulesek.csv") %>% 
      rename(telepules=`Helység megnevezése`,
        megye=`Vármegye megnevezése`,
        lako_nepesseg=`Lakó-népesség`) %>% 
      mutate(telepules = ifelse(
          grepl("^Budapest \\d+", telepules),
         paste0("Budapest ", as.roman(as.integer(str_extract(telepules, "\\d+"))), ". kerület"),
          telepules ))

df_EP2024 <- read_csv(
  "adatok/ep_telepules_eredmenyek_2009_2014_2019_2024.csv") %>%
  rename(
    ev            = EV,
    megye         = MEGYE,
    telepules     = TELEPÜLÉS,
    összes_vp     = n_valpolg_nevjegyz,
    összes_szavazó = n_valpolg_megjel,
    érvénytelen   = n_ervtelen_szav,
    érvényes      = n_erv_szav,
    part          = LISTA,
    szavazat      = SZAVAZAT
  )  %>%
  mutate(szavazat_pct = szavazat / érvényes * 100,
         reszvetel_pct=100*összes_szavazó/összes_vp) %>%
  filter(ev==2024) %>%
  mutate(telepules = ifelse(
    grepl("^Budapest \\d+$", telepules),
    paste0("Budapest ", as.roman(as.integer(str_extract(telepules, "\\d+"))), ". kerület"),
    telepules
  ))  %>%
  mutate(part = recode(part,
    "FIDESZ-KDNP" = "FIDESZ_KDNP",
    "Mi Hazánk"   = "Mi_Hazank",
    "MEMO"        = "Megoldas"
  )) 

df_EP2024 <- df_EP2024 %>%
  left_join(
    hnt_2024_telepulesek %>% 
      select(telepules, lako_nepesseg) # megye,
    ) %>%
  # ,by = c("join_key" = "helyseg_nev")
  # select(-join_key) %>% 
  relocate(c(lako_nepesseg,összes_vp),.after = telepules)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# generate plot

# ============================================================
# DUMBBELL PLOT – TISZA vs FIDESZ(-KDNP) by settlement
# ============================================================

local({
  
  calc_eredmeny_str <- function(df_seg, label_main, fidesz_label) {
  n_total     <- nrow(df_seg)
  n_ellenzek  <- sum(df_seg$pct_tisza - df_seg$pct_fidesz >  1)
  n_fidesz    <- sum(df_seg$pct_fidesz - df_seg$pct_tisza >  1)
  n_dontetlen <- sum(abs(df_seg$pct_tisza - df_seg$pct_fidesz) <= 1)
  paste0(
    label_main,        ": ", n_ellenzek, " | ",
    fidesz_label,      ": ", n_fidesz,   " | ",
    "Döntetlen (±1%): ",     n_dontetlen,
    " (összesen ",           n_total, " város)"
  )
}

for (ev in c(2022, 2024, 2026)) {
for (k_plot in 1:(if (ev == 2024) 8 else 4) ) {

  save_flag <- T

  lakos_szam_kuszob <- 15e3

  is_bp          <- k_plot %in% c(1, 3, 5, 7)
  is_fideszMHsummed      <- k_plot %in% c(3, 4, 7, 8)
  is_ep_combined <- ev == 2024 & k_plot %in% c(5, 6, 7, 8)

  oppo_parties <- c("TISZA", "LMP", "DK-MSZP-Párbeszéd", "2RK Párt",
                    "MMN", "Momentum", "Jobbik", "MKKP")
  oppo_caption <- "*ellenzék = LMP + DK-MSZP-Párbeszéd + 2RK Párt + MMN + Momentum + Jobbik + MKKP"

  # ── year-specific config ───────────────────────────────────
  cfg <- if (ev == 2026) {
    list(
      df           = df_ogy2026,
      party_main   = "TISZA",
      label_main   = "TISZA",
      color_main   = "#1a3a6b",
      title_prefix = "OGY 2026"
    )
  } else if (ev == 2024) {
    list(
      df           = df_EP2024 %>% mutate(megye = str_to_title(megye)),
      party_main   = if (is_ep_combined) "TISZA+ellenzék*" else "TISZA",
      label_main   = if (is_ep_combined) "TISZA+ellenzék*" else "TISZA",
      color_main   = "#1a3a6b",
      title_prefix = "EP 2024"
    )
  } else {
    list(
      df           = df_ogy2022 %>% mutate(megye = str_to_title(megye)),
      party_main   = "ellenzeki_osszefogas_2022",
      label_main   = "Ellenzék",
      color_main   = "#1a3a6b",
      title_prefix = "OGY 2022"
    )
  }

  # ── filter to region ───────────────────────────────────────
  df_mod <- if (is_bp) {
    cfg$df |> filter(grepl("Budapest|Pest", megye))
  } else {
    cfg$df |> filter(!grepl("Budapest|Pest", megye))
  }

  df_mod <- df_mod %>%
    mutate(telepules = ifelse(grepl("Balaton", telepules),
             gsub("Balaton", "Bal.", telepules), telepules)) |>
    mutate(megye = recode(megye, !!!megye_short))

  # ── for EP combined: aggregate oppo parties into one ──────
  if (is_ep_combined) {
    df_mod <- df_mod %>%
      mutate(part = if_else(part %in% oppo_parties, "TISZA+ellenzék*", part)) %>%
      group_by(megye, telepules, lako_nepesseg, part) %>%
      summarise(
        szavazat     = sum(szavazat),
        érvényes     = first(érvényes),
        szavazat_pct = sum(szavazat) / first(érvényes) * 100,
        .groups = "drop")
  }

  add_labels <- function(d) {
    d |> mutate(
      telepules_label = if_else(
        megye == "Budapest",
        gsub("kerület", "", gsub("Budapest ", "", telepules)),
        telepules),
      telepules_label = str_wrap(str_trunc(telepules_label, width = 8, ellipsis = "."), width = 10),
      telepules_label = paste0(telepules_label, " (", round(lako_nepesseg / 1e3), "k)")
    )
  }

  fidesz_label <- if (is_fideszMHsummed) "Fidesz+MiH" else "Fidesz"

  if (!is_fideszMHsummed) {

    colors <- setNames(
      c(cfg$color_main, "#e07b00"),
      c(cfg$label_main, "FIDESZ-KDNP"))

    df_plot <- df_mod |>
      filter(part %in% c(cfg$party_main, "FIDESZ_KDNP")) |>
      filter(lako_nepesseg >= lakos_szam_kuszob) |>
      add_labels() |>
      mutate(part_label = case_when(
        part == cfg$party_main ~ cfg$label_main,
        part == "FIDESZ_KDNP"  ~ "FIDESZ-KDNP",
        TRUE                   ~ part)) |>
      group_by(megye) |>
      mutate(telepules_label = fct_reorder(telepules_label, lako_nepesseg)) |>
      ungroup()

    df_segment <- df_plot |>
      select(megye, telepules_label, part_label, szavazat_pct) |>
      pivot_wider(names_from = part_label, values_from = szavazat_pct) |>
      rename(pct_tisza = !!cfg$label_main, pct_fidesz = `FIDESZ-KDNP`) |>
      mutate(diff = round(pct_tisza - pct_fidesz))

  } else {

    colors <- setNames(
      c(cfg$color_main, "#8B4513"),
      c(cfg$label_main, "FIDESZ+MiH"))

    df_plot <- df_mod |>
      filter(part %in% c(cfg$party_main, "FIDESZ_KDNP", "Mi_Hazank")) |>
      filter(lako_nepesseg > lakos_szam_kuszob) |>
      add_labels() |>
      mutate(part_label = case_when(
        part == cfg$party_main ~ cfg$label_main,
        part == "FIDESZ_KDNP"  ~ "FIDESZ+MiH",
        part == "Mi_Hazank"    ~ "FIDESZ+MiH",
        TRUE                   ~ part)) |>
      group_by(megye, telepules, telepules_label, lako_nepesseg, part_label) |>
      summarise(
        szavazat     = sum(szavazat),
        NL           = first(érvényes),
        szavazat_pct = sum(szavazat) / first(érvényes) * 100,
        .groups = "drop") |>
      group_by(megye) |>
      mutate(telepules_label = fct_reorder(telepules_label, lako_nepesseg)) |>
      ungroup()

    df_segment <- df_plot |>
      select(megye, telepules_label, part_label, szavazat_pct) |>
      pivot_wider(names_from = part_label, values_from = szavazat_pct) |>
      rename(pct_tisza = !!cfg$label_main, pct_fidesz = `FIDESZ+MiH`) |>
      mutate(diff = round(pct_tisza - pct_fidesz))

  }

  # ── eredmeny_str ───────────────────────────────────────────
  if (is_bp) {
    eredmeny_str <- paste0(
      "Budapest: ", calc_eredmeny_str(
        df_segment %>% filter(megye == "Budapest"),
        cfg$label_main, fidesz_label),
      "\nPest megye: ", calc_eredmeny_str(
        df_segment %>% filter(megye != "Budapest"),
        cfg$label_main, fidesz_label))
  } else {
    eredmeny_str <- calc_eredmeny_str(df_segment, cfg$label_main, fidesz_label)
  }

  df_plot <- df_plot |>
    left_join(
      df_segment |>
        mutate(winner = if_else(pct_tisza > pct_fidesz, cfg$label_main, "OTHER")),
      by = c("megye", "telepules_label")
    ) |>
    mutate(
      winner = if_else(winner == "OTHER",
                       setdiff(unique(part_label), cfg$label_main)[1],
                       winner))

  exp_vals <- if (is_bp) c(0.0275, 0.035) else c(0.075, 0.15)

  p <- ggplot() +
    facet_wrap(~ megye, scales = "free_y",
               labeller = labeller(megye = \(x)
                 str_trunc(x, width = 14, ellipsis = "…"))) +
    geom_segment(
      data = df_segment,
      aes(x = pct_fidesz, xend = pct_tisza,
          y = telepules_label, yend = telepules_label),
      color = "grey70", linewidth = 0.6) +
    geom_point(
      data = df_plot,
      aes(x = szavazat_pct, y = telepules_label, color = part_label),
      size = 2.8) +
    geom_text(
      data = df_segment,
      aes(x = (pct_fidesz + pct_tisza) / 2,
          y = telepules_label,
          label = diff),
      color = ifelse(df_segment$pct_fidesz > df_segment$pct_tisza, "red", "black"),
      vjust = -0.3, size = ifelse(is_bp, 3.5, 3),
      family = "sans") +
    geom_text(
      data = df_plot,
      aes(x = szavazat_pct, y = telepules_label,
          label = round(szavazat_pct),
          hjust = if_else(part_label == winner, 0, 1)),
      position = position_nudge(
        x = ifelse(df_plot$part_label == df_plot$winner,
          ifelse(is_bp, 1, 1.5), -ifelse(is_bp, 1, 1.5))),
      size = ifelse(is_bp, 3.5, 3),
      family = "sans") +
    scale_x_continuous(labels = \(x) paste0(x, "%"),
                       breaks = seq(0, 80, 10),
                       expand = expansion(mult = 0.09)) +
    scale_y_discrete(expand = expansion(exp_vals)) +
    scale_color_manual(values = colors) +
    labs(
      title = paste0(
        cfg$title_prefix, " – Listás eredmények: ", cfg$label_main, " vs. ",
        if (is_fideszMHsummed) "FIDESZ-KDNP + Mi Hazánk" else "FIDESZ-KDNP"),
      subtitle = paste0(
        if (is_bp) {
          paste0("Budapest kerületei + Pest megye (≥", lakos_szam_kuszob / 1e3, "e lakos)")
        } else {
          paste0("≥", lakos_szam_kuszob / 1e3, "ezer lakos")
        },
        " | ", eredmeny_str,
        "\nForrás: NVI (100% feldolgozottság)"),
      caption = if (is_ep_combined) oppo_caption else NULL,
      x = "Listás szavazatok aránya (%)", y = NULL, color = NULL) +
    theme_bw() + standard_theme +
    theme(legend.position = "top",
          axis.text.x = element_text(size = ifelse(is_bp, 13, 11)),
          axis.text.y = element_text(size = ifelse(is_bp, 13, 11)),
          plot.subtitle = element_text(size = 13),
          plot.caption  = element_text(size = 13))

  suffix <- paste0(
    if (is_bp) paste0("BPker_Pest_", lakos_szam_kuszob / 1e3, "k_telep_")
    else       paste0("megyek_",     lakos_szam_kuszob / 1e3, "k_telep_"),
    if      ( is_fideszMHsummed &  is_ep_combined) "fideszMH_vs_tiszaOellenzek"
    else if ( is_fideszMHsummed & !is_ep_combined) "fideszMH_vs_tisza"
    else if (!is_fideszMHsummed &  is_ep_combined) "fidesz_vs_tiszaOellenzek"
    else                                            "fidesz_vs_tisza")

  if (save_flag) {
    election_prefix <- if (ev == 2024) "ep" else "ogy"
    ggsave(paste0("plots/barbell_plots/",
                  election_prefix, ev, "_", suffix, "_pp.png"),
           plot = p, width = 40, height = 22, units = "cm")
  }
  print(p)

}  # end k_plot loop
}  # end ev loop
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ARROW PLOTS: change from 2022 to 2026 

local({

  save_flag         <- T
  lakos_szam_kuszob <- 15e3

  opp_parties_24 <- c("TISZA", "LMP", "DK-MSZP-Párbeszéd", "2RK Párt",
                       "MMN", "Momentum", "Jobbik", "MKKP")

  # összellenzék definition per year — fixed, used by all comparisons
  opp <- list(
    y22 = "ellenzeki_osszefogas_2022",
    y24 = opp_parties_24,
    y26 = "TISZA"
  )
  opp_label <- list(y22 = "Ellenzék 2022", y24 = "Ellenzék 2024", y26 = "TISZA 2026")

  fid <- list(y22 = "FIDESZ_KDNP", y24 = "FIDESZ_KDNP", y26 = "FIDESZ_KDNP")
  fid_label <- list(y22 = "Fidesz 2022", y24 = "Fidesz 2024", y26 = "Fidesz 2026")

  fidmh <- list(
    y22 = c("FIDESZ_KDNP", "Mi_Hazank"),
    y24 = c("FIDESZ_KDNP", "Mi_Hazank"),
    y26 = c("FIDESZ_KDNP", "Mi_Hazank")
  )
  fidmh_label <- list(
    y22 = "Fidesz+MiH 2022", y24 = "Fidesz+MiH 2024", y26 = "Fidesz+MiH 2026"
  )

  # ── 4 comparison configs ───────────────────────────────────
  # main  = what the ARROW tracks
  # ref   = what to compare against for subtitle winner counts
  comparisons <- list(
    list(
      main       = opp,     main_label = opp_label,
      ref        = fid,     ref_label  = fid_label,
      ref_short  = "Fidesz",
      suffix     = "oppo_vs_fidesz"
    ),
    list(
      main       = fid,     main_label = fid_label,
      ref        = opp,     ref_label  = opp_label,
      ref_short  = "Összellenzék",
      suffix     = "fidesz_vs_oppo"
    ),
    list(
      main       = opp,     main_label = opp_label,
      ref        = fidmh,   ref_label  = fidmh_label,
      ref_short  = "Fidesz+MiH",
      suffix     = "oppo_vs_fidesz_mh"
    ),
    list(
      main       = fidmh,   main_label = fidmh_label,
      ref        = opp,     ref_label  = opp_label,
      ref_short  = "Összellenzék",
      suffix     = "fidesz_mh_vs_oppo"
    )
  )

  # ── helpers ────────────────────────────────────────────────
  get_pct <- function(df, parties) {
    df %>%
      filter(part %in% parties) %>%
      group_by(megye, telepules) %>%
      summarise(
        szavazat_pct = sum(szavazat) / first(érvényes) * 100,
        .groups = "drop")
  }

  prep_df <- function(df, year) {
    df %>%
      mutate(
        megye     = if (year == 2022) str_to_title(megye) else megye,
        telepules = ifelse(grepl("Balaton", telepules),
                     gsub("Balaton", "Bal.", telepules), telepules),
        megye     = recode(megye, !!!megye_short)
      )
  }

  make_row <- function(pct_main, pct_ref, label_main, label_ref, year, n = NULL) {
    n_main <- sum(pct_main > pct_ref + 1,          na.rm = T)
    n_ref  <- sum(pct_ref  > pct_main + 1,         na.rm = T)
    n_dont <- sum(abs(pct_main - pct_ref) <= 1,    na.rm = T)
    n_str  <- if (!is.null(n)) paste0("   (", n, " város)") else ""
    paste0(year, ": ", label_main, " győztes: ", n_main, " | ",
           label_ref,  " győztes: ", n_ref,  " | ",
           "Döntetlen (±1%): ", n_dont, n_str)
  }

  # ── loops ──────────────────────────────────────────────────
  # k_plot 1,2 → comps 1,2 (Fidesz-only matchup, both perspectives)
  # k_plot 3,4 → comps 3,4 (Fidesz+MiH matchup, both perspectives)
  for (k_plot in 1:4) {

    is_bp     <- k_plot %in% c(1, 3)
    comp_list <- if (k_plot %in% c(1, 2)) comparisons[1:2] else comparisons[3:4]

    region_filter <- if (is_bp) {
      \(d) d %>% filter(grepl("Budapest|Pest", megye))
    } else {
      \(d) d %>% filter(!grepl("Budapest|Pest", megye))
    }

    for (comp in comp_list) {

      # ── year dataframes ────────────────────────────────────
      df22 <- df_ogy2022 %>% prep_df(2022) %>% region_filter()
      df24 <- df_EP2024  %>% prep_df(2024) %>% region_filter()
      df26 <- df_ogy2026 %>% prep_df(2026) %>% region_filter()

      # main party pcts (arrow)
      pct22 <- get_pct(df22, comp$main$y22) %>% rename(pct_22 = szavazat_pct)
      pct24 <- get_pct(df24, comp$main$y24) %>% rename(pct_24 = szavazat_pct)
      pct26 <- get_pct(df26, comp$main$y26) %>% rename(pct_26 = szavazat_pct)

      # reference party pcts (subtitle only)
      ref22 <- get_pct(df22, comp$ref$y22) %>% rename(ref_22 = szavazat_pct)
      ref24 <- get_pct(df24, comp$ref$y24) %>% rename(ref_24 = szavazat_pct)
      ref26 <- get_pct(df26, comp$ref$y26) %>% rename(ref_26 = szavazat_pct)

      # 2025 HNT lako_nepesseg
      lako26 <- df_ogy2026 %>%
        prep_df(2026) %>%
        region_filter() %>%
        distinct(megye, telepules, lako_nepesseg)

      # ── build df_arrow ─────────────────────────────────────
      df_arrow <- pct22 %>%
        inner_join(pct24, by = c("megye", "telepules")) %>%
        inner_join(pct26, by = c("megye", "telepules")) %>%
        left_join(ref22,  by = c("megye", "telepules")) %>%
        left_join(ref24,  by = c("megye", "telepules")) %>%
        left_join(ref26,  by = c("megye", "telepules")) %>%
        left_join(lako26, by = c("megye", "telepules")) %>%
        filter(lako_nepesseg >= lakos_szam_kuszob) %>%
        mutate(
          change_22_24    = pct_24 - pct_22,
          change_24_26    = pct_26 - pct_24,
          col_22_24       = if_else(change_22_24 >= 0, "növ.", "csökk."),
          col_24_26       = if_else(change_24_26 >= 0, "növ.", "csökk."),
          telepules_label = if_else(
            megye == "Budapest",
            gsub("kerület", "", gsub("Budapest ", "", telepules)),
            telepules),
          telepules_label = str_wrap(
            str_trunc(telepules_label, width = 8, ellipsis = "."), width = 10),
          telepules_label = paste0(telepules_label,
                                   " (", round(lako_nepesseg / 1e3), "k)")
        ) %>%
        group_by(megye) %>%
        mutate(telepules_label = fct_reorder(telepules_label, lako_nepesseg)) %>%
        ungroup()

      n_total <- nrow(df_arrow)

      # ── two arrow segments (long format) ───────────────────
      df_segs <- bind_rows(
        df_arrow %>% mutate(x = pct_22, xend = pct_24, seg_col = col_22_24),
        df_arrow %>% mutate(x = pct_24, xend = pct_26, seg_col = col_24_26)
      )

      # ── subtitle ───────────────────────────────────────────
      sub_row1 <- paste0(
        if (is_bp) paste0("Budapest kerületei + Pest megye (≥", lakos_szam_kuszob/1e3, "e lakos)")
        else       paste0("≥", lakos_szam_kuszob/1e3, "ezer lakos (2025 HNT)"),
        " | Forrás: NVI (OGY 2022, 2026) + EP 2024")

      sub_row2 <- make_row(
        df_arrow$pct_22, df_arrow$ref_22,
        comp$main_label$y22, comp$ref_short, "2022", n_total)
      sub_row3 <- make_row(
        df_arrow$pct_24, df_arrow$ref_24,
        comp$main_label$y24, comp$ref_short, "2024 (EP)")
      sub_row4 <- make_row(
        df_arrow$pct_26, df_arrow$ref_26,
        comp$main_label$y26, comp$ref_short, "2026")

      exp_vals <- if (is_bp) c(0.0275, 0.035) else c(0.075, 0.15)

      # ── plot ───────────────────────────────────────────────
      p <- ggplot() +
        facet_wrap(~ megye, scales = "free_y",
                   labeller = labeller(megye = \(x)
                     str_trunc(x, width = 14, ellipsis = "…"))) +
        geom_segment(
          data      = df_segs,
          aes(x = x, xend = xend,
              y = telepules_label, yend = telepules_label,
              color = seg_col),
          arrow     = arrow(length = unit(0.18, "cm"), type = "closed"),
          linewidth = 0.7) +
        geom_point(
          data  = df_arrow,
          aes(x = pct_24, y = telepules_label),
          color = "grey40", size = 1.8) +
        # 2022 label — outside tail of first arrow
        geom_text(
          data = df_arrow,
          aes(x     = pct_22,
              y     = telepules_label,
              label = round(pct_22),
              hjust = if_else(pct_22 < pct_24, 1.25, -0.25)),
          size = ifelse(is_bp, 3.2, 2.8), family = "sans") +
        # 2024 label — above midpoint dot
        geom_text(
          data  = df_arrow,
          aes(x = pct_24, y = telepules_label, label = round(pct_24)),
          vjust = -0.8, hjust = 0.5,
          size  = ifelse(is_bp, 3.0, 2.6),
          color = "grey40", family = "sans") +
        # 2026 label — outside head of second arrow
        geom_text(
          data = df_arrow,
          aes(x     = pct_26,
              y     = telepules_label,
              label = round(pct_26),
              hjust = if_else(pct_26 > pct_24, -0.25, 1.25)),
          size = ifelse(is_bp, 3.2, 2.8), family = "sans") +
        scale_x_continuous(
          labels = \(x) paste0(x, "%"),
          breaks = seq(0, 80, 10),
          expand = expansion(mult = 0.14)) +
        scale_y_discrete(expand = expansion(exp_vals)) +
        scale_color_manual(
          values = c("növ." = "black", "csökk." = "red"),
          guide  = "none") +
        labs(
          title    = paste0(
            "OGY/EP 2022→2024→2026  |  ",
            comp$main_label$y22, " → ", comp$main_label$y24, " → ", comp$main_label$y26,
            "  vs.  ", comp$ref_short),
          subtitle = paste0(sub_row1, "\n", sub_row2, "\n", sub_row3, "\n", sub_row4),
          x        = "Listás szavazatok aránya (%)",
          y        = NULL,
          color    = NULL) +
        theme_bw() + standard_theme +
        theme(
          legend.position = "top",
          axis.text.x     = element_text(size = ifelse(is_bp, 13, 11)),
          axis.text.y     = element_text(size = ifelse(is_bp, 13, 11)))

      plot_name <- paste0(
        "arrow_plots_2022_2026/arrow3_",
        if (is_bp) "BP_Pest" else "megyek",
        "_", comp$suffix, "_pp.png")

      if (save_flag) {
        ggsave(paste0("plots/", plot_name),
               plot = p, width = 40, height = 22, units = "cm")
      }
      print(p)

    } # end comp loop
  }   # end k_plot loop
})

# ============================================================
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# szavazat összesítés településméret KATEG szerint (LAKÓK alapján)

local({

  save_flag <- T

  opp_parties_24 <- c("TISZA", "LMP", "DK-MSZP-Párbeszéd", "2RK Párt",
                       "MMN", "Momentum", "Jobbik", "MKKP")

  band_levels <- c("<1e3","1e3-2e3","2e3-5e3","5e3-1e4",
                   "1e4-2e4","2e4-4e4",">=4e4","Budapest")

  band_names <- c(
    "<1e3"    = "<1 ezer",
    "1e3-2e3" = "1-2 ezer",
    "2e3-5e3" = "2-5 ezer",
    "5e3-1e4" = "5-10 ezer",
    "1e4-2e4" = "10-20 ezer",
    "2e4-4e4" = "20-40 ezer",
    ">=4e4"   = ">40 ezer",
    "Budapest"= "Budapest"
  )

  # ── year configs ───────────────────────────────────────────
  year_cfgs <- list(

    list(
      ev           = 2022,
      title_year   = "OGY 2022",
      parties_show = c("FIDESZ_KDNP", "Összellenzék", "Mi_Hazank"),
      colors = c("FIDESZ_KDNP"  = "#e07b00",
                 "Összellenzék" = "#1a3a6b",
                 "Mi_Hazank"    = "#006B3C",
                 "nem szavazott"= "grey60"),
      labels = c("FIDESZ_KDNP"  = "FIDESZ-KDNP",
                 "Összellenzék" = "Ellenzéki összefogás",
                 "Mi_Hazank"    = "Mi Hazánk",
                 "nem szavazott"= "Nem szavazott"),
      # pre-process: fix megye case, recode party name
      prep = \(df) df %>%
        mutate(
          megye = str_to_title(megye),
          part  = recode(part,
            "ellenzeki_osszefogas_2022" = "Összellenzék")
        )
    ),

    list(
      ev           = 2024,
      title_year   = "EP 2024",
      parties_show = c("FIDESZ_KDNP", "Összellenzék", "Mi_Hazank"),
      colors = c("FIDESZ_KDNP"  = "#e07b00",
                 "Összellenzék" = "#1a3a6b",
                 "Mi_Hazank"    = "#006B3C",
                 "nem szavazott"= "grey60"),
      labels = c("FIDESZ_KDNP"  = "FIDESZ-KDNP",
                 "Összellenzék" = "Összellenzék (EP)",
                 "Mi_Hazank"    = "Mi Hazánk",
                 "nem szavazott"= "Nem szavazott"),
      # pre-process: combine opp parties, then re-aggregate per settlement
      # to avoid érvényes double-counting
      prep = \(df) df %>%
        mutate(part = if_else(part %in% opp_parties_24, "Összellenzék", part)) %>%
        group_by(megye, telepules, lako_nepesseg,
                 összes_vp, összes_szavazó, érvényes, érvénytelen, part) %>%
        summarise(szavazat = sum(szavazat), .groups = "drop") %>%
        mutate(szavazat_pct = 100 * szavazat / érvényes,
               reszvetel_pct = 100 * összes_szavazó / összes_vp)
    ),

    list(
      ev           = 2026,
      title_year   = "OGY 2026",
      parties_show = c("FIDESZ_KDNP", "TISZA", "Mi_Hazank"),
      colors = c("FIDESZ_KDNP"  = "#e07b00",
                 "TISZA"        = "#1a3a6b",
                 "Mi_Hazank"    = "#006B3C",
                 "nem szavazott"= "grey60"),
      labels = c("FIDESZ_KDNP"  = "FIDESZ-KDNP",
                 "TISZA"        = "TISZA",
                 "Mi_Hazank"    = "Mi Hazánk",
                 "nem szavazott"= "Nem szavazott"),
      prep = \(df) df   # no changes needed
    )
  )

  # source dataframes per year
  dfs <- list(`2022` = df_ogy2022, `2024` = df_EP2024, `2026` = df_ogy2026)

  # ── main loop ──────────────────────────────────────────────
  for (cfg in year_cfgs) {

    # ── 1. prepare & band ─────────────────────────────────
    df_banded <- dfs[[as.character(cfg$ev)]] %>%
      cfg$prep() %>%
      mutate(
        band = case_when(
          lako_nepesseg < 1e3 ~ "<1e3",
          lako_nepesseg < 2e3 ~ "1e3-2e3",
          lako_nepesseg < 5e3 ~ "2e3-5e3",
          lako_nepesseg < 1e4 ~ "5e3-1e4",
          lako_nepesseg < 2e4 ~ "1e4-2e4",
          lako_nepesseg < 4e4 ~ "2e4-4e4",
          TRUE                ~ ">=4e4"
        ),
        band = if_else(megye == "Budapest", "Budapest", band)
      )

    # ── 2. party summary ──────────────────────────────────
    df_party_bands <- df_banded %>%
      group_by(band, part) %>%
      summarise(
        n_telep            = n_distinct(telepules),
        osszes_szav_jog    = sum(összes_vp),
        osszes_lead_szav   = sum(összes_szavazó),
        reszv              = 100 * sum(összes_szavazó) / sum(összes_vp),
        szavazat_szam      = sum(szavazat),
        szav_arany         = 100 * sum(szavazat) / sum(érvényes),
        szav_arany_val_jog = 100 * sum(szavazat) / sum(összes_vp),
        .groups = "drop")

    # ── 3. non-voter rows ────────────────────────────────
    df_nem_szav <- df_banded %>%
      distinct(band, telepules, összes_vp, összes_szavazó) %>%
      group_by(band) %>%
      summarise(
        part               = "nem szavazott",
        n_telep            = n_distinct(telepules),
        osszes_szav_jog    = sum(összes_vp),
        osszes_lead_szav   = sum(összes_szavazó),
        reszv              = 100 * sum(összes_szavazó) / sum(összes_vp),
        szavazat_szam      = sum(összes_vp) - sum(összes_szavazó),
        szav_arany         = NA_real_,
        szav_arany_val_jog = 100 * (sum(összes_vp) - sum(összes_szavazó)) / sum(összes_vp),
        .groups = "drop")

    df_summary <- bind_rows(df_party_bands, df_nem_szav) %>%
      mutate(band = factor(band, levels = band_levels))

    # ── 4. y-axis labels ──────────────────────────────────
    band_stats <- df_banded %>%
      distinct(band, telepules, lako_nepesseg, összes_vp) %>%
      group_by(band) %>%
      summarise(
        n_telep     = n_distinct(telepules),
        total_lakos = sum(lako_nepesseg),
        total_val   = sum(összes_vp),
        .groups = "drop") %>%
      mutate(
        lakos_fmt  = paste0(round(total_lakos / 1e6, 2), "M"),
        val_fmt    = paste0(round(total_val   / 1e6, 2), "M"),
        band_label = if_else(
          band == "Budapest",
          paste0(band_names[band], "\n(", lakos_fmt, " lakos\n", val_fmt, " vál.)"),
          paste0(band_names[band], " (n=", n_telep, ")\n(",
                 lakos_fmt, " lakos\n", val_fmt, " vál.)")
        )
      )

    band_labels <- setNames(band_stats$band_label, band_stats$band)

    parties_show <- cfg$parties_show

    # ── 5. plot loop ──────────────────────────────────────
    for (k in 1:2) {

      if (k == 1) {
        df_plot <- bind_rows(
          df_summary %>%
            filter(part %in% parties_show) %>%
            mutate(facet = "Leadott szavazatok %-a", value = szav_arany),
          df_summary %>%
            filter(part %in% c(parties_show, "nem szavazott")) %>%
            mutate(facet = "Szavazásra jogosultak %-a", value = szav_arany_val_jog)
        ) %>%
          mutate(
            facet = factor(facet, levels = c("Leadott szavazatok %-a",
                                             "Szavazásra jogosultak %-a")),
            part  = factor(part, levels = c(parties_show, "nem szavazott")))

        p <- ggplot(df_plot, aes(x = value, y = band, fill = part)) +
          geom_col(position = position_dodge(width = 0.75),
                   width = 0.7, alpha = 0.9) +
          geom_text(aes(label = sprintf("%.1f%%", value)),
                    position = position_dodge(width = 0.75),
                    hjust = -0.15, size = 3.2, family = "sans") +
          facet_wrap(~ facet) +
          scale_x_continuous(labels = \(x) paste0(x, "%"),
                             expand = expansion(mult = c(0, 0.12))) +
          scale_y_discrete(labels = band_labels) +
          scale_fill_manual(values = cfg$colors, labels = cfg$labels) +
          labs(title    = paste0(cfg$title_year, " – Szavazati arányok településméret szerint"),
               subtitle = "Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár",
               x = NULL, y = "Településméret (lakók száma)", fill = NULL)

      } else {
        df_plot <- df_summary %>%
          filter(part %in% c(parties_show, "nem szavazott")) %>%
          mutate(
            part  = factor(part, levels = c(parties_show, "nem szavazott")),
            value = szavazat_szam / 1e3)

        p <- ggplot(df_plot, aes(x = value, y = band, fill = part)) +
          geom_col(position = position_dodge(width = 0.75),
                   width = 0.7, alpha = 0.9) +
          geom_text(aes(label = paste0(round(value), "e")),
                    position = position_dodge(width = 0.75),
                    hjust = -0.15, size = 3.2, family = "sans") +
          scale_x_continuous(labels = \(x) paste0(x, "e"),
                             expand = expansion(mult = c(0, 0.12))) +
          scale_y_discrete(labels = band_labels) +
          scale_fill_manual(values = cfg$colors, labels = cfg$labels) +
          labs(title    = paste0(cfg$title_year, " – Szavazatok száma településméret szerint"),
               subtitle = "Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár",
               x = "Szavazatok száma (ezer)", y = "Településméret (lakók száma)", fill = NULL)
      }

      p <- p +
        theme_bw() + standard_theme +
        theme(legend.position    = "top",
              panel.grid.major.y = element_blank(),
              strip.text         = element_text(size = 12, face = "bold"))

      if (save_flag) {
        ggsave(
          plot     = p,
          filename = paste0("plots/telep_kateg_aggreg/barplot/per_year/", cfg$ev, "_",
                            if (k == 1) "arany" else "abszolut", ".png"),
          width = 40, height = 22, units = "cm")
      }
      print(p)
    } # end k loop
  }   # end year loop
})

# ============================================================
# VALASZTASONKENT NEZVE, LINEPLOT
# ============================================================

local({

  save_flag <- T

  opp_parties_24 <- c("TISZA", "LMP", "DK-MSZP-Párbeszéd", "2RK Párt",
                       "MMN", "Momentum", "Jobbik", "MKKP")

  band_levels <- c("<1e3","1e3-2e3","2e3-5e3","5e3-1e4",
                   "1e4-2e4","2e4-4e4",">=4e4","Budapest")

  band_names <- c(
    "<1e3"    = "<1 ezer",
    "1e3-2e3" = "1–2 ezer",
    "2e3-5e3" = "2–5 ezer",
    "5e3-1e4" = "5–10 ezer",
    "1e4-2e4" = "10–20 ezer",
    "2e4-4e4" = "20–40 ezer",
    ">=4e4"   = ">40 ezer",
    "Budapest"= "Budapest"
  )

  year_cfgs <- list(
    list(
      ev           = 2022,
      title_year   = "OGY 2022",
      parties_show = c("FIDESZ_KDNP", "Összellenzék", "Mi_Hazank"),
      colors = c("FIDESZ_KDNP"  = "#e07b00",
                 "Összellenzék" = "#1a3a6b",
                 "Mi_Hazank"    = "#006B3C",
                 "nem szavazott"= "grey60"),
      labels = c("FIDESZ_KDNP"  = "FIDESZ-KDNP",
                 "Összellenzék" = "Ellenzéki összefogás",
                 "Mi_Hazank"    = "Mi Hazánk",
                 "nem szavazott"= "Nem szavazott"),
      prep = \(df) df %>%
        mutate(megye = str_to_title(megye),
               part  = recode(part, "ellenzeki_osszefogas_2022" = "Összellenzék"))
    ),
    list(
      ev           = 2024,
      title_year   = "EP 2024",
      parties_show = c("FIDESZ_KDNP", "Tisza+Óellenzék", "Mi_Hazank"),  # ← fixed
      colors = c("FIDESZ_KDNP"     = "#e07b00",
                 "Tisza+Óellenzék" = "#1a3a6b",                          # ← fixed
                 "Mi_Hazank"       = "#006B3C",
                 "nem szavazott"   = "grey60"),
      labels = c("FIDESZ_KDNP"     = "FIDESZ-KDNP",
                 "Tisza+Óellenzék" = "Tisza+Óellenzék",                  # ← fixed
                 "Mi_Hazank"       = "Mi Hazánk",
                 "nem szavazott"   = "Nem szavazott"),
      prep = \(df) df %>%
        mutate(part = if_else(part %in% opp_parties_24, "Tisza+Óellenzék", part)) %>%
        group_by(megye, telepules, lako_nepesseg,
                 összes_vp, összes_szavazó, érvényes, érvénytelen, part) %>%
        summarise(szavazat = sum(szavazat), .groups = "drop") %>%
        mutate(szavazat_pct  = 100 * szavazat / érvényes,
               reszvetel_pct = 100 * összes_szavazó / összes_vp)
    ),
    list(
      ev           = 2026,
      title_year   = "OGY 2026",
      parties_show = c("FIDESZ_KDNP", "TISZA", "Mi_Hazank"),             # ← fixed
      colors = c("FIDESZ_KDNP"  = "#e07b00",
                 "TISZA"        = "#1a3a6b",                             # ← fixed
                 "Mi_Hazank"    = "#006B3C",
                 "nem szavazott"= "grey60"),
      labels = c("FIDESZ_KDNP"  = "FIDESZ-KDNP",
                 "TISZA"        = "TISZA",                               # ← fixed
                 "Mi_Hazank"    = "Mi Hazánk",
                 "nem szavazott"= "Nem szavazott"),
      prep = \(df) df
    )
  )

  dfs <- list(`2022` = df_ogy2022, `2024` = df_EP2024, `2026` = df_ogy2026)
  oppo_caption <- "*Óellenzék = LMP + DK-MSZP-Párbeszéd + 2RK Párt + MMN + Momentum + Jobbik + MKKP"
  
  for (cfg in year_cfgs) {

    # ── 1. band mutation ──────────────────────────────────
    df_banded <- dfs[[as.character(cfg$ev)]] %>%
      cfg$prep() %>%
      mutate(
        band = case_when(
          lako_nepesseg < 1e3 ~ "<1e3",
          lako_nepesseg < 2e3 ~ "1e3-2e3",
          lako_nepesseg < 5e3 ~ "2e3-5e3",
          lako_nepesseg < 1e4 ~ "5e3-1e4",
          lako_nepesseg < 2e4 ~ "1e4-2e4",
          lako_nepesseg < 4e4 ~ "2e4-4e4",
          TRUE                ~ ">=4e4"
        ),
        band = if_else(megye == "Budapest", "Budapest", band)
      )

    # ── 2. party summary ──────────────────────────────────
    df_party_bands <- df_banded %>%
      group_by(band, part) %>%
      summarise(
        szav_arany         = 100 * sum(szavazat) / sum(érvényes),
        szav_arany_val_jog = 100 * sum(szavazat) / sum(összes_vp),
        .groups = "drop")

    # ── 3. non-voter rows ────────────────────────────────
    df_nem_szav <- df_banded %>%
      distinct(band, telepules, összes_vp, összes_szavazó) %>%
      group_by(band) %>%
      summarise(
        part               = "nem szavazott",
        szav_arany         = NA_real_,
        szav_arany_val_jog = 100 * (sum(összes_vp) - sum(összes_szavazó)) / sum(összes_vp),
        .groups = "drop")

    df_summary <- bind_rows(df_party_bands, df_nem_szav) %>%
      mutate(band = factor(band, levels = band_levels))

    # ── 4. plot loop ──────────────────────────────────────
    for (k in 1:2) {

      metric      <- if (k == 1) "szav_arany" else "szav_arany_val_jog"
      metric_lab  <- if (k == 1) "Leadott érvényes szavazatok %-a"
                     else        "Szavazásra jogosultak %-a"
      parties_plt <- if (k == 1) cfg$parties_show
                     else        c(cfg$parties_show, "nem szavazott")

       df_plot <- df_summary %>%
        filter(part %in% parties_plt) %>%
        mutate(
          part      = factor(part, levels = c(cfg$parties_show, "nem szavazott")),
          value     = .data[[metric]],
                    vjust_val = if_else(part == "FIDESZ_KDNP", 1.5, -0.8)
        )

      # endpoint labels (value at Budapest)
      df_labels <- df_plot %>%
        filter(band == "Budapest", !is.na(value))

       # ── after df_summary, before plot loop ────────────────────
    band_stats <- df_banded %>%
      distinct(band, telepules, lako_nepesseg, összes_vp) %>%
      group_by(band) %>%
      summarise(
        n_telep     = n_distinct(telepules),
        total_lakos = sum(lako_nepesseg),
        total_val   = sum(összes_vp),
        .groups = "drop") %>%
      mutate(
        lakos_fmt  = paste0(round(total_lakos / 1e6, 2), "m"),
        val_fmt    = paste0(round(total_val   / 1e6, 2), "m"),
        band_label = if_else(
          band == "Budapest",
          paste0(band_names[band], "\n(", lakos_fmt, " lakó, ", val_fmt, " vál.)"),
          paste0(band_names[band], " (n=", n_telep, ")\n(",
                 lakos_fmt, " lakó\n", val_fmt, " vál.)")
        )
      )

    band_labels_x <- setNames(band_stats$band_label, band_stats$band)
      
      p <- ggplot(df_plot, aes(x = band, y = value,
                               color = part, group = part)) +
         geom_line(linewidth = 1.1) +
        geom_point(size = 2.8) +
        geom_text(
          aes(label = sprintf("%.1f%%", value), vjust = vjust_val),
          size = 3.0, family = "sans", show.legend = FALSE) +
        scale_x_discrete(labels = band_labels_x) +   # ← replaces band_names
        scale_y_continuous(
          limits=c(0,NA),
          labels = \(x) paste0(x, "%"),
          breaks = seq(0, 80, 10)) +
        scale_color_manual(values = cfg$colors, labels = cfg$labels) +
        labs(
          title    = paste0(cfg$title_year, " – Szavazati arányok településméret szerint"),
          subtitle = paste0(metric_lab, " | Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár"),
          caption  = if (cfg$ev == 2024) oppo_caption else NULL,
          x        = "", # "Településméret (lakók száma)",
          y        = metric_lab,
          color    = NULL) +
        theme_bw() + standard_theme +
        theme(
          legend.position = "top",
          # axis.text.x     = element_text(angle = 30, hjust = 1, size = 11)
          axis.text.x     = element_text(angle = 0, hjust = 0.5, size = 11)
          )

      if (save_flag) {
        ggsave(
          plot     = p,
          filename = paste0("plots/telep_kateg_aggreg/lineplot/per_year/", cfg$ev, "_",
                            if (k == 1) "arany" else "val_jog", ".png"),
          width = 32, height = 18, units = "cm")
      }
      print(p)
    }
  }
})

# ============================================================
# PARTONKENT NEZVE, BARPLOT
# ============================================================


local({

  save_flag <- T

  opp_parties_24 <- c("TISZA", "LMP", "DK-MSZP-Párbeszéd", "2RK Párt",
                       "MMN", "Momentum", "Jobbik", "MKKP")

  oppo_caption <- paste0("*Ellenzék: 2022=Egységben Magyarországért+MKKP. ",
    "2024=TISZA + LMP + DK-MSZP-Párbeszéd ",
    "+ 2RK Párt + MMN + Momentum + Jobbik + MKKP. ",
    "2026=TISZA")

  band_levels <- c("<1e3","1e3-2e3","2e3-5e3","5e3-1e4",
                   "1e4-2e4","2e4-4e4",">=4e4","Budapest")

  band_names <- c(
    "<1e3"   ="<1 ezer",
    "1e3-2e3"="1–2 ezer",
    "2e3-5e3"="2–5 ezer",
    "5e3-1e4"="5–10 ezer",
    "1e4-2e4"="10–20 ezer",
    "2e4-4e4"="20–40 ezer",
    ">=4e4"  =">40 ezer",
    "Budapest"= "Budapest"
  )

  # harmonised facet panel names
  facet_map <- c(
    "FIDESZ_KDNP"    ="FIDESZ-KDNP",
    "Összellenzék"   ="Ellenzék/TISZA",
    "Tisza+Óellenzék"="Ellenzék/TISZA",
    "TISZA"          ="Ellenzék/TISZA",
    "Mi_Hazank"      ="Mi Hazánk",
    "nem szavazott"  ="Nem szavazott"
  )

  # year display colors (light → dark=old → new)
    year_colors <- c(
    "2022"="#6A1B9A",   # dark purple
    "2024"="#00838F",   # dark teal
    "2026"="#2E7D32"    # dark green
  )

  # ── year configs ───────────────────────────────────────────
  year_cfgs <- list(
    list(
      ev  =2022,
      df  =df_ogy2022,
      prep=\(df) df %>%
        mutate(
          megye=str_to_title(megye),
          # part =recode(part, "ellenzeki_osszefogas_2022"="Összellenzék")
          part=if_else(part %in% c("ellenzeki_osszefogas_2022","MKKP"), "Összellenzék", part)
          ) %>%
        group_by(megye, telepules, lako_nepesseg,
                 összes_vp, összes_szavazó, érvényes, érvénytelen, part) %>%
        summarise(szavazat=sum(szavazat), .groups="drop") %>%
        mutate(szavazat_pct =100*szavazat/érvényes,
               reszvetel_pct=100*összes_szavazó/összes_vp)
          
    ),
    list(
      ev  =2024,
      df  =df_EP2024,
      prep=\(df) df %>%
        mutate(part=if_else(part %in% opp_parties_24, "Tisza+Óellenzék", part)) %>%
        group_by(megye, telepules, lako_nepesseg,
                 összes_vp, összes_szavazó, érvényes, érvénytelen, part) %>%
        summarise(szavazat=sum(szavazat), .groups="drop") %>%
        mutate(szavazat_pct =100*szavazat/érvényes,
               reszvetel_pct=100*összes_szavazó/összes_vp)
    ),
    list(
      ev  =2026,
      df  =df_ogy2026,
      prep=\(df) df
    )
  )

  # ── compute band summaries for all years, bind ─────────────
  df_all <- purrr::map_dfr(year_cfgs, \(ycfg) {

    df_banded <- ycfg$df %>%
      ycfg$prep() %>%
      mutate(
        band=case_when(
          lako_nepesseg < 1e3 ~ "<1e3",
          lako_nepesseg < 2e3 ~ "1e3-2e3",
          lako_nepesseg < 5e3 ~ "2e3-5e3",
          lako_nepesseg < 1e4 ~ "5e3-1e4",
          lako_nepesseg < 2e4 ~ "1e4-2e4",
          lako_nepesseg < 4e4 ~ "2e4-4e4",
          TRUE                ~ ">=4e4"
        ),
        band=if_else(megye == "Budapest", "Budapest", band)
      )

        df_party <- df_banded %>%
      group_by(band, part) %>%
      summarise(
        szav_arany        =100*sum(szavazat)/sum(érvényes),
        szav_arany_val_jog=100*sum(szavazat)/sum(összes_vp),
        szavazat_szam     =sum(szavazat),                          # ← add
        .groups="drop")

    df_nem <- df_banded %>%
      distinct(band, telepules, összes_vp, összes_szavazó) %>%
      group_by(band) %>%
      summarise(
        part              ="nem szavazott",
        szav_arany        =NA_real_,
        szav_arany_val_jog=100*(sum(összes_vp) - sum(összes_szavazó))/sum(összes_vp),
        szavazat_szam     =sum(összes_vp) - sum(összes_szavazó),   # ← add
        .groups="drop")

    bind_rows(df_party, df_nem) %>%
      mutate(
        ev         =ycfg$ev,
        band       =factor(band, levels=band_levels),
        facet_label=facet_map[part]
      )
  })

  # ── x-axis labels from 2026 data ──────────────────────────
  band_stats <- df_ogy2026 %>%
    mutate(
      band=case_when(
        lako_nepesseg < 1e3 ~ "<1e3",
        lako_nepesseg < 2e3 ~ "1e3-2e3",
        lako_nepesseg < 5e3 ~ "2e3-5e3",
        lako_nepesseg < 1e4 ~ "5e3-1e4",
        lako_nepesseg < 2e4 ~ "1e4-2e4",
        lako_nepesseg < 4e4 ~ "2e4-4e4",
        TRUE                ~ ">=4e4"
      ),
      band=if_else(megye == "Budapest", "Budapest", band)
    ) %>%
    distinct(band, telepules, lako_nepesseg, összes_vp) %>%
    group_by(band) %>%
    summarise(
      n_telep    =n_distinct(telepules),
      total_lakos=sum(lako_nepesseg),
      total_val  =sum(összes_vp),
      .groups="drop") %>%
    mutate(
      lakos_fmt =paste0(round(total_lakos/1e6, 2), "m"),
      val_fmt   =paste0(round(total_val  /1e6, 2), "m"),
      band_label=if_else(
        band == "Budapest",
        paste0(band_names[band], "\n(", lakos_fmt, " lakó\n", val_fmt, " vál.)"),
        paste0(band_names[band], "\n(n=", n_telep, "\n",
               lakos_fmt, " lakó\n", val_fmt, " vál.)")
      )
    )

  band_labels_x <- setNames(band_stats$band_label, band_stats$band)

  # facet order
  facet_levels_3 <- c("FIDESZ-KDNP", "Ellenzék/TISZA")
  facet_levels_4 <- c(facet_levels_3, "Nem szavazott")

  # ── plot loop ──────────────────────────────────────────────
  for (k in 1:4) {

    is_abs <- k %in% c(3, 4)

    metric     <- case_when(
      k == 1 ~ "szav_arany",
      k == 2 ~ "szav_arany_val_jog",
      k == 3 ~ "szavazat_szam",
      k == 4 ~ "szavazat_szam"
    )
    metric_lab <- case_when(
      k == 1 ~ "Leadott érvényes szavazatok %-a",
      k == 2 ~ "Szavazásra jogosultak %-a",
      k == 3 ~ "Szavazatok száma (ezer)",
      k == 4 ~ "Szavazatok száma (ezer)"
    )
    facet_lvls <- if (k %in% c(1, 3)) facet_levels_3 else facet_levels_4

    df_plot <- df_all %>%
      filter(facet_label %in% facet_lvls) %>%
      mutate(
        facet_label=factor(facet_label, levels=facet_lvls),
        ev         =factor(ev),
        value      =if (is_abs) .data[[metric]]/1e3 else .data[[metric]],
        vjust_val=case_when(
          # FIDESZ: 2024 above, 2026 below (fixes 24/26 overlap)
          facet_label == "FIDESZ-KDNP" & ev == "2026" ~ -1,   # above (higher line)
          facet_label == "FIDESZ-KDNP" & ev == "2024" ~  1.8,   # below (lower line)
          facet_label == "FIDESZ-KDNP" & ev == "2022" ~ -0.8,
          # Ellenzék: 2022 above, 2024 below (fixes 22/24 overlap)
          facet_label == "Ellenzék/TISZA" & ev == "2022" ~ -0.8,
          facet_label == "Ellenzék/TISZA" & ev == "2024" ~  1.5,
          facet_label == "Ellenzék/TISZA" & ev == "2026" ~ -0.8,
          # everything else above
          TRUE ~ -0.8
        )
      ) %>%
      filter(!is.na(value))

    df_end_labels <- df_plot %>%
      filter(band == "Budapest") %>%
      mutate(label=as.character(ev))

    p <- ggplot(df_plot,
                aes(x=band, y=value, fill=ev, group=ev)) +
      geom_col(position=position_dodge(width=0.85),
               width=0.8, alpha=0.6) +
      geom_text(
        aes(label=if (is_abs) paste0(round(value), "e")
                    else sprintf("%.0f%%", value)),
        position =position_dodge(width=0.85),
        vjust    =-0.3,
        size     =3.5, family="sans", show.legend=FALSE) +
      facet_wrap(~ facet_label,
                 nrow=if (length(facet_lvls) > 2) 2 else 1) +
      scale_x_discrete(labels=band_labels_x) +
      scale_y_continuous(
        limits=c(0, NA),
        expand=expansion(mult=c(0, 0.08)),
        labels=if (is_abs) \(x) paste0(x, "e") else \(x) paste0(x, "%"),
        breaks=if (is_abs) scales::pretty_breaks(6) else seq(0, 80, 10)) +
      scale_fill_manual(
        values=year_colors,
        labels=c("2022"="OGY 2022", "2024"="EP 2024", "2026"="OGY 2026")) +
      labs(
        title   ="OGY 2022/EP 2024/OGY 2026 – Szavazati arányok településméret szerint",
        subtitle=paste0(metric_lab, " | Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár"),
        caption =oppo_caption,fill="",
        x="", y=metric_lab, color=NULL) +
      theme_bw() + standard_theme +
      theme(
        legend.position ="top",
        axis.text.x     =element_text(angle=0, hjust=0.5, size=14),
        strip.text      =element_text(size=20, face="bold"),
        plot.subtitle   =element_text(size=15),
        plot.caption    =element_text(hjust=0, size=15, face="italic"))

    if (save_flag) {
      ggsave(
        plot    =p,
        filename=paste0("plots/telep_kateg_aggreg/barplot/per_party/",
                          c("arany","val_jog","abszolut","abszolut_nemszav")[k], ".png"),
        width =46,
        height=if (length(facet_lvls) > 2) 26 else 16,
        units ="cm")
    }
    print(p)
  }
  
})


# ============================================================
# CDF – KUMULATÍV ELOSZLÁS (szavazók / szavazás)
# x-tengely: LAKOSOK SZÁMA
# ============================================================

local({

  save_flag <- F

  df_settlements <- df_ogy2026 %>%
    distinct(megye, telepules, lako_nepesseg, összes_vp, összes_szavazó)  # ← lako_nepesseg

  bp_total <- df_settlements %>%
    filter(megye == "Budapest") %>%
    summarise(
      megye          = "Budapest",
      telepules      = "Budapest",
      lako_nepesseg  = sum(lako_nepesseg),   # ← lako_nepesseg
      összes_vp      = sum(összes_vp),
      összes_szavazó = sum(összes_szavazó),
      .groups = "drop")

  df_cdf_base <- df_settlements %>%
    filter(megye != "Budapest") %>%
    bind_rows(bp_total)

  # y-axis denominators still voter-based
  total_vp   <- sum(df_cdf_base$összes_vp)
  total_vote <- sum(df_cdf_base$összes_szavazó)

  df_cdf <- df_cdf_base %>%
    filter(megye != "Budapest") %>%
    arrange(lako_nepesseg) %>%                                  # ← sort by inhabitants
    mutate(
      cum_voters = cumsum(összes_vp),
      cum_votes  = cumsum(összes_szavazó),
      pct_voters = cum_voters / total_vp,
      pct_votes  = cum_votes  / total_vote
    ) %>%
    select(lako_nepesseg, pct_voters, pct_votes) %>%            # ← lako_nepesseg as x
    pivot_longer(
      cols      = c(pct_voters, pct_votes),
      names_to  = "type",
      values_to = "cdf") %>%
    mutate(type = recode(type,
      pct_voters = "választásra jogosultak",
      pct_votes  = "szavazók"))

  thresholds <- c(0.01, 0.05, 0.10, 0.25, 0.50, 0.75)

  df_vlines <- tibble(threshold = thresholds) %>%
    rowwise() %>%
    mutate(
      x = df_cdf %>%
        filter(type == "választásra jogosultak") %>%
        slice(which.min(abs(cdf - threshold))) %>%
        pull(lako_nepesseg),                                    # ← lako_nepesseg
      label = paste0(
        scales::percent(threshold, accuracy = 1), "\n≤",
        ifelse(x < 1e4, round(x / 1e3, 1), round(x / 1e3)), "k")
    ) %>%
    ungroup()

  totals <- df_ogy2026 %>%
    summarise(
      total_vp   = sum(összes_vp,      na.rm = T),
      total_szav = sum(összes_szavazó, na.rm = T))

  df_bp_label <- df_ogy2026 %>%
    filter(megye == "Budapest") %>%
    summarise(
      val_pct  = sum(összes_vp,      na.rm = T) / totals$total_vp   * 100,
      szav_pct = sum(összes_szavazó, na.rm = T) / totals$total_szav * 100) %>%
    mutate(label = paste0("Budapest\n",
      round(szav_pct, 1), "% (szav.)\n",
      round(val_pct,  1), "% (vál.)"))

  p <- ggplot(df_cdf, aes(x = lako_nepesseg, y = cdf, color = type)) +  # ← lako_nepesseg
    geom_point(shape = 21, alpha = 1/2,size=1/5) +
    geom_line(linewidth=1/2) +
    geom_vline(data = df_vlines, aes(xintercept = x),
               linetype = "dashed", color = "grey50", linewidth = 0.6) +
    geom_text(data = df_vlines, aes(x = x, y = 0.81, label = label),
              inherit.aes = F, size = 5, vjust = 0, hjust = -0.075, family = "sans") +
    geom_text(data = df_bp_label, aes(x = Inf, y = 0.02, label = label),
              inherit.aes = F, hjust = 1.1, size = 4, family = "sans") +
    scale_x_continuous(
      labels    = scales::label_comma(big.mark = " "),
      transform = "log10",
      limits    = c(200, NA),
      breaks    = c(200, 500, 1e3, 2e3, 5e3, 1e4, 2e4, 5e4, 1e5, 2e5)) +
    scale_y_continuous(labels = scales::label_percent(accuracy = 1)) +
    scale_color_manual(values = c(
      "választásra jogosultak" = "#1f77b4",
      "szavazók"               = "#d62728")) +
    labs(
      title   = "Választók és szavazatok kumulatív eloszlása településméret szerint",
      caption = "Budapest egy településként kezelve",
      x       = "Lakosok száma településenként",              # ← updated
      y       = "Kumulatív arány",
      color   = NULL) +
    coord_cartesian(clip = "off") +
    theme_bw() + standard_theme +
    theme(plot.caption = element_text(size = 11), legend.position = "top")

  if (save_flag) {
    ggsave(plot = p, "plots/ogy2026_CDF_osszes_valjog_szav_telepmeret.png",
           width = 40, height = 22, units = "cm")
  }
  print(p)
})


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ============================================================
# CDF PÁRTONKÉNT
# x-tengely: LAKOSOK SZÁMA
# ============================================================

local({
  save_flag <- T
  for (mode_to_plot in c("share", "count")) { # [2]

  df_ogy2026 <- df_ogy2026 %>%
    mutate(part = ifelse(grepl("Mi_Haz", part), "MiHazánk", part))

  df_settlements <- df_ogy2026 %>%
    distinct(megye, telepules, lako_nepesseg, összes_vp, összes_szavazó)  # ← lako_nepesseg

  bp_total <- df_settlements %>%
    filter(megye == "Budapest") %>%
    summarise(
      megye          = "Budapest",
      telepules      = "Budapest",
      lako_nepesseg  = sum(lako_nepesseg),   # ← lako_nepesseg
      összes_vp      = sum(összes_vp),
      összes_szavazó = sum(összes_szavazó),
      .groups = "drop")

  df_base <- df_settlements %>%
    filter(megye != "Budapest") %>%
    bind_rows(bp_total)

  df_party_all <- df_ogy2026 %>%
    group_by(megye, telepules, part) %>%
    summarise(szavazat = sum(szavazat), .groups = "drop")

  df_party_base <- df_party_all %>%
    filter(megye != "Budapest") %>%
    bind_rows(
      df_party_all %>%
        filter(megye == "Budapest") %>%
        group_by(part) %>%
        summarise(
          megye     = "Budapest",
          telepules = "Budapest",
          szavazat  = sum(szavazat),
          .groups = "drop"))

  make_cdf <- function(party, mode = c("share", "count")) {
    mode <- match.arg(mode)
    df <- df_base %>%
      left_join(df_party_base %>% filter(part == party),
                by = c("megye", "telepules")) %>%
      mutate(szavazat = replace_na(szavazat, 0)) %>%
      arrange(lako_nepesseg) %>%                               # ← lako_nepesseg
      mutate(
        cum_party = cumsum(szavazat),
        cum_vp    = cumsum(összes_vp))
    total_party <- sum(df$szavazat)
    df <- df %>%
      mutate(
        cdf   = if (mode == "share") cum_party / total_party else cum_party,
        party = party,
        mode  = mode)
    df %>% select(megye, telepules, lako_nepesseg, cdf, party, mode)  # ← lako_nepesseg
  }

  parties <- if (mode_to_plot == "count") {
    c("TISZA", "FIDESZ_KDNP")
  } else {
    c("TISZA", "FIDESZ_KDNP", "MiHazánk")
  }

  df_cdf <- purrr::map_dfr(parties, \(p)
    purrr::map_dfr(c("share", "count"), \(m) make_cdf(p, m)))

  df_bp_label <- df_party_all %>%
    filter(megye == "Budapest") %>%
    group_by(part) %>%
    summarise(bp_votes = sum(szavazat), .groups = "drop") %>%
    filter(part %in% c("TISZA", "FIDESZ_KDNP", "MiHazánk"))

  df_bp_label_share <- df_party_all %>%
    group_by(part) %>%
    summarise(total = sum(szavazat), .groups = "drop") %>%
    right_join(df_bp_label, by = "part") %>%
    mutate(share = bp_votes / total)

  df_bp_label_plot <- if (mode_to_plot == "share") {
    df_bp_label_share %>%
      mutate(display_name = ifelse(part == "FIDESZ_KDNP", "FIDESZ", part),
             piece = paste0(display_name, " ", scales::percent(share, accuracy = 1))) %>%
      summarise(label = paste0("Budapest: ", paste(piece, collapse = ", ")))
  } else {
    df_bp_label %>%
      mutate(display_name = ifelse(part == "FIDESZ_KDNP", "FIDESZ", part),
             piece = paste0(display_name, " ",
               scales::label_number(scale = 1e-3, suffix = "e")(bp_votes))) %>%
      summarise(label = paste0("Budapest: ", paste(piece, collapse = ", ")))
  }

  df_plot <- df_cdf %>%
    filter(mode == mode_to_plot, megye != "Budapest")

  df_endpoints <- df_plot %>%
    group_by(party) %>%
    slice_max(lako_nepesseg, n = 1) %>%
    ungroup() %>%
       mutate(
      vjust_val = case_when(
        mode_to_plot == "count" & grepl("TISZA", party)       ~ -1,
        mode_to_plot == "count"                               ~  2,
        # share mode: spread the three labels out
        grepl("TISZA", party)                                 ~ 0,
        grepl("FIDESZ", party)                                ~  -1,
        grepl("MiH", party)                                   ~  1,
        TRUE                                                  ~  0
      ),
      hjust_val = if_else(mode_to_plot == "count", 0, -1/4)
    )
  print(df_endpoints)
  
  if (grepl("count",mode_to_plot)) {
  # ── endpoint (last non-BP settlement per party) ────────────
  
  # print(df_endpoints)
  
  # ── crossing point ─────────────────────────────────────────
df_cross <- df_plot %>%
    filter(lako_nepesseg > 500) %>%          # ← ignore tiny settlements
    group_by(party) %>%
    arrange(lako_nepesseg, .by_group = TRUE) %>%
    mutate(cdf_clean = cummax(cdf)) %>%
    ungroup()
  
  # print(df_cross)
  
  # build a common grid and interpolate both parties
  x_grid <- sort(unique(df_cross$lako_nepesseg))

  interp <- function(p) {
    d <- df_cross %>% filter(party == p)
    approx(d$lako_nepesseg, d$cdf_clean, xout = x_grid, rule = 2)$y
  }

  tisza_y  <- interp("TISZA")
  fidesz_y <- interp("FIDESZ_KDNP")
  diff_vec <- tisza_y - fidesz_y
  cross_i  <- which(diff(sign(diff_vec)) != 0)[1]
  cross_x  <- mean(x_grid[cross_i:(cross_i + 1)])

  df_crossing <- tibble(
    party         = c("TISZA", "FIDESZ_KDNP"),
    lako_nepesseg = cross_x,
    cdf           = c(
      approx(df_cross %>% filter(party=="TISZA")        %>% pull(lako_nepesseg),
             df_cross %>% filter(party=="TISZA")        %>% pull(cdf_clean),
             xout=cross_x, rule=2)$y,
      approx(df_cross %>% filter(party=="FIDESZ_KDNP") %>% pull(lako_nepesseg),
             df_cross %>% filter(party=="FIDESZ_KDNP") %>% pull(cdf_clean),
             xout=cross_x, rule=2)$y
    )
  )

  # ── threshold points ───────────────────────────────────────
  thresholds <- c(5e3, 1e4, 2e4, 5e4, 1e5)
  # print(tail(df_plot))
  
    df_thresholds <- df_plot %>%
    group_by(party) %>%
    arrange(lako_nepesseg, .by_group = TRUE) %>%
    reframe(
      threshold      = thresholds,
      lako_nep_snap  = sapply(thresholds, \(t) {   # ← temp name
        idx <- which(lako_nepesseg <= t)
        if (length(idx) == 0) NA_real_ else lako_nepesseg[max(idx)]
      }),
      cdf = sapply(thresholds, \(t) {
        idx <- which(lako_nepesseg <= t)            # ← still sees original column
        if (length(idx) == 0) NA_real_ else max(cdf[idx])
      })
    ) %>%
    rename(lako_nepesseg = lako_nep_snap)
  # print(df_thresholds)
  
  # ── combine annotations ────────────────────────────────────
  df_annot <- bind_rows(
    df_crossing   %>% mutate(annot_type = "crossing"),
    df_thresholds %>% mutate(annot_type = "threshold")
  ) %>%
    mutate(
      label     = paste0(round(cdf / 1e3), "e"),
      vjust_val = if_else(party == "FIDESZ_KDNP", 2, -1)
    )
  
  # ── ribbon between curves ──────────────────────────────────
  df_ribbon <- tibble(
    lako_nepesseg = x_grid,
    tisza         = tisza_y,
    fidesz        = fidesz_y
  ) %>%
    mutate(
      ymin   = pmin(tisza, fidesz),
      ymax   = pmax(tisza, fidesz),
      winner = if_else(tisza > fidesz, "TISZA", "FIDESZ_KDNP")
    )
  
  } # extra dfs for count
  
  y_labels <- if (mode_to_plot == "share") {
    scales::label_percent(accuracy = 1)
  } else {
    scales::label_comma(big.mark = " ")
  }

  p <- ggplot(df_plot, aes(x = lako_nepesseg, y = cdf, color = party)) +  # ← lako_nepesseg
  geom_line() +
    { if (mode_to_plot == "count") list(
        geom_ribbon(
          data        = df_ribbon %>% filter(lako_nepesseg > 1e3),
          aes(x = lako_nepesseg, ymin = ymin, ymax = ymax, fill = winner),
          alpha       = 0.15,
          inherit.aes = FALSE),
        scale_fill_manual(
          values = c("TISZA" = "#1a3a6b", "FIDESZ_KDNP" = "#e07b00"),
          guide  = "none"),
        geom_point(
          data  = df_annot,
          aes(x = lako_nepesseg, y = cdf, color = party),
          shape = 21, size = 3, stroke = 1.5), # , fill = "white"
        geom_text(
          data = df_annot,
          aes(x = lako_nepesseg, y = cdf, color = party,
              label = label, vjust = vjust_val),
          size = 3.2, family = "sans", show.legend = F)
    )} +
    # endpoints
    geom_point(
          data  = df_endpoints,
          aes(x = lako_nepesseg, y = cdf, color = party),
          shape = 19, size = 3) +
    geom_text(
          data  = df_endpoints,
          aes(x = lako_nepesseg, y = cdf, color = party,
              label = paste0(round(cdf / ifelse(grepl("count",mode_to_plot),1e3,1/100)),
                ifelse(grepl("count",mode_to_plot),"e","%") ), 
            vjust = vjust_val,hjust =hjust_val), # hjust = -0.2, 
          size = 3.5, family = "sans", show.legend = F) +
    geom_text(data = df_bp_label_plot,
              aes(x = Inf, y = 0.05, label = label),
              inherit.aes = F, hjust = 1.1, size = 4) +
    scale_x_continuous(
      labels    = scales::label_comma(big.mark = " "),
      transform = "log10",
      limits    = c(200, NA),
      breaks    = c(200, 500, 1e3, 2e3, 3e3, 5e3, 1e4, 2e4, 5e4, 1e5, 2e5)) +
    scale_y_continuous(
      labels = y_labels,
      limits = c(0, NA),
      breaks = if (grepl("count", mode_to_plot)) c(0:5) * 5e5 else 0:10 * 10/100) +
    scale_color_manual(
      values = c("TISZA" = "#1a3a6b", "FIDESZ_KDNP" = "#e07b00", "MiHazánk" = "#006B3C"),
      labels = c("TISZA" = "TISZA", "FIDESZ_KDNP" = "FIDESZ", "MiHazánk" = "MiHazánk")) +
    labs(
      title = "Pártok szavazatainak kumulatív eloszlása településméret szerint",
      x= "Lakosok száma településenként",                 # ← updated
      y= paste0("Kumulatív ", ifelse(grepl("share", mode_to_plot), "arány", "szám")),
      color = NULL) +
    theme_bw() + standard_theme +
    theme(legend.position = "top")

  if (save_flag) {
    ggsave(plot = p, paste0("plots/ogy2026_CDF_partonkent_telepmeret",
                  ifelse(grepl("share", mode_to_plot), "_arany", "_szam"), ".png"),
           width = 40, height = 22, units = "cm")
  }
  print(p)
  }
})



# ============================================================
# ============================================================
# AD-HOC QUERIES  (összes_vp → lako_nepesseg as size filter)
# ============================================================

# hány településen fidesz+MH > Tisza?
df_ogy2026 %>%
  filter(lako_nepesseg > 1e4) %>%                              # ← lako_nepesseg
  select(!szavazat) %>%
  pivot_wider(names_from = part, values_from = szavazat_pct) %>%
  filter(FIDESZ_KDNP > TISZA) %>%
  select(c(megye, telepules, lako_nepesseg, összes_szavazó,    # ← lako_nepesseg
           reszvetel_pct, TISZA, FIDESZ_KDNP, Mi_Hazank)) %>%
  nrow()

# hány településen fidesz > 40
df_ogy2026 %>%
  filter(lako_nepesseg > 1e4) %>%                              # ← lako_nepesseg
  select(!szavazat) %>%
  pivot_wider(names_from = part, values_from = szavazat_pct) %>%
  filter(FIDESZ_KDNP > 40) %>%
  select(c(megye, telepules, lako_nepesseg, összes_szavazó,    # ← lako_nepesseg
           reszvetel_pct, TISZA, FIDESZ_KDNP, Mi_Hazank)) |>
  arrange(-FIDESZ_KDNP)

# fidesz < 30
df_ogy2026 %>%
  filter(lako_nepesseg > 1e4) %>%                              # ← lako_nepesseg
  select(!szavazat) %>%
  pivot_wider(names_from = part, values_from = szavazat_pct) %>%
  filter(FIDESZ_KDNP < 30 & !grepl("Budap", megye)) |>
  arrange(FIDESZ_KDNP) %>%
  select(c(megye, telepules, lako_nepesseg, összes_szavazó,    # ← lako_nepesseg
           reszvetel_pct, TISZA, FIDESZ_KDNP, Mi_Hazank)) |>
  arrange(-FIDESZ_KDNP)

# hány településen fidesz+MH > 45
df_ogy2026 %>%
  filter(lako_nepesseg > 1e4) %>%                              # ← lako_nepesseg
  select(!szavazat) %>%
  pivot_wider(names_from = part, values_from = szavazat_pct) %>%
  filter(FIDESZ_KDNP + Mi_Hazank > 45) %>%
  mutate(FIDESZ_MH = FIDESZ_KDNP + Mi_Hazank) %>%
  select(megye, telepules, lako_nepesseg,                      # ← lako_nepesseg
         reszvetel_pct, FIDESZ_KDNP, FIDESZ_MH, TISZA) |>
  arrange(-FIDESZ_MH)

# hány településen NEM kapott 50+%-ot a Tisza
df_ogy2026 %>%
  filter(lako_nepesseg > 1e4) %>%                              # ← lako_nepesseg
  select(!szavazat) %>%
  pivot_wider(names_from = part, values_from = szavazat_pct) %>%
  filter(TISZA < 50) %>%
  select(megye, telepules, lako_nepesseg,                      # ← lako_nepesseg
         reszvetel_pct, FIDESZ_KDNP, TISZA) |>
  arrange(-TISZA)

# 5000+ lakos (229 volt összes) – fidesz+MH > 45?
df_ogy2026 %>%
  filter(lako_nepesseg > 5e3) %>%                              # ← lako_nepesseg
  select(!szavazat) %>%
  pivot_wider(names_from = part, values_from = szavazat_pct) %>%
  filter(FIDESZ_KDNP + Mi_Hazank > 45) %>%
  mutate(FIDESZ_MH = FIDESZ_KDNP + Mi_Hazank) %>%
  select(megye, telepules, lako_nepesseg,                      # ← lako_nepesseg
         reszvetel_pct, FIDESZ_KDNP, FIDESZ_MH, TISZA) |>
  arrange(-FIDESZ_MH)

# max vote shares by town
df_ogy2026 %>%
  select(!c(összes_vp, `átjelentk.`, `külképv.`,
            helyi_szavazó, átjel_külk_boríték, érvénytelen)) |>
  group_by(part) %>%
  filter(szavazat_pct == max(szavazat_pct))

df_ogy2026 %>% group_by(part) %>%
  filter(szavazat_pct > 65 & grepl("TISZA", part)) %>%
  View()

df_ogy2026 %>% group_by(part) %>%
  filter(szavazat_pct > 70 & grepl("FIDESZ", part)) %>%
  select(!c(szavazo, ervenyes)) %>%
  arrange(-szavazat_pct) %>%
  View()

# "észak-koreai" eredmények
df_ogy2026 %>%
  filter(grepl("FIDESZ", part) & szavazat_pct > 60) |>
  group_by(megye) |>
  summarise(
    n_telep        = n(),
    lako_nepesseg  = sum(lako_nepesseg),                       # ← lako_nepesseg
    összes_szavazó = sum(összes_szavazó),
    reszvetel_pct  = 100 * összes_szavazó / sum(összes_vp),
    szavazat       = sum(szavazat))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# részvétel számok

# local({
#   
#   compute_row <- function(df, ev_label, filter_pat) {
#   vp <- df %>%
#     select(telepules, összes_vp) %>% distinct() %>%
#     summarise(sum(összes_vp)) %>% pull()
# 
#   party <- df %>%
#     filter(!grepl(filter_pat, part)) %>%
#     group_by(part) %>% summarise(szavazat=sum(szavazat)) %>%
#     mutate(kateg=case_when(
#       grepl("FIDESZ", part) ~ "Fidesz",
#       grepl("TISZA",  part) ~ "Tisza",
#       grepl("Mi_Haz", part) ~ "MiHazank",
#       TRUE                  ~ "Oellenzek")) %>%
#     group_by(kateg) %>%
#     summarise(pct=round(sum(szavazat)/vp*100, 1)) %>%
#     pivot_wider(names_from=kateg, values_from=pct)
# 
#   turnout <- df %>%
#     select(telepules, összes_vp, összes_szavazó) %>% distinct() %>%
#     summarise(Szavazott     = round(sum(összes_szavazó)/sum(összes_vp)*100, 1),
#               Nem_szavazott = round((sum(összes_vp)-sum(összes_szavazó))/sum(összes_vp)*100, 1))
# 
#   bind_cols(tibble(ev=ev_label), party, turnout)
# }
# 
# bind_rows(
#   compute_row(df_ogy2022, "OGY2022", "Megold|NEP"),
#   compute_row(df_EP2024,  "EP2024",  "Megold"),
#   compute_row(df_ogy2026, "OGY2026", "Megold|NEP")
# ) %>%
#   select(ev, Fidesz, MiHazank, Tisza, Oellenzek, Szavazott, Nem_szavazott)
#   
#   
# })

#
# df_EP2024 %>% 
#   filter(!grepl("Megold",part)) %>%
#   group_by(part) %>%
#   summarise(szavazat=sum(szavazat)) %>%
#   mutate(kateg=ifelse(grepl("TISZA|FIDESZ|Mi_Haz",part),part,"oellenzek")) %>%
#   group_by(kateg) %>%
#   summarise(szavazat=round(sum(szavazat)/1e6,2))
# 
# df_EP2024 %>% select(telepules,összes_vp,összes_szavazó) %>% 
#   distinct() %>% 
#   summarise(ossz_vp=sum(összes_vp),
#             ossz_szav=sum(összes_szavazó),
#             nem_szav=ossz_vp-ossz_szav) %>%
#   mutate(across(everything(), ~ round(. / 1e6, 2)))
# 
# ############
# 
# df_ogy2022 %>% 
#   filter(!grepl("Megold|NEP",part)) %>%
#   group_by(part) %>%
#   summarise(szavazat=sum(szavazat)) %>%
#   mutate(kateg=ifelse(grepl("TISZA|FIDESZ|Mi_Haz",part),part,"oellenzek")) %>%
#   group_by(kateg) %>%
#   summarise(szavazat=round(sum(szavazat)/1e6,2))
# 
# df_ogy2022 %>% select(telepules,összes_vp) %>% distinct() %>% summarise(sum(összes_vp))
# 
# df_ogy2022 %>% select(telepules,összes_vp,összes_szavazó) %>% 
#   distinct() %>% 
#   summarise(ossz_vp=sum(összes_vp),
#             ossz_szav=sum(összes_szavazó),
#             nem_szav=ossz_vp-ossz_szav) %>%
#   mutate(across(everything(), ~ round(. / 1e6, 2)))
# 
# #################
# 
# 
# df_ogy2026 %>% 
#   filter(!grepl("Megold|NEP",part)) %>%
#   group_by(part) %>%
#   summarise(szavazat=sum(szavazat)) %>%
#   mutate(kateg=ifelse(grepl("TISZA|FIDESZ|Mi_Haz",part),part,"oellenzek")) %>%
#   group_by(kateg) %>%
#   summarise(szavazat=round(sum(szavazat)/1e6,2))
# 
# df_ogy2026 %>% select(telepules,összes_vp,összes_szavazó) %>% 
#   distinct() %>% 
#   summarise(ossz_vp=sum(összes_vp),
#             ossz_szav=sum(összes_szavazó),
#             nem_szav=ossz_vp-ossz_szav) %>%
#   mutate(across(everything(), ~ round(. / 1e6, 2)))
# 
# 
# ########### ########### ########### ########### ########### ########### 
# ########### ########### ########### ########### ########### ########### 
# 
# local({
# # ---- EP2024 ----
# vp_ep <- df_EP2024 %>%
#   select(telepules, összes_vp) %>% distinct() %>%
#   summarise(sum(összes_vp)) %>% pull()
# 
# df_EP2024 %>%
#   filter(!grepl("Megold", part)) %>%
#   group_by(part) %>% summarise(szavazat=sum(szavazat)) %>%
#   mutate(kateg=ifelse(grepl("TISZA|FIDESZ|Mi_Haz", part), part, "oellenzek")) %>%
#   group_by(kateg) %>%
#   summarise(pct=round(sum(szavazat)/vp_ep*100, 1))
# 
# df_EP2024 %>% select(telepules, összes_vp, összes_szavazó) %>% distinct() %>%
#   summarise(szavazott = round(sum(összes_szavazó)/sum(összes_vp)*100, 1),
#             nem_szav  = round((sum(összes_vp)-sum(összes_szavazó))/sum(összes_vp)*100, 1))
# 
# # ---- OGY2022 ----
# vp_22 <- df_ogy2022 %>%
#   select(telepules, összes_vp) %>% distinct() %>%
#   summarise(sum(összes_vp)) %>% pull()
# 
# df_ogy2022 %>%
#   filter(!grepl("Megold|NEP", part)) %>%
#   group_by(part) %>% summarise(szavazat=sum(szavazat)) %>%
#   mutate(kateg=ifelse(grepl("TISZA|FIDESZ|Mi_Haz", part), part, "oellenzek")) %>%
#   group_by(kateg) %>%
#   summarise(pct=round(sum(szavazat)/vp_22*100, 1))
# 
# df_ogy2022 %>% select(telepules, összes_vp, összes_szavazó) %>% distinct() %>%
#   summarise(szavazott = round(sum(összes_szavazó)/sum(összes_vp)*100, 1),
#             nem_szav  = round((sum(összes_vp)-sum(összes_szavazó))/sum(összes_vp)*100, 1))
# 
# # ---- OGY2026 ----
# vp_26 <- df_ogy2026 %>%
#   select(telepules, összes_vp) %>% distinct() %>%
#   summarise(sum(összes_vp)) %>% pull()
# 
# df_ogy2026 %>%
#   filter(!grepl("Megold|NEP", part)) %>%
#   group_by(part) %>% summarise(szavazat=sum(szavazat)) %>%
#   mutate(kateg=ifelse(grepl("TISZA|FIDESZ|Mi_Haz", part), part, "oellenzek")) %>%
#   group_by(kateg) %>%
#   summarise(pct=round(sum(szavazat)/vp_26*100, 1))
# 
# df_ogy2026 %>% 
#   select(telepules, összes_vp, összes_szavazó) %>% distinct() %>%
#   summarise(szavazott = round(sum(összes_szavazó)/sum(összes_vp)*100, 1),
#             nem_szav  = round((sum(összes_vp)-sum(összes_szavazó))/sum(összes_vp)*100, 1))
# 
# })