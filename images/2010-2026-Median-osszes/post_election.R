### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Europion 2026/05 felmérés

# Medián (HVG): https://shorturl.at/9r6wB
# Europion: https://europion.hu/partpreferencia_202605/

###  standard plotting settings --------------
library(tidyverse); library(forcats); library(knitr)
library(kableExtra); library(gt); library(patchwork)
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

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ADATOK
europion_median_zavecz <- read_csv("inputs/demogr/europion_median_zavecz_2026_01_06.csv")
# "inputs/demogr/europion_median_zavecz_2026_05_06.csv"

# Adatforrások
# Závecz 2026-01 (jan 19-24): https://24.hu/belfold/2026/01/26/zavecz-kutatas-valasztas-januar/
# Závecz 2026-06 (jun eleje):  https://24.hu/belfold/2026/06/04/zavecz-research-tisza-rekord-fidesz/
# Europion 2026-05: https://europion.hu/partpreferencia_202605/
# Medián 2026-01 (jan 7-13):   https://hvg.hu/360/20260121_hvg-median-fidesz-orban-felelem-dpk-fiatalok
# Medián 2026-02 (feb 18-23):  
# https://hvg.hu/360/20260305_hvg-tisza-vs-fidesz-median-kozvelemeny-kutatas-demografiai-alapu-bontas
# Medián 2026-04-08: 
# https://hvg.hu/360/20260408_median-mandatumbecsles-fidesz-tisza-valasztas-kethamad-kampany
# Medián 2026-04-12: 
# hvg.hu/360/20260412_a-tisza-tortenelmi-gyozelmet-vetiti-elore-a-median-merese-a-kampany-utolso-napjaibol


# --- 3. Harmonizálás ---
plot_df <- europion_median_zavecz |>
  filter(!(forras=="Závecz" & dimenzio=="Korcsoport")) |>
  # filter(!grepl("Nem", dimenzio)) |>
  mutate(part=case_when(
    part %in% c("Mi Hazánk","Pártnélküli","DK","MKKP") ~ "Egyéb",
    TRUE ~ part)) |>
  group_by(forras, datum, dimenzio, csoport, part) |>
  summarise(szazalek=sum(szazalek), .groups="drop") |>
  # wide -> fill Egyéb residual -> long
  pivot_wider(names_from=part, values_from=szazalek) |>
  mutate(Egyéb=if_else(is.na(Egyéb), 100 - Fidesz - Tisza, Egyéb)) |>
  pivot_longer(cols=c(Fidesz, Tisza, Egyéb), names_to="part", values_to="szazalek") |>
  mutate(csoport=case_when(
    csoport %in% c("50-59","50-64") ~ "50-64*",
    csoport %in% c("60+","65+")     ~ "65+*",
    TRUE ~ csoport)) |>
    mutate(datum=if_else(datum==as.Date("2026-04-08"), as.Date("2026-04-12"), datum)) |>
  mutate(
    part=factor(part, levels=c("Fidesz","Tisza","Egyéb")),
    datum=factor(as.character(datum),
                 levels=c("2026-04-12","2026-05-09","2026-06-01"),
                 labels=c("Április (Medián)","Május (Europion)","Június (Závecz)")),
    csoport=factor(csoport, levels=c(
      "Teljes népesség",
      "Férfi","Nő",
      "18-29","30-39","40-49","50-64*","65+*",
      "község","egyéb város","megyei jogú város","főváros",
      "≤8 általános","szakmunkás","érettségi","felsőfokú") )
  )

# View(plot_df)

