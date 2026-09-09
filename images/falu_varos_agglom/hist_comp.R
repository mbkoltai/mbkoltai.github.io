# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# 1949 ---> 1990/94 osszehasonlitas

local({
  save_flag <- T
  raw_mek <- read_csv("adatok/mek_52_53_nepesseg_meretetkategoriak.csv")
  fmt <- scales::label_number(big.mark=" ")

  recode_band <- function(meret) case_when(
    meret == "Budapest"        ~ "Budapest",
    meret == "500 alatt"       ~ "<1k",
    meret == "500-1000"        ~ "<1k",
    meret == "1000-2000"       ~ "1–2k",
    meret == "2000-5000"       ~ "2–5k",
    meret == "5000 alatt"      ~ "2–5k",
    meret == "5000-10000"      ~ "5–10k",
    meret == "10000-20000"     ~ "10–25k",
    meret == "10000-25000"     ~ "10–25k",
    meret == "20000 felett"    ~ "25–50k",
    meret == "25000-50000"     ~ "25–50k",
    meret == "50000-100000"    ~ "50–100k",
    meret == "100000 felett"   ~ "100k+",
    TRUE ~ NA_character_)

  band_lvls <- c("<1k","1–2k","2–5k","5–10k",
                 "10–25k","25–50k","50–100k","100k+","Budapest")
  brks <- c(-Inf, 1e3, 2e3, 5e3, 1e4, 2.5e4, 5e4, 1e5, Inf)
  blabs <- c("<1k","1–2k","2–5k","5–10k",
             "10–25k","25–50k","50–100k","100k+")

  recl_tipus <- function(jogallas) case_when(
    jogallas %in% c("község","nagyközség") ~ "község",
    jogallas == "fővárosi kerület"          ~ "város",
    TRUE                                    ~ "város")

  # --- 1949 & 1990/94 from MEK (község/város split in the source) ---
  d_mek <- raw_mek |>
    filter(meret_kategoria != "együtt", !is.na(nepesseg)) |>
    mutate(
      band=recode_band(meret_kategoria) |>
        factor(levels=band_lvls),
      tipus=case_when(
        tipus == "község" ~ "község", TRUE ~ "város"),
      yr=if_else(year %in% c(1990, 1994),
                   "1990/94", as.character(year))) |>
    filter(!is.na(band)) |>
    summarise(n=sum(n_telepules, na.rm=T),
              tot=sum(nepesseg),
              .by=c(yr, band, tipus))

  # --- 2004 & 2025 from hntr (population) + jogállás frame (type) ---
  d_hnt <- hnt_2004_2010_2025_jogallas |>
    filter(year %in% c(2004, 2025)) |>
    mutate(
      tipus=recl_tipus(jogallas),
      band=if_else(
        grepl("Budapest", telepules), "Budapest",
        as.character(cut(lakonepesseg, brks, blabs, right=F))) |>
        factor(levels=band_lvls),
      yr=as.character(year)) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(lakonepesseg),
              .by=c(yr, band, tipus))

  # --- combine ---
  yr_lvls <- c("1949","1990/94","2004","2025")
  d <- bind_rows(d_mek, d_hnt) |>
    mutate(yr=factor(yr, levels=yr_lvls))

  natl <- d |> summarise(natl=sum(tot), .by=yr)
  d <- d |> left_join(natl, by="yr") |>
    mutate(
      pct=100 * tot / natl,
      x=as.integer(band),
      y=if_else(tipus == "város", 2, 1),
      inside=sprintf("%.2fm", tot / 1e6),
      below=case_when(
        band == "Budapest" ~ sprintf("ország\n%.1f%%-a", pct),
        n == 0             ~ "",
        TRUE               ~ sprintf("n=%d\nország\n%.1f%%-a", n, pct)))

  row_tot <- d |>
    summarise(rtot=sum(tot), .by=c(yr, tipus)) |>
    left_join(natl, by="yr") |>
    mutate(
      lab=sprintf("%s\n%.2fm (%.1f%%)",
                    tipus, rtot / 1e6, 100 * rtot / natl))

  row_ann <- row_tot |>
    mutate(x=length(band_lvls) + 0.3,
           y=if_else(tipus == "város", 2.45, 1.3),
           lab2=sprintf("%.2fm\n(%.1f%%)",
                          rtot / 1e6, 100 * rtot / natl))

  p <- ggplot(d, aes(x, y)) +
    facet_wrap(~ yr, ncol=2) +
    geom_point(aes(size=tot, fill=tipus),
               shape=21, colour="white",
               stroke=1.2, alpha=0.9) +
    scale_size_area(max_size=40, guide="none") +
    geom_text(aes(label=inside),
              fontface="bold", size=5, colour="grey15") +
    geom_text(aes(label=below), vjust=1, nudge_y=-0.38,
              size=4.5, lineheight=0.88) +
    geom_text(data=row_ann, aes(label=lab2),
              inherit.aes=F,
              x=row_ann$x, y=row_ann$y,
              size=4.5, fontface="italic",
              hjust=0, vjust=1,
              colour="grey30", lineheight=0.9) +
    scale_x_continuous(
      breaks=1:length(band_lvls), labels=band_lvls,
      position="top",
      limits=c(0.5, length(band_lvls) + 1.5),
      expand=expansion(0)) +
    scale_y_continuous(
      breaks=c(1, 2), labels=c("község","város"),
      limits=c(0.3, 2.6), expand=expansion(0)) +
    scale_fill_manual(
      values=c("város"="#00BFC4", "község"="#F8766D"),
      guide="none") +
    geom_hline(yintercept=1.35) +
    coord_cartesian(clip="off") +
    labs(
      x=NULL, y=NULL,
      title="Település-kategóriák népessége, 1949–2025",
      subtitle=paste0(
        "A körök területe a kategória összlakosságával arányos · ",
        "község=község + nagyközség, város=minden városi jogállás"),
      caption=paste0(
        "1949, 1990/94: MEK (községek 1990, városok 1994) · ",
        "2004, 2025: KSH HNT")) +
    theme_bw() +
    theme(panel.grid=element_blank(),
          axis.text.x.top=element_text(face="bold", size=16),
          axis.text.y=element_text(face="bold", size=16),
          plot.title=element_text(face="bold", size=20),
          plot.subtitle=element_text(size=13),
          plot.caption=element_text(size=12),
          strip.text=element_text(face="bold", size=18),
          panel.spacing=unit(18, "pt"))
  if (save_flag) {
  ggsave("plots/hist/mek_bubble_1949_2025.png", p,
         width=18, height=13, units="in", dpi=300, bg="white")
    }
  print(p)
})

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# 1949 --> 1990 ---> 2012 --> 2025

