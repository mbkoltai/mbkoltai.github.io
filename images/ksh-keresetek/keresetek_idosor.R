# KSH keresetek — time-series plots from the tidy long CSV
# (date | type | value | period), produced by ksh_parse.py

# steps to extract new data
# 1) download the html like https://www.ksh.hu/gyorstajekoztatok/ker/ker2605.html
# [or run: 
# source ~/ksh-venv/bin/activate
# python3 -c "from ksh_keresetek import download; download()"
# ]
# 2) python3 ksh_keresetek.py

rm(list=ls())
lapply(c("tidyverse","ggplot2","scales","plotly","htmlwidgets"), \(x) library(x, character.only=T) )
# library(stringr)
standard_theme <- theme(plot.title=element_text(hjust=0.5,size=20),
                        axis.text.x=element_text(size=14),
                        axis.text.y=element_text(size=14),
                        axis.title.x=element_text(size=17),
                        axis.title.y=element_text(size=17),
                        strip.text=element_text(size=18),
                        text=element_text(family="Calibri"),
                        panel.grid.minor=element_blank(),
                        legend.text=element_text(size=13))

# KSH keresetek — time-series plots from the tidy long CSV
# (date | type | value | period), produced by ksh_parse.py
#
#   install.packages(c("dplyr","tidyr","stringr","ggplot2","scales"))
#   Rscript ksh_plot.R

# LOAD DATA
dat <- read_csv("ksh_keresetek_long.csv", show_col_types=FALSE) |>
  mutate(date=as.Date(paste0(date, "-01")))   # "2026-05" -> 2026-05-01

# ------------------------------------------------------------------ Plot 1 --
# df_atlag_median figures: two panels (gross | net), mean vs median by colour.
df_atlag_median <- dat |>
  filter(measure %in% c("atlag", "median", "rendsz"),
         scope == "nemzetgazdasag",
         is.na(netto_koncepcio) | netto_koncepcio != "kedvezmeny_nelkul") |>
  mutate(
    metric = case_when(measure == "atlag"  ~ "Átlag (teljes)",
                       measure == "rendsz" ~ "Átlag (rendszeres)",
                       measure == "median" ~ "Medián"
      ),
    tax    = factor(if_else(tax == "brutto", "Bruttó", "Nettó"),
                    levels = c("Bruttó", "Nettó"))
  )

# MAKE THE PLOT
df_atlag_median <- dat |>
  filter(measure %in% c("atlag", "median", "rendsz"),
         scope == "nemzetgazdasag") |>
  mutate(
    metric = case_when(
      measure == "rendsz"                            ~ "Átlag (rendszeres)",
      measure == "median"                            ~ "Medián",
      measure == "atlag" & tax == "brutto"           ~ "Átlag (teljes)",
      # kedvezmeny_nelkul ends 2025-02; the rest (kedvezmennyel + the
      # post-revision unified series) are one continuous with-credits line
      netto_koncepcio %in% "kedvezmeny_nelkul" ~ "Átlag (kedvezmény nélkül)",
      TRUE                                           ~ "Átlag (kedvezménnyel)"
    ),
    metric = factor(metric, levels = c("Átlag (teljes)", "Átlag (kedvezménnyel)",
                                       "Átlag (kedvezmény nélkül)",
                                       "Átlag (rendszeres)", "Medián")),
    tax = factor(if_else(tax == "brutto", "Bruttó", "Nettó"),
                 levels = c("Bruttó", "Nettó"))
  )

### ### ### ### 

