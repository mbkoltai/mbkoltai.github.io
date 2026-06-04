### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Europion 2026/05 felmérés

# Medián (HVG): https://shorturl.at/9r6wB
# Europion: https://europion.hu/partpreferencia_202605/

europion_2026_05 <- read_csv("adatok/europion_2026_05.csv")

library(readr)
library(dplyr)
library(ggplot2)

# --- 1. Beolvasás ---
europion_2026_05 <- read_csv("adatok/europion_2026_05.csv")

# --- 3. Harmonizálás ---
plot_df <- europion_2026_05 |>
  # Mi Hazánk az "Egyéb"-be olvasztva, mert a Medián nem közli külön -> így összevethető
  mutate(part = if_else(part == "Mi Hazánk", "Egyéb", part)) |>
  group_by(datum, dimenzio, csoport, part,forras) |>
  summarise(fo=sum(fo),szazalek = sum(szazalek), .groups = "drop") |>
  # eltérő életkori sávok közös címkére (lásd csillag a feliratban)
  mutate(csoport = case_when(
    csoport %in% c("50-59", "50-64") ~ "50-64*",
    csoport %in% c("60+",  "65+")    ~ "65+*",
    TRUE ~ csoport )) |>
  # a nem szerinti bontás kimarad: a Mediánnál nincs áprilisi adat hozzá
  filter(!grepl("Nem",dimenzio)) |>
  mutate(
    part    = factor(part,  levels = c("Fidesz", "Tisza", "Egyéb")),
    datum = factor(as.character(datum),
               levels = c("2026-04-12", "2026-05-09"),
               labels = c("Április (Medián)", "Május (Europion)")),
    csoport = factor(csoport, levels = c(
      "Teljes népesség",
      "18-29", "30-39", "40-49", "50-64*", "65+*",
      "község", "egyéb város", "megyei jogú város", "főváros",
      "≤8 általános", "szakmunkás", "érettségi", "felsőfokú"
    ))
)

# --- 4. Ábra ---