local({
  raw_mek <- read_csv("adatok/mek_52_53_nepesseg_meretetkategoriak.csv")
  fmt <- scales::label_number(big.mark=" ")

    fmt_m <- function(x) if_else(x < 0.005e6,
                                sprintf("%.3fm", x / 1e6),
                                sprintf("%.2fm", x / 1e6))
  
  recode_band <- function(meret) case_when(
    meret == "Budapest"        ~ "Budapest",
    meret == "500 alatt"       ~ "<1k",
    meret == "500-1000"        ~ "<1k",
    meret == "1000-2000"       ~ "1–2k",
    meret == "2000-5000"       ~ "2–5k",
    meret == "5000 alatt"      ~ "2–5k",
    meret == "5000-10000"      ~ "5–10k",
    meret == "10000-20000"     ~ "10–25k",
    meret == "10000-25000"     ~ "10–25k",
    meret == "20000 felett"    ~ "25–50k",
    meret == "25000-50000"     ~ "25–50k",
    meret == "50000-100000"    ~ "50–100k",
    meret == "100000 felett"   ~ "100k+",
    TRUE ~ NA_character_)

  band_lvls <- c("<1k","1–2k","2–5k","5–10k",
                 "10–25k","25–50k","50–100k","100k+","Budapest")
  brks <- c(-Inf, 1e3, 2e3, 5e3, 1e4, 2.5e4, 5e4, 1e5, Inf)
  blabs <- c("<1k","1–2k","2–5k","5–10k",
             "10–25k","25–50k","50–100k","100k+")

  recl_tipus <- function(jogallas) case_when(
    jogallas %in% c("község","nagyközség") ~ "község",
    TRUE                                   ~ "város")

  # --- historical (MEK) — only needed for by_type 1949 & 1990/94 ---
  d_mek <- raw_mek |>
    filter(meret_kategoria != "együtt", !is.na(nepesseg)) |>
    mutate(
      band=recode_band(meret_kategoria) |>
        factor(levels=band_lvls),
      tipus=case_when(
        tipus == "község" ~ "község", TRUE ~ "város"),
      yr=if_else(year %in% c(1990, 1994),
                   "1990/94", as.character(year))) |>
    filter(!is.na(band)) |>
    summarise(n=sum(n_telepules, na.rm=TRUE),
              tot=sum(nepesseg),
              .by=c(yr, band, tipus))

  # --- modern with jogállás (2004 & 2025) ---
  d_hnt_jog <- hnt_2004_2010_2025_jogallas |>
    filter(year %in% c(2004, 2025)) |>
    mutate(
      tipus=recl_tipus(jogallas),
      band=if_else(
        grepl("Budapest", telepules), "Budapest",
        as.character(cut(lakonepesseg, brks, blabs,
                         right=FALSE))) |>
        factor(levels=band_lvls),
      yr=as.character(year)) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(lakonepesseg),
              .by=c(yr, band, tipus))

  # --- size-only from hntr (any years, no jogállás needed) ---
  d_hntr_size <- HNT_1990_2025 |>
    filter(year %in% c(1990, 2001, 2012, 2025)) |>
    mutate(
      band=if_else(
        telepules == "Budapest", "Budapest",
        as.character(cut(lakonepesseg, brks, blabs,
                         right=FALSE))) |>
        factor(levels=band_lvls),
      yr=as.character(year)) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(lakonepesseg),
              .by=c(yr, band))

  # === plot function ===
  make_bubble <- function(by_type=TRUE, size_by_pct=FALSE) {

    if (by_type) {
      # MEK (1949, 1990/94) + HNT jogállás (2004, 2025)
      yr_lvls <- c("1949","1990/94","2004","2025")
      d <- bind_rows(d_mek, d_hnt_jog) |>
        mutate(yr=factor(yr, levels=yr_lvls))
    } else {
      # all from hntr — no type, fine bands, clean source
      yr_lvls <- c("1990","2001","2012","2025")
      d <- d_hntr_size |>
        mutate(yr=factor(yr, levels=yr_lvls),
               tipus="összes")
    }

    natl <- d |> summarise(natl=sum(tot), .by=yr)
    d <- d |> left_join(natl, by="yr") |>
      mutate(
        pct=100 * tot / natl,
        x=as.integer(band),
        y=if (by_type) if_else(tipus == "város", 2, 1) else 1.5,
        bubble_val=if (size_by_pct) pct else tot)

    d <- d |> mutate(
      szint=case_when(
        band == "Budapest"                     ~ "Budapest",
        band %in% c("50–100k","100k+")         ~ "nagyváros",
        band %in% c("5–10k","10–25k","25–50k") ~ "kis/középváros",
        TRUE                                   ~ "falu") |>
        factor(levels=c("falu","kis/középváros",
                           "nagyváros","Budapest")))

    d <- d |> mutate(
        inside=if (size_by_pct) sprintf("%.1f%%", pct) else fmt_m(tot),
      below=case_when(
    band == "Budapest" &  size_by_pct ~ fmt_m(tot),
    band == "Budapest" & !size_by_pct ~ sprintf("ország\n%.1f%%-a", pct),
     size_by_pct ~ paste0("n=", n, "\n", fmt_m(tot)),
    !size_by_pct ~ sprintf("n=%d\nország\n%.1f%%-a", n, pct))
      )

    if (by_type) {
      row_tot <- d |>
        summarise(rtot=sum(tot), .by=c(yr, tipus)) |>
        left_join(natl, by="yr") |>
        mutate(
          x=length(band_lvls) + 0.3,
          y=if_else(tipus == "város", 2.45, 1.3),
          lab2=sprintf("%s\n%.2fm (%.1f%%)",
                         tipus, rtot / 1e6, 100 * rtot / natl))
    }

    max_sz <- if (by_type) 38 else 48
    h      <- if (by_type) 13 else 8
    ny     <- if (by_type) -0.35 else -0.45

    p <- ggplot(d, aes(x, y)) +
      facet_wrap(~ yr, ncol=2) +
      geom_point(aes(size=bubble_val,
                     fill=if (by_type) tipus else szint),
                 shape=21, colour="white",
                 stroke=1.2, alpha=0.9) +
      scale_size_area(max_size=max_sz, guide="none") +
      geom_text(aes(label=inside),
                fontface="bold", size=5, colour="grey15") +
      geom_text(aes(label=below), vjust=1, nudge_y=ny,
                size=4.5, lineheight=0.88) +
      scale_x_continuous(
        breaks=1:length(band_lvls), labels=band_lvls,
        position="top",
        limits=c(0.5, length(band_lvls) +
                     if (by_type) 0.75 else 0.75),
        expand=expansion(0))

    if (by_type) {
      p <- p +
        scale_y_continuous(
          breaks=c(1, 2), labels=c("község","város"),
          limits=c(0.3, 2.6), expand=expansion(0)) +
        scale_fill_manual(
          values=c("város"="#00BFC4", "község"="#F8766D"),
          guide="none") +
        geom_hline(yintercept=1.35) +
        geom_text(data=row_tot, aes(label=lab2),
                  inherit.aes=FALSE,
                  x=row_tot$x*0.8, y=row_tot$y,
                  size=6, fontface="italic",
                  hjust=0, vjust=1,
                  lineheight=0.9) +
        theme(legend.position="none")
    } else {
      p <- p +
        scale_y_continuous(
          breaks=NULL,
          limits=c(0.7, 2.3), expand=expansion(0)) +
        scale_fill_manual(
          values=c("falu"           ="#F8766D",
                     "kis/középváros" ="#C49A6C",
                     "nagyváros"      ="#7CAE9E",
                     "Budapest"       ="#00BFC4"),
          name=NULL) +
        guides(fill=guide_legend(
          override.aes=list(size=5))) +
        theme(legend.position="top")
    }

    type_str <- if_else(by_type, "tipus", "osszes")
    size_str <- if_else(size_by_pct, "pct", "abs")
    sub_str  <- if_else(
      size_by_pct,
      "A körök területe az országos népesség-részaránnyal arányos",
      "A körök területe a kategória összlakosságával arányos")
    sub_extra <- if_else(
      by_type,
      paste0(" · község=község + nagyközség, ",
             "város=minden városi jogállás"),
      "")
    caption <- if (by_type) {
      paste0("1949, 1990/94: MEK (községek 1990, városok 1994) · ",
             "2004, 2025: KSH HNT")
    } else {
      "Forrás: KSH Helységnévtár (hntr)"
    }

    p <- p +
      coord_cartesian(clip="off") +
      labs(x=NULL, y=NULL,
           title=paste0("Település-kategóriák népessége, ",
                          if (by_type) "1949–2025" else "1990–2025"),
           subtitle=paste0(sub_str, sub_extra),
           caption=caption) +
      theme_bw() +
      theme(panel.grid=element_blank(),
            axis.text.x.top=element_text(face="bold", size=15),
            axis.text.y=element_text(face="bold", size=15),
            plot.title=element_text(face="bold", size=18),
            plot.subtitle=element_text(size=13),
            plot.caption=element_text(size=13),
            strip.text=element_text(face="bold", size=17),
            panel.spacing=unit(16, "pt"))

    fname <- sprintf("plots/hist/mek_bubble_%s_%s.png",
                     type_str, size_str)
    ggsave(fname, p, width=18, height=h,
           units="in", dpi=300, bg="white")
    print(p)
  }

  make_bubble(by_type=TRUE,  size_by_pct=FALSE)
  make_bubble(by_type=TRUE,  size_by_pct=TRUE)
  make_bubble(by_type=FALSE, size_by_pct=FALSE)
  make_bubble(by_type=FALSE, size_by_pct=TRUE)
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# trajektoriak 1949 -> 2025
# y-tengely: meret kategoriak, x-tengely: evek

