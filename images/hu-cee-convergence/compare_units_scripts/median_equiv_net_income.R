# Median equivalised net income
# EUROSTAT

rm(list = ls())
# load settings
source("fcns/functions_settings.R")
# LOAD data, functions, libraries
source("fcns/load_pop_data.R") # ; source("fcns/transl_tables.R")
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
output_folder <- "output/compare_units/median_equiv_net_income/"

l_median_net_equiv_income <- list()
l_median_net_equiv_income$raw_data <- read_csv(
  "data/median_equiv_net_income/ilc_di04__custom_20670879_linear_2_0.csv") %>% # geo
  select(`Unit of measure`, # `Time frequency`,`Type of household`,
         `Geopolitical entity (reporting)`,TIME_PERIOD,OBS_VALUE) %>%
  rename(country=`Geopolitical entity (reporting)`,
         unit=`Unit of measure`,
         year=TIME_PERIOD,value=OBS_VALUE) %>%
  relocate(c(country,year),.before = unit) %>%
  filter(country %in% c(l_groups$list_cntrs$CEE,l_groups$comp_groups$EU8 ) ) %>% 
  arrange(country,year) 
  # %>%
  # left_join(l_pop$total_pop %>% rename(pop=value)) %>%
  # select(!Code)
  
# calculate 2006 eur/LUC exchange rates for those cntrs&yrs not yet in eurozone
l_median_net_equiv_income$exch_rates <- tibble(
  country           = c("Bulgaria", "Croatia", "Czechia", "Denmark", "Estonia",
                        "Hungary", "Latvia", "Lithuania", "Poland", "Romania",
                        "Slovakia", "Slovenia", "Sweden"),
  currency_code     = c("BGN", "HRK", "CZK", "DKK", "EEK",
                        "HUF", "LVL", "LTL", "PLN", "RON",
                        "SKK", "SIT", "SEK"),
  eur_LCU_rate      = c(
    1.95583,  # BGN – currency board peg = adoption rate (Jan 2026)
    7.53450,  # HRK – irrevocable fixed_adoption rate (Jan 2023)
   27.766,    # CZK – ECB annual avg 2007 (not yet adopted)
    7.4506,   # DKK – ECB annual avg 2007 (not in eurozone)
   15.6466,   # EEK – irrevocable fixed_adoption rate (Jan 2011)
  251.35,     # HUF – ECB annual avg 2007 (not yet adopted)
    0.702804, # LVL – irrevocable fixed_adoption rate (Jan 2014)
    3.45280,  # LTL – irrevocable fixed_adoption rate (Jan 2015)
    3.7837,   # PLN – ECB annual avg 2007 (not yet adopted)
    3.3353,   # RON – ECB annual avg 2007 (not yet adopted)
   30.1260,   # SKK – irrevocable fixed_adoption rate (Jan 2009)
  239.640,    # SIT – irrevocable fixed_adoption rate (Jan 2007)
    9.2501    # SEK – ECB annual avg 2007 (not in eurozone)
  ),
  rate_type         = c(
    "fixed_adoption", # BGN
    "fixed_adoption", # HRK
    "2007avg",# CZK
    "2007avg",# DKK
    "fixed_adoption", # EEK
    "2007avg",# HUF
    "fixed_adoption", # LVL
    "fixed_adoption", # LTL
    "2007avg",# PLN
    "2007avg",# RON
    "fixed_adoption", # SKK
    "fixed_adoption", # SIT
    "2007avg" ) # SEK  
)

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# inflation data

l_median_net_equiv_income$HICP <- read_csv(
  "data/inflation/prc_hicp_aind_page_linear_2_0.csv") %>%
  select(TIME_PERIOD,`Geopolitical entity (reporting)`,
    `Unit of measure`,OBS_VALUE) %>% # `Time frequency`,
  rename(country=`Geopolitical entity (reporting)`,
    year=TIME_PERIOD,value_2015_base=OBS_VALUE) %>%
    group_by(country) %>%                     # in case you have multiple countries
  mutate(
    value_2007_base = value_2015_base/value_2015_base[year == 2006]*100
    # `Unit of measure` = paste0(`Unit of measure`, " (2006=100)"
      ) %>%
  ungroup()

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# deflate by inflation and convert LCUs to EURO, at 2006 XC rate

