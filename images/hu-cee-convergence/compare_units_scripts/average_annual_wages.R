# average_annual_wages
# OECD

rm(list = ls())
# load settings
source("fcns/functions_settings.R")
# LOAD data, functions, libraries
source("fcns/load_pop_data.R")

output_folder <- "output/compare_units/average_annual_wages/"

l_aver_annual_wage <- list()
l_aver_annual_wage$raw_data <- read_csv(
  "data/wages/oecd_average_annual_wages.csv") %>%
  select(TIME_PERIOD, `Unit of measure`, `Reference area`,
         `Price base`, OBS_VALUE) %>%
  filter(!(grepl("Current", `Price base`) &
           !grepl("PPP", `Unit of measure`))) %>%
  mutate(series = case_when(
    grepl("PPP", `Unit of measure`) & grepl("Constant", `Price base`) ~
      "usd_ppp_const",
    grepl("PPP", `Unit of measure`) & grepl("Current",  `Price base`) ~
      "usd_ppp_current",
    !grepl("US dollars, PPP converted", `Unit of measure`) &
       grepl("Constant", `Price base`) ~
      "lcu_constant"                        # <-- honest: still LCU at this point
  ))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# -------------------------
# XC RATES — 2021 annual averages to match constant 2021 price base
# defined once, reused in both weighted avg and norm_values
# -------------------------
l_aver_annual_wage$xc_rates_2021 <- tibble(
  country   = c("Czechia", "Hungary", "Poland", "Romania",
                "Bulgaria", "Denmark", "Sweden"),
  currency  = c("CZK",     "HUF",     "PLN",    "RON",
                "BGN",     "DKK",     "SEK"),
  rate_2021 = c(
    25.640,   # CZK
   358.517,   # HUF
     4.565,   # PLN
     4.921,   # RON
     1.9558,  # BGN – fixed peg
     7.4368,  # DKK
    10.1469   # SEK
  )
)

# -------------------------
# EU8 WEIGHTED AVERAGE (all EU8 incl. DK and SE)
# -------------------------
l_aver_annual_wage$eu8_weighted_average <-
  l_aver_annual_wage$raw_data %>%
  filter(`Reference area` %in% l_groups$comp_groups$EU8,
         TIME_PERIOD >= 2000) %>%
  rename(country = `Reference area`, year = TIME_PERIOD) %>%
  left_join(l_pop$total_pop %>% rename(pop = value),
            by = c("country", "year")) %>%
  left_join(l_aver_annual_wage$xc_rates_2021, by = "country") %>%
  mutate(
    rate_2021    = replace_na(rate_2021, 1),        # euro countries → 1
    value_eur    = ifelse(
      series == "lcu_constant",
      OBS_VALUE / rate_2021,                        # deflated LCU → constant 2021 EUR
      OBS_VALUE                                     # PPP series unchanged
    )
  ) %>%
  group_by(year, series) %>%
  summarise(
    weighted_avg = sum(value_eur * pop, na.rm = TRUE) /
                   sum(pop[!is.na(value_eur)], na.rm = TRUE),
    .groups = "drop"
  )

# -------------------------
# NORMALISED VALUES — CEE countries as % of EU8
# -------------------------

l_aver_annual_wage$norm_values <- l_aver_annual_wage$raw_data %>%
  mutate(`Reference area` = ifelse(
            grepl("Slovak", `Reference area`),
              "Slovakia", `Reference area`) ) %>%
  filter(`Reference area` %in% l_groups$list_cntrs$CEE,
         TIME_PERIOD >= 2000) %>%
  left_join(l_aver_annual_wage$xc_rates_2021,
            by = c("Reference area" = "country")) %>%
  mutate(
    rate_2021         = replace_na(rate_2021, 1),
    value_common_unit = ifelse(
      series == "lcu_constant",
      OBS_VALUE / rate_2021,                        # now genuinely constant 2021 EUR
      OBS_VALUE
    ),
    # rename series now that conversion is done
    series = ifelse(
      series == "lcu_constant", "eur_constant_2021", series)   ) %>%
  left_join(
    l_aver_annual_wage$eu8_weighted_average %>%
      mutate(series = ifelse(                       # match renamed series
        series == "lcu_constant", "eur_constant_2021", series
      )),
    by = c("TIME_PERIOD" = "year", "series")
  ) %>%
  mutate(`% of EU8` = 100 * value_common_unit / weighted_avg) %>%
  select(!c(weighted_avg, `Unit of measure`, `Price base`)) %>%
  rename(country = `Reference area`, year = TIME_PERIOD)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# save init and final (normalised) values