# RENDER PLOT
p1 <- ggplot(df_atlag_median,
             aes(date, value/1e3, colour = metric,
                 text = paste0(format(date, "%Y. %m."), "<br>",
                               metric, " (", tax, ")<br>",
                               sub("\\.", ",", sprintf("%.1f", value/1e3)),
                               " ezer Ft/fő/hó"))) +
  geom_line(aes(group = metric), linewidth = 0.6) +
  geom_point(size = 1.1) +
  facet_wrap(~tax) +
  scale_x_date(date_breaks = "3 months", date_labels = "%Y-%m", expand = 0.08) +
  scale_y_continuous(labels = label_number(big.mark = " ", accuracy = 1),
                     breaks = 0:20*50) +
  scale_colour_manual(values = c(
    "Átlag (teljes)"            = "#C0504D",
    "Átlag (kedvezménnyel)"     = "#C0504D",
    "Átlag (kedvezmény nélkül)" = "#E39B99",
    "Átlag (rendszeres)"        = "tomato1",
    "Medián"                    = "#4A7EBB"), drop = FALSE) +
  labs(title = "Teljes munkaidős keresetek – átlag és medián",
       x = NULL, y = "ezer Ft / fő / hó", colour = NULL) +
  theme_bw() + standard_theme +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top")
p1

# SAVE
ggsave(plot = p1, "plots/ksh_df_atlag_median.png", width=10, height=7, dpi=150)
write_csv(df_atlag_median,file = "plots/ksh_df_atlag_median.csv")

# PLOTLY
p_ply <- ggplotly(p1 + theme(plot.margin = margin(t = 10, r=30, b = 20, l = 30)), 
  tooltip = "text") |>
  layout(legend = list(orientation = "h", y = -0.2, x = 0),
         margin = list(b = 90),
         annotations = list(text = "KSH, havi adatok",
                            showarrow = FALSE, xref = "paper", yref = "paper",
                            x = 1, y = -0.28, xanchor = "right",
                            margin = list(b = 90, l = 200, r = 60, t = 60),
                            font = list(size = 10, color = "grey40"))
    )

p_ply$x$layout$shapes <- lapply(
  grep("^xaxis", names(p_ply$x$layout), value = TRUE), function(a) {
  dom <- p_ply$x$layout[[a]]$domain
  list(type = "rect", xref = "paper", yref = "paper",
       x0 = dom[1], x1 = dom[2], 
       y0 = p_ply$x$layout$yaxis$domain[1], y1 = p_ply$x$layout$yaxis$domain[2],
       line = list(color = "black", width = 1),
       fillcolor = "rgba(0,0,0,0)", layer = "above")
})
p_ply
# SAVE
saveWidget(p_ply, "plots/atlag_median_keresetek.html", selfcontained = TRUE)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Plot 2
# Quintile means: five panels, points shaped by reference period.

# lets work out the monthly quintile figures where they are cumulated
quint <- local({
  df <- dat %>%
    filter(str_detect(measure, "kvintilis")) %>%
    rename(type = measure)

  quintile_processed <- df %>%
    filter(str_detect(type, "kvintilis"), year(date) == 2025) %>%
    mutate( mon = month(date) ) %>%
    arrange(type, date) %>%
    group_by(type) %>%
    mutate(
      value_orig = value,
      orig_period = period,
      value = ifelse(
        orig_period == "monthly",
        value,
        mon * value - lag(mon, default = 0) * lag(value, default = 0)
      ),
      value_cumul = ifelse(orig_period == "cumulative", value_orig, NA_real_),
      period = "monthly",
      `adat forrás` = ifelse(orig_period == "cumulative", "számítás", "adat")
    ) %>%
    ungroup() %>%
    select(date, type, value, value_cumul, period, `adat forrás`) %>%
    distinct()

  quintile_2026 <- df %>%
    filter(str_detect(type, "kvintilis"), year(date) == 2026) %>%
    mutate(value_cumul = NA_real_, `adat forrás` = "adat") %>%
    select(date, type, value, value_cumul, period, `adat forrás`)

  quintile_combined <- bind_rows(quintile_processed, quintile_2026)

  df %>%
    filter(!((year(date) == 2025 | year(date) == 2026) & str_detect(type, "kvintilis"))) %>%
    bind_rows(quintile_combined) %>%
    arrange(date, type) %>%
    filter(str_detect(type, "kvintilis")) %>%
    relocate(c(value,value_cumul),.after = last_col())

})

