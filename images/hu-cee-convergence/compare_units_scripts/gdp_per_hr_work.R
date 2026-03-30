# GDP per hour of work
# OECD

rm(list = ls())
# load settings
source("fcns/functions_settings.R")
# LOAD data, functions, libraries
source("fcns/load_pop_data.R")

output_folder <- "output/compare_units/gdp_per_hr_worked/"

l_gdp_per_hr_worked <- list()
l_gdp_per_hr_worked$raw_data <- read_csv(
  paste0(
    "data/productivity/OECD.SDD.TPS,DSD_PDB@DF_PDB_LV,",
    "+ROU+BGR+AUT+BEL+FRA+FIN+EST+DNK+CZE+LVA+NLD+SVK+SVN+SWE+HUN+DEU+LTU+POL",
    ".A.GDPHRS..USD_PPP_H+XDC_H.V+Q....csv"
    )) %>%
  select(TIME_PERIOD,`Unit of measure`,`Reference area`,
      `Price base`,OBS_VALUE) %>%
  filter(!(grepl("Current",`Price base`) & 
           grepl("National",`Unit of measure`)  )) %>%
  mutate(series=case_when(
      grepl("PPP",`Unit of measure`) & grepl("Constant",`Price base`) ~ 
            "usd_ppp_const",
      grepl("PPP",`Unit of measure`) & grepl("Current",`Price base`) ~
            "usd_ppp_current",
      grepl("National",`Unit of measure`) & grepl("Constant",`Price base`) ~
            "eur_constant") )

# weighted average of EU6 groups (euro cntrs only)
# -------------------------
# XC RATES — 2020 annual averages to match constant 2020 price base
# defined once, used in both weighted avg and norm_values
# -------------------------
l_gdp_per_hr_worked$xc_rates_2020 <- tibble(
  country  = c("Czechia", "Hungary", "Poland", "Romania",
               "Bulgaria", "Denmark", "Sweden"),
  currency = c("CZK",     "HUF",     "PLN",    "RON",
               "BGN",     "DKK",     "SEK"),
  rate_2020 = c(
     26.455,  # CZK – ECB 2020 annual avg
    351.249,  # HUF – ECB 2020 annual avg
      4.444,  # PLN – ECB 2020 annual avg
      4.837,  # RON – ECB 2020 annual avg
      1.9558, # BGN – fixed peg
      7.4542, # DKK – ERM II quasi-fixed
     10.4867  # SEK – ECB 2020 annual avg
  )
)

# -------------------------
# EU8 WEIGHTED AVERAGE (all EU8 incl. DK and SE)
# -------------------------
l_gdp_per_hr_worked$eu8_weighted_average <- 
  l_gdp_per_hr_worked$raw_data %>%
  filter(`Reference area` %in% l_groups$comp_groups$EU8 &
           TIME_PERIOD >= 2004) %>%
  rename(country = `Reference area`, year = TIME_PERIOD) %>%
  left_join(l_pop$total_pop %>% rename(pop = value),
            by = c("country", "year")) %>%
  left_join(l_gdp_per_hr_worked$xc_rates_2020, by = "country") %>%
  mutate(
    rate_2020     = replace_na(rate_2020, 1),       # euro countries → 1
    value_eur     = ifelse(
      grepl("eur_constant", series),
      OBS_VALUE / rate_2020,                        # DK/SE/CZ/HU/PL/RO/BG → EUR
      OBS_VALUE                                     # PPP series unchanged
    )
  ) %>%
  group_by(year, series) %>%
  summarise(
    weighted_avg = sum(value_eur * pop, na.rm = TRUE) /
                   sum(pop[!is.na(value_eur)], na.rm = TRUE),.groups = "drop"
  )

# -------------------------
# NORMALISED VALUES — CEE countries as % of EU8
# -------------------------

