# pull everything from 1991 from 
# https://www.ksh.hu/apps/hntr.telepules?p_lang=HU&p_id=18847

library(tidyverse); library(rvest); library(httr)

hu_hnt_lakonepesseg_2012_2025 <- read_csv("adatok/hu_hnt_lakonepesseg_2012_2025.csv")
HNT_1990_2025 <- read_csv("adatok/HNT_1990_2025.csv")

# 1. get the complete, de-duplicated list of settlement codes you already have

if (!exists("HNT_1990_2025")) {
  
local({
  ids <- hu_hnt_lakonepesseg_2012_2025 |>
  filter(year == 2025) |>
  distinct(ksh_kod, telepules) |>
  mutate(p_id=as.integer(ksh_kod))     # or str_remove leading zeros if needed

base <- "https://www.ksh.hu/apps/hntr.telepules?p_lang=HU&p_id=%d"
dir.create("adatok/cache_hntr", showWarnings=FALSE)

# 2. download each settlement's history page (cached, resumable, polite)
#    robots blocks *bots*; a normal browser UA + slow rate is the workaround
ua <- user_agent("Mozilla/5.0 (research; contact: you@email)")
for (i in seq_len(nrow(ids))) { # 1:5
  id <- ids$p_id[i]
  f <- sprintf("adatok/cache_hntr/%d.html", id)
  if (file.exists(f) && file.size(f) > 3000) next
  r <- possibly(~GET(sprintf(base, id), ua, timeout(30)), NULL)()
  if (!is.null(r) && status_code(r) == 200 && length(r$content) > 3000)
    writeBin(r$content, f)
  Sys.sleep(1)
  if (i %% 50 == 0) cat(i, "/", nrow(ids), "\n")
}

# 3. parse one page -> long tibble (year × settlement)
read_hist <- function(f) {
  id <- as.integer(str_extract(basename(f), "\\d+"))
  html <- read_html(iconv(rawToChar(readBin(f, "raw", file.size(f))),
                          "ISO-8859-2", "UTF-8"), encoding="UTF-8")
  # the year table is the one with an "Időpont" header
  tabs <- html_table(html, fill=TRUE)
  tab <- tabs[[which(map_lgl(tabs, ~ any(str_detect(names(.x), "Id.pont") |
                                          str_detect(.x[[1]], "Id.pont"))))[1]]]
  names(tab) <- c("idopont","lakonepesseg","lakasok","terulet_ha")
  tab |>
    filter(str_detect(idopont, "\\d{4}")) |>
    mutate(p_id=id,
           year=as.integer(str_extract(idopont, "\\d{4}")),
           census=str_detect(idopont, "n.psz.ml.l.s"),
           across(c(lakonepesseg, lakasok, terulet_ha),
                  ~ as.numeric(gsub("[^0-9]", "", .x))))
}

# 4. bind all + attach names
HNT_1990_2025 <- list.files("adatok/cache_hntr", full.names=TRUE,include.dirs=F) |>
  map(possibly(read_hist, NULL), .progress=TRUE) |>
  list_rbind() |>
  left_join(ids |> select(p_id, telepules), by="p_id") |>
  arrange(telepules, year)

# 5. validate
HNT_1990_2025 |> summarise(n_settlements=n_distinct(p_id),
                      yr_min=min(year), yr_max=max(year))
HNT_1990_2025 |> filter(year == 2011) |> summarise(total=sum(lakonepesseg))  # ~9,937,628

write_csv(HNT_1990_2025,"adatok/HNT_1990_2025.csv") |> 
  select(!idopont) |> relocate(telepules,.before = firs)
})
HNT_1990_2025 <- read_csv("adatok/HNT_1990_2025.csv")
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

bind_rows(HNT_1990_2025 |> group_by(year) |> 
  summarise(lakonepesseg=sum(lakonepesseg),n_telep=n()) |> 
    mutate(type="ALL"),
hnt_2004_2010_2025_jogallas |> group_by(year) |> 
  summarise(lakonepesseg=sum(lakonepesseg),n_telep=n()) |> 
    mutate(type="from_2012")) |> 
  pivot_longer(!c(year,type)) |>
ggplot(aes(x=year,y=value,group=type,color=type)) + 
  facet_wrap(~name,scale="free_y") +
  geom_line() + geom_point() + 
  scale_x_continuous(breaks = seq(1990,2025,5)) +
  theme_bw()
# SAVE
ggsave("adatok/HNT_dev_totals.png",width = 18, height = 12, 
  units = "in", dpi = 300, bg = "white")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# some discrepancies!
# scatter plot of deviations

# this is because of revisions at time of censuses, esp. 2001

local({
  df_all <- left_join(
    HNT_1990_2025 |> rename(ksh_kod=p_id) |> select(year, telepules, lakonepesseg, ksh_kod), 
    hu_hnt_lakonepesseg_2012_2025 |> select(year, telepules, lakonepesseg, ksh_kod) |> 
      rename(lakonep_from2012=lakonepesseg) |> mutate(ksh_kod=as.numeric(ksh_kod))
  )

  df <- df_all |> filter(year >= 2012 & lakonepesseg != lakonep_from2012)

  cor_df <- df |> 
  group_by(year) |> 
  summarise(
    r=cor(lakonepesseg, lakonep_from2012, use="complete.obs"),
    n_dev=n(),
    cum_abs_dev=sum(abs(lakonep_from2012-lakonepesseg), na.rm=TRUE),
    .groups="drop"
  ) |> 
  left_join(
    df_all |> filter(year >= 2012) |> 
      group_by(year) |> 
      summarise(n_total=n(), total_pop=sum(lakonepesseg, na.rm=TRUE)),
    by="year" )

  ggplot(df, aes(x=lakonepesseg, y=lakonep_from2012)) +
    facet_wrap(~year) +
    geom_point(alpha=1/3) +
    geom_abline(slope=1, intercept=0, linetype="dashed", color="red") +
    geom_text(data=cor_df,
  aes(x=2e3, y=Inf,
    label=sprintf("r=%.2f%%\ndev=%d/%d towns\nΣ dev=%.0fk (out of %.3fm)",
      r*100, n_dev, n_total, cum_abs_dev/1000, total_pop/1e6 )),
      hjust=1.1, vjust=1.5, inherit.aes=F) +
    scale_x_log10() + scale_y_log10() +
    theme_bw()

  ggsave("adatok/HNT_dev_scatter.png", width=18, height=12,
    units="in", dpi=300, bg="white")
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# distrib of deviations

local({
  df_all <- left_join(
    HNT_1990_2025 |> rename(ksh_kod=p_id) |> select(year, telepules, lakonepesseg, ksh_kod),
    hu_hnt_lakonepesseg_2012_2025 |> select(year, telepules, lakonepesseg, ksh_kod) |>
      rename(lakonep_from2012=lakonepesseg) |> mutate(ksh_kod=as.numeric(ksh_kod))
  )

  df <- df_all |> 
    filter(year >= 2012, lakonepesseg != lakonep_from2012) |>
    mutate(
      abs_deviation=lakonep_from2012-lakonepesseg,
      deviation_pct=abs_deviation/lakonepesseg*100,
      abs_deviation_pct=abs(deviation_pct)
    )

  cor_df <- df |> 
    group_by(year) |> 
    summarise(
      r=cor(lakonepesseg, lakonep_from2012, use="complete.obs"),
      n_dev=n(),
      cum_abs_dev=sum(abs(abs_deviation), na.rm=TRUE),
      .groups="drop"
    ) |> 
    left_join(
      df_all |> filter(year >= 2012) |> 
        group_by(year) |> 
        summarise(
          n_total=n(),
          total_pop=sum(lakonepesseg, na.rm=TRUE)
        ),
      by="year"
    )

  ggplot(df, aes(x=deviation_pct)) +
    facet_wrap(~year) +
    geom_histogram(bins=50, alpha=1/2, color="black", linewidth=1/4) +
    geom_vline(xintercept=0, linetype="dashed") +
    geom_text(
      data=cor_df,
      aes(
        x=0, y=Inf,
        label=sprintf(
          "r=%.2f%%\ndev=%d/%d towns\nΣ|dev|=%.0fk (Σ: %.3fm)",
          r*100, n_dev, n_total, cum_abs_dev/1e3, total_pop/1e6
        )
      ),
      hjust=1.1, vjust=1.5, inherit.aes=FALSE
    ) +
    labs(x="% deviation") +
    coord_cartesian(xlim=c(-20,20)) +
    theme_bw()

  ggsave("adatok/HNT_dev_histogr.png", width=18, height=12,
    units="in", dpi=300, bg="white")
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# concatenated 2010 and 2011 to 2012-2025 csv

hnt_2004_2010_2025_jogallas <- bind_rows(
read_csv("adatok/HNT_forrasok/hnt2004.csv"),
read_csv("adatok/HNT_forrasok/hnt2010.csv"),
read_csv("adatok/HNT_forrasok/hnt2011.csv"),
read_csv("adatok/hu_hnt_lakonepesseg_2012_2025.csv") |> mutate(ksh_kod=as.numeric(ksh_kod))
) |> filter(lakonepesseg>0)

# checks
hnt_2004_2010_2025_jogallas |> group_by(year) |>
  summarise(n=n(),`lakonepesseg (ezer)`=sum(lakonepesseg)/1e3) |>
  pivot_longer(!year) |>
ggplot(aes(x=year,y=value)) + 
  facet_wrap(~name,scale="free_y") + 
  geom_line() + geom_point() +
  theme_bw()
  

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# PULL 2005 HNT from census 2001 archives

if (!dir.exists("adatok/cache2005/")) {
base <- "https://nepszamlalas2001.hu/hun/egyeb/hnk2005/tablak/tablMunka%d.html"
dir.create("cache2005", showWarnings=FALSE)
# 
# --- 1. download all 3167 pages (cached, resumable) ---
for (i in 1:3167) {
  f <- sprintf("cache2005/%d.html", i)
  if (file.exists(f) && file.size(f) > 500) next
  r <- possibly(~GET(sprintf(base, i), timeout(30)), NULL)()
  if (!is.null(r) && status_code(r) == 200) writeBin(r$content, f)
  Sys.sleep(0.25)
  if (i %% 10 == 0) cat("downloaded", i, "\n")
}
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# html files for 2004 - these have lakonepesseg and jogallas

hnt2004 <- local({
# ------------------------------------------------------------
# Clean text from an HTML cell
# ------------------------------------------------------------
clean_text <- function(x) {
  x |>
    str_replace_all("\u00A0", " ") |>   # non-breaking spaces
    str_squish()
}

# ------------------------------------------------------------
# Extract one value from the key-value table
# ------------------------------------------------------------
read_one <- function(f) {

  # Read old Hungarian ISO-8859-2 HTML
  raw <- readBin(f, "raw", n = file.info(f)$size)

  txt <- iconv(
    rawToChar(raw),
    from = "ISO-8859-2",
    to   = "UTF-8"
  )

  html <- read_html(txt, encoding = "UTF-8")

  # ----------------------------------------------------------
  # Get every table row and its cells
  # ----------------------------------------------------------
  rows <- html |>
    html_elements("tr") |>
    map(function(row) {

      cells <- row |> html_elements("td, th")

      if (length(cells) < 2)
        return(NULL)

      tibble(
        key = clean_text(cells[[1]] |> html_text2()),
        value = clean_text(cells[[2]] |> html_text2())
      )
    }) |>
    compact() |>
    list_rbind()

  # ----------------------------------------------------------
  # Function to find a value by the beginning of the label
  # ----------------------------------------------------------
  pick <- function(pattern) {

    i <- grep(pattern, rows$key, ignore.case=T)

    if (length(i) == 0)
      return(NA_character_)

    rows$value[i[1]]
  }

  # ----------------------------------------------------------
  # Numeric cleaner
  # ----------------------------------------------------------
  num <- function(x) {

    if (is.na(x))
      return(NA_real_)

    # remove spaces, thousands separators etc.
    x <- str_replace_all(x, "[^0-9]", "")

    if (x == "")
      return(NA_real_)

    as.numeric(x)
  }

  # ----------------------------------------------------------
  # Extract county
  # Example:
  # "20 Zala megye"
  # -> "Zala megye"
  # ----------------------------------------------------------
  megye_clean <- function(x) {

    if (is.na(x))
      return(NA_character_)

    x |>
      str_remove("^\\s*\\d+\\s*") |>
      clean_text()
  }

  # ----------------------------------------------------------
  # Build output row
  # ----------------------------------------------------------
  tibble(
  year = 2004,

  ksh_kod = pick("^KSH-kód"),

  telepules = rows$key[
  grep("A helység hivatalos megnevezése",
    rows$key,ignore.case=T)][1] |>
  str_extract( "(?<=A helység hivatalos megnevezése:)\\s*.*?(?=KSH-kód:)" ) |>
  clean_text(),

  jogallas = pick("^Igazgatási rang"),

  megye = megye_clean( pick("^Megye KSH-kódja") ),

  terulet_ha = num( pick("^Terület") ),
  lakonepesseg = num( pick("^Lakónépesség") ),
  lakasok = num( pick("^Lakások száma") ),
  idx = as.integer( str_extract(basename(f), "\\d+") )
)
}


files <- list.files( "adatok/cache2005",
  pattern = "^\\d+\\.html$", full.names=T) # [1:22]

d2004 <- map_dfr(files,
  possibly(read_one, otherwise = NULL),
  .progress=T)

return(d2004)
})
