# load data, libraries
source("load_data.R")


# A közüzemi szennyvízgyűjtő hálózatba bekapcsolt lakások száma (1990 -> most): 41 -> 85%
# https://ksh.hu/s/kiadvanyok/fenntarthato-fejlodes-indikatorai-2022/1-12-sdg-3
# ivóvízvezeték: ... -> 95%
# A közüzemi ivóvízvezeték- és szennyvízgyűjtő- hálózatba bekapcsolt lakások aránya 
# https://www.ksh.hu/stadat_files/kor/hu/kor0066.html
# 3. táblázat. A városi és a falusi népesség aránya, 1900–1990 (%)
# https://mek.oszk.hu/02100/02185/html/171.html

# 5e feletti telepulesek aranya: 9.3+7.8+11.2+20.9+1.5+17.7=68.4%
# 5e felett + kisebb agglomeracios=68.4 + (1.6+2.2+6+2.9)=81.1%
# 10e felett: 7.8+11.2+20.9+1.5+17.7=59.1%
# 10e felett + kisebb agglomeracios=59.1 + (1.6+2.2+6+2.9)=71.8%

# osszefoglalo statisztika jogallas szerint
hnt_2004_2010_2025_jogallas |>
  mutate(
    jogallas=case_when(
      grepl("megyei", jogallas) ~ "msz/mjv",
      grepl("fővárosi", jogallas) ~ "Budapest",
      .default=jogallas) ) |>
  group_by(year, jogallas) |>
  summarise(
    sum_pop=sum(lakonepesseg, na.rm=TRUE),
    n=n(), .groups="drop" ) |>
  (\(df) list(
    pop=df |>
      select(year, jogallas, sum_pop) |>
      pivot_wider(
        names_from=jogallas,
        values_from=sum_pop,
        values_fill=0 ) |>
      select(year, Budapest, `msz/mjv`,város,
        nagyközség, község) |>
      mutate(TOTAL=Budapest + `msz/mjv` + város + nagyközség + község),
    n=df |>
      select(year, jogallas, n) |>
      pivot_wider(
        names_from=jogallas,
        values_from=n,
        values_fill=0) |>
      select(year, Budapest,`msz/mjv`, város,
        nagyközség, község ) |>
      mutate(TOTAL=Budapest + `msz/mjv` +
          város + nagyközség + község )
  ))()

# agglomerations: https://www.ksh.hu/teruletiatlasz_egyeb_teruletilehatarolasok
# join with agglom data
hnt_2004_2010_2025_jogallas |>
  left_join(hu_agglomeracio_telepulesek_2024) |>
  mutate(agglom=ifelse(!is.na(szerkezet),T,F)) |> 
  filter(!agglom & grepl("község",jogallas)) |> # lakonepesseg<3e3 & year==2025 & 
  group_by(year) |>
  summarise(sum(lakonepesseg))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# TREND: FIX eves kategorizálás meret szerint