l_gdp_per_hr_worked$norm_values <- 
  l_gdp_per_hr_worked$raw_data %>%
  mutate(
    `Reference area` = ifelse(
      grepl("Slovak", `Reference area`), "Slovakia", `Reference area`
    )
  ) %>%
  filter(`Reference area` %in% l_groups$list_cntrs$CEE,
         TIME_PERIOD >= 2004) %>%
  left_join(l_gdp_per_hr_worked$xc_rates_2020,
            by = c("Reference area" = "country")) %>%
  mutate(
    rate_2020         = replace_na(rate_2020, 1),   # euro-adopted CEE → 1
    value_common_unit = ifelse(
      grepl("eur_constant", series),
      OBS_VALUE / rate_2020,
      OBS_VALUE
    )
  ) %>%
  left_join(
    l_gdp_per_hr_worked$eu8_weighted_average,
    by = c("TIME_PERIOD" = "year", "series")
  ) %>%
  mutate(`% of EU8` = 100 * value_common_unit / weighted_avg) %>%  # <-- EU8
  select(!c(weighted_avg, `Unit of measure`, `Price base`))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# check ratios

l_gdp_per_hr_worked$norm_values %>%
  select(country = `Reference area`,
         year    = TIME_PERIOD,
         series,
         value   = `% of EU8`) %>%                      # <-- EU8
  group_by(country,series) %>%
  mutate(last_year = max(year, na.rm = T)) %>%           # <-- per cntry
  ungroup() %>%
  mutate(last_year=min(last_year)) %>%
  group_by(country,series) %>%
  filter(year %in% c(2010, last_year)) %>%
  summarise(
    base_2010      = value[year == 2010],
    last_val       = value[year == last_year],
    last_year      = unique(last_year),                          # <-- carry through for col name
    ratio          = last_val / base_2010,.groups        = "drop"
  ) %>%
  mutate(ratio_label = paste0("ratio_", last_year, "_2010")) %>%  # <-- dynamic name
  select(country, series, ratio,last_year) %>% # 
  pivot_wider(names_from  = series,
              values_from = ratio) %>%
  arrange(desc(usd_ppp_const))


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# SAVE initial and final values