# --- 4. Ábra ---
local({
for (jan_pollster in c("Medián","Závecz")) {
  kor_keep <- if (jan_pollster=="Závecz") "Závecz" else c("Medián","Europion")

  plot_df <- europion_median_zavecz |>
    filter(!(grepl("2026-01", as.character(datum)) & forras != jan_pollster)) |>
    filter(!(dimenzio=="Korcsoport" & !(forras %in% kor_keep))) |>
    mutate(part=case_when(
      part %in% c("Mi Hazánk","Pártnélküli","DK","MKKP") ~ "Egyéb",
      TRUE ~ part)) |>
    group_by(forras, datum, dimenzio, csoport, part) |>
    summarise(szazalek=sum(szazalek), .groups="drop") |>
    pivot_wider(names_from=part, values_from=szazalek) |>
    mutate(Egyéb=if_else(is.na(Egyéb), 100 - Fidesz - Tisza, Egyéb)) |>
    pivot_longer(cols=c(Fidesz, Tisza, Egyéb), names_to="part", values_to="szazalek") |>
    mutate(csoport=case_when(
      csoport %in% c("50-59","50-64") ~ "50-64*",
      csoport %in% c("60+","65+")     ~ "65+*",
      TRUE ~ csoport)) |>
    mutate(datum=if_else(datum==as.Date("2026-04-08"), as.Date("2026-04-12"), datum)) |>
    mutate(datum=if_else(grepl("2026-01", as.character(datum)), as.Date("2026-01-15"), datum)) |>
    filter(datum %in% as.Date(c("2026-01-15","2026-02-23","2026-04-12","2026-05-09","2026-06-01"))) |>
    mutate(
      part=factor(part, levels=c("Fidesz","Tisza","Egyéb")),
      datum=factor(as.character(datum),
                   levels=c("2026-01-15","2026-02-23","2026-04-12","2026-05-09","2026-06-01"),
                   labels=c(paste0("Január (", jan_pollster, ")"),
                            "Február (Medián)","Április (Medián)",
                            "Május (Europion)","Június (Závecz)")),
      csoport=factor(csoport, levels=c(
        "Teljes népesség","Férfi","Nő",
        "18-29","30-39","40-49","50-64*","65+*",
        "18-39","40-59","59+",
        "község","egyéb város","megyei jogú város","főváros",
        "≤8 általános","szakmunkás","érettségi","felsőfokú"))
    )

  lev <- levels(plot_df$datum)
  fill_vals <- setNames(
    c("#fee6ce","#fdae6b","#fd8d3c","#f16913","#d94801",   # Fidesz: jan->jún
      "#c6dbef","#9ecae1","#6baed6","#2171b5","#08519c",   # Tisza
      "#d9d9d9","#bdbdbd","#969696","#737373","#525252"),  # Egyéb
    c(paste("Fidesz", lev), paste("Tisza", lev), paste("Egyéb", lev)))

  plot_df <- plot_df |>
    filter(!grepl("Teljes", dimenzio)) |>
    mutate(fillkey=factor(paste(part, datum), levels=names(fill_vals)))

  post_labels <- c("Május (Europion)","Június (Závecz)")
    
  make_row <- function(dim, show_legend=FALSE) {
    plot_df |>
      filter(dimenzio==dim) |>
      mutate(fillkey=factor(paste(part, datum), levels=names(fill_vals)),
             post=datum %in% post_labels) |>
      ggplot(aes(part, szazalek, fill=fillkey)) +
      geom_col(aes(colour=post), linewidth=0.6,
               position=position_dodge(0.8, preserve="single"), width=0.7) +
      geom_text(aes(label=szazalek),
                position=position_dodge(0.8, preserve="single"),
                vjust=-0.3, size=3) +
      facet_wrap(~ csoport, nrow=1) +
      scale_fill_manual(values=fill_vals, drop=FALSE, name=NULL,
                        guide=if (show_legend) "legend" else "none") +
      scale_colour_manual(values=c(`FALSE`=NA, `TRUE`="green"), guide="none") +
      scale_x_discrete(expand = expansion(mult=0.22)) +
      scale_y_continuous(expand=expansion(mult=c(0,0.14))) +
      labs(subtitle=dim, x=NULL, y="összes választó %-a") +
      theme_bw() + standard_theme +
      theme(panel.grid.major.x=element_blank(),
            plot.title = element_text(size=25),
            plot.subtitle=element_text(size=20),
            plot.caption=element_text(size=30))
  }

  age_note <- if (jan_pollster=="Závecz")
  { paste0("A korcsoport-panel a Závecz sávjait használja (18-39, 40-59, 59+), Závecz jan.+jún.; ",
      "a Medián/Europion eltérő sávjai itt kimaradnak.")
    }
  else
    {"*Életkori sávok: Medián 18-29, 50-64, 65+; Europion 50-59, 60+." }

   dims <- intersect(c("Iskolázottság","Korcsoport","Nem","Településtípus"),
                    unique(plot_df$dimenzio))
  
  p <- wrap_plots(
    lapply(seq_along(dims), function(i) make_row(dims[i], show_legend=(i==1))),
    ncol=1) +
    plot_layout(guides="collect") +
    plot_annotation(
      title=paste0("Pártpreferenciák a teljes népességben, 2026 január–június (január: ", 
        jan_pollster, ")"),
       caption=paste(age_note,
                    "A Mi Hazánk, DK, MKKP és Pártnélküli az Egyébben szerepel.",
                    "Zöld kerettel a választás (2026/04/12) utáni mérések (május, június).",
                    sep="\n")
      )

  suffix <- if (jan_pollster=="Medián") "median" else "zavecz"
  ggsave(paste0("plots/demogr/demogr_2026_jan_jun_",suffix,"_europion.png"),
         plot=p, width=40, height=25, units="cm")
  print(p)
}

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
      part =factor(part, levels=c("Fidesz", "Tisza")),
      honap=factor(datum, levels=lev,
                     labels=c("2026/04", "2026/05")) )

  plot_specs <- list(
    list(
      name  ="fidesz_tisza",
      parts =c("Fidesz", "Tisza"),
      palette=function(n)
        viridisLite::viridis(
          n, option="mako", begin=0.5, end=0.92,
          direction=1 ),
      title="Fidesz- és Tisza-támogatók száma, 2026 április → május" ),

    list(
      name  ="fidesz_only",
      parts =c("Fidesz"),
      # palette=function(n)   hcl.colors(     14,     palette="Oranges"   )[4:(n + 3)],
      palette=function(n)   hcl.colors(n, palette="Oranges"),
      title="Fidesz-támogatók száma, 2026 április → május")
  )

  for (spec in plot_specs) {

    bar_df <- base_df |>
      filter(part %in% spec$parts) |>
      mutate( xkey=interaction(part, honap,
                sep=", ", lex.order=T) )

    make_panel <- function(dim) {

      df <- bar_df |>
        filter(dimenzio == dim) |>
        mutate(
          csoport=droplevels(csoport),
          csoport=factor( csoport,
            levels=rev(levels(csoport)) )  )

      ggplot(df, aes(x=xkey, y=fo, fill=csoport)) +
        geom_col( colour="grey",alpha=3/4 ) + # , linewidth=0.3
        geom_text(
          aes(label=round(fo / 10) * 10),
          position=position_stack(vjust=0.5),
          size=6) +
        # fill
        scale_fill_manual(
          values=spec$palette(nlevels(df$csoport)),
          name=NULL ) +
        scale_x_discrete(limits=rev) +
        scale_y_continuous(
          expand=expansion(mult=c(0, 0.05)),
          breaks=1e3 * 0:8 / 2 ) +

        coord_flip() +
        guides(fill=guide_legend(reverse=T)) +
        labs( subtitle=dim, x=NULL, y="" ) +
        theme_bw() + standard_theme +
        theme( panel.grid.major.y=element_blank(),
          plot.subtitle=element_text(size=25, margin=margin(b=0)),
          # plot.caption=element_text(size=15),
          plot.margin=margin(t=5, r=5, b=5, l=5),
          legend.text=element_text(size=20),
          legend.position="top" )
    }

    dims <- c( "Korcsoport", "Településtípus", "Iskolázottság" )

    p <- wrap_plots( lapply(dims, make_panel), ncol=1 ) +
      plot_annotation(
        title=paste0( spec$title,
          " (ezer főben megadva, tízezerre kerekítve; ",
          "április: Medián, május: Europion)" ),
        caption=paste(
          "*Bizonyos életkori sávok nem azonosak:",
          "Medián 18-29 / 50-64 / 65+ vs. Europion 16-29 / 50-59 / 60+",
          "Az Europionnál a 8 általános és szakmunkás kategóriák nincsenek elkülönítve",
          # "(azonos %, csak népességarányos a bontás).",
          sep="\n" ) )

    print(p)

    ggsave( paste0(
      "plots/demogr/median202604_europion202605_", spec$name, "_teljnepesseg_absz_szam.png" ),
      plot=p, width=44, height=22, units="cm" )

  }

})