local({

library(patchwork)

# light = április, dark = május — names built from the real datum levels (accent-proof)
lev <- levels(plot_df$datum)                       # [1] április, [2] május
fill_vals <- setNames(
  c("#fdae6b", "#d94801",    # Fidesz: világos / sötét narancs
    "#6baed6", "#08519c",    # Tisza : világosabb / sötét kék
    "#d9d9d9", "#636363"),   # Egyéb : világos / sötét szürke
  c(paste("Fidesz", lev), paste("Tisza", lev), paste("Egyéb", lev))
)

plot_df <- plot_df |>
  filter(!grepl("Teljes",dimenzio)) %>%
  mutate(fillkey = factor(paste(part, datum), levels = names(fill_vals)))

# egy panelsor egy dimenzióhoz
make_row <- function(dim) {
  plot_df |>
    filter(dimenzio == dim) |>
    ggplot(aes(part, szazalek, fill = fillkey)) +
    geom_col(position = position_dodge(0.75), width = 0.65) +
    geom_text(aes(label = szazalek),
              position = position_dodge(0.75), vjust = -0.3, size = 4) +
    facet_wrap(~ csoport, nrow = 1) +
    scale_fill_manual(values = fill_vals, drop = FALSE, name = NULL) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
    labs(subtitle = dim, x = NULL, y = "összes választó %-a") +
    theme_bw() + standard_theme +
    theme(panel.grid.major.x = element_blank(),
      plot.caption=element_text(size=16))
}

dims <- unique(plot_df$dimenzio)  # c("Korcsoport", "Településtípus", "Iskolázottság")

p <- wrap_plots(lapply(dims, make_row), ncol = 1) +
  plot_layout(guides = "collect") +
  plot_annotation(
    title    = "Pártpreferenciák a teljes népességben, 2026 április-május",
    subtitle = "(világos = április / Medián, sötét = május / Europion)",
    caption  = paste(
      "*Bizonyos életkori sávok nem azonosak: ",
      "Medián 18-29, 50-64, 65+, Europion 16-29, 50-59, 60+.",
      "Az Europion felmérésben a \"8 általános\" és \"szakmunkás\" ",
      "kategóriák nincsenek elkülönítve.",
      "A Mi Hazánk az Egyébben szerepel (a Medián nem közölte külön).",
      sep = "\n")
  ) # &# theme(legend.position = "top")
  
ggsave(paste0("plots/KVK/",
                  "median202604_europion202605_teljesnepesseg.png"),
           plot = p, width = 40, height = 22, units = "cm")
print(p)
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# STACKED BARPLOTS

local({

  library(patchwork)
  library(viridisLite)

  lev <- levels(plot_df$datum)

  base_df <- plot_df |>
    filter(part %in% c("Fidesz", "Tisza"),
           !grepl("Teljes", dimenzio)) |>
    mutate(
      part  = factor(part, levels = c("Fidesz", "Tisza")),
      honap = factor(datum, levels = lev,
                     labels = c("2026/04", "2026/05")) )

  plot_specs <- list(
    list(
      name   = "fidesz_tisza",
      parts  = c("Fidesz", "Tisza"),
      palette = function(n)
        viridisLite::viridis(
          n, option = "mako", begin = 0.5, end = 0.92,
          direction = 1 ),
      title = "Fidesz- és Tisza-támogatók száma, 2026 április → május" ),

    list(
      name   = "fidesz_only",
      parts  = c("Fidesz"),
      # palette = function(n)   hcl.colors(     14,     palette = "Oranges"   )[4:(n + 3)],
      palette = function(n)   hcl.colors(n, palette = "Oranges"),
      title = "Fidesz-támogatók száma, 2026 április → május")
  )

  for (spec in plot_specs) {

    bar_df <- base_df |>
      filter(part %in% spec$parts) |>
      mutate( xkey = interaction(part, honap,
                sep = ", ", lex.order=T) )

    make_panel <- function(dim) {

      df <- bar_df |>
        filter(dimenzio == dim) |>
        mutate(
          csoport = droplevels(csoport),
          csoport = factor( csoport,
            levels = rev(levels(csoport)) )  )

      ggplot(df, aes(x = xkey, y = fo, fill = csoport)) +
        geom_col( colour = "grey",alpha=3/4 ) + # , linewidth = 0.3
        geom_text(
          aes(label = round(fo / 10) * 10),
          position = position_stack(vjust = 0.5),
          size=6) +
        # fill
        scale_fill_manual(
          values = spec$palette(nlevels(df$csoport)),
          name = NULL ) +
        scale_x_discrete(limits = rev) +
        scale_y_continuous(
          expand = expansion(mult = c(0, 0.05)),
          breaks = 1e3 * 0:8 / 2 ) +

        coord_flip() +
        guides(fill = guide_legend(reverse=T)) +
        labs( subtitle = dim, x = NULL, y = "" ) +
        theme_bw() + standard_theme +
        theme( panel.grid.major.y = element_blank(),
          plot.subtitle = element_text(size=25, margin = margin(b = 0)),
          # plot.caption = element_text(size=15),
          plot.margin = margin(t = 5, r = 5, b = 5, l = 5),
          legend.text = element_text(size=20),
          legend.position = "top" )
    }

    dims <- c( "Korcsoport", "Településtípus", "Iskolázottság" )

    p <- wrap_plots( lapply(dims, make_panel), ncol = 1 ) +
      plot_annotation(
        title = paste0( spec$title,
          " (ezer főben megadva, tízezerre kerekítve; ",
          "április: Medián, május: Europion)" ),
        caption = paste(
          "*Bizonyos életkori sávok nem azonosak:",
          "Medián 18-29 / 50-64 / 65+ vs. Europion 16-29 / 50-59 / 60+",
          "Az Europionnál a 8 általános és szakmunkás kategóriák nincsenek elkülönítve",
          # "(azonos %, csak népességarányos a bontás).",
          sep = "\n" ) )

    print(p)

    ggsave( paste0(
      "plots/KVK/median202604_europion202605_", spec$name, "_teljnepesseg_absz_szam.png" ),
      plot = p, width = 44, height = 22, units = "cm" )

  }

})