local({
  raw_mek <- read_csv("adatok/mek_52_53_nepesseg_meretetkategoriak.csv")
  fmt <- scales::label_number(big.mark=" ")

  fmt_m <- function(x) if_else(x < 0.005e6,
                                sprintf("%.3fm", x / 1e6),
                                sprintf("%.2fm", x / 1e6))

  recode_band <- function(meret) case_when(
    meret == "Budapest"        ~ "Budapest",
    meret == "500 alatt"       ~ "<1k",
    meret == "500-1000"        ~ "<1k",
    meret == "1000-2000"       ~ "1–2k",
    meret == "2000-5000"       ~ "2–5k",
    meret == "5000 alatt"      ~ "2–5k",
    meret == "5000-10000"      ~ "5–10k",
    meret == "10000-20000"     ~ "10–25k",
    meret == "10000-25000"     ~ "10–25k",
    meret == "20000 felett"    ~ "25–50k",
    meret == "25000-50000"     ~ "25–50k",
    meret == "50000-100000"    ~ "50–100k",
    meret == "100000 felett"   ~ "100k+",
    TRUE ~ NA_character_)

  band_lvls <- c("<1k","1–2k","2–5k","5–10k",
                 "10–25k","25–50k","50–100k","100k+","Budapest")
  brks <- c(-Inf, 1e3, 2e3, 5e3, 1e4, 2.5e4, 5e4, 1e5, Inf)
  blabs <- c("<1k","1–2k","2–5k","5–10k",
             "10–25k","25–50k","50–100k","100k+")

  # --- MEK ---
  d_mek <- raw_mek |>
    filter(meret_kategoria != "együtt", !is.na(nepesseg)) |>
    mutate(
      band=recode_band(meret_kategoria) |>
        factor(levels=band_lvls),
      tipus=case_when(tipus == "község" ~ "község",
                        TRUE ~ "város"),
      yr=if_else(year %in% c(1990, 1994),
                   "1990/94", as.character(year))) |>
    filter(!is.na(band)) |>
    summarise(n=sum(n_telepules, na.rm=T),
              tot=sum(nepesseg),
              .by=c(yr, band, tipus))

  # --- 2001 from hntr (size-only, no tipus) ---
  d_2001 <- HNT_1990_2025 |>
    filter(year == 2001) |>
    mutate(band=if_else(
      telepules == "Budapest", "Budapest",
      as.character(cut(lakonepesseg, brks, blabs,
                       right=F))) |>
      factor(levels=band_lvls)) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(lakonepesseg), .by=band) |>
    mutate(yr="2001", tipus=NA_character_)

  # --- HNT ---
  d_hnt <- hnt_2004_2010_2025_jogallas |>
    filter(year %in% c(2012, 2025)) |>
    mutate(telepules=if_else(grepl("Budapest", telepules),
                               "Budapest", telepules)) |>
    summarise(pop=sum(lakonepesseg),
              jogallas=first(jogallas),
              .by=c(year, telepules)) |>
    mutate(
      tipus=case_when(
        jogallas %in% c("község","nagyközség") ~ "község",
        TRUE ~ "város"),
      band=if_else(telepules == "Budapest", "Budapest",
                     as.character(cut(pop, brks, blabs,
                                      right=F))) |>
        factor(levels=band_lvls),
      yr=as.character(year)) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(pop),
              .by=c(yr, band, tipus))

  yr_lvls <- c("1949","1990/94","2001","2012","2025")
  d_all <- bind_rows(d_mek, d_2001, d_hnt) |>
    mutate(yr=factor(yr, levels=yr_lvls))

  # === trajectory plot ===
  make_trajectory <- function(by_type=F, size_by_pct=F) {

    if (by_type) {
      # 2001 has no tipus — drop it, then re-level so positions are contiguous
      d <- d_all |>
        filter(!is.na(tipus), tipus != "Budapest") |>
        mutate(yr=fct_drop(yr))
    } else {
      d <- d_all |>
        summarise(n=sum(n), tot=sum(tot), .by=c(yr, band)) |>
        mutate(tipus="összes")
    }

    natl <- d |> summarise(natl=sum(tot), .by=yr)
    d <- d |> left_join(natl, by="yr") |>
      mutate(
        pct=100 * tot / natl,
        szint=case_when(
          band == "Budapest"                      ~ "Budapest",
          band %in% c("50–100k","100k+")          ~ "nagyváros",
          band %in% c("5–10k","10–25k","25–50k")  ~ "kis/középváros",
          TRUE                                    ~ "falu") |>
          factor(levels=c("falu","kis/középváros",
                            "nagyváros","Budapest")),
        yr_pos=as.integer(yr),
        y=as.integer(fct_rev(band)),
        bubble_val=if (size_by_pct) pct else tot,
        inside=if (size_by_pct) sprintf("%.1f%%", pct)
                 else fmt_m(tot))

    arrows <- d |>
      arrange(band, tipus, yr_pos) |>
      group_by(band, tipus) |>
      mutate(x_end=lead(yr_pos), y_end=lead(y)) |>
      ungroup() |>
      filter(!is.na(x_end))

    max_sz <- if (by_type) 50 else 55
    w <- if (by_type) 18 else 16
    h <- 18

    x_lvls <- levels(d$yr)

    p <- ggplot(d, aes(yr_pos, y))

    if (by_type) {
      p <- p + facet_wrap(~ tipus, ncol=2)
    }

    p <- p +
      geom_segment(data=arrows,
                   aes(x=yr_pos, y=y,
                       xend=x_end, yend=y_end),
                   colour="grey70", linewidth=0.5,
                   arrow=arrow(length=unit(0.15, "inches"),
                                 type="closed"),
                   show.legend=F) +
      geom_point(aes(size=bubble_val,
                     fill=if (by_type) tipus else szint),
                 shape=21, colour="white",
                 stroke=1, alpha=0.75) +
      scale_size_area(max_size=max_sz, guide="none") +
      geom_text(aes(label=inside), size=9,
                fontface="bold") +
      geom_text(aes(label=sprintf("n=%d", n)),
                vjust=1, nudge_y=-0.35, size=8) +
      scale_x_continuous(
        breaks=seq_along(x_lvls), labels=x_lvls,
        position="top",
        expand=expansion(mult=0.12)) +
      scale_y_continuous(
        breaks=1:length(band_lvls),
        labels=rev(band_lvls),
        expand=expansion(add=0.3))

    if (by_type) {
      p <- p +
        scale_fill_manual(
          values=c("város"="#00BFC4", "község"="#F8766D"),
          guide="none")
    } else {
      p <- p +
        scale_fill_manual(
          values=c("falu"           ="#F8766D",
                     "kis/középváros" ="#C49A6C",
                     "nagyváros"      ="#7CAE9E",
                     "Budapest"       ="#00BFC4"),
          name=NULL) +
        guides(fill=guide_legend(
          override.aes=list(size=6)))
    }

    type_str <- if_else(by_type, "tipus", "osszes")
    size_str <- if_else(size_by_pct, "pct", "abs")
    sub_str  <- if (size_by_pct) {
      "Buborékméret ∝ országos népesség-részarány"
    } else "Buborékméret ∝ összlakosság"

    p <- p +
      coord_cartesian(clip="off") +
      labs(x=NULL, y=NULL,
           title="Település-kategóriák népessége, 1949–2025",
           subtitle=paste0(sub_str,
             if (by_type) paste0(
               " · község=község + nagyközség, ",
               "város=minden városi jogállás") else ""),
           caption=paste0(
             "1990/94: községek 1990, városok 1994 · ",
             "Korábbi évek: MEK · 2001–2025: KSH HNT")) +
      theme_bw(base_size=20) +
      theme(panel.grid.major.x=element_blank(),
            panel.grid.minor=element_blank(),
            axis.text.y=element_text(face="bold", size=20),
            axis.text.x.top=element_text(face="bold", size=20),
            plot.title=element_text(face="bold", size=26),
            plot.subtitle=element_text(size=16),
            plot.caption=element_text(size=14),
            strip.text=element_text(face="bold", size=20),
            panel.spacing=unit(20, "pt"))

    # conditional theme AFTER theme_bw so it doesn't get wiped
    if (by_type) {
      p <- p + theme(legend.position="none")
    } else {
      p <- p + theme(legend.position="top",
                     legend.text=element_text(size=16))
    }

    ggsave(sprintf("plots/hist/mek_trajectory_%s_%s.png",
                   type_str, size_str), p,
           width=w, height=h,
           units="in", dpi=300, bg="white")
    print(p)
  }

  make_trajectory(by_type=F, size_by_pct=F)
  make_trajectory(by_type=F, size_by_pct=T)
  make_trajectory(by_type=T,  size_by_pct=F)
  make_trajectory(by_type=T,  size_by_pct=T)
})
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### 1920 --> 2025, meretkategoriak, idosor