l_median_net_equiv_income$data_constant2007 <-
  l_median_net_equiv_income$raw_data %>%
  # -------------------------
  # PIVOT WIDER to get Euro & National currency side by side
  # so we can detect where conversion is needed
  # -------------------------
  pivot_wider(names_from = unit, values_from = value) %>%
  rename(
    eur_nominal = Euro,
    lcu_nominal = `National currency`,
    pps_nominal = `Purchasing power standard (PPS)`
  ) %>%

  # -------------------------
  # FLAG: does this row need LCU -> EUR conversion?
  # i.e. pre-adoption years where LCU != EUR
  # -------------------------
  mutate(needs_conversion = abs(eur_nominal - lcu_nominal) > 0.01) %>%

  # -------------------------
  # JOIN HICP (national, 2007 base)
  # -------------------------
  left_join(
    l_median_net_equiv_income$HICP %>%
      select(country, year, hicp_national = value_2007_base),
    by = c("country", "year")
  ) %>%

  # -------------------------
  # JOIN EU27 HICP (for PPS deflation)
  # -------------------------
  left_join(
    l_median_net_equiv_income$HICP %>%
      filter(country == "European Union - 27 countries (from 2020)") %>%
      select(year, hicp_eu27 = value_2007_base),
    by = "year"
  ) %>%

  # -------------------------
  # JOIN XC RATES
  # -------------------------
  left_join(
    l_median_net_equiv_income$exch_rates %>% 
      select(country, eur_LCU_rate),
      by="country"
  ) %>%

  # -------------------------
  # DEFLATE: constant 2007 prices
  # -------------------------
  mutate(
    # LCU deflated by national HICP
    lcu_constant2007     = lcu_nominal / hicp_national * 100,
    # PPS deflated by EU27 HICP
    pps_constant2007     = pps_nominal / hicp_eu27    * 100,

    # -------------------------
    # CONVERT LCU -> EUR at fixed rate
    # only where pre-adoption (needs_conversion == TRUE)
    # post-adoption: already in EUR, rate = 1
    # -------------------------
    effective_rate       = ifelse(needs_conversion, eur_LCU_rate, 1),
    eur_constant2007     = lcu_constant2007 / effective_rate
  ) %>%

  # -------------------------
  # PIVOT LONGER: stack all value types
  # -------------------------
  select(country, year,
         lcu_nominal, lcu_constant2007,
         eur_constant2007,
         pps_nominal, pps_constant2007) %>%
  pivot_longer(
    cols      = -c(country, year),
    names_to  = "unit",
    values_to = "value"
  ) %>%

  # -------------------------
  # LABEL current_constant and currency dimensions
  # -------------------------
  mutate(
    current_constant = case_when(
      grepl("nominal",   unit) ~ "current",
      grepl("constant",  unit) ~ "constant"
    ),
    currency = case_when(
      grepl("^lcu", unit) ~ "LCU",
      grepl("^eur", unit) ~ "euro_2007",
      grepl("^pps", unit) ~ "PPS"
    ),
    unit = paste0(current_constant, "_", currency)
  )


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# weighted average of EU8 groups

l_median_net_equiv_income$eu8_weighted_average <-
  l_median_net_equiv_income$data_constant2007 %>%
  # keep only EU8 countries
  filter(country %in% l_groups$comp_groups$EU8 &
         !grepl("LCU", currency)) %>%   # exclude LCU — not cross-country comparable
  # join population
  left_join(
    l_pop$total_pop %>% rename(pop = value),
    by = c("country", "year")
  ) %>%
  # weighted average by year + unit series
  group_by(year, unit) %>%
  summarise(
    weighted_avg = sum(value*pop, na.rm=T)/
      sum(pop[!is.na(value)]),.groups = "drop" )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# normalised values

