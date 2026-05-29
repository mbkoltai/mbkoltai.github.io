# checks if code works properly

df_ogy2026 %>%
  filter(lako_nepesseg>=1e3 & lako_nepesseg<=2e3) %>%
  group_by(part) %>%
  summarise(szavazat=sum(szavazat),
            összes_vp=) %>%
  ungroup() %>%
  
df_ogy2026 %>% 
  select(telepules,lako_nepesseg,összes_vp,part,szavazat) %>%
  pivot_wider(values_from = szavazat,names_from = part)  %>% 
  # filter(lako_nepesseg>=2e4 & lako_nepesseg<=4e4 & !grepl("Budap",telepules)) %>%
  filter(lako_nepesseg>=4e4 & !grepl("Budap",telepules)) %>%
  summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Europion 2026/05 felmérés

# hvg.hu/360/20260412_a-tisza-tortenelmi-gyozelmet-vetiti-elore-a-median-merese-a-kampany-utolso-napjaibol
# https://europion.hu/partpreferencia_202605/

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
  summarise(szazalek = sum(szazalek), .groups = "drop") |>
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
      "*Bizonyos életkori sávok nem azonosak: Medián 18-29, 50-64, 65+, Europion 16-29, 50-59, 60+.",
      "Az Europion felmérésben a \"8 általános\" és \"szakmunkás\" kategóriák nincsenek elkülönítve.",
      "A Mi Hazánk az Egyébben szerepel (a Medián nem közölte külön).",
      sep = "\n")
  ) # &# theme(legend.position = "top")
  
ggsave(paste0("plots/KVK/",
                  "median202604_europion202605_teljesnepesseg.png"),
           plot = p, width = 40, height = 22, units = "cm")
print(p)
})

