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

party_cols <- c(
  "Fidesz"        ="#FF8C00",
  "Jobbik"        ="black",
  "MiHazank"      ="green4",
  "MDF"           ="green",
  "Egyutt"        ="violet",
  "DK"            ="#1E90FF",       # bright dodger blue
  "DK-MSZP-PM"   ="#FF0000",
  "MSZP-PM"       ="#FF0000",
  "MSZP"          ="#FF0000",
  "Osszefogas2014"="#2E5FA3",       # mid-navy — between DK and Tisza
  "Osszefogas2022"="#2E5FA3",
  "Tisza"         ="#00008B",       # darkblue
  "MKKP"          ="darkmagenta",
  "LMP"           ="darkgreen",
  "Momentum"      ="#6A5ACD",
  "Egyutt"      ="#6A5ACD",
  "Munkaspart"    ="brown",
  "nincs_partja"  ="grey50",
  "egyeb"         ="grey70"
)


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

# ---------------------------------------------------
# LOAD
# ---------------------------------------------------

df_polls <- read_csv("inputs/median_polls.csv") %>%
  mutate( datum=as.Date(datum) )

df_elections <- read_csv("inputs/val_eredmenyek.csv") %>%
  mutate(
    # election date approximation
    datum=case_when(
      ev == 2010 ~ as.Date("2010-04-11"),
      ev == 2014 ~ as.Date("2014-04-06"),
      ev == 2018 ~ as.Date("2018-04-08"),
      ev == 2022 ~ as.Date("2022-04-03"),
      ev == 2024 ~ as.Date("2024-06-09"),
      ev == 2026 ~ as.Date("2026-04-12")
    ),
    # turnout-adjusted share among total electorate
    teljes_nepesseg_share=100 * lista_szavazat / jogosult
  ) # %>% filter(valasztas_tipusa == "ogy") 

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ---------------------------------------------------
# PLOT
# ---------------------------------------------------