# MAKE PLOT
# Reshape to long format for plotting both series
quint_long <- quint %>%
  mutate(type = gsub("kvintilis_(\\d+)", "\\1. kvintilis", type)) %>%
  pivot_longer(cols = c(value, value_cumul),
               names_to = "source",
               values_to = "earnings") %>%
  filter(!is.na(earnings)) %>%
  mutate(
    `adat forrás`=ifelse(grepl("cumul",source),"adat",`adat forrás`),
    source = case_when(
      source == "value" ~ "havi",
      source == "value_cumul" ~ "kumulált" ),
    shape_key = case_when(
      source == "havi" & `adat forrás` == "adat" ~ "Havi (adat)",
      source == "havi" & `adat forrás` == "számítás" ~ "Havi (becsült)",
      source == "kumulált" ~ "Kumulált (adat)",
      # source == "Év eleji kumulált" & `adat forrás` == számítás ~ "Kumulált (becsült)",
      TRUE ~ NA_character_ ) 
    )

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# MAKE PLOT

# Note: 2026-01: "fegyverpénz" - torzito hatas!
# a real monthly value, but an outlier for trend reading (esp. Q5).

p2 <- quint_long %>% filter(grepl("havi",source)) %>%
ggplot(aes(x=date,y=earnings/1e3,fill=`adat forrás`)) +
  geom_line(aes(group = interaction(type, source), fill = NULL),
            linewidth = 0.4, linetype = "dashed") +
  geom_point(shape = 21, size = 3, stroke = 1/2, alpha =2/3) +  # shape=21 supports fill
  facet_wrap(~type, nrow=2, scales = "free_y", axes = "all_x") +
  scale_x_date(breaks = seq(min(quint_long$date), max(quint_long$date), by = "3 months"),
              date_labels = "%y/%m") +
  scale_y_continuous(labels = label_number(big.mark = " ", accuracy = 1),expand = 0.15) + # 
  scale_fill_manual(values = c(
    "adat" = "dodgerblue3",     # blue filled
    "számítás" = "tomato3"), na.translate = F) +
  labs(title = "Bruttó kereseti kvintilisek",
       caption = "Kék=nyers adat, piros=kumulatívából kikövetkeztetett",
       x = NULL, y = "ezer Ft / fő / hó",
       fill = "adat forrás") +
  theme_bw() +
  theme(# axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        legend.title = element_text(size = 14),
        plot.caption = element_text(size = 11),
        strip.background = element_rect(fill = "grey90")) +
  standard_theme
p2

# SAVE
ggsave("plots/ksh_quintiles.png", p2, width=13, height=8, dpi=150)
write_csv(quint_long %>% filter(grepl("havi",source)), file = "plots/ksh_quintiles.csv")

# SAME PLOT AS PLOTLY

p2_ply <- ggplotly(
  p2 + theme(panel.spacing=unit(0.4, "lines"),
    plot.margin=margin(t=15, r=30, b=20, l=30)) + 
    aes(text=paste0(format(date, "%y/%m"), " | ", type, "<br>",
               format(round(earnings/1e3), big.mark=""),
              " ezer Ft/fő/hó<br>" )), # `adat forrás`
  tooltip="text") # |>

p2_ply <- local({
  
  p2_ply <- tighten_panels(p2_ply, gap=0.05)

# frame every panel (works here: free_y -> one y-axis per facet)
for (nm in grep("^[xy]axis", names(p2_ply$x$layout), value=TRUE)) {
  p2_ply$x$layout[[nm]]$showline  <- TRUE
  p2_ply$x$layout[[nm]]$mirror    <- TRUE
  p2_ply$x$layout[[nm]]$linecolor <- "black"
  p2_ply$x$layout[[nm]]$linewidth <- 1
}

yax <- grep("^yaxis", names(p2_ply$x$layout), value = TRUE)
xax <- grep("^xaxis", names(p2_ply$x$layout), value = TRUE)
xdoms <- lapply(xax, function(a) p2_ply$x$layout[[a]]$domain)

edges <- list()
for (a in yax) {
  yd <- p2_ply$x$layout[[a]]$domain
  if (yd[1] <= 0.5) next                       # bottom row already has its axis
  # this panel's horizontal extent = the x-domain it overlaps
  xa <- sub("^y", "x", a)
  xd <- if (!is.null(p2_ply$x$layout[[xa]])) p2_ply$x$layout[[xa]]$domain else xdoms[[1]]
  edges[[length(edges) + 1]] <- list(
    type = "line", xref = "paper", yref = "paper",
    x0 = xd[1], x1 = xd[2], y0 = yd[1], y1 = yd[1],
    line = list(color = "black", width = 1), layer = "above")
}
p2_ply$x$layout$shapes <- c(p2_ply$x$layout$shapes, edges)
p2_ply
})