local({
  raw_mek <- read_csv("adatok/mek_52_53_nepesseg_meretetkategoriak.csv")
  raw_1920 <- read_csv("adatok/mek_51_nepesseg_meretetkategoriak_1910_1920.csv")

  fmt_m <- function(x) if_else(x < 0.005e6,
                                sprintf("%.3fm", x / 1e6),
                                sprintf("%.2fm", x / 1e6))

  bp_1920 <- 1233278
  band_lvls <- c("<1k","1–2k","2–5k","5–10k",">10k","Budapest")

  recode_coarse <- function(meret) case_when(
    meret == "Budapest"        ~ "Budapest",
    meret == "500 alatt"       ~ "<1k",
    meret == "500-1000"        ~ "<1k",
    meret == "1000-2000"       ~ "1–2k",
    meret == "2000-5000"       ~ "2–5k",
    meret == "5000 alatt"      ~ "2–5k",
    meret == "5000-10000"      ~ "5–10k",
    meret %in% c("10000 felett","10000-20000","10000-25000",
                 "20000 felett","25000-50000","50000-100000",
                 "100000 felett") ~ ">10k",
    TRUE ~ NA_character_)

  # --- 1920 ---
  d_1920 <- raw_1920 |>
    filter(year == 1920, meret_kategoria != "együtt") |>
    mutate(band=recode_coarse(meret_kategoria)) |>
    summarise(n=sum(n_telepules), tot=sum(nepesseg), .by=band)
  gt10k <- d_1920 |> filter(band == ">10k")
  d_1920 <- d_1920 |>
    filter(band != ">10k") |>
    bind_rows(
      tibble(band=">10k",     n=gt10k$n - 1,
             tot=gt10k$tot - bp_1920),
      tibble(band="Budapest", n=1, tot=bp_1920))
  d_1920$yr <- "1920"

  # --- 1949 & 1990/94 ---
  d_mek <- raw_mek |>
    filter(meret_kategoria != "együtt", !is.na(nepesseg)) |>
    mutate(band=recode_coarse(meret_kategoria),
           yr=if_else(year %in% c(1990, 1994),
                        "1990/94", as.character(year))) |>
    filter(!is.na(band)) |>
    summarise(n=sum(n_telepules, na.rm=T),
              tot=sum(nepesseg), .by=c(yr, band))

  # --- 2001 from hntr ---
  brks_hnt <- c(-Inf, 1e3, 2e3, 5e3, 1e4, Inf)
  blabs_hnt <- c("<1k","1–2k","2–5k","5–10k",">10k")
  d_2001 <- HNT_1990_2025 |>
    filter(year == 2001) |>
    mutate(band=if_else(
      telepules == "Budapest", "Budapest",
      as.character(cut(lakonepesseg, brks_hnt, blabs_hnt,
                       right=F)))) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(lakonepesseg), .by=band) |>
    mutate(yr="2001")

  # --- 2012 & 2025 ---
  d_hnt <- hnt_2004_2010_2025_jogallas |>
    filter(year %in% c(2012, 2025)) |>
    mutate(telepules=if_else(grepl("Budapest", telepules),
                               "Budapest", telepules)) |>
    summarise(pop=sum(lakonepesseg), .by=c(year, telepules)) |>
    mutate(band=if_else(
      telepules == "Budapest", "Budapest",
      as.character(cut(pop, brks_hnt, blabs_hnt, right=F))),
      yr=as.character(year)) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(pop), .by=c(yr, band))

  yr_lvls <- c("1920","1949","1990/94","2001","2012","2025")
  d_all <- bind_rows(d_1920, d_mek, d_2001, d_hnt) |>
    mutate(band=factor(band, levels=band_lvls),
           yr=factor(yr, levels=yr_lvls))

  make_trajectory <- function(size_by_pct=F) {
    natl <- d_all |> summarise(natl=sum(tot), .by=yr)
    d <- d_all |> left_join(natl, by="yr") |>
      mutate(
        pct=100 * tot / natl,
        szint=case_when(
          band == "Budapest" ~ "Budapest",
          band == ">10k"     ~ "város (>10k)",
          band == "5–10k"    ~ "kisváros (5–10k)",
          TRUE               ~ "falu (<5k)") |>
          factor(levels=c("falu (<5k)","kisváros (5–10k)",
                            "város (>10k)","Budapest")),
        yr_pos=as.integer(yr),
        y=as.integer(fct_rev(band)),
        bubble_val=if (size_by_pct) pct else tot,
        inside=if (size_by_pct) sprintf("%.1f%%", pct)
                 else fmt_m(tot))

    arrows <- d |>
      arrange(band, yr_pos) |>
      group_by(band) |>
      mutate(x_end=lead(yr_pos), y_end=lead(y)) |>
      ungroup() |>
      filter(!is.na(x_end))

    size_str <- if (size_by_pct) "pct" else "abs"
    sub_str  <- if (size_by_pct) {
      "Buborékméret ∝ országos népesség-részarány"
    } else "Buborékméret ∝ összlakosság"

    p <- ggplot(d, aes(yr_pos, y)) +
      geom_segment(data=arrows,
                   aes(x=yr_pos, y=y,
                       xend=x_end, yend=y_end),
                   colour="grey70", linewidth=0.5,
                   arrow=arrow(length=unit(0.15, "inches"),
                                 type="closed"),
                   show.legend=F) +
      geom_point(aes(size=bubble_val, fill=szint),
                 shape=21, colour="white",
                 stroke=1, alpha=0.75) +
      scale_size_area(max_size=60, guide="none") +
      geom_text(aes(label=inside),
                size=7, fontface="bold") +
      geom_text(aes(label=sprintf("n=%d", n)),
                vjust=1, nudge_y=-0.35, size=6) +
      scale_x_continuous(
        breaks=1:length(yr_lvls), labels=yr_lvls,
        position="top",
        expand=expansion(mult=0.1)) +
      scale_y_continuous(
        breaks=1:length(band_lvls),
        labels=rev(band_lvls),
        expand=expansion(add=0.3)) +
      scale_fill_manual(
        values=c("falu (<5k)"      ="#F8766D",
                   "kisváros (5–10k)"="#C49A6C",
                   "város (>10k)"    ="#7CAE9E",
                   "Budapest"        ="#00BFC4"),
        name=NULL) +
      guides(fill=guide_legend(
        override.aes=list(size=6))) +
      coord_cartesian(clip="off") +
      labs(x=NULL, y=NULL,
           title="Település-kategóriák népessége, 1920–2025",
           subtitle=sub_str,
           caption=paste0(
             "1920: MEK 51. táblázat · ",
             "1949, 1990/94: MEK 52–53. · ",
             "2001–2025: KSH HNT\n",
             "1990/94: községek 1990, városok 1994")) +
      theme_bw(base_size=20) +
      theme(panel.grid.major.x=element_blank(),
            panel.grid.minor=element_blank(),
            legend.position="top",
            legend.text=element_text(size=20),
            axis.text.y=element_text(face="bold", size=20),
            axis.text.x.top=element_text(face="bold", size=20),
            plot.title=element_text(face="bold", size=30),
            plot.subtitle=element_text(size=20),
            plot.caption=element_text(size=16))

    ggsave(sprintf("plots/hist/mek_trajectory_1920_%s.png",
                   size_str), p,
           width=18, height=16,
           units="in", dpi=300, bg="white")
    print(p)
  }

  make_trajectory(size_by_pct=F)
  make_trajectory(size_by_pct=T)
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# trendlines from 1920