local({

  polls     <- df_polls
  elections <- df_elections

  save_flag <- T

  party_labels <- c(
    "Fidesz"="Fidesz", "Osszefogas2014"="Összefogás 2014",
    "Osszefogas2022"="Összefogás 2022", "Tisza"="Tisza",
    "MSZP"="MSZP", "DK"="DK", "Jobbik"="Jobbik",
    "MiHazank"="Mi Hazánk", "LMP"="LMP",
    "Egyutt"="Együtt", "Momentum"="Momentum", "MKKP"="MKKP",
    "nincs_partja"="Nincs pártja/NT/NV",
    "egyeb"="Egyéb")

  parties_show <- c(
    "Fidesz", "Osszefogas2014", "Osszefogas2022",
    "Tisza", "MSZP", "DK", "Jobbik", "LMP", "MKKP", "MiHazank",
    "Momentum", "Egyutt", "nincs_partja")

  subsumed_14 <- c("MSZP", "DK", "Jobbik", "LMP", "Egyutt", "Parbeszed")
  subsumed_22 <- c("MSZP", "DK", "Jobbik", "LMP", "Momentum", "Parbeszed")

  og_ranges <- polls %>%
    filter(grepl("Osszefogas", part)) %>%
    group_by(part) %>%
    summarise(from=min(datum), to=max(datum), .groups="drop")

  r14_from <- og_ranges %>% filter(part=="Osszefogas2014") %>% pull(from)
  r14_to   <- og_ranges %>% filter(part=="Osszefogas2014") %>% pull(to)
  r22_from <- og_ranges %>% filter(part=="Osszefogas2022") %>% pull(from)
  r22_to   <- og_ranges %>% filter(part=="Osszefogas2022") %>% pull(to)

  oe_parties <- c("Egyutt","DK","DK-MSZP-PM","Liberalisok","Parbeszed",
    "SZDSZ","MDF","Egyutt_Parbeszed","MMN","MSZP-PM","MSZP","MKKP","LMP","Momentum")
  jobbik_cutoff  <- as.Date("2020-11-01")
  oe_keep_as_is  <- c("Fidesz","Tisza","Osszefogas2014","Osszefogas2022",
                      "MiHazank","nincs_partja")
  party_labels_oe <- c(
    "Fidesz"="Fidesz", "Osszefogas2014"="Összefogás 2014",
    "Osszefogas2022"="Összefogás 2022", "Tisza"="Tisza",
    "oellenzek"="Óellenzék", "Jobbik"="Jobbik (−2020/11)",
    "MiHazank"="Mi Hazánk", "nincs_partja"="Nincs pártja/NT/NV",
    "egyeb"="Egyéb")
  oe_cols <- c(party_cols, "oellenzek"="#1E90FF")

  for (k_yr_start in 1:2) {

    yr_cutoff  <- ifelse(k_yr_start==1, year(min(polls$datum)), 2020)
    fname_year <- ifelse(k_yr_start==1, as.character(year(min(polls$datum))), "2020")

    # --- original plot data ---
    polls_plot <- polls %>%
      filter(year(datum) >= yr_cutoff) %>%
      filter(part %in% parties_show) %>%
      filter(!(part %in% subsumed_14 & between(datum, r14_from, r14_to))) %>%
      filter(!(part %in% subsumed_22 & between(datum, r22_from, r22_to))) %>%
      arrange(datum)

    polls_egyeb_orig <- polls %>%
      filter(year(datum) >= yr_cutoff) %>%
      filter(!part %in% parties_show) %>%
      group_by(datum) %>%
      summarise(teljes_nepesseg=sum(teljes_nepesseg, na.rm=TRUE), .groups="drop") %>%
      filter(teljes_nepesseg > 0) %>%
      mutate(part="egyeb")

    polls_plot <- bind_rows(polls_plot, polls_egyeb_orig) %>% arrange(datum)

    nincs_election <- elections %>%
      filter(ev >= yr_cutoff) %>%
      distinct(datum, ev, valasztas_tipusa, jogosult, megjelent) %>%
      mutate(part="nincs_partja",
             teljes_nepesseg_share=100*(jogosult-megjelent)/jogosult)

    elections_egyeb_orig <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(!part %in% parties_show) %>%
      group_by(datum, ev) %>%
      summarise(teljes_nepesseg_share=sum(teljes_nepesseg_share, na.rm=TRUE), .groups="drop") %>%
      filter(teljes_nepesseg_share > 0) %>%
      mutate(part="egyeb")

    elections_plot <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(part %in% parties_show) %>%
      bind_rows(nincs_election) %>%
      bind_rows(elections_egyeb_orig)

    election_lines <- elections %>%
      filter(ev >= yr_cutoff) %>%
      distinct(datum, ev) %>%
      arrange(datum) %>%
      mutate(label_hjust=if_else(datum==max(datum), 1.08, -0.08))

    polls_smooth <- polls_plot %>% filter(!grepl("Osszefogas", part))
    polls_og     <- polls_plot %>% filter(grepl("Osszefogas", part))

    # ==== ORIGINAL PLOT ====
    p <- ggplot() +
      geom_line(data=polls_plot,
        aes(x=datum, y=teljes_nepesseg, color=part),
        linewidth=0.4, alpha=0.25) +
      geom_smooth(data=polls_smooth %>% filter(datum<=max(unique(elections$datum))),
        aes(x=datum, y=teljes_nepesseg, color=part),
        method="loess", span=0.3, se=F, linewidth=1.15, alpha=2/3) +
      geom_point(data=polls_plot,
        aes(x=datum, y=teljes_nepesseg, color=part),
        size=2.5, alpha=0.5) +
      geom_line(data=polls_og,
        aes(x=datum, y=teljes_nepesseg, color=part),
        linewidth=1.3, alpha=0.9) +
      geom_point(data=polls_og,
        aes(x=datum, y=teljes_nepesseg, color=part),
        size=2.5, alpha=0.85) +
      geom_vline(data=election_lines, aes(xintercept=datum),
        linetype="dashed", color="grey40", linewidth=0.65) +
      geom_text(data=election_lines,
        aes(x=datum, y=ifelse(ev==2024,50,60),
            label=paste0(ifelse(ev==2024,"EP vál.\n","OGY vál.\n"),
                         format(datum,"%Y. %m. %d.")), hjust=label_hjust),
        vjust=1.4, size=4.5, color="grey35", lineheight=0.9) +
      geom_point(data=elections_plot,
        aes(x=datum, y=teljes_nepesseg_share, color=part),
        shape=18, size=5) +
      scale_color_manual(values=party_cols, labels=party_labels) +
      scale_x_date(date_breaks="1 year", date_labels="%Y",
        expand=expansion(mult=c(0.01, 0.01))) +
      geom_vline(xintercept=seq(
        floor_date(min(polls_plot$datum),"6 months"),
        ceiling_date(max(polls_plot$datum),"6 months"),
        by="6 months"), color="grey85", linewidth=0.15) +
      scale_y_continuous(breaks=0:10*10,
        labels=scales::label_number(suffix="%"),
        limits=c(0,NA), expand=expansion(c(0.01,0.02))) +
      labs(x="", y="Pártpreferenciák a teljes népességben",
        caption=paste0("Választási eredmények (◆), ",
          "illetve a Medián által mért preferenciák (o) az összes szavazásra jogosult %-ában"),
        color=NULL) +
      guides(color=guide_legend(nrow=2)) +
      theme_bw() + standard_theme +
      theme(legend.position="top", plot.caption=element_text(size=13))

    if (save_flag) ggsave(plot=p,
      paste0("plots/osszes_szav_szazalek_",fname_year,"_2026.png"),
      width=40, height=22, units="cm")
    print(p)

    # ==== ÓELLENZÉK VERSION ====
    polls_plot_oe_base <- polls %>%
      filter(year(datum) >= yr_cutoff) %>%
      filter(!(part %in% subsumed_14 & between(datum, r14_from, r14_to))) %>%
      filter(!(part %in% subsumed_22 & between(datum, r22_from, r22_to))) %>%
      arrange(datum)

    polls_oe_sum <- polls_plot_oe_base %>%
      filter(part %in% c(oe_parties, "Jobbik")) %>%
      filter(!(part=="Jobbik" & datum < jobbik_cutoff)) %>%
      group_by(datum) %>%
      summarise(teljes_nepesseg=sum(teljes_nepesseg, na.rm=TRUE), .groups="drop") %>%
      filter(teljes_nepesseg > 0) %>%
      mutate(part="oellenzek") %>%
      { if (length(r14_from)>0) filter(., !between(datum, r14_from, r14_to)) else . } %>%
      { if (length(r22_from)>0) filter(., !between(datum, r22_from, r22_to)) else . }

    polls_egyeb_oe <- polls_plot_oe_base %>%
      filter(!part %in% c(oe_keep_as_is, oe_parties, "Jobbik")) %>%
      group_by(datum) %>%
      summarise(teljes_nepesseg=sum(teljes_nepesseg, na.rm=TRUE), .groups="drop") %>%
      filter(teljes_nepesseg > 0) %>%
      mutate(part="egyeb")

    polls_plot_oe <- bind_rows(
      polls_plot_oe_base %>% filter(part %in% oe_keep_as_is),
      polls_plot_oe_base %>% filter(part=="Jobbik" & datum < jobbik_cutoff),
      polls_oe_sum,
      polls_egyeb_oe
    )

    elections_oe <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(part %in% c(oe_parties,"Osszefogas2014","Osszefogas2022","Jobbik")) %>%
      filter(!(part=="Jobbik" & datum < jobbik_cutoff)) %>%
      group_by(datum, ev) %>%
      summarise(teljes_nepesseg_share=sum(teljes_nepesseg_share, na.rm=TRUE), .groups="drop") %>%
      filter(teljes_nepesseg_share > 0) %>%
      mutate(part="oellenzek")

    elections_egyeb_oe <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(!part %in% c(oe_keep_as_is, oe_parties, "Jobbik")) %>%
      group_by(datum, ev) %>%
      summarise(teljes_nepesseg_share=sum(teljes_nepesseg_share, na.rm=TRUE), .groups="drop") %>%
      filter(teljes_nepesseg_share > 0) %>%
      mutate(part="egyeb")

    elections_plot_oe <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(part %in% c("Fidesz","Tisza","Osszefogas2014","Osszefogas2022",
                         "Jobbik","MiHazank")) %>%
      bind_rows(nincs_election) %>%
      bind_rows(elections_oe) %>%
      bind_rows(elections_egyeb_oe)

    polls_smooth_oe <- polls_plot_oe %>%
      filter(!grepl("Osszefogas", part)) %>%
      mutate(smooth_group=case_when(
        part != "oellenzek"                   ~ as.character(part),
        length(r22_from)>0 & datum > r22_to   ~ "oellenzek_c",
        length(r14_from)>0 & datum > r14_to   ~ "oellenzek_b",
        TRUE                                  ~ "oellenzek_a"))

    polls_og_oe <- polls_plot_oe %>% filter(grepl("Osszefogas", part))

    p_oe <- ggplot() +
      geom_vline(xintercept=seq(
        floor_date(min(polls_plot_oe$datum),"6 months"),
        ceiling_date(max(polls_plot_oe$datum),"6 months"),
        by="6 months"), color="grey85", linewidth=0.15) +
      geom_line(data=polls_plot_oe,
        aes(x=datum, y=teljes_nepesseg, color=part),
        linewidth=0.4, alpha=0.25) +
      geom_smooth(data=polls_smooth_oe %>% filter(datum<=max(unique(elections$datum))),
        aes(x=datum, y=teljes_nepesseg, color=part, group=smooth_group),
        method="loess", span=0.3, se=F, linewidth=1.15, alpha=2/3) +
      geom_point(data=polls_plot_oe,
        aes(x=datum, y=teljes_nepesseg, color=part),
        size=2.5, alpha=0.5) +
      geom_line(data=polls_og_oe,
        aes(x=datum, y=teljes_nepesseg, color=part),
        linewidth=1.3, alpha=0.9) +
      geom_point(data=polls_og_oe,
        aes(x=datum, y=teljes_nepesseg, color=part),
        size=2.5, alpha=0.85) +
      geom_vline(data=election_lines, aes(xintercept=datum),
        linetype="dashed", color="grey40", linewidth=0.65) +
      geom_text(data=election_lines,
        aes(x=datum, y=ifelse(ev==2024,50,60),
            label=paste0(ifelse(ev==2024,"EP vál.\n","OGY vál.\n"),
                         format(datum,"%Y. %m. %d.")), hjust=label_hjust),
        vjust=1.4, size=4.5, color="grey35", lineheight=0.9) +
      # election results diamonds
      geom_point(data=elections_plot_oe,
        aes(x=datum, y=teljes_nepesseg_share, color=part),
        shape=18, size=5) +
      # labels
      geom_text(
        data=elections_plot_oe, # %>% filter(part %in% label_parties_oe),
        aes(x=datum, y=teljes_nepesseg_share, color=part,
        label=paste0(round(teljes_nepesseg_share), "%")),
        hjust=-0.2, vjust=0.5, size=3.8, fontface="bold", show.legend=F) +
      scale_color_manual(values=oe_cols, labels=party_labels_oe) +
      scale_x_date(date_breaks="1 year", date_labels="%Y",
        expand=expansion(mult=c(0.01, 0.01))) +
      scale_y_continuous(breaks=0:10*10,
        labels=scales::label_number(suffix="%"),
        limits=c(0,NA), expand=expansion(c(0.01,0.02))) +
      labs(x="", y="Pártpreferenciák a teljes népességben",
        caption=paste0("Választási eredmények (◆), Medián preferenciák (o)\n",
          "Óellenzék = SZDSZ+MDF+DK+MSZP+LMP+Momentum+Együtt+MKKP+Liberálisok+Párbeszéd",
          " + Jobbik (2020/11-től)"),
        color=NULL) +
      guides(color=guide_legend(nrow=2)) +
      theme_bw() + standard_theme +
      theme(legend.position="top", plot.caption=element_text(size=13))

    if (save_flag) ggsave(plot=p_oe,
      paste0("plots/osszes_szav_szazalek_oell_",fname_year,"_2026.png"),
      width=40, height=22, units="cm")
    print(p_oe)

  } # end for loop
})