# SAVE
saveWidget(p2_ply, "plots/kvintilisek.html", selfcontained = TRUE)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# eloszlások (kvintilisek) idő szerint csoportosítva

p3 <- quint_long %>%
  filter(grepl("havi", source)) %>%
  mutate(qnum=as.integer(str_extract(type, "\\d")),
         qnum=qnum + rescale(as.numeric(date), to=c(-0.45, 0.45))) %>%
  ggplot(aes(x=qnum, y=earnings/1e3, group=date, colour=date,
             text=paste0(format(date, "%Y. %m."), "<br>", type, "<br>",
                           sub("\\.", ",", sprintf("%.0f", earnings/1e3)),
                           " ezer Ft/fő/hó<br>", `adat forrás`))) +
  geom_line(aes(group=type), linewidth=0.5) +
  geom_point(aes(shape=`adat forrás`), size=3, fill=NA, stroke=0.5) +
  scale_x_continuous(breaks=1:5, labels=paste0("Q", 1:5), expand=0.01) +
  scale_y_log10(breaks=c(3e5,4e5,5e5,0.75e6,1e6,1.25e6,1.5e6,1.75e6,2e6)/1e3) +
  scale_shape_manual(values=c("adat"=21, "számítás"=24)) +
  geom_vline(xintercept=1:4 + 1/2) +
  labs(title="A bruttó keresetek eloszlása kvintilisenként, havonta",
       x=NULL, y="ezer Ft / fő / hó (logaritmikus)", colour="Hónap") +
  theme_bw() + standard_theme +
  theme(plot.margin=margin(t=10, r=30, b=10, l=30))
# SAVE
ggsave(plot=p3,"plots/ksh_quintiles_groupedquint.png",
  width=13,height=8,dpi=150)
# CSV
quint_long %>%
  filter(grepl("havi", source)) %>%
  mutate(qnum=as.integer(str_extract(type, "\\d")),
         qnum=qnum + rescale(as.numeric(date), to=c(-0.45, 0.45))) %>% 
  write_csv("plots/ksh_quintiles_groupedquint.csv")


# PLOTLY
p3_ply <- local({
  p3_ply <- ggplotly(p3, tooltip="text")

for (nm in grep("^[xy]axis", names(p3_ply$x$layout), value=T)) {
  p3_ply$x$layout[[nm]]$showline  <- T
  p3_ply$x$layout[[nm]]$mirror    <- T
  p3_ply$x$layout[[nm]]$linecolor <- "black"
  p3_ply$x$layout[[nm]]$linewidth <- 1
}
  p3_ply
})
p3_ply

# SAVE
saveWidget(p3_ply, "plots/ksh_quintiles_groupedquint.html", selfcontained=T)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# nemzetgazd kategóriák szerint (állam/vállalat/nonprofit)

