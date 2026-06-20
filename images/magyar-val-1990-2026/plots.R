### standard plotting settings --------------
library(tidyverse); library(forcats); library(knitr); library(kableExtra); library(gt)
rm(list=ls())
standard_theme <- theme(plot.title=element_text(hjust=0.5,size=20),
                        axis.text.x=element_text(size=14),
                        axis.text.y=element_text(size=14),
                        axis.title.x=element_text(size=17),
                        axis.title.y=element_text(size=17),
                        strip.text=element_text(size=18),
                        text=element_text(family="Calibri"),
                        panel.grid.minor=element_blank(),
                        legend.text=element_text(size=13))

# ── Colour map ─────────────────────────────────────────────────────────────────
party_cols <- c(
    "Fidesz"         = "#FF8C00",
    "FIDESZ-MDF"     = "#FF8C00",
    "FIDESZ-KDNP"    = "#FF8C00",
    "KDNP"           = "#FF6600",
    "FKGP"           = "olivedrab",
    "MDF"            = "green",
    "SZDSZ"          = "#5BC2E7",
    "MSZP"           = "#FF0000",
    "MSZP-PM"        = "#FF0000",
    "DK"             = "#1E90FF",
    "DK-MSZP-PM"     = "#FF0000",
    "Jobbik"         = "black",
    "Mi Hazánk"       = "green4",
    "Egyutt"         = "violet",
    "Összefog. 2014" = "#2E5FA3",
    "Összefog. 2022" = "#2E5FA3",
    "Tisza"          = "navyblue",
    "MKKP"           = "darkmagenta",
    "LMP"            = "darkgreen",
    "Momentum"       = "#6A5ACD",
    "Munkaspart"     = "brown",
    "MIÉP"           = "saddlebrown",
    "MIÉP-JOBBIK"    = "saddlebrown",
    "más"            = "grey30",
    "NSZ"            = "grey85"
  )

# ── Government coalitions ──────────────────────────────────────────────────────
gov_parties <- list(
  `1990` = c("MDF","KDNP","FKGP"),
  `1994` = c("MSZP","SZDSZ"),
  `1998` = c("Fidesz","FKGP","MDF","KDNP"),
  `2002` = c("MSZP","SZDSZ"),
  `2006` = c("MSZP","SZDSZ"),
  `2010` = c("Fidesz"),
  `2014` = c("Fidesz"),
  `2018` = c("Fidesz"),
  `2022` = c("Fidesz"),
  `2026` = c("Tisza")
)

# ── Load and filter ────────────────────────────────────────────────────────────
df_raw <- read_csv("val_eredmenyek_1990_2026.csv")