# ============================================================
# BLOCK 2: absolute numbers
# ============================================================


local({

  polls     <- df_polls
  elections <- df_elections

  save_flag <- T

  party_labels <- c(
    "Fidesz"="Fidesz", "Osszefogas2014"="Összefogás 2014",
    "Osszefogas2022"="Összefogás 2022", "Tisza"="Tisza",
    "MSZP"="MSZP", "Jobbik"="Jobbik", "DK"="DK",
    "MiHazank"="Mi Hazánk", "LMP"="LMP", "MKKP"="MKKP",
    "Egyutt"="Együtt", "Momentum"="Momentum",
    "nincs_partja"="Nincs pártja/NT/NV",
    "egyeb"="Egyéb")

  parties_show <- c(
    "Fidesz", "Osszefogas2014", "Osszefogas2022",
    "Tisza", "MSZP", "DK", "Jobbik", "LMP", "MKKP", "MiHazank",
    "Momentum", "Egyutt", "nincs_partja")

  subsumed_14 <- c("MSZP", "DK", "Jobbik", "LMP", "Egyutt", "Parbeszed")
  subsumed_22 <- c("MSZP", "DK", "Jobbik", "LMP", "Momentum", "Parbeszed")

  og_ranges <- polls %>%
    filter(grepl("Osszefogas", part)) %>%
    group_by(part) %>%
    summarise(from=min(datum), to=max(datum), .groups="drop")

  r14_from <- og_ranges %>% filter(part=="Osszefogas2014") %>% pull(from)
  r14_to   <- og_ranges %>% filter(part=="Osszefogas2014") %>% pull(to)
  r22_from <- og_ranges %>% filter(part=="Osszefogas2022") %>% pull(from)
  r22_to   <- og_ranges %>% filter(part=="Osszefogas2022") %>% pull(to)

  jogosult_ref <- elections %>%
    filter(valasztas_tipusa=="ogy") %>%
    distinct(datum, jogosult) %>%
    arrange(datum)

  oe_parties <- c("Egyutt","DK","DK-MSZP-PM","Liberalisok","Parbeszed",
    "SZDSZ","MDF","Egyutt_Parbeszed","MMN","MSZP-PM","MSZP","MKKP","LMP","Momentum")
  jobbik_cutoff  <- as.Date("2020-11-01")
  oe_keep_as_is  <- c("Fidesz","Tisza","Osszefogas2014","Osszefogas2022",
                      "MiHazank","nincs_partja")
  party_labels_oe <- c(
    "Fidesz"="Fidesz", "Osszefogas2014"="Összefogás 2014",
    "Osszefogas2022"="Összefogás 2022", "Tisza"="Tisza",
    "oellenzek"="Óellenzék", "Jobbik"="Jobbik (−2020/11)",
    "MiHazank"="Mi Hazánk", "nincs_partja"="Nincs pártja/NT/NV",
    "egyeb"="Egyéb")
  oe_cols <- c(party_cols, "oellenzek"="#1E90FF")

  for (k_yr_start in 1:2) {

    yr_cutoff  <- ifelse(k_yr_start==1, year(min(polls$datum)), 2020)
    fname_year <- ifelse(k_yr_start==1, as.character(year(min(polls$datum))), "2020")

    # compute abs_szavazat for ALL parties first (needed for egyeb sum)
    polls_with_abs <- polls %>%
      filter(year(datum) >= yr_cutoff) %>%
      mutate(
        jogosult_interp=approx(
          x=as.numeric(jogosult_ref$datum), y=jogosult_ref$jogosult,
          xout=as.numeric(datum), method="linear", rule=2)$y,
        abs_szavazat=teljes_nepesseg/100*jogosult_interp)

    polls_plot <- polls_with_abs %>%
      filter(part %in% parties_show) %>%
      filter(!(part %in% subsumed_14 & between(datum, r14_from, r14_to))) %>%
      filter(!(part %in% subsumed_22 & between(datum, r22_from, r22_to))) %>%
      arrange(datum)

    polls_egyeb_orig <- polls_with_abs %>%
      filter(!part %in% parties_show) %>%
      group_by(datum) %>%
      summarise(abs_szavazat=sum(abs_szavazat, na.rm=TRUE), .groups="drop") %>%
      filter(abs_szavazat > 0) %>%
      mutate(part="egyeb")

    polls_plot <- bind_rows(polls_plot, polls_egyeb_orig) %>% arrange(datum)

    nincs_election_abs <- elections %>%
      filter(ev >= yr_cutoff) %>%
      distinct(datum, ev, valasztas_tipusa, jogosult, megjelent) %>%
      mutate(part="nincs_partja", lista_szavazat=jogosult-megjelent)

    elections_egyeb_orig <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(!part %in% parties_show) %>%
      group_by(datum, ev) %>%
      summarise(lista_szavazat=sum(lista_szavazat, na.rm=TRUE), .groups="drop") %>%
      filter(lista_szavazat > 0) %>%
      mutate(part="egyeb")

    elections_plot_abs <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(part %in% parties_show) %>%
      bind_rows(nincs_election_abs) %>%
      bind_rows(elections_egyeb_orig)

    election_lines <- elections %>%
      filter(ev >= yr_cutoff) %>%
      distinct(datum, ev) %>%
      arrange(datum) %>%
      mutate(label_hjust=if_else(datum==max(datum), 1.08, -0.08))

    polls_smooth <- polls_plot %>% filter(!grepl("Osszefogas", part))
    polls_og     <- polls_plot %>% filter(grepl("Osszefogas", part))

    # ==== ORIGINAL PLOT ====
    p <- ggplot() +
      geom_point(data=polls_plot,
        aes(x=datum, y=abs_szavazat, color=part), size=2.5, alpha=0.5) +
      geom_line(data=polls_plot,
        aes(x=datum, y=abs_szavazat, color=part), linewidth=0.4, alpha=0.25) +
      geom_smooth(data=polls_smooth %>% filter(datum<=max(unique(elections$datum))),
        aes(x=datum, y=abs_szavazat, color=part),
        method="loess", span=0.25, se=F, linewidth=1.15) +
      geom_line(data=polls_og,
        aes(x=datum, y=abs_szavazat, color=part), linewidth=1.3, alpha=0.9) +
      geom_point(data=polls_og,
        aes(x=datum, y=abs_szavazat, color=part), size=2.5, alpha=0.85) +
      geom_vline(data=election_lines, aes(xintercept=datum),
        linetype="dashed", color="grey40", linewidth=0.65) +
      geom_text(data=election_lines,
        aes(x=datum, y=ifelse(ev==2024,4e6,4.5e6),
            label=paste0(ifelse(ev==2024,"EP vál.\n","OGY vál.\n"),
                         format(datum,"%Y. %m. %d.")), hjust=label_hjust),
        vjust=1.4, size=4.5, color="grey35", lineheight=0.9) +
      geom_point(data=elections_plot_abs,
        aes(x=datum, y=lista_szavazat, color=part), shape=18, size=5) +
      scale_color_manual(values=party_cols, labels=party_labels) +
      scale_x_date(date_breaks="1 year", date_labels="%Y",
        expand=expansion(mult=c(0.01, 0.008))) +
      geom_vline(xintercept=seq(
        floor_date(min(polls_plot$datum),"6 months"),
        ceiling_date(max(polls_plot$datum),"6 months"),
        by="6 months"), color="grey85", linewidth=0.15) +
      scale_y_continuous(
        breaks=seq(0,6e6,by=5e5),
        labels=scales::label_number(scale=1e-6, suffix=" M", accuracy=0.1),
        limits=c(0,NA), expand=expansion(c(0.01,0.02))) +
      labs(x="", y="Szavazók száma (millió fő)",
        caption=paste0("Választási eredmények (◆), ",
          "illetve a Medián \"teljes népesség\" %-ai x (szavazásra jogosultak) száma (o)"),
        color=NULL) +
      guides(color=guide_legend(nrow=2)) +
      theme_bw() + standard_theme +
      theme(legend.position="top", plot.caption=element_text(size=13))

    if (save_flag) ggsave(plot=p,
      paste0("plots/abszolut_szam_",fname_year,"_2026.png"),
      width=40, height=22, units="cm")
    print(p)

    # ==== ÓELLENZÉK VERSION ====
    polls_plot_oe_base <- polls_with_abs %>%
      filter(!(part %in% subsumed_14 & between(datum, r14_from, r14_to))) %>%
      filter(!(part %in% subsumed_22 & between(datum, r22_from, r22_to))) %>%
      arrange(datum)

    polls_oe_sum <- polls_plot_oe_base %>%
      filter(part %in% c(oe_parties,"Jobbik")) %>%
      filter(!(part=="Jobbik" & datum < jobbik_cutoff)) %>%
      group_by(datum) %>%
      summarise(abs_szavazat=sum(abs_szavazat, na.rm=TRUE), .groups="drop") %>%
      filter(abs_szavazat > 0) %>%
      mutate(part="oellenzek") %>%
      { if (length(r14_from)>0) filter(., !between(datum, r14_from, r14_to)) else . } %>%
      { if (length(r22_from)>0) filter(., !between(datum, r22_from, r22_to)) else . }

    polls_egyeb_oe <- polls_plot_oe_base %>%
      filter(!part %in% c(oe_keep_as_is, oe_parties, "Jobbik")) %>%
      group_by(datum) %>%
      summarise(abs_szavazat=sum(abs_szavazat, na.rm=TRUE), .groups="drop") %>%
      filter(abs_szavazat > 0) %>%
      mutate(part="egyeb")

    polls_plot_oe <- bind_rows(
      polls_plot_oe_base %>% filter(part %in% oe_keep_as_is),
      polls_plot_oe_base %>% filter(part=="Jobbik" & datum < jobbik_cutoff),
      polls_oe_sum,
      polls_egyeb_oe
    )

    elections_oe_abs <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(part %in% c(oe_parties,"Osszefogas2014","Osszefogas2022","Jobbik")) %>%
      filter(!(part=="Jobbik" & datum < jobbik_cutoff)) %>%
      group_by(datum, ev) %>%
      summarise(lista_szavazat=sum(lista_szavazat, na.rm=TRUE), .groups="drop") %>%
      filter(lista_szavazat > 0) %>%
      mutate(part="oellenzek")

    elections_egyeb_oe <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(!part %in% c(oe_keep_as_is, oe_parties, "Jobbik")) %>%
      group_by(datum, ev) %>%
      summarise(lista_szavazat=sum(lista_szavazat, na.rm=TRUE), .groups="drop") %>%
      filter(lista_szavazat > 0) %>%
      mutate(part="egyeb") 

    elections_plot_oe <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(part %in% c("Fidesz","Tisza",
        "Osszefogas2014","Osszefogas2022","MiHazank","Jobbik")) %>%
      bind_rows(nincs_election_abs) %>%
      bind_rows(elections_oe_abs) %>%
      bind_rows(elections_egyeb_oe) %>%
      filter(!(part=="Jobbik" & datum > jobbik_cutoff) & !grepl("egyeb",part)) 

    polls_smooth_oe <- polls_plot_oe %>%
      filter(!grepl("Osszefogas", part)) %>%
      mutate(smooth_group=case_when(
        part != "oellenzek"                   ~ as.character(part),
        length(r22_from)>0 & datum > r22_to   ~ "oellenzek_c",
        length(r14_from)>0 & datum > r14_to   ~ "oellenzek_b",
        TRUE                                  ~ "oellenzek_a"))

    polls_og_oe <- polls_plot_oe %>% filter(grepl("Osszefogas", part))

    p_oe <- ggplot() +
      geom_vline(xintercept=seq(
        floor_date(min(polls_plot_oe$datum),"6 months"),
        ceiling_date(max(polls_plot_oe$datum),"6 months"),
        by="6 months"), color="grey85", linewidth=0.15) +
      geom_point(data=polls_plot_oe,
        aes(x=datum, y=abs_szavazat, color=part), size=2.5, alpha=0.5) +
      geom_line(data=polls_plot_oe,
        aes(x=datum, y=abs_szavazat, color=part), linewidth=0.4, alpha=0.25) +
      geom_smooth(data=polls_smooth_oe %>% filter(datum<=max(unique(elections$datum))),
        aes(x=datum, y=abs_szavazat, color=part, group=smooth_group),
        method="loess", span=0.25, se=F, linewidth=1.15) +
      geom_line(data=polls_og_oe,
        aes(x=datum, y=abs_szavazat, color=part), linewidth=1.3, alpha=0.9) +
      geom_point(data=polls_og_oe,
        aes(x=datum, y=abs_szavazat, color=part), size=2.5, alpha=0.85) +
      geom_vline(data=election_lines, aes(xintercept=datum),
        linetype="dashed", color="grey40", linewidth=0.65) +
      geom_text(data=election_lines,
        aes(x=datum, y=ifelse(ev==2024,4e6,4.5e6),
            label=paste0(ifelse(ev==2024,"EP vál.\n","OGY vál.\n"),
                         format(datum,"%Y. %m. %d.")), hjust=label_hjust),
        vjust=1.4, size=4.5, color="grey35", lineheight=0.9) +
      # election result diamnods
      geom_point(data=elections_plot_oe,
        aes(x=datum, y=lista_szavazat, color=part), shape=18, size=5) +
      # LABELS
      geom_text(
          data=elections_plot_oe, # %>% filter(part %in% label_parties_oe),
          aes(x=datum, y=lista_szavazat, color=part,
          label=gsub("\\.", ",", sprintf("%.2fM", lista_szavazat/1e6))),
          hjust=-0.15, vjust=0.5, size=3.8, fontface="bold", show.legend=F) +
      scale_color_manual(values=oe_cols, labels=party_labels_oe) +
      scale_x_date(date_breaks="1 year", date_labels="%Y",
        expand=expansion(mult=c(0.01, ifelse(yr_cutoff>2010,0.007,0.03) ))) +
      scale_y_continuous(
        breaks=seq(0,6e6,by=5e5),
        labels=scales::label_number(scale=1e-6, suffix=" M", accuracy=0.1),
        limits=c(0,NA), expand=expansion(c(0.01,0.02))) +
      labs(x="", y="Szavazók száma (millió fő)",
        caption=paste0("Választási eredmények (◆), Medián mérések (o)\n",
          "Óellenzék = SZDSZ+MDF+DK+MSZP+LMP+Momentum+Együtt+MKKP+Liberálisok+Párbeszéd",
          " + Jobbik (2020/11-től)"),
        color=NULL) +
      guides(color=guide_legend(nrow=2)) +
      theme_bw() + standard_theme +
      theme(legend.position="top", plot.caption=element_text(size=13))

    if (save_flag) ggsave(plot=p_oe,
      paste0("plots/abszolut_szam_oell_",fname_year,"_2026.png"),
      width=40, height=22, units="cm")
    print(p_oe)

  } # end for loop
})