pA <- local({
  scope_A <- c(
  # nemzetgazdasag = "Nemzetgazdaság összesen",
  vallalkozas    = "Vállalkozás",
  koltsegvetes   = "Költségvetés",
  nonprofit      = "Nonprofit",
  # kozfoglalk     = "Közfoglalkoztatottak",
  nem_kozfoglalk = "Nem közfoglalkoztatottak")

df_A <- dat |>
  filter(scope %in% names(scope_A),
         # keep the headline (with-credits) net; drop the parallel pre-2025-03
         # "kedvezmény nélkül" series so each panel has one net line
         is.na(netto_koncepcio) | netto_koncepcio != "kedvezmeny_nelkul") |>
  mutate(
    sorozat = case_when(
      measure == "atlag"  & tax == "brutto" ~ "Bruttó teljes átlag",
      measure == "atlag"  & tax == "netto"  ~ "Nettó átlag",
      measure == "rendsz"                   ~ "Bruttó rendszeres átlag"
      # measure == "median" & tax == "brutto" ~ "Bruttó medián",
      # measure == "median" & tax == "netto"  ~ "Nettó medián"
      ),
    sorozat = factor(sorozat, levels = c(
      "Bruttó teljes átlag", "Bruttó rendszeres átlag", "Nettó átlag" # , 
      # "Bruttó medián", "Nettó medián"
      )),
    scope = factor(scope_A[scope], levels = scope_A))

pA <- df_A |> 
  mutate(value=ifelse(date==ym("2026-01") & 
    scope %in% "Költségvetés",NA,value)) %>%
  ggplot(aes(date, value/1e3, colour = sorozat)) +
  
  geom_line(linewidth = 0.5) +
  geom_point(size = 1.2) +
  facet_wrap(~scope,nrow=2) + # ,scales="free_y"
  scale_x_date(breaks = seq(min(df_A$date), max(df_A$date), by="3 months"),
               date_labels = "%y/%m", expand = expansion(mult = 0.05)) +
  scale_y_continuous(labels=label_number(big.mark = " ", accuracy=1) ) + # limits=c(0,1e3)
  scale_colour_manual(values = c(
    "Bruttó teljes átlag"            = "#C0504D",
    "Bruttó rendszeres átlag" = "tomato1",
    "Bruttó medián"           = "#4A7EBB",
    "Nettó átlag"             = "#7E3B39",
    "Nettó medián"            = "#2E5580"), drop = FALSE) +
  labs(title = "Keresetek nemzetgazdasági kategóriánként",
      caption = "2026/01: fegyverpénz miatt a költségvetési szektor adat kb. 2x-re ugrott, nem mutatjuk",
       x = NULL, y = "ezer Ft / fő / hó", colour = NULL) +
  theme_bw() + standard_theme +
  theme(# axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        strip.background = element_rect(fill = "grey90"))


# SAVE
ggsave(plot=pA,"plots/nemzetgazd_kateg.png",
  width=13,height=8,dpi=150)
# CSV
df_A |> 
  mutate(value=ifelse(date==ym("2026-01") & 
    scope %in% "Költségvetés",NA,value)) %>%
write_csv(file = "plots/nemzetgazd_kateg.csv")

return(pA)
})
pA

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# create plotly

pA_ply <- local({
  p <- pA +
    # explicit group: the per-row `text` string otherwise shatters the lines
    geom_line(aes(group = sorozat), linewidth = 0.5) +
    aes(text = paste0(format(date, "%Y. %m."), "<br>",
                      scope, "<br>", sorozat, "<br>",
                      sub("\\.", ",", sprintf("%.0f", value/1e3)),
                      " ezer Ft/fő/hó")) +
    theme(plot.margin = margin(t = 15, r = 30, b = 10, l = 30))

  gp <- ggplotly(p, tooltip = "text") |>
     plotly::layout(
      legend = list(orientation = "h", y = -0.08, x = 0),
      margin = list(b = 55, l = 90, r = 40, t = 90),
      title  = list(y = 0.98, yanchor = "top"),
      annotations = list(
  text = "2026/01: fegyverpénz miatt a költségvetési szektor adata kb. 2x-re ugrott, nem mutatjuk",
        showarrow = FALSE, xref = "paper", yref = "paper",
        x = 1, y = -0.26, xanchor = "right",
        font = list(size = 10, color = "grey40")))

  # axis lines where they exist
  for (nm in grep("^[xy]axis", names(gp$x$layout), value = TRUE)) {
    gp$x$layout[[nm]]$showline  <- TRUE
    gp$x$layout[[nm]]$mirror    <- TRUE
    gp$x$layout[[nm]]$linecolor <- "black"
    gp$x$layout[[nm]]$linewidth <- 1
  }

  # full box on every panel: all (x-domain × y-domain) combinations
  xax <- grep("^xaxis", names(gp$x$layout), value = TRUE)
  yax <- grep("^yaxis", names(gp$x$layout), value = TRUE)
  boxes <- list()
  for (a in yax) for (b in xax) {
    yd <- gp$x$layout[[a]]$domain; xd <- gp$x$layout[[b]]$domain
    boxes[[length(boxes) + 1]] <- list(
      type = "rect", xref = "paper", yref = "paper",
      x0 = xd[1], x1 = xd[2], y0 = yd[1], y1 = yd[2],
      line = list(color = "black", width = 1),
      fillcolor = "rgba(0,0,0,0)", layer = "above")
  }
  gp$x$layout$shapes <- boxes
  gp
})
pA_ply

# SAVE
saveWidget(pA_ply, "plots/nemzetgazd_kateg.html", selfcontained=T)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ÁGAZATOK SZERINT

pB <- local({
  scope_B <- c(
    penzugyi_szolgaltatas                = "Pénzügyi szolgáltatás",
    energiaipar                          = "Energiaipar",
    tavkozles_es_it_szolgaltatas         = "Távközlés és IT-szolgáltatás",
    tartalomszolgaltatas                 = "Tartalomszolgáltatás",
    tudomanyos_muszaki_tevekenyseg       = "Tudományos és műszaki tevékenység",
    tudomanyos_es_muszaki_tevekenyseg    = "Tudományos és műszaki tevékenység",
    banyaszat                            = "Bányászat",
    kozigazgatas                         = "Közigazgatás",
    egeszsegugyi_szocialis_ellatas       = "Egészségügy, szociális ellátás",
    egeszsegugy_szocialis_ellatas        = "Egészségügy, szociális ellátás",
    feldolgozoipar                       = "Feldolgozóipar",
    oktatas                              = "Oktatás",
    muveszet_szabadido                   = "Művészet, sport, szabadidő",
    muveszet_sport_szabadido             = "Művészet, sport, szabadidő",
    szallitas_raktarozas                 = "Szállítás, raktározás",
    kereskedelem                         = "Kereskedelem",
    viz_es_hulladekgazdalkodas           = "Víz- és hulladékgazdálkodás",
    ingatlanugyletek                     = "Ingatlanügyletek",
    adminisztrativ_szolgaltatasok        = "Adminisztratív szolgáltatás",
    adminisztrativ_szolgaltatas          = "Adminisztratív szolgáltatás",
    epitoipar                            = "Építőipar",
    egyeb_szolgaltatas                   = "Egyéb szolgáltatás",
    mezogazdasag                         = "Mezőgazdaság",
    szallashely_szolgaltatas_vendeglatas = "Szálláshely-szolgáltatás, vendéglátás")

  base <- dat |> filter(measure == "atlag", tax == "brutto")

  # each sector's own series
  sajat <- base |>
    filter(scope %in% names(scope_B)) |>
    mutate(agazat = scope_B[scope], sorozat = "saját ág")

  # the old TEÁOR'08 aggregate, copied into BOTH successor panels as history
  elozmeny <- base |>
    filter(scope == "informacio_kommunikacio") |>
    tidyr::crossing(agazat = c("Távközlés és IT-szolgáltatás",
                               "Tartalomszolgáltatás")) |>
    mutate(sorozat = "Információ, kommunikáció (TEÁOR'08)")

  df_B <- bind_rows(sajat, elozmeny) |>
    mutate(
      # 2026/01: fegyverpénz -> Közigazgatás ~2 276 ezer Ft, kitakarva
      value   = ifelse(date == ym("2026-01") & agazat == "Közigazgatás",
                       NA, value),
      sorozat = factor(sorozat, levels = c("saját ág",
                                           "Információ, kommunikáció (TEÁOR'08)")))

  # panels ordered by the most recent value, high -> low (own series only)
  ord <- df_B |> filter(sorozat == "saját ág") |>
    group_by(agazat) |>
    filter(date == max(date)) |>
    summarise(v = max(value, na.rm = TRUE)) |>
    arrange(desc(v)) |> pull(agazat)
  
  df_B <- df_B |> mutate(agazat = factor(agazat, levels = ord))

  ggplot(df_B, aes(date, value/1e3, colour = sorozat, group = sorozat)) +
    geom_line(linewidth = 0.5) +
    geom_point(size = 0.9) +
    facet_wrap(~agazat, nrow = 3,
               labeller = labeller(agazat = function(x) str_wrap(x, 21))) +
    scale_x_date(breaks = seq(min(df_B$date), max(df_B$date), by = "6 months"),
                 date_labels = "%y/%m", expand = expansion(mult = 0.05)) +
    scale_y_continuous(labels = label_number(big.mark = " ", accuracy = 1)) +
    scale_colour_manual(
      values = c("saját ág" = "#C0504D",
                 "Információ, kommunikáció (TEÁOR'08)" = "grey55"),
      breaks = "Információ, kommunikáció (TEÁOR'08)", name = NULL) +
    labs(title = "Bruttó átlagkereset nemzetgazdasági áganként",
         caption = "KSH, havi adatok, közfoglalkoztatottak nélkül.
      2026/04-től TEÁOR'25: az „Információ, kommunikáció” kettévált
      „Távközlés és IT-szolgáltatás” és „Tartalomszolgáltatás” ágra;
      a szürke vonal a közös előzményük (2026/03-ig).
      2026/01: a fegyverpénz miatt kiugró közigazgatási adatot nem mutatjuk.",
         x = NULL, y = "ezer Ft / fő / hó") +
    theme_bw() + standard_theme +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = "top",
          strip.background = element_rect(fill = "grey90"),
          strip.text = element_text(size =17))
  # SAVE
  ggsave("plots/nemzetgazd_agak.png", width = 20, height = 10, dpi = 150) # plot = pB, 
  # CSV
  write_csv(df_B,file = "plots/nemzetgazd_agak.csv")
})
pB

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# PLOTLY
pB_ply <- local({
  p <- pB +
    aes(text = paste0(format(date, "%Y. %m."), "<br>",
                      agazat, "<br>",
                      sub("\\.", ",", sprintf("%.0f", value/1e3)),
                      " ezer Ft/fő/hó",
                      ifelse(sorozat == "saját ágazat", "",
                             "<br>(Információ, kommunikáció, TEÁOR'08)"))) +
    theme(plot.margin = margin(t = 15, r = 30, b = 10, l = 30),
          strip.text = element_text(size = 13))

  gp <- ggplotly(p, tooltip = "text") |>
    plotly::layout(
      legend = list(orientation = "h", y = -0.10, x = 0),
      margin = list(b = 80, l = 90, r = 40, t = 90),
      title  = list(y = 0.99, yanchor = "top"),
      annotations = list(
        text = "KSH, havi adatok, közfoglalkoztatottak nélkül. 
        2026/04-től TEÁOR'25; a szürke vonal a két utódág közös előzménye. 
        2026/01: a fegyverpénz miatt kiugró közigazgatási adatot nem mutatjuk.",
        showarrow = FALSE, xref = "paper", yref = "paper",
        x = 1, y = -0.16, xanchor = "right",
        font = list(size = 10, color = "grey40")))

  # ---- axis lines -------------------------------------------------------
  for (nm in grep("^[xy]axis", names(gp$x$layout), value = TRUE)) {
    gp$x$layout[[nm]]$showline  <- TRUE
    gp$x$layout[[nm]]$mirror    <- TRUE
    gp$x$layout[[nm]]$linecolor <- "black"
    gp$x$layout[[nm]]$linewidth <- 1
  }

  # ---- capture ORIGINAL domains before moving anything -------------------
  xax <- grep("^xaxis", names(gp$x$layout), value = TRUE)
  yax <- grep("^yaxis", names(gp$x$layout), value = TRUE)
  ox  <- setNames(lapply(xax, function(a) gp$x$layout[[a]]$domain), xax)
  oy  <- setNames(lapply(yax, function(a) gp$x$layout[[a]]$domain), yax)

  xgap <- 0.012      # <- gap between columns
  ygap <- 0.10       # <- gap between rows
  strip_pad <- 0.004 # <- gap between a panel's top and its own strip

  # ---- retile columns ---------------------------------------------------
  cols <- sort(unique(round(sapply(ox, `[`, 1), 6)))
  L <- min(sapply(ox, `[`, 1)); R <- max(sapply(ox, `[`, 2))
  w <- (R - L - xgap * (length(cols) - 1)) / length(cols)
  for (a in xax) {
    k  <- match(round(ox[[a]][1], 6), cols)
    x0 <- L + (k - 1) * (w + xgap)
    gp$x$layout[[a]]$domain <- c(x0, x0 + w)
  }

  # ---- retile rows ------------------------------------------------------
  rows <- sort(unique(round(sapply(oy, `[`, 1), 6)), decreasing = TRUE)
  B <- min(sapply(oy, `[`, 1)); T <- max(sapply(oy, `[`, 2))
  h <- (T - B - ygap * (length(rows) - 1)) / length(rows)
  for (a in yax) {
    k  <- match(round(oy[[a]][1], 6), rows)
    y1 <- T - (k - 1) * (h + ygap)
    gp$x$layout[[a]]$domain <- c(y1 - h, y1)
  }

  # ---- place each strip label exactly on top of its OWN panel ------------
  strip_labs <- unique(str_wrap(levels(pB$data$agazat), 21))
  occupied <- list()
  gp$x$layout$annotations <- lapply(gp$x$layout$annotations, function(an) {
    
    # an$bgcolor <- "rgba(217,217,217,1)"
    # an$borderpad <- 4
    
    if (is.null(an$text) || !(an$text %in% strip_labs)) return(an)
    # column: the x-axis whose ORIGINAL domain contains this label's x
    cx <- xax[which.min(sapply(ox, function(d) abs(mean(d) - an$x)))]
    # row: the y-axis whose ORIGINAL top is the nearest one below the label
    tops <- sapply(oy, `[`, 2)
    d <- an$y - tops; d[d < -1e-9] <- Inf
    ry <- yax[which.min(d)]
    occupied[[length(occupied) + 1]] <<- c(cx, ry)
    an$x <- mean(gp$x$layout[[cx]]$domain)
    an$y <- gp$x$layout[[ry]]$domain[2] + strip_pad
    an$xanchor <- "center"; an$yanchor <- "bottom"
    an
  })

    # drop ggplotly's grey strip rectangles (their sizes don't follow the
  # retiled panels; the black panel frames already delimit each facet)
  keep <- vapply(gp$x$layout$shapes, function(s) {
    !(identical(s$type, "rect") &&
      !is.null(s$fillcolor) && grepl("^rgba\\(217|^rgba\\(204|grey|#d9d9d9|#cccccc",
                                     tolower(paste(s$fillcolor, collapse = ""))))
  }, logical(1))
  # gp$x$layout$shapes <- gp$x$layout$shapes[keep]
  gp$x$layout$shapes <- list()     # clear everything, then append boxes
    
  # ---- frame only the cells that actually hold a panel -------------------
  boxes <- list()
  for (p_ in occupied) {
    xd <- gp$x$layout[[p_[1]]]$domain
    yd <- gp$x$layout[[p_[2]]]$domain
    boxes[[length(boxes) + 1]] <- list(
      type = "rect", xref = "paper", yref = "paper",
      x0 = xd[1], x1 = xd[2], y0 = yd[1], y1 = yd[2],
      line = list(color = "black", width = 1),
      fillcolor = "rgba(0,0,0,0)", layer = "above")
  }
  # APPEND, so the grey strip backgrounds survive
  gp$x$layout$shapes <- c(gp$x$layout$shapes, boxes)
  gp
})
pB_ply

saveWidget(pB_ply, "plots/nemzetgazd_agak.html", selfcontained = TRUE)