local({
  fix_year <- c(2001, 2025)[1]
  save_flag <- T

  brks <- c(-Inf, 1e3, 2e3, 5e3, 1e4, 5e4, Inf)
  fin  <- brks[is.finite(brks)]
  k    <- function(x) paste0(x/1e3, "k")
  labs <- c(paste0("<", k(fin[1])),
            paste0(k(head(fin, -1)), "–", k(fin[-1])),
            paste0(">", k(tail(fin, 1))))

  dat <- HNT_1990_2025 |> filter(year >= 2001)

  natl <- dat |> summarise(natl = sum(lakonepesseg), .by = year)
  hu_nobp <- dat |> filter(telepules != "Budapest")

  bandfix <- hu_nobp |>
    filter(year == fix_year) |>
    mutate(band = cut(lakonepesseg, brks, labs, right = FALSE)) |>
    select(telepules, band)

  base <- hu_nobp |>
    inner_join(bandfix, by = "telepules") |>
    left_join(hu_agglomeracio_telepulesek_2024, by = "telepules") |>
    mutate(agglom = if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül")) |>
    summarise(pop = sum(lakonepesseg), n = n(), .by = c(year, band, agglom)) |>
    left_join(natl, by = "year") |>
    mutate(pct = 100 * pop / natl, mill = pop / 1e6)

  bp <- dat |>
    filter(telepules == "Budapest") |>
    left_join(natl, by = "year") |>
    mutate(pct = 100 * lakonepesseg / natl, mill = lakonepesseg / 1e6) |>
    filter(year %in% range(year)) |> arrange(year)
  subtitle <- sprintf(
    "Budapest: %.1f%% → %.1f%% | %.2fm → %.2fm fő",
    bp$pct[1], bp$pct[2], bp$mill[1], bp$mill[2])

  d <- base |>
    pivot_longer(c(mill, pct), names_to = "metric", values_to = "value") |>
    mutate(metric = recode(metric,
                           pct  = "Az ország %-ában",
                           mill = "Lakónépesség (millió fő)") |>
                    factor(levels = c("Az ország %-ában", "Lakónépesség (millió fő)")))

  ends <- d |> filter(year %in% range(year)) |>
    mutate(lab = case_when(
             metric != "Az ország %-ában" ~ sprintf("%.2fm", value),
             year == fix_year             ~ sprintf("%.1f%% | n=%d", value, n),
             T ~ sprintf("%.1f%%", value)),
           vj = if_else(agglom == "Agglom. kívül", -0.8, 1.6) +
                if_else(band == tail(labs, 1), 0.6, 0),
           hj = case_when(
             metric != "Az ország %-ában" & year == min(year) ~ 0.15,
             metric != "Az ország %-ában"                     ~ 0.85,
             year == min(year)                                ~ 0.15,
             T                                                ~ 0.85))

  yr_breaks <- seq(2000, 2025, 10)

  p <- ggplot(d, aes(year, value, colour = agglom, group = agglom)) +
    facet_grid(metric ~ band, scales = "free_y", switch = "y") +
    geom_line(linewidth = 0.8, show.legend = F) +
    geom_point(size = 1.2) +
    geom_point(data = ends, aes(fill = agglom),
               shape = 21, colour = "black", stroke = 0.7, size = 2) +
    geom_text(data = ends, aes(label = lab, vjust = vj, hjust = hj),
              size = 3.75, fontface = "bold", show.legend = FALSE) +
    scale_x_continuous(breaks = yr_breaks, expand = expansion(mult = 0.1)) +
    scale_y_continuous(expand = expansion(mult = 0.12)) +
    labs(x = NULL, y = NULL, colour = NULL, fill = NULL,
         title = sprintf("%d-ös méretkategóriák szerinti népességarány és -szám, 2001–2025", fix_year),
         subtitle = subtitle,
         caption = "Forrás: KSH Helységnévtár (hntr)") +
    theme_bw(base_size = 15) +
    theme(legend.position = "top", strip.placement = "outside",
          plot.title = element_text(size = 16, face = "bold"),
          plot.subtitle = element_text(size = 12))

  if (save_flag) {
    ggsave(sprintf("plots/idosor_meret_fix_%d_from2001.png", fix_year), p,
           width = 14, height = 8, units = "in", dpi = 300, bg = "white")
  }
  print(p)
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ugyanez jogallas (telep.tipus) szerint

local({
  sel_yr <- 2025
  floating <- F       # FALSE = frozen at sel_yr, TRUE = each year's own jogállás
  save_flag <- TRUE

  start_yr <- if (floating) 2010 else 2001   # floating can only go as far as jogállás data allows

  recl <- function(x) dplyr::case_when(
    x %in% c("község","nagyközség")       ~ x,
    x == "fővárosi kerület"               ~ "Budapest",
    stringr::str_detect(x, "megyei jogú") ~ "megyeszékhely/mjv",
    TRUE                                  ~ "város")
  jlev <- c("község","nagyközség","város","megyeszékhely/mjv","Budapest")

  if (floating) {
    # each year carries its OWN jogállás -> use the jogállás frame directly
    dat <- hnt_2004_2010_2025_jogallas |>
      filter(year >= start_yr) |>
      mutate(jog = factor(recl(jogallas), levels = jlev))
  } else {
    # freeze jogállás at sel_yr, population from the continuous hntr series
    fix_jogallas <- hnt_2004_2010_2025_jogallas |>
      filter(year == sel_yr) |>
      mutate(jog = factor(recl(jogallas), levels = jlev)) |>
      select(telepules, jog)
    dat <- HNT_1990_2025 |>
      filter(year >= start_yr) |>
      inner_join(fix_jogallas, by = "telepules")
  }

  natl <- dat |> summarise(natl = sum(lakonepesseg), .by = year)

  base <- dat |>
    left_join(hu_agglomeracio_telepulesek_2024, by = "telepules") |>
    mutate(agglom = if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül")) |>
    summarise(pop = sum(lakonepesseg), n = n(), .by = c(year, jog, agglom)) |>
    left_join(natl, by = "year") |>
    mutate(pct = 100 * pop / natl, mill = pop / 1e6)

  d <- base |>
    pivot_longer(c(mill, pct), names_to = "metric", values_to = "value") |>
    mutate(metric = recode(metric,
                           pct  = "Az ország %-ában",
                           mill = "Lakónépesség (millió fő)") |>
                    factor(levels = c("Az ország %-ában", "Lakónépesség (millió fő)")))

  mode_label <- if (floating) "éves (változó)" else sprintf("%d-ös (rögzített)", sel_yr)

  ends <- d |> filter(year %in% range(year)) |>
    mutate(lab = case_when(
             metric != "Az ország %-ában" ~ sprintf("%.2fm", value),
             year == max(year)            ~ sprintf("%.1f%% (n=%d)", value, n),
             T ~ sprintf("%.1f%%", value)),
           vj = if_else(agglom == "Agglom. kívül", -0.8, 2),
           hj = case_when(
             metric != "Az ország %-ában" & year == min(year) ~ 0.3,
             metric != "Az ország %-ában"                     ~ 0.85,
             year == min(year)                                ~ 0.16,
             TRUE                                             ~ 0.92))

  yr_breaks <- seq(ceiling(start_yr/5)*5, 2025, 5)

  p <- ggplot(d, aes(year, value, colour = agglom, group = agglom)) +
    facet_grid(metric ~ jog, scales = "free_y", switch = "y") +
    geom_line(linewidth = 0.8, show.legend = F) +
    geom_point(size = 1.2) +
    geom_point(data = ends, aes(fill = agglom),
               shape = 21, colour = "black", stroke = 0.7, size = 2) +
    geom_text(data = ends, aes(label = lab, vjust = vj, hjust = hj),
              size = 3.75, fontface = "bold", show.legend = FALSE) +
    scale_x_continuous(breaks = yr_breaks, expand = expansion(mult = c(0.08, 0.05))) +
    scale_y_continuous(expand = expansion(mult = 0.12)) +
    labs(x = NULL, y = NULL, colour = NULL, fill = NULL,
         title = sprintf("Jogállás szerinti népességarány és -szám, %d–2025", start_yr),
         subtitle = sprintf("Besorolás: %s", mode_label),
         caption = if (floating)
           "Forrás: KSH HNT · Minden év saját jogállás-besorolásával"
         else
           paste0("Forrás: KSH Helységnévtár (hntr) · ",
      "A 2001 és 2011 népszámlálási illesztések kisebb törést okozhatnak")) +
    theme_bw(base_size = 15) +
    theme(legend.position = "top", strip.placement = "outside",
          plot.title = element_text(size = 16, face = "bold"),
          plot.subtitle = element_text(size = 12))

  fname <- if (floating) {
    sprintf("plots/idosor_jogallas_floating_from%d.png", start_yr)
  } else {
    sprintf("plots/idosor_jogallas_fix_%d_from%d.png", sel_yr, start_yr)
  }
  if (save_flag) {
    ggsave(fname, p, width = 14, height = 8, units = "in", dpi = 300, bg = "white")
  }
  print(p)
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# popul eloszlas kategoria szerint EGY EVBEN

local({
  save_flag <- T
  sel_yr <- c(2004,2010,2020,2025)[4]
  bp_pop <- hnt_2004_2010_2025_jogallas |>
    filter(year == sel_yr, grepl("Budapest", telepules)) |>
    summarise(p=sum(lakonepesseg)) |> pull(p)
  natl <- hnt_2004_2010_2025_jogallas |>
    filter(year == sel_yr) |> summarise(p=sum(lakonepesseg)) |> pull(p)
  pd <- hnt_2004_2010_2025_jogallas |>
    left_join(hu_agglomeracio_telepulesek_2024, by="telepules") |>
    mutate(agglom=if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül")) |>
    filter(year == sel_yr, telepules != "Budapest",
           jogallas %in% c("város", "nagyközség", "község",
                           "megyei jogú város", "megyeszékhely, megyei jogú város")) |>
    mutate(jogallas3=case_when(
             jogallas %in% c("község","nagyközség") ~ "község/nagyközség",
             str_detect(jogallas, "megyei jogú")    ~ "megyeszékhely/megyei jogú város",
             TRUE                                   ~ "város") |>
             factor(levels=c("község/nagyközség","város","megyeszékhely/megyei jogú város")),
           panel=jogallas3)
  fmt <- scales::label_number(big.mark=" ")

  stats <- pd |>
    summarise(med=median(lakonepesseg),
              q1=quantile(lakonepesseg, .25), q3=quantile(lakonepesseg, .75),
              n=n(), pop=sum(lakonepesseg), .by=c(panel, jogallas3, agglom))

  # n label -> ABOVE the box
    n_lab <- stats |> mutate(lab=sprintf("n=%d", n))

  # summary (median + össz) -> BELOW the box, n removed
  lane <- stats |>
    mutate(lab=if_else(n == 1, NA_character_,
              sprintf("medián=%s fő (IQR %s-%s)\n %.2fm (%.1f%%)", # ország -a
                      fmt(round(med)), fmt(round(q1)), fmt(round(q3)),
                      pop/1e6, 100*pop/natl)))

  singletons <- pd |>
    summarise(name=first(telepules), pop=first(lakonepesseg), k=n(),
              .by=c(panel, jogallas3, agglom)) |>
    filter(k == 1) |>
    mutate(lab=sprintf("%s\n%.3fm (%.2f%%)",
                         name, pop/1e6, 100*pop/natl))

  box_dat <- pd |> filter(n() >= 5, .by=c(panel, agglom))

  ggplot(pd, aes(lakonepesseg, agglom, colour=agglom)) +
    facet_grid(. ~ panel, scales="free_x") +
    geom_jitter(aes(size=jogallas3), height=0.28, width=0, alpha=0.35) +
    scale_size_manual(values=c("község/nagyközség"=1.0,
                                 "város"=1.8,
                                 "megyeszékhely/megyei jogú város"=3.0),
                      guide="none") +
    geom_boxplot(data=box_dat, width=0.55, outlier.shape=NA,
                 colour="grey25", fill=NA, linewidth=0.6) +
    # n ABOVE the box, left-anchored & bold
    geom_text(data=n_lab, aes(label=lab), inherit.aes=FALSE,
              x=-Inf, y=n_lab$agglom, hjust=-0.25, vjust=-4,
              size=5, fontface="bold", colour="grey20") +
    # summary BELOW the box, pushed down more
    geom_text(data=lane, aes(label=lab), inherit.aes=FALSE,
              x=-Inf, y=lane$agglom, hjust=-0.05, vjust=3.4,
              size=4, lineheight=0.92, na.rm=TRUE) +
    geom_text(data=singletons, aes(x=pop, y=agglom, label=lab),
              inherit.aes=FALSE, hjust=-0.05, vjust=1.6,
              size=4, lineheight=0.92) +
    geom_hline(yintercept=1.5) +
    scale_x_log10(labels=fmt) +
    # scale_y_discrete(expand=expansion(add=c(0.9, 0.7))) +
    coord_cartesian(clip="off") +
    labs(y=NULL, x="Lakónépesség (fő, log skála)",
         title=paste0("Településméret jogállás és agglomeráció szerint, ",sel_yr),
         caption=sprintf("Budapest: %.2fm fő, ország %.1f%%-a",
                           bp_pop/1e6, 100*bp_pop/natl)) +
    theme_bw(base_size=14) +
    theme(legend.position="none",
          plot.title=element_text(face="bold"),
          plot.caption=element_text(size=13),
          panel.spacing=unit(14, "pt"))
  # SAVE
  if (save_flag) {
  ggsave(paste0("plots/box_jogallas_",sel_yr,".png"), last_plot(),
         width=14, height=6.2, units="in", dpi=300, bg="white")
    }
  print(last_plot())
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# osszefoglalo tablazat ugyanerrol

local({
  sel_yr <- range(hnt_2004_2010_2025_jogallas$year)[2]
  fmt <- scales::label_number(big.mark=" ")

  natl <- hnt_2004_2010_2025_jogallas |>
    filter(year == sel_yr) |> summarise(p=sum(lakonepesseg)) |> pull(p)

  pd <- hnt_2004_2010_2025_jogallas |>
    left_join(hu_agglomeracio_telepulesek_2024, by="telepules") |>
    mutate(agglom=if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül")) |>
    filter(year == sel_yr, telepules != "Budapest",
           jogallas %in% c("város","nagyközség","község",
                           "megyei jogú város","megyeszékhely, megyei jogú város")) |>
    mutate(jog=case_when(
             jogallas == "község"                        ~ "község",
             jogallas == "nagyközség"                    ~ "nagyközség",
             jogallas == "város"                         ~ "város",
             jogallas == "megyei jogú város"             ~ "megyei jogú város",
             TRUE                                        ~ "megyeszékhely") |>
           factor(levels=c("község","nagyközség","város",
                             "megyei jogú város","megyeszékhely")))

  cell <- pd |>
    summarise(n=n(), pop=sum(lakonepesseg),
              med=median(lakonepesseg),
              q1=quantile(lakonepesseg, .25), q3=quantile(lakonepesseg, .75),
              lo=min(lakonepesseg), hi=max(lakonepesseg),
              # name the towns when the cell is small (<=3)
              names=if_else(n() <= 3,
                              paste(telepules, collapse=", "), NA_character_),
              .by=c(jog, agglom)) |>
    mutate(text=if_else(
      n <= 3,
      # small cell: n + names + population
      paste0("n=", n, " (", names, ")<br>",
             sprintf("%.3fm fő (ország %.2f%%-a)", pop/1e6, 100*pop/natl), "<br>",
             "méret: ", fmt(lo), if_else(n > 1, paste0(" - ", fmt(hi)), "")),
      # full cell
      paste0("n=", n, "<br>",
             sprintf("%.2fm fő (ország %.1f%%-a)", pop/1e6, 100*pop/natl), "<br>",
             "medián: ", fmt(round(med)), " fő<br>",
             "IQR: ", fmt(round(q1)), " - ", fmt(round(q3)), "<br>",
             "min - max: ", fmt(lo), " - ", fmt(hi))))

  tab <- cell |>
    select(jog, agglom, text) |>
    pivot_wider(names_from=agglom, values_from=text) |>
    arrange(jog)

  gt(tab) |>
    fmt_markdown(columns=everything()) |>
    fmt_missing(columns=everything(), missing_text=" - ") |>
    cols_label(jog="Jogállás") |>
    tab_header(
      title=md(paste0("**Településméret és agglomeráció jogállás szerint, ", sel_yr, "**")),
      subtitle=md(sprintf("Budapest nélkül · ország összesen %.2fm fő", natl/1e6))) |>
    tab_style(style=cell_text(weight="bold"),
              locations=cells_body(columns=jog)) |>
    tab_style(style=cell_text(v_align="top"), locations=cells_body()) |>
    cols_width(jog ~ px(160), everything() ~ px(300)) |>
    tab_options(table.font.size=px(13), data_row.padding=px(8),
                heading.title.font.size=px(18)) |>
    gtsave(paste0("plots/jogallas_table_", sel_yr, ".html"))
  
  webshot("plots/jogallas_table_2025.html", "plots/jogallas_table_2025.png",
        vwidth=800, vheight=600, zoom=2)
  
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# buborék ábrák

local({
  sel_yr <- c(2004,2010,2025)[1]
  fmt <- scales::label_number(big.mark=" ")

  jog_lvls <- c("község","nagyközség","város","megyei jogú város","megyeszékhely","Budapest")

  sett <- hnt_2004_2010_2025_jogallas |>
    filter(year == sel_yr) |>
    mutate(telepules=if_else(grepl("Budapest", telepules), "Budapest", telepules)) |>
    summarise(pop=sum(lakonepesseg), jogallas=first(jogallas), .by=telepules)
  natl <- sum(sett$pop)

  cells <- sett |>
    left_join(hu_agglomeracio_telepulesek_2024, by="telepules") |>
    mutate(
      agglom=if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül"),
      jog=case_when(
        telepules == "Budapest"                          ~ "Budapest",
        jogallas == "község"                             ~ "község",
        jogallas == "nagyközség"                         ~ "nagyközség",
        jogallas == "város"                              ~ "város",
        jogallas == "megyei jogú város"                  ~ "megyei jogú város",
        str_detect(jogallas, "megyeszékhely")            ~ "megyeszékhely",
        TRUE                                             ~ NA_character_) |>
        factor(levels=jog_lvls)) |>
    filter(!is.na(jog)) |>
    summarise(n=n(), tot=sum(pop), med=median(pop),
              .by=c(jog, agglom)) |>
    mutate(
      pct=100 * tot / natl,
      x=as.integer(jog),
      y=if_else(agglom == "Agglomerációban", 2, 1),
      inside=sprintf("%.2fm", tot / 1e6),
      below=case_when(
        jog == "Budapest" ~ sprintf("ország %.1f%%-a", pct),
        n <= 3            ~ sprintf("n=%d\nország %.1f%%-a", n, pct),
        TRUE              ~ sprintf("n=%d\nmedián %s fő\nország %.1f%%-a",
                                    n, fmt(round(med)), pct)))

    # after the cells mutate block, compute row totals
  row_tot <- cells |>
    summarise(rtot=sum(tot), .by=agglom) |>
    mutate(lab=sprintf("%s\n%.2fm fő (%.1f%%)",
                         if_else(agglom == "Agglomerációban", "Agglomerációban", "Agglom.-n kívül"),
                         rtot / 1e6, 100 * rtot / natl))

  # then in the scale_y_continuous, use those labels keyed by position
  ylabs <- row_tot |> arrange(agglom) |> pull(lab)   # alphabetical: Agglom. kívül=1, Agglomerációban=2
  
  ggplot(cells, aes(x, y)) +
    geom_point(aes(size=tot, fill=agglom),
               shape=21, colour="white", stroke=1.2, alpha=0.9) +
    scale_size_area(max_size=60, guide="none") +
    geom_text(aes(label=inside), fontface="bold", size=4, colour="grey15") +
    geom_text(aes(label=below), vjust=1, nudge_y=-0.4,
              size=4, lineheight=0.9) +
    scale_x_continuous(breaks=1:length(jog_lvls), labels=jog_lvls,
                       position="top", limits=c(0.5, length(jog_lvls) + 0.5),
                       expand=expansion(0)) +
    scale_y_continuous(breaks=c(1, 2),
                       labels=ylabs,
                       limits=c(0.35, 2.55), expand=expansion(0)) +
    scale_fill_manual(values=c("Agglomerációban"="#00BFC4",
                                 "Agglom. kívül"="#F8766D"), guide="none") +
    geom_hline(yintercept=1.35) +
    labs(x=NULL, y=NULL,
         title=paste0("Jogállás és agglomeráció, ", sel_yr),
         subtitle="A körök területe a kategória összlakosságával arányos",
         caption=sprintf("Ország összesen %.2fm fő", natl/1e6)) +
    theme_bw() +
    theme(panel.grid=element_blank(),
          axis.text.x.top=element_text(face="bold", size=16),
          axis.text.y=element_text(face="bold", size=16),
          plot.title=element_text(face="bold", size=19),
          plot.caption=element_text(size=16)
      )

  ggsave(paste0("plots/bubble_jogallas_", sel_yr, ".png"), last_plot(),
         width=16, height=7.5, units="in", dpi=300, bg="white")
  print(last_plot())
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# popul eloszlás méret szerint (2025)

local({
  
  sel_yr <- c(2004,2010,2025)[1]
  
  brks <- c(-Inf, 1e3, 2e3, 5e3, 1e4, 3e4, Inf)
  fin  <- brks[is.finite(brks)]
  k    <- function(x) paste0(x/1e3, "k")
  labs <- c(paste0("<", k(fin[1])),
            paste0(k(head(fin, -1)), "–", k(fin[-1])),
            paste0(">", k(tail(fin, 1))))

  bp_pop <- hnt_2004_2010_2025_jogallas |>
    filter(year == sel_yr, grepl("Budapest", telepules)) |>
    summarise(p=sum(lakonepesseg)) |> pull(p)
  natl <- hnt_2004_2010_2025_jogallas |>
    filter(year == sel_yr) |> summarise(p=sum(lakonepesseg)) |> pull(p)

  pd <- hnt_2004_2010_2025_jogallas |>
    left_join(hu_agglomeracio_telepulesek_2024, by="telepules") |>
    mutate(agglom=if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül")) |>
    filter(year == sel_yr, telepules != "Budapest",
           jogallas %in% c("város","nagyközség","község",
                           "megyei jogú város","megyeszékhely, megyei jogú város")) |>
        mutate(
      band=cut(lakonepesseg, brks, labs, right=F),
      panel=band,
      # 4 status groups -> 4 shapes
      tipus=case_when(
        jogallas == "község"                ~ "község",
        jogallas == "nagyközség"            ~ "nagyközség",
        str_detect(jogallas, "megyei jogú") ~ "megyeszékhely/mjv",
        TRUE                                ~ "város") |>
        factor(levels=c("község","nagyközség","város","megyeszékhely/mjv")),
      psize=as.integer(band))

  fmt <- scales::label_number(big.mark=" ")

  stats <- pd |>
    summarise(med=median(lakonepesseg),
              q1=quantile(lakonepesseg, .25), q3=quantile(lakonepesseg, .75),
              n=n(), pop=sum(lakonepesseg), .by=c(panel, agglom))

    n_lab <- stats |>
    mutate(lab=sprintf("n=%d", n),
      # top lane lifted more
           vj =if_else(agglom == "Agglomerációban", -4.5, -3.5))   

  lane <- stats |>
    mutate(lab=if_else(n == 1, NA_character_,
              sprintf("%.2fm (%.1f%%)", # medián=%s fő (IQR %s–%s)\n 
                      # fmt(round(med)), fmt(round(q1)), fmt(round(q3)),
                      pop/1e6, 100*pop/natl)),
      # top lane higher (smaller vjust)
           vj =if_else(agglom == "Agglomerációban", 4.5, 5.5))   

  box_dat <- pd |> filter(n() >= 5, .by=c(panel, agglom))

ggplot(pd, aes(lakonepesseg, agglom, colour=agglom)) +
    facet_wrap(~ panel, scales="free_x", ncol=3) +
    geom_jitter(aes(shape=tipus, size=psize),
                height=0.26, width=0, alpha=0.4, stroke=0) +
    scale_shape_manual(values=c("község"=16,            # filled circle
                                "nagyközség"=18,         # filled diamond
                                "város"=17,              # triangle
                                "megyeszékhely/mjv"=15), # square
                       name=NULL) +
    scale_size(range=c(1.1, 3.2), guide="none") +
    geom_boxplot(data=box_dat, width=0.55, outlier.shape=NA,
                 colour="grey25", fill=NA, linewidth=0.6) +
    geom_text(data=n_lab, aes(label=lab, vjust=vj), inherit.aes=F,
              x=-Inf, y=n_lab$agglom, hjust=-0.15,
              size=4.5, fontface="bold", colour="grey20") +
    geom_text(data=lane, aes(label=lab, vjust=vj), inherit.aes=F,
              x=-Inf, y=lane$agglom, hjust=-0.05,
              size=4.5, lineheight=0.92, na.rm=TRUE) +
    # geom_text(data=singletons, aes(x=pop, y=agglom, label=lab),
    #           inherit.aes=F, hjust=-0.05, vjust=1.6,
    #           size=3.5, lineheight=0.92) +
    geom_hline(yintercept=1.5) +
    scale_x_continuous(labels=fmt) +
    coord_cartesian(clip="off") +
    guides(colour="none",
           shape=guide_legend(override.aes=list(size=3, alpha=1))) +
    labs(y=NULL, x="Lakónépesség (fő)",
         title=paste0("Településméret méretkategória és agglomeráció szerint, ",sel_yr),
         caption=sprintf("Budapest: %.2fm fő, ország %.1f%%-a",
                           bp_pop/1e6, 100*bp_pop/natl)) +
    theme_bw(base_size=14) +
    theme(legend.position="top",
          plot.title=element_text(face="bold"),
          plot.caption=element_text(size=13),
          strip.text=element_text(size=15),                          # panel strip bigger
          axis.title=element_text(size=15),                          # x/y axis titles bigger
          panel.spacing=unit(16, "pt"))

  ggsave(paste0("plots/box_meret_",sel_yr,".png"), last_plot(),
         width=15, height=9, units="in", dpi=300, bg="white")
  print(last_plot())
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# HTML osszefoglalo tablazat

local({
  sel_yr <- c(2012, 2025)[2]

  brks <- c(-Inf, 1e3, 2e3, 5e3, 1e4, 3e4, Inf)
  fin  <- brks[is.finite(brks)]
  k    <- function(x) paste0(x/1e3, "k")
  labs <- c(paste0("<", k(fin[1])),
            paste0(k(head(fin, -1)), "-", k(fin[-1])),
            paste0(">", k(tail(fin, 1))))
  fmt <- scales::label_number(big.mark=" ")

  natl <- hnt_2004_2010_2025_jogallas |>
    filter(year == sel_yr) |> summarise(p=sum(lakonepesseg)) |> pull(p)

  pd <- hnt_2004_2010_2025_jogallas |>
    left_join(hu_agglomeracio_telepulesek_2024, by="telepules") |>
    mutate(agglom=if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül")) |>
    filter(year == sel_yr, telepules != "Budapest",
           jogallas %in% c("város","nagyközség","község",
                           "megyei jogú város","megyeszékhely, megyei jogú város")) |>
    mutate(
      band=cut(lakonepesseg, brks, labs, right=FALSE),
      tipus=case_when(
        jogallas == "község"                ~ "község",
        jogallas == "nagyközség"            ~ "nagyközség",
        str_detect(jogallas, "megyei jogú") ~ "megyeszékhely/mjv",
        TRUE                                ~ "város") |>
        factor(levels=c("község","nagyközség","város","megyeszékhely/mjv")))

  # composition-by-type string, only when >1 type present
  comp <- pd |>
    count(band, agglom, tipus, .drop=FALSE) |>
    filter(n > 0) |>
    summarise(
      ntypes=n(),
      comp=paste(sprintf("%s: %d (%.0f%%)", tipus, n, 100*n/sum(n)), collapse="<br>"),
      .by=c(band, agglom)) |>
    mutate(comp=if_else(ntypes > 1, comp, NA_character_))

  # core stats per cell
  cell <- pd |>
    summarise(n=n(), pop=sum(lakonepesseg),
              med=median(lakonepesseg),
              q1=quantile(lakonepesseg, .25), q3=quantile(lakonepesseg, .75),
              lo=min(lakonepesseg), hi=max(lakonepesseg),
              .by=c(band, agglom)) |>
    left_join(comp, by=c("band","agglom")) |>
    mutate(text=paste0(
      "n=", n, "<br>",
      sprintf("%.2fm fő (ország %.1f%%-a)", pop/1e6, 100*pop/natl), "<br>",
      "medián: ", fmt(round(med)), " fő<br>",
      "IQR: ", fmt(round(q1)), "-", fmt(round(q3)), "<br>",
      # "min-max: ", fmt(lo), "-", fmt(hi),
      if_else(is.na(comp), "", 
        paste0("<hr style='margin:4px 0;border:none;border-top:1px solid #ddd'>", comp))
    ))

  # wide: bands as rows, agglom as columns
  tab <- cell |>
    select(band, agglom, text) |>
    pivot_wider(names_from=agglom, values_from=text) |>
    arrange(band)

  gt(tab) |>
    fmt_markdown(columns=everything()) |>
    cols_label(band="Méretkategória") |>
    tab_header(
      title=md(paste0("**Településméret és agglomeráció, ", sel_yr, "**")),
      subtitle=md(sprintf("Budapest nélkül · ország összesen %.2fm fő", natl/1e6))) |>
    tab_style(style=cell_text(weight="bold"),
              locations=cells_body(columns=band)) |>
    tab_style(style=cell_text(v_align="top"),
              locations=cells_body()) |>
    cols_width(band ~ px(130), everything() ~ px(300)) |>
    tab_options(table.font.size=px(13), data_row.padding=px(8),
                heading.title.font.size=px(18)) |>
    gtsave(paste0("plots/meret_table_", sel_yr, ".html"))
  
  library(webshot2)

webshot("plots/meret_table_2025.html", "plots/meret_table_2025.png",
        vwidth=800, vheight=600, zoom=2)
  
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# buborék ábrák

local({
  sel_yr <- c(2004,2025)[1]
  brks <- c(-Inf, 1e3, 2e3, 5e3, 1e4, 3e4, Inf)
  k    <- function(x) paste0(x/1e3, "k")
  fin  <- brks[is.finite(brks)]
  labs <- c(paste0("<", k(fin[1])),
            paste0(k(head(fin, -1)), "–", k(fin[-1])),
            paste0(">", k(tail(fin, 1))))
  fmt  <- scales::label_number(big.mark=" ")
  band_lvls <- c(labs, "Budapest")
  sett <- hnt_2004_2010_2025_jogallas |>
    filter(year == sel_yr) |>
    mutate(telepules=if_else(grepl("Budapest", telepules), "Budapest", telepules)) |>
    summarise(pop=sum(lakonepesseg), .by=telepules)
  natl <- sum(sett$pop)
  cells <- sett |>
    left_join(hu_agglomeracio_telepulesek_2024, by="telepules") |>
    mutate(agglom=if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül"),
           band=if_else(telepules == "Budapest", "Budapest",
                          as.character(cut(pop, brks, labs, right=FALSE))),
           band=factor(band, levels=band_lvls)) |>
    summarise(n=n(), tot=sum(pop), med=median(pop),
              q1=quantile(pop, .25), q3=quantile(pop, .75),
              .by=c(band, agglom)) |>
    mutate(
      pct=100 * tot / natl,
      x=as.integer(band),
      y=if_else(agglom == "Agglomerációban", 2, 1),
      inside=sprintf("%.2fm", tot / 1e6),
      below=case_when(
        band == "Budapest" ~ sprintf("ország %.1f%%-a", pct),
        n == 1 ~ sprintf("n=1 · %s fő\nország %.1f%%-a", fmt(tot), pct),
        TRUE ~ sprintf("n=%d \n medián %s fő\nország %.1f%%-a", n, fmt(round(med)), pct)))

  row_tot <- cells |>
    summarise(rtot=sum(tot), .by=agglom) |>
    mutate(lab=sprintf("%s\n%.2fm fő (%.1f%%)", agglom, rtot / 1e6, 100 * rtot / natl))
  ylabs <- row_tot |> arrange(agglom) |> pull(lab)

  ggplot(cells, aes(x, y)) +
    geom_point(aes(size=tot, fill=agglom),
               shape=21, colour="white", stroke=1.2, alpha=0.9) +
    scale_size_area(max_size=60, guide="none") +
    geom_text(aes(label=inside), fontface="bold", size=4, colour="grey15") +
    geom_text(aes(label=below), vjust=1, nudge_y=-0.4,
              size=4, lineheight=0.9) +
    scale_x_continuous(breaks=1:length(band_lvls), labels=band_lvls,
                       position="top", limits=c(0.5, length(band_lvls) + 0.5),
                       expand=expansion(0)) +
    scale_y_continuous(breaks=c(1, 2),
                       labels=ylabs,
                       limits=c(0.35, 2.55), expand=expansion(0)) +
    scale_fill_manual(values=c("Agglomerációban"="#00BFC4",
                                 "Agglom. kívül"="#F8766D"), guide="none") +
    geom_hline(yintercept=1.35) +
    labs(x=NULL, y=NULL,
         title=paste0("Településméret és agglomeráció, ", sel_yr),
         subtitle="A körök területe a kategória összlakosságával arányos",
         caption=sprintf("Ország összesen %.2fm fő", natl/1e6)) +
    theme_bw() +
    theme(panel.grid=element_blank(),
          axis.text.x.top=element_text(face="bold", size=16),
          axis.text.y=element_text(face="bold", size=16),
          plot.title=element_text(face="bold", size=19),
          plot.caption=element_text(size=15))
  ggsave(paste0("plots/bubble_meret_", sel_yr, ".png"), last_plot(),
         width=16, height=7.5, units="in", dpi=300, bg="white")
  print(last_plot())
})

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# https://kormany.hu/nyilvantartasok/statisztika/lakossagi-szamadatok
# "állandó lakosság" - broader than HNT files
# hu_nepesseg_telepules_2011_2019_2026 <- read_csv(
#   "hu_nepesseg_telepules_2011_2019_2026.csv")


# classifications
# summ_list <- local({
#   jog_levels <- c("község/nagyközség", "város",
#                   "megyeszékhely/megyei jogú város", "Budapest")
# 
#   dat <- hnt_2004_2010_2025_jogallas |>
#     left_join(hu_agglomeracio_telepulesek_2024, by="telepules") |>
#     mutate(
#       agglom=if_else(!is.na(szerkezet), "Agglomerációban", "Agglom. kívül"),
#       jogallas3=case_when(
#         jogallas %in% c("község", "nagyközség") ~ "község/nagyközség",
#         jogallas == "fővárosi kerület" ~ "Budapest",
#         str_detect(jogallas, "megyei jogú") ~ "megyeszékhely/megyei jogú város",
#         TRUE ~ "város" ) |> factor(levels=jog_levels),
#       meret=cut(lakonepesseg,
#                   breaks=c(-Inf, 1e3, 2e3, 5e3, 1e4, 5e4, Inf),
#                   labels=c("0–1k","1–2k","2–5k","5–10k","10-50k",">50k"),
#                   right=F) )
#   natl <- dat |> summarise(natl=sum(lakonepesseg), .by=year)
# 
#   tblA <- dat |>
#     summarise(n=n(), pop=sum(lakonepesseg), .by=c(year, agglom)) |>
#     left_join(natl, by="year") |>
#     mutate(pct=round(100 * pop / natl, 1)) |> select(-natl) |> arrange(year, agglom)
# 
#   tblB <- dat |>
#     summarise(n=n(), pop=sum(lakonepesseg), .by=c(year, agglom, jogallas3)) |>
#     left_join(natl, by="year") |>
#     mutate(pct=round(100 * pop / natl, 1)) |> select(-natl) |> arrange(year, jogallas3, agglom)
# 
#   tblC <- dat |>
#     summarise(n=n(), pop=sum(lakonepesseg), .by=c(year, agglom, meret)) |>
#     left_join(natl, by="year") |>
#     mutate(pct=round(100 * pop / natl, 1)) |> select(-natl) |> arrange(year, meret, agglom)
# 
#   list(agglom_in_out=tblA, agglom_out_tipus=tblB, agglom_out_telepmeret=tblC)
# })
# 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# # PLOT trends
# 
# trace_plot <- function(df, group_var, title=NULL) {
#   d <- df |>
#     pivot_longer(c(pop, pct), names_to="metric", values_to="value") |>
#     mutate(metric=recode(metric,
#                            pct="Az ország %-ában",
#                            pop="Lakónépesség (millió fő)") |>
#                     factor(levels=c("Az ország %-ában", "Lakónépesség (millió fő)")))
#   ends <- d |> filter(year %in% range(year)) |>
#     mutate(lab=if_else(metric == "Az ország %-ában",
#                          sprintf("%.1f%% (n=%d)", value, n),
#                          paste0(sprintf("%.2f", value/1e6),"m")),
#            vj=if_else(agglom == "Agglom. kívül", -0.8, 1.6))   # out=up, in=down
#   ggplot(d, aes(year, value, colour=agglom, group=agglom)) +
#     geom_line(linewidth=0.9) +
#     geom_point(size=1.4) +
#     geom_text(data=ends, aes(label=lab, vjust=vj), size=2.8, show.legend=F, lineheight=0.85) +
#     facet_grid(rows=vars(metric), cols=vars({{ group_var }}),
#                scales="free_y", switch="y") +
#     scale_x_continuous(breaks=seq(2012, 2025, 4), expand=expansion(mult=0.15)) +
#     scale_y_continuous(expand=expansion(mult=0.22)) +
#     labs(x=NULL, y=NULL, colour=NULL) + # , title=title
#     theme_bw() +
#     theme(legend.position="top", strip.placement="outside")
# }
# 
# # make plots
# # trace_plot(summ_list$agglom_out_tipus, jogallas3,
# #   "Jogállás szerint")
# trace_plot(summ_list$agglom_out_telepmeret, meret)
# 
# # THE ISSUE with this is that towns are moving
# # across categs in time. eg falling from 1-2k to 0-1k
# # so stable <1k is partly an illusion...
# # probly better solution: fix the towns by categ at
# # starting point and track their evolution