# ============================================================
# BLOCK 3: partvalasztok %
# ============================================================


local({

  polls     <- df_polls
  elections <- df_elections

  save_flag <- T

  party_order <- c(
    "Fidesz","Tisza","Osszefogas2014","Osszefogas2022",
    "MSZP","MSZP-PM","Jobbik","DK","MiHazank",
    "Egyutt","Momentum","LMP","MKKP","nincs_partja")

  party_labels <- c(
    "Fidesz"="Fidesz", "Osszefogas2014"="Összefogás 2014",
    "Osszefogas2022"="Összefogás 2022", "Tisza"="Tisza",
    "MSZP"="MSZP", "MSZP-PM"="MSZP-PM", "Jobbik"="Jobbik",
    "DK"="DK", "MiHazank"="Mi Hazánk", "LMP"="LMP", "MKKP"="MKKP",
    "Egyutt"="Együtt", "Momentum"="Momentum",
    "nincs_partja"="Nincs pártja/NT/NV",
    "egyeb"="Egyéb")

  parties_show <- c(
    "Fidesz","Osszefogas2014","Osszefogas2022",
    "Tisza","MSZP","DK","MSZP-PM",
    "Jobbik","LMP","MKKP","MiHazank",
    "Momentum","Egyutt","nincs_partja")

  subsumed_14 <- c("MSZP","DK","Jobbik","LMP","Egyutt","Parbeszed")
  subsumed_22 <- c("MSZP","DK","Jobbik","LMP","Momentum","Parbeszed")

  og_ranges <- polls %>%
    filter(grepl("Osszefogas", part)) %>%
    group_by(part) %>%
    summarise(from=min(datum), to=max(datum), .groups="drop")

  r14_from <- og_ranges %>% filter(part=="Osszefogas2014") %>% pull(from)
  r14_to   <- og_ranges %>% filter(part=="Osszefogas2014") %>% pull(to)
  r22_from <- og_ranges %>% filter(part=="Osszefogas2022") %>% pull(from)
  r22_to   <- og_ranges %>% filter(part=="Osszefogas2022") %>% pull(to)

  oe_parties <- c("Egyutt","DK","DK-MSZP-PM","Liberalisok","Parbeszed",
    "SZDSZ","MDF","Egyutt_Parbeszed","MMN","MSZP-PM","MSZP","MKKP","LMP","Momentum")
  jobbik_cutoff  <- as.Date("2020-11-01")
  oe_keep_as_is  <- c("Fidesz","Tisza","Osszefogas2014","Osszefogas2022",
                      "MiHazank","nincs_partja")
  party_labels_oe <- c(
    "Fidesz"="Fidesz", "Osszefogas2014"="Összefogás 2014",
    "Osszefogas2022"="Összefogás 2022", "Tisza"="Tisza",
    "oellenzek"="Óellenzék", "Jobbik"="Jobbik (−2020/11)",
    "MiHazank"="Mi Hazánk", "nincs_partja"="Nincs pártja/NT/NV",
    "egyeb"="Egyéb")
  oe_cols <- c(party_cols, "oellenzek"="#1E90FF")

  for (k_yr_start in 1:2) {

    yr_cutoff  <- ifelse(k_yr_start==1, year(min(polls$datum)), 2020)
    fname_year <- ifelse(k_yr_start==1, as.character(year(min(polls$datum))), "2020")

    # compute poll_pct for ALL parties first (needed for egyeb sum)
    polls_with_pct <- polls %>%
      filter(year(datum) >= yr_cutoff) %>%
      mutate(poll_pct=rowMeans(cbind(valasztani_tudok, biztos_szavazok), na.rm=TRUE)) %>%
      filter(!is.nan(poll_pct))

    polls_plot <- polls_with_pct %>%
      filter(part %in% parties_show) %>%
      arrange(datum)

    polls_egyeb_orig <- polls_with_pct %>%
      filter(!part %in% parties_show) %>%
      group_by(datum) %>%
      summarise(poll_pct=sum(poll_pct, na.rm=TRUE), .groups="drop") %>%
      filter(poll_pct > 0) %>%
      mutate(part="egyeb")

    polls_plot <- bind_rows(polls_plot, polls_egyeb_orig) %>% arrange(datum)

    elections_plot <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(part %in% parties_show)

    elections_egyeb_orig <- elections %>%
      filter(ev >= yr_cutoff) %>%
      filter(!part %in% parties_show) %>%
      group_by(datum, ev) %>%
      summarise(lista_szavazat_pct=sum(lista_szavazat_pct, na.rm=TRUE), .groups="drop") %>%
      filter(lista_szavazat_pct > 0) %>%
      mutate(part="egyeb")

    elections_plot <- bind_rows(elections_plot, elections_egyeb_orig)

    election_lines <- elections %>%
      filter(ev >= yr_cutoff) %>%
      distinct(datum, ev) %>%
      arrange(datum) %>%
      mutate(label_hjust=if_else(datum==max(datum), 1.08, -0.08))

    polls_smooth <- polls_plot %>% filter(!grepl("Osszefogas", part))
    polls_og     <- polls_plot %>% filter(grepl("Osszefogas", part))

    # ==== ORIGINAL PLOT ====
    p <- ggplot() +
      geom_line(data=polls_plot,
        aes(x=datum, y=poll_pct, color=part), linewidth=0.4, alpha=0.25) +
      geom_smooth(data=polls_smooth %>% filter(datum<=max(unique(elections$datum))),
        aes(x=datum, y=poll_pct, color=part),
        method="loess", span=0.3, se=F, linewidth=1.15, alpha=1/3) +
      geom_point(data=polls_plot,
        aes(x=datum, y=poll_pct, color=part), size=2.5, alpha=0.5) +
      geom_line(data=polls_og,
        aes(x=datum, y=poll_pct, color=part), linewidth=1.3, alpha=0.9) +
      geom_point(data=polls_og,
        aes(x=datum, y=poll_pct, color=part), size=2.5, alpha=0.85) +
      geom_vline(data=election_lines, aes(xintercept=datum),
        linetype="dashed", color="grey40", linewidth=0.65) +
      geom_text(data=election_lines,
        aes(x=datum, y=ifelse(ev==2024,60,70),
            label=paste0(ifelse(ev==2024,"EP vál.\n","OGY vál.\n"),
                         format(datum,"%Y/%m/%d")), hjust=label_hjust),
        vjust=1.4, size=4.5, color="grey35", lineheight=0.9) +
      geom_text(data=elections_plot %>% filter(lista_szavazat_pct>10),
        aes(x=datum, y=lista_szavazat_pct, color=part,
            label=sprintf("%.1f%%", lista_szavazat_pct)),
        vjust=-0.8, size=3.8, fontface="bold", show.legend=F) +
      geom_point(data=elections_plot,
        aes(x=datum, y=lista_szavazat_pct, color=part), shape=18, size=5) +
      scale_color_manual(values=party_cols, labels=party_labels) +
      scale_x_date(date_breaks="1 year", date_labels="%Y",
        expand=expansion(mult=c(0.01, 0.015))) +
      geom_vline(xintercept=seq(
        floor_date(min(polls_plot$datum),"6 months"),
        ceiling_date(max(polls_plot$datum),"6 months"),
        by="6 months"), color="grey85", linewidth=0.15) +
      scale_y_continuous(breaks=0:10*10,
        labels=scales::label_number(suffix="%"),
        limits=c(0,NA), expand=expansion(c(0.01,0.02))) +
      labs(x="", y="Pártpreferenciák a pártválasztók körében",
        caption=paste0("Választási eredmények (◆, lista%), ",
          "illetve a Medián által mért preferenciák",
          " (o, pártválasztók és biztos pártválasztók átlaga)"),
        color=NULL) +
      guides(color=guide_legend(nrow=2)) +
      theme_bw() + standard_theme +
      theme(legend.position="top", plot.caption=element_text(size=13))

    if (save_flag) ggsave(plot=p,
      paste0("plots/partvalasztok_pct_", fname_year, "_2026.png"),
      width=40, height=22, units="cm")
    print(p)

    # ==== ÓELLENZÉK VERSION ====
    polls_plot_oe_base <- polls_with_pct %>%
      filter(!(part %in% subsumed_14 & between(datum, r14_from, r14_to))) %>%
      filter(!(part %in% subsumed_22 & between(datum, r22_from, r22_to))) %>%
      arrange(datum)

    polls_oe_sum <- polls_plot_oe_base %>%
      filter(part %in% c(oe_parties, "Jobbik")) %>%
      { if (length(r14_from)>0)
          filter(., !(part %in% subsumed_14 & between(datum, r14_from, r14_to)))
        else . } %>%
      { if (length(r22_from)>0)
          filter(., !(part %in% subsumed_22 & between(datum, r22_from, r22_to)))
        else . } %>%
      filter(!(part=="Jobbik" & datum < jobbik_cutoff)) %>%
      group_by(datum) %>%
      summarise(poll_pct=sum(poll_pct, na.rm=TRUE), .groups="drop") %>%
      filter(poll_pct > 0) %>%
      mutate(part="oellenzek") %>%
      { if (length(r14_from)>0) filter(., !between(datum, r14_from, r14_to)) else . } %>%
      { if (length(r22_from)>0) filter(., !between(datum, r22_from, r22_to)) else . }

    polls_egyeb_oe <- polls_plot_oe_base %>%
      filter(!part %in% c(oe_keep_as_is, oe_parties, "Jobbik")) %>%
      group_by(datum) %>%
      summarise(poll_pct=sum(poll_pct, na.rm=TRUE), .groups="drop") %>%
      filter(poll_pct > 0) %>%
      mutate(part="egyeb")

    polls_plot_oe <- bind_rows(
      polls_plot_oe_base %>% filter(part %in% oe_keep_as_is),
      polls_plot_oe_base %>% filter(part=="Jobbik" & datum < jobbik_cutoff),
      polls_oe_sum,
      polls_egyeb_oe
    )

    elections_oe_pct <- elections_plot %>%
      filter(part %in% c(oe_parties,"Osszefogas2014","Osszefogas2022","Jobbik")) %>%
      filter(!(part=="Jobbik" & datum < jobbik_cutoff)) %>%
      group_by(datum, ev) %>%
      summarise(lista_szavazat_pct=sum(lista_szavazat_pct, na.rm=TRUE), .groups="drop") %>%
      filter(lista_szavazat_pct > 0) %>%
      mutate(part="oellenzek")

    elections_egyeb_oe <- elections_plot %>%
      filter(!part %in% c(oe_keep_as_is, oe_parties, "Jobbik")) %>%
      group_by(datum, ev) %>%
      summarise(lista_szavazat_pct=sum(lista_szavazat_pct, na.rm=TRUE), .groups="drop") %>%
      filter(lista_szavazat_pct > 0) %>%
      mutate(part="egyeb")

    elections_plot_oe <- elections_plot %>%
      bind_rows(elections_oe_pct) %>%
      bind_rows(elections_egyeb_oe)  %>%
      filter(part %in% c("Fidesz","Tisza","Osszefogas2014","Osszefogas2022",
        "Jobbik","MiHazank"))  %>%
      filter(!(part=="Jobbik" & datum > jobbik_cutoff)) 

    polls_smooth_oe <- polls_plot_oe %>%
      filter(!grepl("Osszefogas", part)) %>%
      mutate(smooth_group=case_when(
        part != "oellenzek"                   ~ as.character(part),
        length(r22_from)>0 & datum > r22_to   ~ "oellenzek_c",
        length(r14_from)>0 & datum > r14_to   ~ "oellenzek_b",
        TRUE                                  ~ "oellenzek_a"))

    polls_og_oe <- polls_plot_oe %>% filter(grepl("Osszefogas", part))

    p_oe <- ggplot() +
      geom_vline(xintercept=seq(
        floor_date(min(polls_plot_oe$datum),"6 months"),
        ceiling_date(max(polls_plot_oe$datum),"6 months"),
        by="6 months"), color="grey85", linewidth=0.15) +
      geom_line(data=polls_plot_oe,
        aes(x=datum, y=poll_pct, color=part), linewidth=0.4, alpha=0.25) +
      geom_smooth(data=polls_smooth_oe %>% filter(datum<=max(unique(elections$datum))),
        aes(x=datum, y=poll_pct, color=part, group=smooth_group),
        method="loess", span=0.3, se=F, linewidth=1.15, alpha=1/3) +
      geom_point(data=polls_plot_oe,
        aes(x=datum, y=poll_pct, color=part), size=2.5, alpha=0.5) +
      geom_line(data=polls_og_oe,
        aes(x=datum, y=poll_pct, color=part), linewidth=1.3, alpha=0.9) +
      geom_point(data=polls_og_oe,
        aes(x=datum, y=poll_pct, color=part), size=2.5, alpha=0.85) +
      geom_vline(data=election_lines, aes(xintercept=datum),
        linetype="dashed", color="grey40", linewidth=0.65) +
      geom_text(data=election_lines,
        aes(x=datum, y=ifelse(ev==2024,60,70),
            label=paste0(ifelse(ev==2024,"EP vál.\n","OGY vál.\n"),
                         format(datum,"%Y/%m/%d")), hjust=label_hjust),
        vjust=1.4, size=4.5, color="grey35", lineheight=0.9) +
      geom_text(data=elections_plot_oe,
         # %>% filter(lista_szavazat_pct>10),
        aes(x=datum, y=lista_szavazat_pct, color=part,
            label=sprintf("%.1f%%", lista_szavazat_pct)),
        vjust=-0.8, size=3.8, fontface="bold", show.legend=F) +
      geom_point(data=elections_plot_oe,
        aes(x=datum, y=lista_szavazat_pct, color=part), shape=18, size=5) +
      scale_color_manual(values=oe_cols, labels=party_labels_oe) +
      scale_x_date(date_breaks="1 year", date_labels="%Y",
        expand=expansion(mult=c(0.01, 0.015))) +
      scale_y_continuous(breaks=0:10*10,
        labels=scales::label_number(suffix="%"),
        limits=c(0,NA), expand=expansion(c(0.01,0.02))) +
      labs(x="", y="Pártpreferenciák a pártválasztók körében",
        caption=paste0("Választási eredmények (◆, lista%), Medián mérések (o)\n",
          "Óellenzék = SZDSZ+MDF+DK+MSZP+LMP+Momentum+Együtt+MKKP+Liberálisok+Párbeszéd",
          " + Jobbik (2020/11-től)"),
        color=NULL) +
      guides(color=guide_legend(nrow=2)) +
      theme_bw() + standard_theme +
      theme(legend.position="top", plot.caption=element_text(size=13))

    if (save_flag) ggsave(plot=p_oe,
      paste0("plots/partvalasztok_pct_oell_", fname_year, "_2026.png"),
      width=40, height=22, units="cm")
    print(p_oe)

  } # end for loop
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# medián/závecz/21kk összehasonlítás

local({
  save_flag <- T
  
  key_to_hu <- c(
  "Tisza"   ="Tisza",
  "Fidesz"  ="Fidesz",
  "MiHazank"="Mi Hazánk",
  "DK"      ="DK",
  "DK-MSZP-PM"="DK",  # 2024 EP combined list → DK facet
  "MKKP"    ="MKKP"
)

elections_raw <- read_csv("inputs/val_eredmenyek.csv") %>%
  filter(ev %in% c(2024,2026)) %>%
  filter(part %in% names(key_to_hu)) %>%        # keep only parties in polling data
  mutate(
    party   =key_to_hu[part],              # remap to Hungarian label
    result_pct=lista_szavazat / jogosult * 100,
    date    =as.Date(case_when(
      ev == 2024 ~ "2024-06-09",
      ev == 2026 ~ "2026-04-06"
    ))
  )

# ── Election vlines ───────────────────────────────────────────────────────────
election_dates <- tibble(
  date =as.Date(c("2024-06-09","2026-04-06")),
  label=c("EP2024","OGY2026") )

# ── Polling data ──────────────────────────────────────────────────────────────
df <- read_csv("inputs/median_zavecz_21kk_osszehas/polling_combined_long.csv") %>%
  mutate(date=as.Date(date))

#   library(ggh4x)

party_colour_map <- c(
  "Tisza"    =party_cols[["Tisza"]],
  "Fidesz"   =party_cols[["Fidesz"]],
  "Pártnélküli"=party_cols[["nincs_partja"]],
  "Mi Hazánk"=party_cols[["MiHazank"]],
  "DK"       =party_cols[["DK"]],
  "Egyéb párt" =party_cols[["egyeb"]],
  "MKKP"     =party_cols[["MKKP"]]
)

df_plot <- df %>%
  mutate(party=factor(party,levels=names(party_colour_map))) %>%
  filter(!grepl("Egy",party)) # |MKKP

elections_plot <- elections_raw %>%
  mutate(party=factor(party,levels=names(party_colour_map))) %>%
  filter(!grepl("Egy",party)) # |MKKP

# per-facet y scales: positions 1-3 (Tisza,Fidesz,Pártnélküli) fixed ~0-60
# positions 4-5 (Mi Hazánk,DK) free/lower
y_scales <- list(
  scale_y_continuous(limits=c(0,60),breaks = 0:6*10), # Tisza
  scale_y_continuous(limits=c(0,60),breaks = 0:6*10), # Fidesz
  scale_y_continuous(limits=c(0,60),breaks = 0:6*10), # Pártnélküli
  scale_y_continuous(limits=c(0,10)), # Mi Hazánk
  scale_y_continuous(limits=c(0,10)),  # DK
  scale_y_continuous(limits=c(0,10))   # MKKP
)

# ── Date labels with linebreak ────────────────────────────────────────────
  date_labeller <- function(x) format(x, "%Y-\n%m")

  # ── Base plot (no loess) ──────────────────────────────────────────────────
  p_base <- ggplot(df_plot, aes(x = date, y = value, colour = party)) +
    facet_wrap(~ party, ncol = 3, scales = "free_y") +
    geom_line(aes(group = pollster), linewidth = 1/2, alpha = 0.6, linetype = "dashed") +
    geom_point(aes(shape = pollster), size = 3, alpha = 0.5) +
    geom_point(data = elections_plot,
               aes(x = date, y = result_pct, fill = party),
               shape = 23, size = 4, colour = "black", stroke = 0.5,
               inherit.aes = FALSE, alpha = 2/3) +
    geom_text(data = elections_plot,
              aes(x = date, y = result_pct,
                  label = paste0(format(round(result_pct, 1), nsmall = 1), "%"),
                  hjust = ifelse(ev == 2024, -0.15, 1.15),
                  vjust = ifelse(ev == 2024, 1.5, -0.8)),
              size = 5, inherit.aes = FALSE) +
    geom_vline(data = election_dates,
               aes(xintercept = date),
               linetype = "dashed", colour = "grey40", linewidth = 0.6) +
    geom_text(data = election_dates,
              aes(x = date, label = label,
                  hjust = ifelse(label == "EP2024", -0.08, 1.08)),
              y = Inf, vjust = 1.4, size = 5, inherit.aes = FALSE) +
    ggh4x::facetted_pos_scales(y = y_scales) +
    scale_colour_manual(values = party_colour_map, guide = "none") +
    scale_fill_manual(values = party_colour_map, guide = "none") +
    scale_shape_manual(values = c("21KK" = 16, "Medián" = 17, "Závecz" = 15)) +
    scale_x_date(date_labels = "%Y-\n%m", date_breaks = "3 months") +
    labs(
      title   = "Pártok támogatottsága a teljes népességben (Medián/21KK/Závecz)",
      x       = NULL,
      y       = "Támogatottság (% összes választásra jogosult)",
      shape   = "Közvélemény-kutató",
      caption = "Választási eredmény (◆) az összes választásra jogosult arányában"
    ) +
    theme_bw() +
    standard_theme +
    theme(
      plot.caption  = element_text(size = 15),
      plot.subtitle = element_text(size = 15),
      legend.title  = element_text(size = 19),
      legend.position = "top",
      axis.text.x   = element_text(size = 12, hjust = 0.5)  # centred for multiline
    )

  # ── Two versions ─────────────────────────────────────────────────────────
  plots <- list(
    no_loess = p_base,
    loess    = p_base + geom_smooth(method = "loess", se = FALSE,
                                    linewidth = 2, span = 1, alpha = 0.1)
  )

  if (save_flag) {
    for (nm in names(plots)) {
      ggsave(
        filename = paste0("plots/kvk/median_zav_21kk_comparison_", nm, ".png"),
        plot     = plots[[nm]],
        width    = 40, height = 22, units = "cm" )
    }
  }
  
})