l_median_net_equiv_income$norm_values <- 
  l_median_net_equiv_income$data_constant2007 %>%   # <-- updated
  left_join(
    l_median_net_equiv_income$eu8_weighted_average,
    by = c("year", "unit")
  ) %>%
  mutate(
    `% of EU8` = value / weighted_avg * 100
  )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# check ratios

l_median_net_equiv_income$norm_values %>%
  filter(!grepl("LCU", unit) & country %in% l_groups$list_cntrs$CEE) %>%
  select(country, year, unit, value = `% of EU8`) %>%
  group_by(country, unit) %>%
  filter(year %in% c(2010, 2024)) %>%
  arrange(year) %>%
  summarise(
    base_2010       = value[year == 2010],
    last_val        = value[year == max(year)],
    ratio_2024_2010 = last_val / base_2010,.groups = "drop"
  ) %>%
  select(country, unit, ratio_2024_2010) %>%
  pivot_wider(names_from  = unit,
              values_from = ratio_2024_2010) %>%
  arrange(desc(constant_PPS))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# save init and final (normalised) values

with(list(),{
  
  var_name <- gsub("^output/compare_units/|/$", "", output_folder)
  fixed_min_yr <- 2007
  intermed_yrs <- c(2010,2021)
  last_year_filt <- l_median_net_equiv_income$norm_values %>%
      # filter(country %in% cee_filters[[filt_name]]) %>%
      group_by(unit, country) %>%
      summarise(year = max(year),.groups = "drop") %>%
      summarise(last_year = min(year)) %>%
      pull(last_year)
  min_yr <- max(c(min(l_median_net_equiv_income$norm_values$year),fixed_min_yr))
  
  x <- l_median_net_equiv_income$norm_values %>%
      select(country, year,unit,value=`% of EU8`) %>%
      filter(year %in% c(min_yr,intermed_yrs,last_year_filt)) %>%
      group_by(country, unit) %>%
      summarise(
        val_init = if (any(year == min_yr))  value[year == min_yr] else NA_real_,
        val_2010 = if (any(year == 2010))  value[year == 2010] else NA_real_,
        val_prewar = if (any(year == intermed_yrs[2]))  value[year == intermed_yrs[2]] else NA_real_,
        val_last = if (any(year == last_year_filt))  {
          value[year == last_year_filt]}  else {NA_real_},
        .groups  = "drop" )  %>% 
  filter(!(is.na(val_init) & is.na(val_2010) & is.na(val_last))) %>%
  mutate(variable=var_name,#
        init_yr=min_yr,
        last_yr=last_year_filt) %>%
    relocate(variable,init_yr,last_yr) 
  print(paste0(x$country %>% unique() %>% length()," countries"))
  # show
  print(x)
  
  # save
  x %>%
    write_csv(file = paste0(output_folder,"summ_table.csv"))
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# create plot of dynamics

local({

  save_plot_flag <- T

  for (cee9 in c(T,F)) {
    for (plot_type in c("pct", "abs")) {

      # -------------------------
      # DATA PREP
      # -------------------------
      df_data <- l_median_net_equiv_income$norm_values %>%
        filter(!grepl("LCU", currency) &          # <-- was: currency != "LCU"
                 country %in% l_groups$list_cntrs$CEE)

      if (cee9) {
        df_data <- df_data %>%
          filter(!grepl("Czech|Sloven", country))
      }

      min_year <- min(df_data$year, na.rm = T)
      max_year <- 2024 # max(df_data$year, na.rm = T)

      # -------------------------
      # Y-column setup
      # -------------------------
      if (plot_type=="pct") {
        y_col      <- "% of EU8"
        y_lab      <- "% of EU8"
        plot_title <- "% of EU8 (median net equivalised income) – CEE countries"
      } else {
        y_col      <- "value"
        y_lab      <- "Median net equiv. income (thousands)"
        plot_title <- paste0("Median net equivalised income – absolute values, ",
                             "per capita (thousands) – CEE countries")
      }

      y_sym <- sym(y_col)

      # -------------------------
      # COUNTRY ORDER (always based on % of EU8, constant-PPS)
      # -------------------------
      country_order <- df_data %>%
        select(country, year, val = `% of EU8`, currency, current_constant) %>%
        group_by(country, currency, current_constant) %>%
        filter(year %in% c(2010, max_year)) %>%
        summarise(
          base_2010 = val[year==2010],
          last_val  = val[year==max(year)],
          ratio     = last_val/base_2010,.groups   = "drop"
        ) %>%
        filter(currency=="PPS", current_constant=="constant") %>%
        arrange(desc(ratio)) %>%
        pull(country)

      # -------------------------
      # RATIO LABELS
      # -------------------------
      ratio_df <- df_data %>%
        mutate(country = factor(country, levels = country_order)) %>%
        group_by(country, currency, current_constant) %>%
        # filter(year %in% c(2010, max_year)) %>%
        summarise(
          min_yr_label=min(year),
          base_2010   = (!!y_sym)[year==2010],
          last_val    = (!!y_sym)[year==max_year],
          ratio       = last_val/base_2010,
          perc_change = (ratio - 1) * 100,
          .groups= "drop") %>%
        mutate(
          label = paste0(
            currency, " - ", current_constant, ": ",
            ifelse(perc_change > 0, "+", ""),
            round(perc_change), "%") ) %>%
        group_by(country) %>%
        summarise(label = paste(label, collapse = "\n"),
          min_yr_label=min(min_yr_label))

      # -------------------------
      # MAIN DF + LAST YEAR DF
      # -------------------------
      df_data <- df_data %>%
        mutate(country = factor(country, levels = country_order)) %>%
        arrange(country)

      last_year_df <- df_data %>%
        group_by(country, currency, current_constant) %>%
        filter(year==max_year) %>%
        ungroup()

      # -------------------------
      # PLOT
      # -------------------------
      p <- ggplot(
        data = df_data,
        aes(x= year,y= !!y_sym/ifelse(grepl("abs",plot_type),1e3,1),
          color = paste(currency, current_constant, sep = " - ") )
      ) +
        facet_wrap(~country) +
        geom_line(linewidth = 1) +
        geom_point(shape = 21) +

        # Ratio labels (top-left of each facet)
        geom_text(data= ratio_df,
          aes(x = min_yr_label+1, y = Inf, label = label),
          hjust       = 0.05,
          vjust       = 1.1,
          size        = 3.5,
          inherit.aes = F) +
        # Highlighted last-year points
        geom_point(
          data        = last_year_df,
          aes(x = year, y = !!y_sym/ifelse(grepl("abs",plot_type),1e3,1)),
          size        = 2,
          show.legend = F) +
        # Last-year value labels
        geom_text(
          data = last_year_df,
          aes(
            x = year+1/2,
            y = if (plot_type=="pct") {
                  `% of EU8` + ifelse(current_constant=="constant",-6,5)
                } else {
                  value/1e3 + ifelse(current_constant=="constant",-1.5,1.5)
                },
            label = if (plot_type=="pct") {
                      paste0(round(`% of EU8`), "%")
                    } else {
                      paste0(round(value/1e3, 1))
                    }
          ),
          vjust= 0.5, size = 3.5,show.legend = F) +
        labs(title = plot_title,
          x="",y=y_lab,color = "") +
        scale_x_continuous(breaks = seq(2004, max_year, 8),
                           expand = expansion(c(0.04, 0.1))    ) +
        scale_y_continuous(expand = expansion(c(0.04, 0.1)), 
          limits = c(ifelse(grepl("abs",plot_type),0,NA),NA) ) +
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
        "median_income_dyn",                            # <-- new prefix
        ifelse(cee9,             "_CEE9", ""),
        ifelse(plot_type=="abs", "_abs",  ""),
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
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# plots of ratio changes

local({
  save_plot_flag <- T

  metric_cfg <- list(
    pct = list(
      transform = function(last, base) (last / base - 1) * 100,
      title     = "Median net equivalised income as a share of the EU8 average",
      subtitle  = "Relative change from 2007 or 2010 baseline, in percent",   # <-- 2006→2007
      x_lab     = "Percent change from baseline",
      file_stub = "median_income_pct_change_from_baselines",
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
      title     = "Median net equivalised income as a share of the EU8 average",
      subtitle  = "Absolute change from 2007 or 2010 baseline, in percentage points",  # <-- 2006→2007
      x_lab     = "Change from baseline (pp)",
      file_stub = "median_income_abs_change_from_baselines",
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

    # ── country set ───────────────────────────────────────────────────────────
    cntrs <- if (cee9) {
      setdiff(l_groups$list_cntrs$CEE, c("Czechia", "Slovenia"))
    } else {
      l_groups$list_cntrs$CEE
    }

    # ── single common last year across all series/currencies and countries ────
    last_year_filt <- l_median_net_equiv_income$norm_values %>%
      filter(
        !grepl("LCU", currency),
        country %in% cntrs
      ) %>%
      group_by(currency, current_constant, country) %>%
      summarise(year = max(year, na.rm = TRUE),.groups = "drop") %>%
      summarise(last_year = min(year)) %>%
      pull(last_year)

    message(ifelse(cee9, "CEE9", "full_CEE"), " → common last year: ", last_year_filt)

    for (metric in names(metric_cfg)) {

      cfg <- metric_cfg[[metric]]

      df_change <- l_median_net_equiv_income$norm_values %>%
        filter(
          !grepl("LCU", currency),
          country %in% cntrs
        ) %>%
        select(country, year, currency, current_constant, value = `% of EU8`) %>%
        filter(year %in% c(2007, 2010, last_year_filt)) %>%         # <-- 2006→2007
        group_by(country, currency, current_constant) %>%
        summarise(
          val_2007    = if (any(year == 2007)) value[year == 2007] else NA_real_,  # <-- 2006→2007
          val_2010    = if (any(year == 2010)) value[year == 2010] else NA_real_,
          val_last    = if (any(year == last_year_filt)) value[year == last_year_filt] else NA_real_,
          change_2007 = if (!is.na(val_2007)) cfg$transform(val_last, val_2007) else NA_real_,  # <--
          change_2010 = if (!is.na(val_2010)) cfg$transform(val_last, val_2010) else NA_real_,
          .groups     = "drop"
        )

      country_order <- df_change %>%
        filter(currency == "PPS", current_constant == "constant") %>%
        arrange(change_2010) %>%
        pull(country)

      df_plot <- bind_rows(
        df_change %>%
          transmute(
            country,
            series   = paste(currency, current_constant, sep = " - "),
            period   = paste0("2007\u2013", last_year_filt),          # <-- 2006→2007
            change   = change_2007,                                    # <--
            base_val = val_2007,                                       # <--
            last_val = val_last
          ),
        df_change %>%
          transmute(
            country,
            series   = paste(currency, current_constant, sep = " - "),
            period   = paste0("2010\u2013", last_year_filt),
            change   = change_2010,
            base_val = val_2010,
            last_val = val_last
          )
      ) %>%
        mutate(
          country   = factor(country, levels = country_order),
          period    = factor(period, levels = c(
            paste0("2007\u2013", last_year_filt),                      # <-- 2006→2007
            paste0("2010\u2013", last_year_filt)
          )),
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
            "values in parentheses show the underlying level ",
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

  save_plot_flag <- T
  periods <- c("2006-2024", "2010-2024")
  cee_filters <- list(
    full_CEE = l_groups$list_cntrs$CEE,
    CEE9     = setdiff(l_groups$list_cntrs$CEE, c("Czechia", "Slovenia"))
  )

  for (filt_name in names(cee_filters)) {

    df_base <- l_median_net_equiv_income$norm_values %>%
      filter(!grepl("LCU", unit) &                          # <-- updated
               country %in% cee_filters[[filt_name]]) %>%
      select(country, year, unit, value = `% of EU8`) %>%
      group_by(country, unit) %>%
      filter(year %in% c(2006, 2010, 2024)) %>%
      summarise(
        val_2006 = if (any(year == 2006)) value[year == 2006] else NA_real_,
        val_2010 = if (any(year == 2010)) value[year == 2010] else NA_real_,
        val_last = value[year == max(year)],.groups  = "drop"
      ) %>%
      filter(!is.na(val_2006) | !is.na(val_2010)) %>%
      mutate(
        ch2006_2024_ratio = ifelse(!is.na(val_2006), val_last / val_2006, NA_real_),
        ch2010_2024_ratio = ifelse(!is.na(val_2010), val_last / val_2010, NA_real_),
        ch2006_2024_diff  = ifelse(!is.na(val_2006), val_last - val_2006, NA_real_),
        ch2010_2024_diff  = ifelse(!is.na(val_2010), val_last - val_2010, NA_real_)
      )

    # ---- FOLD CHANGE TABLE ----
    df_ratio <- df_base %>%
      mutate(
        label_2006 = paste0(
          ifelse(ch2006_2024_ratio > 1, "+", ""),
          round((ch2006_2024_ratio - 1) * 100, 1), "% (",
          round(val_2006, 1), "→", round(val_last, 1), ")"
        ),
        label_2010 = paste0(
          ifelse(ch2010_2024_ratio > 1, "+", ""),
          round((ch2010_2024_ratio - 1) * 100, 1), "% (",
          round(val_2010, 1), "→", round(val_last, 1), ")"
        )
      ) %>%
      select(country, unit, label_2006, label_2010) %>%
      pivot_longer(!c(country, unit), names_to = "period") %>%
      mutate(period = paste0(gsub("label_", "", period), "-2024")) %>%
      pivot_wider(values_from = value, names_from = unit)

    for (i in seq_along(periods)) {
      df_out <- df_ratio %>%
        filter(period == periods[i]) %>%
        mutate(sort_val = as.numeric(str_extract(constant_PPS, "-?\\d+\\.?\\d*"))) %>%
        arrange(desc(sort_val)) %>%
        select(-sort_val) %>%
        mutate(across(
            c(constant_PPS, constant_euro_2007, current_PPS),
            ~ paste0("#", rank(-as.numeric(str_extract(., "-?\\d+\\.?\\d*"))), ": ",.)
        ))

      html_table <- format_html_table(df_out)
      writeLines(
        html_table,
        paste0(
          output_folder, "html_tables/median_income_foldchange_",  # <-- new prefix
          periods[i], "_", filt_name, ".html"
        )
      )
    }

    # ---- ABSOLUTE DIFFERENCE TABLE ----
    df_diff <- df_base %>%
      mutate(
        label_2006 = paste0(
          ifelse(ch2006_2024_diff > 0, "+", ""),
          round(ch2006_2024_diff, 1), " (",
          round(val_2006, 1), "→", round(val_last, 1), ")"
        ),
        label_2010 = paste0(
          ifelse(ch2010_2024_diff > 0, "+", ""),
          round(ch2010_2024_diff, 1), " (",
          round(val_2010, 1), "→", round(val_last, 1), ")"
        )
      ) %>%
      select(country, unit, label_2006, label_2010) %>%
      pivot_longer(!c(country, unit), names_to = "period") %>%
      mutate(period = paste0(gsub("label_", "", period), "-2024")) %>%
      pivot_wider(values_from = value, names_from = unit)

    for (i in seq_along(periods)) {
      df_out <- df_diff %>%
        filter(period == periods[i]) %>%
        mutate(sort_val = as.numeric(str_extract(constant_PPS, "-?\\d+\\.?\\d*"))) %>%
        arrange(desc(sort_val)) %>%
        select(-sort_val) %>%
        mutate(across(
          c(constant_PPS, current_PPS, constant_euro_2007),
          ~ paste0("#", rank(-as.numeric(str_extract(., "-?\\d+\\.?\\d*"))), ": ",.)
        ))

      html_table <- format_html_table(df_out)
      writeLines(
        html_table,
        paste0(
          output_folder, "html_tables/median_income_absdiff_",     # <-- new prefix
          periods[i], "_", filt_name, ".html"
        )
      )
    }

  } # end cee filter loop
})