with(list(),{
  
  last_year_filt <- l_gdp_per_hr_worked$norm_values %>%
      rename(country = `Reference area`, year = TIME_PERIOD) %>%
      # filter(country %in% cee_filters[[filt_name]]) %>%
      group_by(series, country) %>%
      summarise(year = max(year),.groups = "drop") %>%
      summarise(last_year = min(year)) %>%
      pull(last_year)
  min_yr <- max(c(min(l_gdp_per_hr_worked$norm_values$TIME_PERIOD),2004))
  
  intermed_yrs <- c(2010,2021)
  
  l_gdp_per_hr_worked$norm_values %>%
      rename(country = `Reference area`, year = TIME_PERIOD) %>%
      select(country, year, series, value = `% of EU8`) %>%
      filter(year %in% c(min_yr,intermed_yrs,last_year_filt)) %>%
      group_by(country, series) %>%
      summarise(
        val_init = if (any(year == min_yr))  value[year == min_yr] else NA_real_,
        val_2010 = if (any(year == 2010))  value[year == 2010] else NA_real_,
        val_prewar = if (any(year == intermed_yrs[2]))  value[year == intermed_yrs[2]] else NA_real_,
        val_last = if (any(year == last_year_filt))  value[year == last_year_filt]  else NA_real_,
        .groups  = "drop" )  %>% 
  mutate(variable="gdp_per_hr_worked",#
        init_yr=min_yr,
        last_yr=last_year_filt) %>%
    relocate(variable,init_yr,last_yr) %>%
    write_csv(file = paste0(output_folder,"summ_table.csv"))
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# PLOTS of dynamics

local({

  save_plot_flag <- T

  for (cee9 in c(T, F)) {
    for (plot_type in c("pct", "abs")) {

      # -------------------------
      # DATA PREP
      # -------------------------
      df_data <- l_gdp_per_hr_worked$norm_values %>%
        rename(country = `Reference area`, year = TIME_PERIOD) %>%
        filter( # !grepl("eur_constant", series),
               country %in% l_groups$list_cntrs$CEE) # only PPP series in plot

      if (cee9) {
        df_data <- df_data %>%
          filter(!grepl("Czech|Sloven", country))
      }

      min_year <- min(df_data$year, na.rm = T)
      max_year <- max(df_data$year, na.rm = T)

      # -------------------------
      # Y-column setup
      # -------------------------
      if (plot_type == "pct") {
        y_col      <- "% of EU8"
        y_lab      <- "% of EU8"
        plot_title <- "% of EU8 (GDP per hour worked) – CEE countries"
      } else {
        y_col      <- "value_common_unit"
        y_lab      <- "GDP per hour worked (USD PPP)"
        plot_title <- "GDP per hour worked – absolute values (USD PPP) – CEE countries"
      }

      y_sym <- sym(y_col)

      # -------------------------
      # COUNTRY ORDER (by usd_ppp_const ratio 2010 → max year)
      # -------------------------
      country_order <- df_data %>%
        group_by(country, series) %>%
        summarise(
          base_2010=`% of EU8`[year == 2010],
          last_val= `% of EU8`[year == max(year, na.rm = T)],   # <-- per group max
          ratio=last_val / base_2010, .groups   = "drop") %>%
        filter(series == "usd_ppp_const") %>%
        arrange(desc(ratio)) %>%
        pull(country)

      # -------------------------
      # RATIO LABELS
      # -------------------------
      ratio_df <- df_data %>%
        mutate(country = factor(country, levels = country_order)) %>%
        group_by(country, series) %>%
        summarise(
          base_2010   = (!!y_sym)[year == 2010],
          last_val    = (!!y_sym)[year == max(year, na.rm = T)],   # <-- per group max
          ratio       = last_val / base_2010,
          perc_change = (ratio - 1) * 100,
          .groups= "drop") %>%
        mutate(
          label = paste0( gsub("usd_", "", series), ": ",
              ifelse(perc_change > 0, "+", ""),
              round(perc_change), "%") ) %>%
      group_by(country) %>%
      summarise(label = paste(label, collapse = "\n"),
          .groups = "drop")

      # -------------------------
      # MAIN DF + LAST YEAR DF
      # -------------------------
      df_data <- df_data %>%
        mutate(country = factor(country, levels = country_order)) %>%
        arrange(country)

      last_year_df <- df_data %>%
          group_by(country, series) %>%
          filter(year == max(year, na.rm = T)) %>%   # <-- max per group, not global
          ungroup()

      # -------------------------
      # PLOT
      # -------------------------
      p <- ggplot(
        df_data,
        aes(
          x     = year,
          y     = !!y_sym,
          color = series
        )
      ) +
        facet_wrap(~country) +
        geom_line(linewidth = 1) +
        geom_point(shape = 21) +

        # ratio labels top-left
        geom_text(
          data        = ratio_df,
          aes(x = min_year, y = Inf, label = label),
          hjust       = 0.05,
          vjust       = 1.1,
          size        = 3.5,
          inherit.aes = F
        ) +

        # highlighted last-year points
        geom_point(
          data        = last_year_df,
          aes(x = year, y = !!y_sym),
          size        = 2,
          show.legend = F
        ) +

        # last-year value labels
        geom_text(
          data = last_year_df,
          aes(
            x = year,
            y = if (plot_type == "pct") {
                  `% of EU8` + ifelse(grepl("current", series), 2, -6)
                } else {
                  value_common_unit + ifelse(grepl("current", series), 0.5, -1.5)
                },
            label = if (plot_type == "pct") {
                      paste0(round(`% of EU8`), "%")
                    } else {
                      paste0(round(value_common_unit, 1))
                    }
          ),
          vjust= -0.5,
          size = 3.5,
          show.legend = F ) +

        labs(title = plot_title,
             x= "", y=y_lab, color="") +
        scale_x_continuous(
          breaks = seq(2004, max_year, 4),
          expand = expansion(c(0.04, 0.1))
        ) +
        scale_y_continuous(expand = expansion(c(0.04, 0.1))) +
        theme_bw() +
        plot_settings +
        theme(
          axis.text.x     = element_text(angle = 0),
          legend.position = "top"
        )

      # -------------------------
      # SAVE
      # -------------------------
      file_name <- paste0(
        output_folder,
        "gdp_per_hr_worked_dyn",
        ifelse(cee9,             "_CEE9", ""),
        ifelse(plot_type == "abs", "_abs",  ""),
        ".png"
      )

      if (save_plot_flag) {
        ggsave(plot = p, filename = file_name,
               width = 30, height = 24, units = "cm")
      }

      print(p)
    }
  }
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# plots of ratio changes

local({
  save_plot_flag <- T

  metric_cfg <- list(
    pct = list(
      transform = function(last, base) (last / base - 1) * 100,
      title     = "GDP per hour worked as a share of the EU8 average",
      subtitle  = "Relative change from 2004 or 2010 baseline, in percent",
      x_lab     = "Percent change from baseline",
      file_stub = "gdp_per_hr_worked_pct_change_from_baselines",
      scales    = "fixed",
      label     = function(change, base, last) {
        paste0(
          ifelse(change > 0, "+", ""),
          round(change), "% (",
          round(base), " to ", round(last), "%)"
        )
      }
    ),
    diff = list(
      transform = function(last, base) last - base,
      title     = "GDP per hour worked as a share of the EU8 average",
      subtitle  = "Absolute change from 2004 or 2010 baseline, in percentage points",
      x_lab     = "Change from baseline (pp)",
      file_stub = "gdp_per_hr_worked_abs_change_from_baselines",
      scales    = "free_x",
      label     = function(change, base, last) {
        paste0(
          ifelse(change > 0, "+", ""),
          round(change), " pp (",
          round(base), " to ", round(last), "%)"
        )
      }
    )
  )

  for (cee9 in c(T, F)) {

    # ── country set for this iteration ───────────────────────────────────────
    cntrs <- if (cee9) {
      setdiff(l_groups$list_cntrs$CEE, c("Czechia", "Slovenia"))
    } else {
      l_groups$list_cntrs$CEE
    }

    # ── single common last year: latest year where ALL series AND countries ──
    #    in this filtered set have data
    last_year_filt <- l_gdp_per_hr_worked$norm_values %>%
      rename(country = `Reference area`, year = TIME_PERIOD) %>%
      filter(country %in% cntrs) %>%
      group_by(series, country) %>%
      summarise(year = max(year),.groups = "drop") %>%
      summarise(last_year = min(year)) %>%
      pull(last_year)

    message(ifelse(cee9, "CEE9", "full_CEE"), " → common last year: ", last_year_filt)

    for (metric in names(metric_cfg)) {

      cfg <- metric_cfg[[metric]]

      # ── base data ──────────────────────────────────────────────────────────
      df_change <- l_gdp_per_hr_worked$norm_values %>%
        rename(country = `Reference area`, year = TIME_PERIOD) %>%
        filter(country %in% cntrs) %>%
        select(country, year, series, value = `% of EU8`) %>%
        filter(year %in% c(2004, 2010, last_year_filt)) %>%
        group_by(country, series) %>%
        summarise(
          val_2004    = if (any(year == 2004))           value[year == 2004]           else NA_real_,
          val_2010    = if (any(year == 2010))           value[year == 2010]           else NA_real_,
          val_last    = if (any(year == last_year_filt)) value[year == last_year_filt] else NA_real_,
          change_2004 = if (!is.na(val_2004)) cfg$transform(val_last, val_2004) else NA_real_,
          change_2010 = if (!is.na(val_2010)) cfg$transform(val_last, val_2010) else NA_real_,
          .groups     = "drop"
        )

      # ── country order by usd_ppp_const change from 2010 ───────────────────
      country_order <- df_change %>%
        filter(series == "usd_ppp_const") %>%
        arrange(change_2010) %>%
        pull(country)

      # ── long format for plotting ───────────────────────────────────────────
      df_plot <- bind_rows(
        df_change %>%
          transmute(
            country,
            series,
            period   = paste0("2004\u2013", last_year_filt),
            change   = change_2004,
            base_val = val_2004,
            last_val = val_last
          ),
        df_change %>%
          transmute(
            country,
            series,
            period   = paste0("2010\u2013", last_year_filt),
            change   = change_2010,
            base_val = val_2010,
            last_val = val_last
          )
      ) %>%
        mutate(
          country   = factor(country, levels = country_order),
          label_txt = cfg$label(change, base_val, last_val)
        )

      dodge_val   <- 0.9
      y_positions <- seq_len(length(levels(df_plot$country))) + 0.5

      p <- ggplot(df_plot, aes(x = change, y = country, group = series)) +
        facet_wrap(~period, scales = cfg$scales) +
        geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
        geom_point(
          aes(color = series),
          size     = 4,
          position = position_dodge(width = dodge_val)
        ) +
        geom_text(
          aes(label = label_txt),
          hjust    = -0.1,
          size     = 4,
          position = position_dodge(width = dodge_val)
        ) +
        geom_hline(
          yintercept = y_positions,
          linewidth  = 0.3,
          linetype   = "dashed"
        ) +
        labs(
          title    = cfg$title,
          subtitle = cfg$subtitle,
          x        = cfg$x_lab,
          y        = NULL,
          color    = NULL,
          caption  = paste0(
            "Labels show the change metric first; ",
            "values in parentheses show the underlying level \n",
            "as % of the EU8 weighted average. ",
            "Data through ", last_year_filt, "."
          )
        ) +
        theme_bw() + plot_settings +
        theme(
          legend.position    = "top",
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_blank()
        )

      if (metric == "pct") {
        p <- p + scale_x_continuous(
          breaks = seq(0, 200, by = 20),
          expand = expansion(mult = c(0.01, 0.36))
        )
      } else {
        p <- p + scale_x_continuous(
          expand = expansion(mult = c(0.02, 0.45))
        )
      }

      file_name <- paste0(
        output_folder,
        cfg$file_stub,
        ifelse(cee9, "_CEE9", ""),
        ".png"
      )

      if (save_plot_flag) {
        ggsave(plot = p, filename = file_name,
               width = 30, height = 24, units = "cm")
      }

      print(p)
    }
  }
})


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# SAVE SUMMARY HTML TABLES

local({

  save_plot_flag <- T

    out_subdir <- "html_tables"
  out_path   <- paste0(output_folder, out_subdir, "/")
  
  if (!dir.exists(out_path)) {
    dir.create(out_path, recursive = TRUE)
    message("Created output directory: ", out_path)
  }
  
  cee_filters <- list(
    full_CEE = l_groups$list_cntrs$CEE,
    CEE9     = setdiff(l_groups$list_cntrs$CEE, c("Czechia", "Slovenia"))
  )

  for (filt_name in names(cee_filters)) {

    # ── 1. single common last year across ALL series AND countries ────────────
    last_year_filt <- l_gdp_per_hr_worked$norm_values %>%
      rename(country = `Reference area`, year = TIME_PERIOD) %>%
      filter(country %in% cee_filters[[filt_name]]) %>%
      group_by(series, country) %>%
      summarise(year = max(year),.groups = "drop") %>%
      summarise(last_year = min(year)) %>%
      pull(last_year)

    # ── 2. diagnostic ─────────────────────────────────────────────────────────
    message(filt_name, " → single common last year: ", last_year_filt)

    # ── 3. periods ────────────────────────────────────────────────────────────
    periods_filt <- c(
      paste0("2004-", last_year_filt),
      paste0("2010-", last_year_filt)
    )

    # ── 4. build base data ────────────────────────────────────────────────────
    df_base <- l_gdp_per_hr_worked$norm_values %>%
      rename(country = `Reference area`, year = TIME_PERIOD) %>%
      filter(country %in% cee_filters[[filt_name]]) %>%
      select(country, year, series, value = `% of EU8`) %>%
      filter(year %in% c(2004, 2010, last_year_filt)) %>%
      group_by(country, series) %>%
      summarise(
        val_2004 = if (any(year == 2004))            value[year == 2004]            else NA_real_,
        val_2010 = if (any(year == 2010))            value[year == 2010]            else NA_real_,
        val_last = if (any(year == last_year_filt))  value[year == last_year_filt]  else NA_real_,
        .groups  = "drop"
      ) %>%
      mutate(last_year = last_year_filt) %>%
      filter(!is.na(val_2004) | !is.na(val_2010)) %>%
      mutate(
        ch2004_ratio = ifelse(!is.na(val_2004), val_last / val_2004, NA_real_),
        ch2010_ratio = ifelse(!is.na(val_2010), val_last / val_2010, NA_real_),
        ch2004_diff  = ifelse(!is.na(val_2004), val_last - val_2004, NA_real_),
        ch2010_diff  = ifelse(!is.na(val_2010), val_last - val_2010, NA_real_)
      )

    # ══════════════════════════════════════════════════════════════════════════
    # FOLD CHANGE TABLE
    # ══════════════════════════════════════════════════════════════════════════
    df_ratio <- df_base %>%
      mutate(
        label_2004 = paste0(
          ifelse(ch2004_ratio > 1, "+", ""),
          round((ch2004_ratio - 1) * 100, 1), "% (",
          round(val_2004, 1), "→", round(val_last, 1), ")"
        ),
        label_2010 = paste0(
          ifelse(ch2010_ratio > 1, "+", ""),
          round((ch2010_ratio - 1) * 100, 1), "% (",
          round(val_2010, 1), "→", round(val_last, 1), ")"
        )
      ) %>%
      select(country, series, last_year, label_2004, label_2010) %>%
      pivot_longer(
        cols     = c(label_2004, label_2010),
        names_to = "period"
      ) %>%
      mutate(period = paste0(gsub("label_", "", period), "-", last_year)) %>%
      pivot_wider(values_from = value, names_from = series)

    
    
    for (i in seq_along(periods_filt)) {

      df_out <- df_ratio %>%
        filter(period == periods_filt[i]) %>%
        mutate(sort_val = as.numeric(str_extract(usd_ppp_const, "-?\\d+\\.?\\d*"))) %>%
        arrange(desc(sort_val)) %>%
        select(-sort_val, -last_year) %>%
        mutate(across(
          c(usd_ppp_const, eur_constant),
          ~ paste0("#", rank(-as.numeric(str_extract(., "-?\\d+\\.?\\d*"))), ": ",.)
        ))
      
      

      if (nrow(df_out) == 0) {
        message("  skipping fold-change — no rows for: ", periods_filt[i]); next
      }

      writeLines(
        format_html_table(df_out),
        paste0(out_path, "gdp_per_hr_worked_foldchange_",
               periods_filt[i], "_", filt_name, ".html")
      )
    }

    # ══════════════════════════════════════════════════════════════════════════
    # ABSOLUTE DIFFERENCE TABLE
    # ══════════════════════════════════════════════════════════════════════════
    df_diff <- df_base %>%
      mutate(
        label_2004 = paste0(
          ifelse(ch2004_diff > 0, "+", ""),
          round(ch2004_diff, 1), " (",
          round(val_2004, 1), "→", round(val_last, 1), ")"
        ),
        label_2010 = paste0(
          ifelse(ch2010_diff > 0, "+", ""),
          round(ch2010_diff, 1), " (",
          round(val_2010, 1), "→", round(val_last, 1), ")"
        )
      ) %>%
      select(country, series, last_year, label_2004, label_2010) %>%
      pivot_longer(
        cols     = c(label_2004, label_2010),
        names_to = "period"
      ) %>%
      mutate(period = paste0(gsub("label_", "", period), "-", last_year)) %>%
      pivot_wider(values_from = value, names_from = series)

    for (i in seq_along(periods_filt)) {

      df_out <- df_diff %>%
        filter(period == periods_filt[i]) %>%
        mutate(sort_val = as.numeric(str_extract(usd_ppp_const, "-?\\d+\\.?\\d*"))) %>%
        arrange(desc(sort_val)) %>%
        select(-sort_val, -last_year) %>%
        mutate(across(
          c(usd_ppp_const, eur_constant),
          ~ paste0("#", rank(-as.numeric(str_extract(., "-?\\d+\\.?\\d*"))), ": ",.)
        ))

      if (nrow(df_out) == 0) {
        message("  skipping abs-diff — no rows for: ", periods_filt[i]); next
      }

      writeLines(
        format_html_table(df_out),
        paste0(out_path, "gdp_per_hr_worked_absdiff_",
               periods_filt[i], "_", filt_name, ".html")
      )
    }

  } # end cee_filters loop
})