local({

  caption_text = paste0(
        "KORMÁNY 1990: MDF+KDNP+FKGP · 1994: MSZP+SZDSZ · 1998: Fidesz+FKGP+MDF+KDNP · ",
        "2002, 2006: MSZP+SZDSZ · 2010–2022: Fidesz · 2026: Tisza"
      )
  
df_gov <- map_dfr(names(gov_parties), function(yr) {
  df_raw %>%
    filter(ev == as.integer(yr),
           part %in% gov_parties[[yr]]) %>%
    select(ev, part, lista_szavazat,ervenyes, nevjegyzek)
}) %>%
  mutate(
    pct_jogosult = lista_szavazat / nevjegyzek * 100,
    # keep party factor in coalition order per year
    part = factor(part, levels = rev(unique(unlist(gov_parties))))
  )

# ── Prepare data with explicit per-year stack positions ────────────────────────
df_gov_long <- df_gov %>%
  mutate(
    abs_M        = lista_szavazat / 1e6,
    pct_jogosult = lista_szavazat / nevjegyzek * 100,
    pct_ervenyes = lista_szavazat / ervenyes   * 100
  ) %>%
  pivot_longer(c(abs_M, pct_jogosult, pct_ervenyes),
               names_to = "metric", values_to = "value") %>%
  mutate(metric = factor(metric,
                         levels = c("abs_M", "pct_jogosult", "pct_ervenyes"),
                         labels = c("Szavazatok (millió)",
                                    "Összes választásra jogosult %-a",
                                    "Érvényes szavazatok %-a")))

# biggest party at the BOTTOM of each stack, computed per year × metric
df_gov_long <- df_gov_long %>%
  group_by(metric, ev) %>%
  arrange(desc(lista_szavazat), .by_group = TRUE) %>%  # biggest first → bottom
  mutate(
    n_parts = n(),
    ymax    = cumsum(value),
    ymin    = ymax - value,
    xpos    = as.integer(factor(ev, levels = sort(unique(df_gov$ev))))
  ) %>%
  ungroup()

# totals per year × metric (label on top)
df_tot <- df_gov_long %>%
  group_by(metric, ev, xpos) %>%
  summarise(total = sum(value), .groups = "drop") %>%
  mutate(lab = ifelse(grepl("milli", metric),
                      paste0(sprintf("%.2f", total),"m"),
                      sprintf("%.1f%%", total)))

bw <- 0.325   # half bar width

# ── Plot ───────────────────────────────────────────────────────────────────────
ggplot(df_gov_long) +
  geom_rect(aes(xmin = xpos - bw, xmax = xpos + bw,
                ymin = ymin, ymax = ymax, fill = part),
            colour = "darkgrey", linewidth = 0.3, alpha = 0.5) +
  facet_wrap(~ metric, ncol = 1, scales = "free_y") +
  # per-party value inside its segment, just below the top edge
  geom_text(aes(x = xpos, y = ymax,
                label = ifelse(n_parts > 1,
                               ifelse(grepl("milli", metric),
                                      sprintf("%.2f", value),
                                      sprintf("%.1f%%", value)),
                               ""),
                size = lista_szavazat >= 2e5),
            vjust = 1.3, colour = "black", show.legend = FALSE) +
  scale_size_manual(values = c(`TRUE` = 4, `FALSE` = 2), guide = "none") +
  # total on top of each bar
  geom_text(data = df_tot,
            aes(x = xpos, y = total, label = lab),
            vjust = -0.4, size = 5, fontface = "bold") +
  scale_fill_manual(values = party_cols, name = NULL) +
  scale_x_continuous(breaks = sort(unique(df_gov_long$xpos)),
                     labels = sort(unique(df_gov$ev)),
                     expand = expansion(mult = c(0.03, 0.03))) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title = "Mekkora támogatás kellett a kormányalakításhoz?", 
        x = NULL, y = NULL,
        caption = caption_text  ) +
  theme_bw() + standard_theme +
  guides(fill = guide_legend(nrow = 1)) +
  theme(legend.position = "top", legend.box = "horizontal",
    plot.caption = element_text(size = 13),
    panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank()
    )

# SAVE
ggsave("plots/kormanypartok.png",width = 15, height = 10, dpi = 200)

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# now also plot oppo and nonvoters

local({

  df_raw <- read_csv("val_eredmenyek_1990_2026.csv")

  # classify each party row: government / opposition (>=5%, not gov) / drop
  df_class <- df_raw %>%
    mutate(
      is_gov = map2_lgl(ev, part, ~ .y %in% gov_parties[[as.character(.x)]]),
      grp    = case_when(
        is_gov                  ~ "kormány",
        lista_szavazat_pct >= 5 ~ "ellenzék",
        TRUE                    ~ NA_character_
      )
    ) %>%
    filter(!is.na(grp))

  # "más" = érvényes − (kormány + parlamenti ellenzék), by subtraction (per year)
  df_mas <- df_class %>%
    group_by(ev) %>%
    summarise(plotted = sum(lista_szavazat),
              nevjegyzek = first(nevjegyzek),
              ervenyes   = first(ervenyes), .groups = "drop") %>%
    transmute(
      ev,
      part           = "más",
      grp            = "más",
      lista_szavazat = ervenyes - plotted,
      nevjegyzek, ervenyes,
      lista_szavazat_pct = NA_real_
    )

  # nonvoters: nevjegyzek − megjelent
  df_nonvote <- df_raw %>%
    distinct(ev, nevjegyzek, megjelent, ervenyes) %>%
    transmute(
      ev,
      part           = "NSZ",
      grp            = "NSZ",
      lista_szavazat = nevjegyzek - megjelent,
      nevjegyzek, ervenyes,
      lista_szavazat_pct = NA_real_
    )

  df_all <- bind_rows(
    df_class   %>% select(ev, part, grp, lista_szavazat, nevjegyzek, ervenyes),
    df_mas     %>% select(ev, part, grp, lista_szavazat, nevjegyzek, ervenyes),
    df_nonvote %>% select(ev, part, grp, lista_szavazat, nevjegyzek, ervenyes)
  )

  # long over three metrics; NSZ excluded from pct_ervenyes panel
  df_long <- df_all %>%
    mutate(
      abs_M        = lista_szavazat / 1e6,
      pct_jogosult = lista_szavazat / nevjegyzek * 100,
      pct_ervenyes = lista_szavazat / ervenyes   * 100
    ) %>%
    pivot_longer(c(abs_M, pct_jogosult, pct_ervenyes),
                 names_to = "metric", values_to = "value") %>%
    filter(!(grp == "NSZ" & metric == "pct_ervenyes")) %>%
    mutate(metric = factor(metric,
                           levels = c("abs_M","pct_jogosult","pct_ervenyes"),
                           labels = c("szavazatszám (millió)",
                                      "% választásra jogosult",
                                      "% szavazat")))

  # within-(metric, year, grp) stack order: biggest = 1 (bottom)
  df_long <- df_long %>%
    group_by(metric, ev, grp) %>%
    arrange(desc(lista_szavazat), .by_group = TRUE) %>%
    mutate(n_parts = n(),
           stack_id = row_number()) %>%
    ungroup()

  # totals per column
  df_tot <- df_long %>%
    group_by(metric, ev, grp) %>%
    summarise(total = sum(value), .groups = "drop") %>%
    mutate(lab = ifelse(grepl("milli", metric),
                        paste0(sprintf("%.2f", total), "m"),
                        sprintf("%.1f%%", total)))

  
  metrics <- c(
  "szavazatszám (millió)",
  "% választásra jogosult",
  "% szavazat"
)

  caption_text = paste0(
        "KORMÁNY 1990: MDF+KDNP+FKGP · 1994: MSZP+SZDSZ · 1998: Fidesz+FKGP+MDF+KDNP · ",
        "2002, 2006: MSZP+SZDSZ · 2010–2022: Fidesz · 2026: Tisza\n",
        
        "ELLENZÉK 1990: SZDSZ, MSZP, Fidesz · 1994: MDF, FKGP, KDNP, Fidesz · ",
        "1998: MSZP, SZDSZ, MIÉP · ", 
        "2002: Fidesz-MDF · 2006: Fidesz-KDNP, MDF\n",
        "2010: MSZP, Jobbik, LMP · 2014: Össz.2014, Jobbik, LMP · ",
        "2018: Jobbik, MSZP-PM, LMP, DK · 2022: Össz.2022, Mi Hazánk · ",
        "2026: Fidesz, Mi Hazánk"
      )
  
  subtitle_text <- paste0(
    "kormány = a választás UTÁN kormányt alakító pártok. ",
    "ellenzék = a választás UTÁNI parlamenti ellenzék. ",
    "NSZ = nem szavazók.  más = parlamentbe be nem jutó pártok")
  
  
for (m in metrics) {

  df_plot <- df_long %>% filter(metric == m)

    df_nev <- df_plot %>%
    distinct(ev, nevjegyzek) %>%
    mutate(lab = paste0(sprintf("%.2f", nevjegyzek / 1e6), "m"))
  
  
  df_tot_plot <- df_tot %>% filter(metric == m)

  p <- ggplot(
      df_plot,
      aes(x = grp, y = value, fill = part, group = -stack_id)
    ) +
    geom_col(
      width = 0.85,
      colour = "black",
      linewidth = 0.2,
      alpha = 0.5,
      position = position_stack() ) +
    facet_wrap(~ev,nrow=2) +
    geom_text(
      aes(label = ifelse(
          n_parts > 1,
          ifelse(
            grepl("milli", metric),
            sprintf("%.2f", value),
            sprintf("%.1f%%", value) ), "" ),
        group = -stack_id,
        size = lista_szavazat >= 2e5 ),
      position = position_stack(vjust = 1),
      vjust = 1.25,
      colour = "black",
      show.legend = F) +
    scale_size_manual(
      values = c(`TRUE` = 3.5, `FALSE` = 2),
      guide = "none" ) +
    # totals by bar
    geom_text(
      data = df_tot_plot,
      aes(x = grp, y = total, label = lab),
      inherit.aes = FALSE,
      vjust = -0.4,
      size = 4,
      fontface = "bold" ) +
    # névjegyzék
      geom_text(
      data = df_nev,
      aes(x = -Inf, y = Inf, label = lab),
      inherit.aes = FALSE,
      hjust = -0.15, vjust = 1.4,
      size = 3.5, fontface = "italic", colour = "grey30" ) +
    
    # colors
    scale_fill_manual(values = party_cols, name = NULL) +
    scale_x_discrete(limits = if (m == "% szavazat") 
                             c("kormány","ellenzék","más") 
                           else 
                             c("kormány","ellenzék","más","NSZ")) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
    labs(
      title = paste("1990-2026 OGY választások —", gsub("\n"," ",m)),
      subtitle = subtitle_text,
      x = NULL,
      y = m,
      caption = caption_text ) +
    theme_bw() + standard_theme +
    guides(fill = guide_legend(nrow = 2)) +
    theme(
      legend.position = "top",
      plot.caption = element_text(size = 12, hjust = 0),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.text.x = element_text(angle=15, hjust = 1) # , size = 9
    )

  fname <- case_when(
    m == "szavazatszám (millió)"      ~ "kormany_ellenzek_abs.png",
    m == "% választásra jogosult" ~ "kormany_ellenzek_jogosult_pct.png",
    m == "% szavazat"              ~ "kormany_ellenzek_ervenyes_pct.png"
  )

  print(p)
  
  ggsave(
    file.path("plots", fname),
    p,
    width = 15,
    height = 8,
    dpi = 200
  )
}
  
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# MENNYIVEL NYERT AZ ÚJ KORMÁNYPÁRT(ok)?

local({

  gov_parties <- list(
    `1990` = c("MDF","KDNP","FKGP"), `1994` = c("MSZP","SZDSZ"),
    `1998` = c("Fidesz","FKGP","MDF","KDNP"), `2002` = c("MSZP","SZDSZ"),
    `2006` = c("MSZP","SZDSZ"), `2010` = c("Fidesz"), `2014` = c("Fidesz"),
    `2018` = c("Fidesz"), `2022` = c("Fidesz"), `2026` = c("Tisza")
  )

  df_raw <- read_csv("val_eredmenyek_1990_2026.csv")

  # per-year gov & parl-oppo vote sums, then the signed margin per metric
  df_margin <- df_raw %>%
    mutate(is_gov = map2_lgl(ev, part, ~ .y %in% gov_parties[[as.character(.x)]]),
           grp = case_when(is_gov ~ "gov",
                           lista_szavazat_pct >= 5 ~ "oppo",
                           TRUE ~ NA_character_)) %>%
    filter(!is.na(grp)) %>%
    group_by(ev, grp) %>%
    summarise(votes = sum(lista_szavazat),
              nevjegyzek = first(nevjegyzek),
              ervenyes   = first(ervenyes), .groups = "drop") %>%
    pivot_wider(names_from = grp, values_from = votes) %>%
    mutate(
      abs_M        = (gov - oppo) / 1e6,
      pct_jogosult = (gov - oppo) / nevjegyzek * 100,
      pct_ervenyes = (gov - oppo) / ervenyes   * 100
    ) %>%
    pivot_longer(c(abs_M, pct_jogosult, pct_ervenyes),
                 names_to = "metric", values_to = "value") %>%
    mutate(
      metric = factor(metric,
                      levels = c("abs_M","pct_jogosult","pct_ervenyes"),
                      labels = c("szavazatszám (millió)",
                                 "% választásra jogosult",
                                 "% szavazat")),
      lab = ifelse(grepl("milli", metric),
                   sprintf("%+.2fm", value),
                   sprintf("%+.1f", value)),
      sign = ifelse(value >= 0, "kormány", "ellenzék")
    )

  ggplot(df_margin, aes(x = factor(ev), y = value, fill = sign)) +
    geom_col(width = 0.6, colour = "black", linewidth = 0.2, alpha = 0.6) +
    geom_hline(yintercept = 0, colour = "black", linewidth = 0.4) +
    facet_grid(metric ~ ., scales = "free_y", switch = "y") +
    geom_text(aes(label = lab,
                  vjust = ifelse(value >= 0, -0.4, 1.3)),
              size = 5, fontface = "bold") +
    scale_fill_manual(values = c("kormány" = "#2E8B57", "ellenzék" = "#C0392B"),
                      name = NULL) +
    scale_y_continuous(expand = expansion(mult = c(0.12, 0.12))) +
    labs(
      title = "A kormányt alakító pártok előnye az (új) ellenzékkel szemben",
      subtitle = "kormányt alakító pártok listás szavazatai mínusz a parlamenti ellenzéké",
      x = NULL, y = NULL,
      caption = paste0("Pozitív = a győztes (kormányt alakító) pártok több szavazatot kaptak.",
      "2014: a Fidesz a baloldali összefogás + Jobbik mögött maradt.")
    ) +
    theme_bw() + standard_theme +
    guides(fill = guide_legend(nrow = 1)) +
    theme(legend.position = "top",
          axis.text.x = element_text(size=18),
          plot.caption = element_text(size=14,hjust=0),
          plot.subtitle = element_text(size=14,hjust=0),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank())
  
  ggsave("plots/kormany_ellenz_kulonbseg.png",width = 15, height = 10, dpi = 200)
  
})