local({
  fmt <- scales::label_number(big.mark=" ")

  band_lvls <- c("<1k","1–2k","2–5k","5–10k",">10k","Budapest")

  # Budapest on CURRENT (Nagy-Budapest) territory, 1920
  # kis-Budapest 928,996 (1920 census) + settlement ring 304,282
  # (Demográfia journal,
  # https://demografia.hu/demografia/index.php/demografia/article/download/1563/1518)
  bp_1920 <- 1233278

  # --- coarse recode for all sources ---
  recode_coarse <- function(meret) case_when(
    meret == "Budapest"        ~ "Budapest",
    meret == "500 alatt"       ~ "<1k",
    meret == "500-1000"        ~ "<1k",
    meret == "1000-2000"       ~ "1–2k",
    meret == "2000-5000"       ~ "2–5k",
    meret == "5000 alatt"      ~ "2–5k",
    meret == "5000-10000"      ~ "5–10k",
    meret %in% c("10000 felett","10000-20000","10000-25000",
                  "20000 felett","25000-50000","50000-100000","100000 felett") ~ ">10k",
    TRUE ~ NA_character_)

  # --- 1920 (MEK table 51) ---
  raw_1920 <- read_csv("adatok/mek_51_nepesseg_meretetkategoriak_1910_1920.csv")   # adjust path
  d_1920 <- raw_1920 |>
    filter(year == 1920, meret_kategoria != "együtt") |>
    mutate(band=recode_coarse(meret_kategoria)) |>
    summarise(n=sum(n_telepules), tot=sum(nepesseg), .by=band)
  # split >10k into Budapest + rest
  gt10k <- d_1920 |> filter(band == ">10k")
  d_1920 <- d_1920 |>
    filter(band != ">10k") |>
    bind_rows(
      tibble(band=">10k",     n=gt10k$n - 1, tot=gt10k$tot - bp_1920),
      tibble(band="Budapest", n=1,            tot=bp_1920))
  d_1920$yr <- "1920"

  # --- 1949 & 1990/94 (MEK tables 52-53) ---
  raw_mek <- read_csv("adatok/mek_52_53_nepesseg_meretetkategoriak.csv")
  d_mek <- raw_mek |>
    filter(meret_kategoria != "együtt", !is.na(nepesseg)) |>
    mutate(band=recode_coarse(meret_kategoria),
           yr=if_else(year %in% c(1990, 1994), "1990/94", as.character(year))) |>
    filter(!is.na(band)) |>
    summarise(n=sum(n_telepules, na.rm=TRUE), tot=sum(nepesseg), .by=c(yr, band))

    # --- 2001 from hntr ---
  d_2001 <- HNT_1990_2025 |>
    filter(year == 2001) |>
    mutate(band=if_else(
      telepules == "Budapest", "Budapest",
      as.character(cut(lakonepesseg,
                       c(-Inf, 1e3, 2e3, 5e3, 1e4, Inf),
                       c("<1k","1–2k","2–5k","5–10k",">10k"),
                       right=F)))) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(lakonepesseg), .by=band) |>
    mutate(yr="2001")
  
  # --- 2012 & 2025 (HNT) ---
  brks_hnt <- c(-Inf, 1e3, 2e3, 5e3, 1e4, Inf)
  blabs_hnt <- c("<1k","1–2k","2–5k","5–10k",">10k")
  d_hnt <- hnt_2004_2010_2025_jogallas |>
    filter(year %in% c(2012, 2025)) |>
    mutate(telepules=if_else(grepl("Budapest", telepules), "Budapest", telepules)) |>
    summarise(pop=sum(lakonepesseg), .by=c(year, telepules)) |>
    mutate(band=if_else(telepules == "Budapest", "Budapest",
                          as.character(cut(pop, brks_hnt, blabs_hnt, right=FALSE))),
           yr=as.character(year)) |>
    filter(!is.na(band)) |>
    summarise(n=n(), tot=sum(pop), .by=c(yr, band))

  # --- combine all 5 time points ---
   yr_lvls <- c("1920","1949","1990/94","2001","2012","2025")
  d_all <- bind_rows(d_1920, d_mek, d_2001, d_hnt) |>
    mutate(band=factor(band, levels=band_lvls),
           yr=factor(yr, levels=yr_lvls))

  natl <- d_all |> summarise(natl=sum(tot), .by=yr)
  d_all <- d_all |> left_join(natl, by="yr") |>
    mutate(pct=100 * tot / natl,
           szint=case_when(
             band == "Budapest" ~ "Budapest",
             band == ">10k"     ~ "város (>10k)",
             band %in% c("5–10k") ~ "kisváros (5–10k)",
             TRUE               ~ "falu (<5k)") |>
             factor(levels=c("falu (<5k)","kisváros (5–10k)","város (>10k)","Budapest")))

  # ============================================================
  # PLOT 1: bubble grid, one version per sizing (abs / pct)
  # ============================================================
  make_bubble <- function(size_by_pct=FALSE) {
    d <- d_all |> mutate(
      x=as.integer(band),
      y=1.5,
      bubble_val=if (size_by_pct) pct else tot,
      inside=if (size_by_pct) sprintf("%.1f%%", pct) else sprintf("%.2fm", tot / 1e6),
      below=case_when(
        band == "Budapest" & size_by_pct  ~ sprintf("%.2fm", tot / 1e6),
        band == "Budapest" & !size_by_pct ~ sprintf("ország\n%.1f%%-a", pct),
        size_by_pct  ~ sprintf("n=%d\n%.2fm", n, tot / 1e6),
        !size_by_pct ~ sprintf("n=%d\nország\n%.1f%%-a", n, pct)))

    size_str <- if (size_by_pct) "pct" else "abs"
    sub_str  <- if (size_by_pct) "A körök területe az országos népesség-részaránnyal arányos" else
                                 "A körök területe a kategória összlakosságával arányos"

    p <- ggplot(d, aes(x, y)) +
      facet_wrap(~ yr, ncol=3) +
      geom_point(aes(size=bubble_val, fill=szint),
                 shape=21, colour="white", stroke=1.2, alpha=0.9) +
      scale_size_area(max_size=42, guide="none") +
      geom_text(aes(label=inside), fontface="bold", size=6, colour="grey15") +
      geom_text(aes(label=below), vjust=1, nudge_y=-0.45,
                size=5, lineheight=0.88) +
      scale_x_continuous(breaks=1:length(band_lvls), labels=band_lvls,
                         position="top",
                         limits=c(0.5, length(band_lvls) + 0.5),
                         expand=expansion(0)) +
      scale_y_continuous(breaks=NULL, limits=c(0.6, 2.4), expand=expansion(0)) +
      scale_fill_manual(values=c("falu (<5k)"      ="#F8766D",
                                   "kisváros (5–10k)"="#C49A6C",
                                   "város (>10k)"    ="#7CAE9E",
                                   "Budapest"        ="#00BFC4"),
                        name=NULL) +
      guides(fill=guide_legend(override.aes=list(size=5))) +
      coord_cartesian(clip="off") +
      labs(x=NULL, y=NULL,
    title="Település-kategóriák népessége, 1920–2025",
    subtitle=sub_str,
    caption=paste0("1920: MEK 51. táblázat · 1949, 1990/94: MEK 52–53. táblázat",
        " · 2012, 2025: KSH HNT\n1990/94: községek 1990, városok 1994")) +
      theme_bw() +
      theme(panel.grid=element_blank(),
            legend.position="top",
            legend.text=element_text(size=16),
            axis.text.x.top=element_text(face="bold", size=16),
            axis.text.y=element_text(face="bold", size=16),
            plot.title=element_text(face="bold", size=20),
            plot.subtitle=element_text(size=13),
            plot.caption=element_text(size=13),
            strip.text=element_text(face="bold", size=18),
            panel.spacing=unit(16, "pt"))

    ggsave(sprintf("plots/hist/mek_bubble_1920_2025_%s.png", size_str), p,
           width=18, height=10, units="in", dpi=300, bg="white")
    print(p)
  }

  make_bubble(size_by_pct=FALSE)
  make_bubble(size_by_pct=TRUE)

  # ============================================================
  # PLOT 2: multi-panel trend (each panel=one size band)
  # ============================================================
  make_trend <- function(show_pct=TRUE) {
    d <- d_all |> mutate(
      yr_num=as.integer(as.character(ifelse(yr == "1990/94", "1992", as.character(yr)))),
      value=if (show_pct) pct else tot / 1e6)

    ends <- d |> filter(yr_num %in% range(yr_num)) |>
      mutate(lab=if (show_pct) sprintf("%.1f%%", value) else sprintf("%.2fm", value),
             hj=if_else(yr_num == min(yr_num), 0.15, 0.85))

    ylab <- if (show_pct) "Az ország %-ában" else "Lakónépesség (millió fő)"
    val_str <- if (show_pct) "pct" else "abs"

    p <- ggplot(d, aes(yr_num, value, colour=szint)) +
      facet_wrap(~ band, ncol=3) + # scales="free_y",
      geom_line(linewidth=1) + geom_point(size=2.2) +
      geom_point(data=ends, shape=21, aes(fill=szint),
                 colour="black", stroke=0.7, size=3.5) +
      geom_text(data=ends, aes(label=lab, hjust=hj),
                vjust=-1.2, size=6, fontface="bold", show.legend=FALSE) +
      scale_x_continuous(breaks=c(1920, 1949, 1992, 2001, 2012, 2025),
                         labels=c("1920","1949","1990/94", "2001","2012","2025"),
                         expand=expansion(mult=0.15)) +
      scale_y_continuous(expand=expansion(mult=0.2)) +
      scale_colour_manual(values=c("falu (<5k)"      ="#F8766D",
                                     "kisváros (5–10k)"="#C49A6C",
                                     "város (>10k)"    ="#7CAE9E",
                                     "Budapest"        ="#00BFC4"),
                          guide="none") +
      scale_fill_manual(values=c("falu (<5k)"      ="#F8766D",
                                   "kisváros (5–10k)"="#C49A6C",
                                   "város (>10k)"    ="#7CAE9E",
                                   "Budapest"        ="#00BFC4"),
                        guide="none") +
      labs(x=NULL, y=ylab,
           title="Település-kategóriák népessége, 1920–2025",
           subtitle="Méretkategóriánkénti idősor · Budapest a >10k kategóriából kiemelve",
           caption="1920: MEK 51. táblázat · 1949, 1990/94: MEK 52–53. · 2012, 2025: KSH HNT") +
      theme_bw(base_size=14) +
      theme(
            strip.text=element_text(face="bold", size=20),
            legend.text=element_text(size=16),
            axis.text.x=element_text(face="bold", size=16),
            axis.text.y=element_text(face="bold", size=16),
            plot.title=element_text(face="bold", size=20),
            plot.subtitle=element_text(size=13),
            plot.caption=element_text(size=13),
            
            panel.spacing=unit(14, "pt"))

    ggsave(sprintf("plots/hist/mek_trend_1920_2025_%s.png", val_str), p,
           width=16, height=10, units="in", dpi=300, bg="white")
    print(p)
  }

  make_trend(show_pct=TRUE)
  make_trend(show_pct=FALSE)
})