with(list(),{
  
  last_year_filt <- l_aver_annual_wage$norm_values %>%
      # filter(country %in% cee_filters[[filt_name]]) %>%
      group_by(series, country) %>%
      summarise(year = max(year),.groups = "drop") %>%
      summarise(last_year = min(year)) %>%
      pull(last_year)
  min_yr <- max(c(min(l_aver_annual_wage$norm_values$year),2004))
  
  intermed_yrs <- c(2010,2021)
  
  x <- l_aver_annual_wage$norm_values %>%
      select(country, year,series,value=`% of EU8`) %>%
      filter(year %in% c(min_yr,intermed_yrs,last_year_filt)) %>%
      group_by(country, series) %>%
      summarise(
        val_init = if (any(year == min_yr))  value[year == min_yr] else NA_real_,
        val_2010 = if (any(year == 2010))  value[year == 2010] else NA_real_,
        val_prewar = if (any(year == intermed_yrs[2]))  value[year == intermed_yrs[2]] else NA_real_,
        val_last = if (any(year == last_year_filt))  value[year == last_year_filt]  else NA_real_,
        .groups  = "drop" )  %>% 
  mutate(variable=gsub("^output/compare_units/|/$", "", output_folder),#
        init_yr=min_yr,
        last_yr=last_year_filt) %>%
    relocate(variable,init_yr,last_yr) 
  # show
  print(x)
  
  # save
  x %>%
    write_csv(file = paste0(output_folder,"summ_table.csv"))
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# create plot of dynamics

local({

  save_plot_flag <- T

  for (cee9 in c(T, F)) {
    for (plot_type in c("pct", "abs")) {

      # -------------------------
      # DATA PREP
      # -------------------------
      df_data <- l_aver_annual_wage$norm_values %>%
        filter(country %in% l_groups$list_cntrs$CEE)

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
        plot_title <- "% of EU8 (average annual wage) – CEE countries"
      } else {
        y_col      <- "value_common_unit"
        y_lab      <- "Average annual wage (USD PPP / EUR constant 2021)"
        plot_title <- "Average annual wage – absolute values – CEE countries"
      }

      y_sym <- sym(y_col)

      # -------------------------
      # COUNTRY ORDER (by eur_constant_2021, per-series last year)
      # -------------------------
      country_order <- df_data %>%
        group_by(country, series) %>%
        summarise(
          base_2010 = `% of EU8`[year == 2010],
          last_val  = `% of EU8`[year == max(year, na.rm = T)],
          ratio     = last_val / base_2010,.groups   = "drop"
        ) %>%
        filter(series == "eur_constant_2021") %>%          # <-- order by volume index
        arrange(desc(ratio)) %>%
        pull(country)

      # -------------------------
      # RATIO LABELS (per-series last year)
      # -------------------------
      ratio_df <- df_data %>%
        mutate(country = factor(country, levels = country_order)) %>%
        group_by(country, series) %>%
        summarise(
          base_2010   = (!!y_sym)[year == 2010],
          last_val    = (!!y_sym)[year == max(year, na.rm = T)],
          ratio       = last_val / base_2010,
          perc_change = (ratio - 1) * 100,.groups     = "drop"
        ) %>%
        mutate(
          label = paste0(
            gsub("usd_", "", series), ": ",
            ifelse(perc_change > 0, "+", ""),
            round(perc_change), "%"
          )
        ) %>%
        group_by(country) %>%
        summarise(label = paste(label, collapse = "\n"),.groups = "drop")

      # -------------------------
      # MAIN DF + LAST YEAR DF (per series)
      # -------------------------
      df_data <- df_data %>%
        mutate(country = factor(country, levels = country_order)) %>%
        arrange(country)

      last_year_df <- df_data %>%
        group_by(country, series) %>%
        filter(year == max(year, na.rm = T)) %>%           # <-- per series last year
        ungroup()

      # -------------------------
      # PLOT
      # -------------------------
      p <- ggplot(
        df_data,
        aes(x = year, y = !!y_sym, color = series)
      ) +
        facet_wrap(~country) +
        geom_line(linewidth = 1) +
        geom_point(shape = 21) +
        # ratio labels top-left
        geom_text(data= ratio_df,
          aes(x = min_year, y = Inf, label = label),
          hjust=-0.05, vjust= 1.5,
          size= 3.5, inherit.aes = F) +
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
                  `% of EU8` + ifelse(grepl("ppp", series), 4, -10)
                } else {
                  value_common_unit + ifelse(grepl("ppp", series), 1000, -2500)
                },
            label = if (plot_type == "pct") {
                      paste0(round(`% of EU8`), "%")
                    } else {
                      paste0(round(value_common_unit / 1e3, 1), "k")
                    }
          ),
          vjust       = -0.5,
          size        = 3.5,
          show.legend = F
        ) +

        labs(
          title = plot_title,
          x= "",y= y_lab, color="") +
        scale_x_continuous(
          breaks = seq(min_year, max_year, 8),
          expand = expansion(c(0.04, 0.1)) ) +
        scale_y_continuous(expand = expansion(c(0.04, 0.1))) +
        theme_bw() +
        plot_settings +
        theme(axis.text.x= element_text(angle = 0),
          legend.position = "top")

      # -------------------------
      # SAVE
      # -------------------------
      file_name <- paste0(
        output_folder, "aver_annual_wage_dyn",
        ifelse(cee9, "_CEE9", ""),
        ifelse(plot_type == "abs", "_abs",  ""),
        ".png")

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
# check ratios

l_aver_annual_wage$norm_values %>%
  select(country, year, series, value = `% of EU8`) %>%       # <-- no rename needed
  group_by(country, series) %>%
  filter(year %in% c(2010, max(year, na.rm = T))) %>%
  summarise(
    base_2010       = value[year == 2010],
    last_val        = value[year == max(year)],
    ratio_last_2010 = last_val / base_2010,                    # <-- generic name.groups         = "drop"
  ) %>%
  select(country, series, ratio_last_2010) %>%
  pivot_wider(names_from  = series,
              values_from = ratio_last_2010) %>%
  arrange(desc(eur_constant_2021))                             # <-- updated series name

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# plots of ratio changes

local({
  save_plot_flag <- T

  metric_cfg <- list(
    pct = list(
      transform = function(last, base) (last / base - 1) * 100,
      title     = "Average annual wage as a share of the EU8 average",
      subtitle  = "Relative change from 2004 or 2010 baseline, in percent",
      x_lab     = "Percent change from baseline",
      file_stub = "aver_annual_wage_pct_change_from_baselines",
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
      title     = "Average annual wage as a share of the EU8 average",
      subtitle  = "Absolute change from 2004 or 2010 baseline, in percentage points",
      x_lab     = "Change from baseline (pp)",
      file_stub = "aver_annual_wage_abs_change_from_baselines",
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

  # -------------------------
  # per-series last year
  # -------------------------
  last_year_by_series <- l_aver_annual_wage$norm_values %>%
    group_by(series) %>%
    summarise(last_year = max(year, na.rm = T),.groups = "drop")

  last_yr_ppp <- last_year_by_series$last_year[
                   last_year_by_series$series == "usd_ppp_const"]
  last_yr_eur <- last_year_by_series$last_year[
                   last_year_by_series$series == "eur_constant_2021"]

  periods <- c(
    paste0("2004\u2013", last_yr_ppp),
    paste0("2010\u2013", last_yr_ppp)
  )

  for (cee9 in c(T, F)) {
    for (metric in names(metric_cfg)) {

      cfg <- metric_cfg[[metric]]

      df_change <- l_aver_annual_wage$norm_values %>%
        filter(country %in% l_groups$list_cntrs$CEE) %>%
        select(country, year, series, value = `% of EU8`) %>%
        left_join(last_year_by_series, by = "series") %>%
        group_by(country, series, last_year) %>%
        filter(year %in% c(2004, 2010, last_year)) %>%
        summarise(
          val_2004    = if (any(year == 2004)) value[year == 2004] else NA_real_,
          val_2010    = if (any(year == 2010)) value[year == 2010] else NA_real_,
          val_last    = if (any(year == last_year)) value[year == last_year] else NA_real_,
          change_2004 = if (!is.na(val_2004)) cfg$transform(val_last, val_2004) else NA_real_,
          change_2010 = if (!is.na(val_2010)) {cfg$transform(val_last, val_2010)} else NA_real_,
          .groups     = "drop")

      if (cee9) {
        df_change <- df_change %>%
          filter(!grepl("Czech|Sloven", country))
      }

      # order by eur_constant_2021 change from 2010
      country_order <- df_change %>%
        filter(series == "eur_constant_2021") %>%
        arrange(change_2010) %>%
        pull(country)

      df_plot <- bind_rows(
        df_change %>%
          transmute(
            country,
            series,
            period   = paste0("2004\u2013", last_year),
            change   = change_2004,
            base_val = val_2004,
            last_val = val_last
          ),
        df_change %>%
          transmute(
            country,
            series,
            period   = paste0("2010\u2013", last_year),
            change   = change_2010,
            base_val = val_2010,
            last_val = val_last
          )
      ) %>%
        filter(!is.na(change)) %>%                    # <-- drop NAs: BG/RO/HR missing PPP
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
            "values in parentheses show the underlying level\n",
            "as % of the EU8 weighted average. ",
            "Note: PPP series not available for BG, RO, HR. "
            # "eur_constant_2021 ends ", last_yr_eur,
            # ", PPP series ends ", last_yr_ppp, "."
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
          expand = expansion(mult = c(0.08, 0.36))
        )
      } else {
        p <- p + scale_x_continuous(
          expand = expansion(mult = c(0.05, 0.45))
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
# SAVE SUMMARY HTML TABLES

local({

  save_plot_flag <- F

  # -------------------------
  # per-series last year
  # -------------------------
  last_year_by_series <- l_aver_annual_wage$norm_values %>%
    group_by(series) %>%
    summarise(last_year = max(year, na.rm = T),.groups = "drop")

  last_yr_ppp <- last_year_by_series$last_year[
                   last_year_by_series$series == "usd_ppp_const"]
  last_yr_eur <- last_year_by_series$last_year[
                   last_year_by_series$series == "eur_constant_2021"]

  periods <- c(
    paste0("2004-", last_yr_ppp),
    paste0("2010-", last_yr_ppp)
  )

  cee_filters <- list(
    full_CEE = l_groups$list_cntrs$CEE,
    CEE9     = setdiff(l_groups$list_cntrs$CEE, c("Czechia", "Slovenia"))
  )

  for (filt_name in names(cee_filters)) {

    df_base <- l_aver_annual_wage$norm_values %>%
      filter(country %in% cee_filters[[filt_name]]) %>%
      select(country, year, series, value = `% of EU8`) %>%   # <-- clean names
      left_join(last_year_by_series, by = "series") %>%
      group_by(country, series, last_year) %>%
      filter(year %in% c(2004, 2010, last_year)) %>%
      summarise(
        val_2004 = if (any(year == 2004)) value[year == 2004] else NA_real_,
        val_2010 = if (any(year == 2010)) value[year == 2010] else NA_real_,
        val_last = value[year == max(year)],.groups  = "drop"
      ) %>%
      filter(!is.na(val_2004) | !is.na(val_2010)) %>%
      mutate(
        ch2004_ratio = ifelse(!is.na(val_2004), val_last / val_2004,    NA_real_),
        ch2010_ratio = ifelse(!is.na(val_2010), val_last / val_2010,    NA_real_),
        ch2004_diff  = ifelse(!is.na(val_2004), val_last - val_2004,    NA_real_),
        ch2010_diff  = ifelse(!is.na(val_2010), val_last - val_2010,    NA_real_)
      )

    # ---- FOLD CHANGE TABLE ----
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
      pivot_longer(!c(country, series, last_year), names_to = "period") %>%
      mutate(period = paste0(gsub("label_", "", period), "-", last_year)) %>%
      pivot_wider(values_from = value, names_from = series)

    for (i in seq_along(periods)) {
      df_out <- df_ratio %>%
        filter(period == periods[i]) %>%
        mutate(sort_val = as.numeric(
          str_extract(eur_constant_2021, "-?\\d+\\.?\\d*")    # <-- sort by eur_constant_2021
        )) %>%
        arrange(desc(sort_val)) %>%
        select(-sort_val, -last_year) %>%
        mutate(across(
          any_of(c("usd_ppp_const", "usd_ppp_current",
                   "eur_constant_2021")),                      # <-- any_of: handles missing PPP cols
          ~ paste0("#", rank(-as.numeric(
              str_extract(., "-?\\d+\\.?\\d*")),
              na.last = "keep"), ": ",.)
        ))

      html_table <- format_html_table(df_out)
      writeLines(
        html_table,
        paste0(
          output_folder, "html_tables/aver_annual_wage_foldchange_",   # <--
          periods[i], "_", filt_name, ".html"
        )
      )
    }

    # ---- ABSOLUTE DIFFERENCE TABLE ----
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
      pivot_longer(!c(country, series, last_year), names_to = "period") %>%
      mutate(period = paste0(gsub("label_", "", period), "-", last_year)) %>%
      pivot_wider(values_from = value, names_from = series)

    for (i in seq_along(periods)) {
      df_out <- df_diff %>%
        filter(period == periods[i]) %>%
        mutate(sort_val = as.numeric(
          str_extract(eur_constant_2021, "-?\\d+\\.?\\d*")
        )) %>%
        arrange(desc(sort_val)) %>%
        select(-sort_val, -last_year) %>%
        mutate(across(
          any_of(c("usd_ppp_const", "usd_ppp_current",
                   "eur_constant_2021")),                      # <-- any_of: safe for missing cols
          ~ paste0("#", rank(-as.numeric(
              str_extract(., "-?\\d+\\.?\\d*")),
              na.last = "keep"), ": ",.)
        ))

      html_table <- format_html_table(df_out)
      writeLines(
        html_table,
        paste0(
          output_folder, "html_tables/aver_annual_wage_absdiff_",      # <--
          periods[i], "_", filt_name, ".html"
        )
      )
    }

  } # end cee filter loop
})



