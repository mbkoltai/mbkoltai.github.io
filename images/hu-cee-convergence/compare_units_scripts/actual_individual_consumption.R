# Actual individual consumption
# EUROSTAT

rm(list = ls())
# load settings
source("fcns/functions_settings.R")
# LOAD data, functions, libraries
source("fcns/load_pop_data.R")

output_folder <- "output/compare_units/actual_indiv_consump/"

l_act_indiv_consump <- list()

# get popul from this
l_act_indiv_consump$pop <- read_csv(
  "data/actual_indiv_consump/prc_ppp_ind_1__custom_20673763_linear_2_0.csv") %>% # geo
  filter(ppp_cat18 %in% "A01") %>%
  select(`Purchasing power parities indicator`, # `Time frequency`,`Type of household`,
         `Geopolitical entity (reporting)`,
          TIME_PERIOD,OBS_VALUE,ppp_cat18) %>%
  rename(country=`Geopolitical entity (reporting)`,
         series=`Purchasing power parities indicator`,
         year=TIME_PERIOD,value=OBS_VALUE) %>%
  relocate(c(country,year),.before = series) %>%
  filter(country %in% c(l_groups$list_cntrs$CEE,
          l_groups$comp_groups$EU8 ) & 
      grepl("Real expenditure per cap|Nominal",series) ) %>% 
  arrange(country,year) %>%
  pivot_wider(names_from = series,values_from = value) %>% 
  mutate(pop=1e6*`Nominal expenditure (in euro)`/
        `Nominal expenditure per inhabitant (in euro)`) %>% 
  select(year,country,pop)

# extract and structure
l_act_indiv_consump$raw_data <- read_csv(
  "data/actual_indiv_consump/prc_ppp_ind_1__custom_20673763_linear_2_0.csv") %>% # geo
  filter(ppp_cat18 %in% "A01") %>%
  select(`Purchasing power parities indicator`, # `Time frequency`,`Type of household`,
         `Geopolitical entity (reporting)`,
          TIME_PERIOD,OBS_VALUE) %>%
  rename(country=`Geopolitical entity (reporting)`,
         series=`Purchasing power parities indicator`,
         year=TIME_PERIOD,value=OBS_VALUE) %>%
  relocate(c(country,year),.before = series) %>%
  filter(country %in% c(l_groups$list_cntrs$CEE,
          l_groups$comp_groups$EU8 ) & 
      grepl("Real expenditure per cap|Nominal",series) ) %>% 
  arrange(country,year) %>%
  pivot_wider(names_from = series,values_from = value) %>% 
  mutate(pop_m=`Nominal expenditure (in euro)`/
        `Nominal expenditure per inhabitant (in euro)`) %>%
  pivot_longer(matches("Nominal|Real"),names_to="unit") %>%
  mutate(value_per_cap=value/ifelse(!grepl("per cap|per inh",unit),pop_m,1)) %>%
  filter(!unit %in% "Nominal expenditure (in euro)") %>%
  select(!value) %>%
  # rename
  mutate(
  unit = case_when(
    grepl("per inhabitant.*euro", unit) ~ "euro_current",
    grepl("national currency", unit)    ~ "LCU_current",
    grepl("PPS", unit)                 ~ "PPS_current",
    T ~ unit  )) %>%
  # select(!c(ppp_cat18,Code,value)) %>%
  relocate(unit,.before=value_per_cap) %>%
  rename(value=value_per_cap)

# the LCU values for cntrs that adopted the euro
# are converted to euros at the XC rate of the time of adoption
  
### ### ### ### ### ### ### ### ### ### ### 
# calculate 2006 eur/LUC exchange rates for those cntrs&yrs not yet in eurozone

l_act_indiv_consump$exch_rates <- tibble(
  country = c("Czechia", "Denmark",
              "Hungary","Poland", "Romania", 
              "Sweden"),
  eur_LCU_rate_2006 = c( 
    28.342,    # CZK
    7.4591,     # DKK
    264.26,    # HUF
    3.8959,     # PLN
    3.5258,     # RON
    9.2544) )

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# inflation data

l_act_indiv_consump$HICP <- read_csv(
  "data/inflation/prc_hicp_aind_page_linear_2_0.csv") %>%
  select(TIME_PERIOD,`Geopolitical entity (reporting)`,
    `Unit of measure`,OBS_VALUE) %>% # `Time frequency`,
  rename(country=`Geopolitical entity (reporting)`,
    year=TIME_PERIOD,value_2015_base=OBS_VALUE) %>%
    group_by(country) %>%  
  mutate(
    value_2006_base = value_2015_base/value_2015_base[year == 2006]*100
    # `Unit of measure` = paste0(`Unit of measure`, " (2006=100)"
      ) %>%
  ungroup()

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# deflate by inflation and convert LCUs to EURO, at 2006 XC rate

l_act_indiv_consump$data_current_constant2006 <- 
  l_act_indiv_consump$raw_data %>%
  filter(!grepl("euro",unit)) %>%
  # join HICP
  left_join(
    l_act_indiv_consump$HICP %>%
      select(country, year, hicp_value = value_2006_base),
    by = c("country", "year")    ) %>%
  # join EU27 HICP for PPS
  left_join(
    l_act_indiv_consump$HICP %>%
      filter(country == "European Union - 27 countries (from 2020)") %>%
      select(year, hicp_eu27 = value_2006_base),
    by = "year"   ) %>%
  mutate(
    value_constant = case_when(
      grepl("LCU", unit) ~ value/hicp_value * 100,
      grepl("PPS", unit) ~ value/hicp_eu27 * 100,
      T ~ value),
    unit_constant = case_when(
      grepl("LCU", unit) ~ "LCU_constant_2006",
      grepl("PPS", unit) ~ "PPS_constant_2006",
      T ~ unit)   ) %>%
  pivot_longer( cols = c(value, value_constant),
        names_to="value_type",
        values_to="value") %>%
mutate(unit = ifelse(value_type %in% "value_constant",
                unit_constant, unit)) %>%
select(!c(unit_constant,value_type)) %>%
left_join(l_act_indiv_consump$exch_rates ) %>%
  # convert to euros at 2006 XC rate
  mutate(
    eur_LCU_rate_2006=ifelse(is.na(eur_LCU_rate_2006) | grepl("PPS",unit),
                    1,eur_LCU_rate_2006),
    euro_constant_2006 = value / eur_LCU_rate_2006 ) %>%
  pivot_longer(
    cols = c(value, euro_constant_2006),   # the columns to stack
    names_to = "new_unit",                      # create a new 'unit' column
    values_to = "value" ) %>%
  filter(!is.na(value)) %>%
  mutate(
  # 1. current vs constant
  current_constant = case_when(
    grepl("constant", unit) ~ "constant",
    TRUE ~ "current"),
  # 2. currency dimension
  currency = case_when(
    grepl("^LCU", unit) & new_unit == "value" ~ "LCU",
    grepl("^LCU", unit) & new_unit == "euro_constant_2006" ~ "euro_2006",
    grepl("^PPS", unit) ~ "PPS") ) %>%
  select(-unit, -new_unit) %>%
  mutate(unit=paste0(current_constant,"-",currency)) %>% 
  distinct()

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# weighted average of EU8 groups

l_act_indiv_consump$eu8_weighted_average <- 
  l_act_indiv_consump$data_current_constant2006 %>%
  # keep only EU8 countries
  filter(country %in% l_groups$comp_groups$EU8 & 
      unit %in% c("constant-euro_2006","current-PPS","constant-PPS") ) %>%
  # join population
  left_join(
    l_pop$total_pop %>% select(!c(Code)) %>%
      rename(pop = value),
    by = c("country", "year")   ) %>%
  # compute weighted average by year + unit (your "series")
  group_by(year, unit) %>%
  summarise(
    weighted_avg = sum(value*pop,na.rm=T)/sum(pop[!is.na(value)]),
    .groups="drop")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# normalised values

l_act_indiv_consump$norm_values <- 
  l_act_indiv_consump$data_current_constant2006 %>%
  filter(unit %in% c("constant-euro_2006","current-PPS","constant-PPS") ) %>%
  # join EU8 averages
  left_join(
    l_act_indiv_consump$eu8_weighted_average,   # your aggregated table
    by = c("year", "unit")  ) %>%
  # compute % of EU8
  mutate(
    `% of EU8` = value / weighted_avg * 100
  ) %>% distinct() %>%
  select(!c(eur_LCU_rate_2006,weighted_avg,hicp_value,hicp_eu27)) %>%
  relocate(value,.after = last_col())

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# check ratios (compared to EU8)

l_act_indiv_consump$norm_values %>%
    # your adjustment
    filter(unit %in% c("constant-euro_2006","current-PPS","constant-PPS") & 
        country %in% l_groups$list_cntrs$CEE) %>%
    # select(country, year, unit,value = `% of EU8` ) %>%
    group_by(country, unit) %>%
    filter(year %in% c(2010, 2024 )) %>% # 2024
    arrange(country,year) %>%
    summarise(
      base_2010 = `% of EU8`[year == 2010],
      last_val  = `% of EU8`[year == max(year)],
      ratio_2024_2010 = last_val / base_2010,
      diff_2024_2010 = last_val - base_2010,
      .groups = "drop") %>%
    select(country, unit, ratio_2024_2010) %>%
    pivot_wider(names_from = unit,
      values_from = ratio_2024_2010) %>%
    arrange(desc(`constant-PPS`))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# save init and final (normalised) values

with(list(),{
  
  var_name <- gsub("^output/compare_units/|/$", "", output_folder)
  fixed_min_yr <- 2004
  last_year_filt <- l_act_indiv_consump$norm_values %>%
      # filter(country %in% cee_filters[[filt_name]]) %>%
      group_by(unit, country) %>%
      summarise(year = max(year),.groups = "drop") %>%
      summarise(last_year = min(year)) %>%
      pull(last_year)
  min_yr <- max(c(min(l_act_indiv_consump$norm_values$year),fixed_min_yr))
  
  intermed_yrs <- c(2010,2021)
  
  x <- l_act_indiv_consump$norm_values %>%
      select(country, year,unit,value=`% of EU8`) %>%
      filter(year %in% c(min_yr,intermed_yrs,last_year_filt)) %>%
      group_by(country, unit) %>%
      summarise(
        val_init = if (any(year == min_yr))  value[year == min_yr] else NA_real_,
        val_2010 = if (any(year == 2010))  value[year == 2010] else NA_real_,
        val_prewar = if (any(year == intermed_yrs[2]))  value[year == intermed_yrs[2]] else NA_real_,
        val_last = if (any(year == last_year_filt))  value[year == last_year_filt]  else NA_real_,
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

  for (cee9 in c(T, F)) {
    for (plot_type in c("pct", "abs")) {

      # -------------------------
      # DATA PREP
      # -------------------------
      df_data <- l_act_indiv_consump$norm_values %>%
        filter(currency != "LCU" & country %in% l_groups$list_cntrs$CEE)

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
        plot_title <- "% of EU8 (actual individual consumption) – CEE countries"
      } else {
        y_col      <- "value"
        y_lab      <- "AIC per capita (thousands)"
        plot_title <- paste0("Actual Individual Consumption – absolute values, ",
        "per capita (thousands) – CEE countries")
      }

      y_sym <- sym(y_col)

      # -------------------------
      # COUNTRY ORDER (always based on % of EU8 PPS constant)
      # -------------------------
      country_order <- df_data %>%
        select(country, year, val = `% of EU8`, currency, current_constant) %>%
        group_by(country, currency, current_constant) %>%
        filter(year %in% c(2010, max_year)) %>%
        summarise(
          base_2010 = val[year == 2010],
          last_val  = val[year == max_year],
          ratio     = last_val / base_2010,.groups   = "drop"
        ) %>%
        filter(currency == "PPS", current_constant == "constant") %>%
        arrange(desc(ratio)) %>%
        pull(country)

      # -------------------------
      # RATIO LABELS
      # -------------------------
      ratio_df <- df_data %>%
        mutate(country = factor(country, levels = country_order)) %>%
        group_by(country, currency, current_constant) %>%
        filter(year %in% c(2010, max_year)) %>%
        summarise(
          base_2010   = (!!y_sym)[year == 2010],
          last_val    = (!!y_sym)[year == max_year],
          ratio       = last_val / base_2010,
          perc_change = (ratio - 1) * 100,.groups     = "drop"
        ) %>%
        mutate(
          label = paste0(
            currency, " - ", current_constant, ": ",
            ifelse(perc_change > 0, "+", ""),
            round(perc_change), "%"
          )
        ) %>%
        group_by(country) %>%
        summarise(label = paste(label, collapse = "\n"),.groups = "drop")

      # -------------------------
      # MAIN DF + LAST YEAR DF
      # -------------------------
      df_data <- df_data %>%
        mutate(country = factor(country, levels = country_order)) %>%
        arrange(country)

      last_year_df <- df_data %>%
        group_by(country, currency, current_constant) %>%
        filter(year == max_year) %>%
        ungroup()

      # -------------------------
      # PLOT
      # -------------------------
      p <- ggplot(data = df_data,
        aes(x= year, y=!!y_sym,
          color=paste(currency, current_constant, sep = " - ") ) ) +
        facet_wrap(~country) +
        geom_line(linewidth = 1) +
        geom_point(shape = 21) +
        # Ratio labels (top-left of each facet)
        geom_text(
          data        = ratio_df,
          aes(x = min_year, y = Inf, label = label),
          hjust       = 0.05,
          vjust       = 1.1,
          size        = 3.5,
          inherit.aes = F) +

        # Highlighted last-year points
        geom_point(
          data = last_year_df,
          aes(x = year, y = !!y_sym),
          size        = 2,
          show.legend = F        ) +

        # Last-year value labels
        geom_text(
          data = last_year_df,
          aes(
            x = year,
            # small nudge up for constant, down for current — scaled to units
            y = if (plot_type == "pct") {
                  `% of EU8` + ifelse(current_constant == "constant",  1, -10)
                } else {
                  value / 1e3 + ifelse(current_constant == "constant",  0.3, -0.8)
                },
            label = if (plot_type == "pct") {
                      paste0(round(`% of EU8`), "%") } else {
                      paste0(round(value / 1e3, 1)) 
                        } ),
          vjust       = 0.5,
          size        = 3.5,
          show.legend = F) +
        labs(title = plot_title,
          x="",y=y_lab,color = "") +
        scale_x_continuous(breaks = seq(2004, max_year, 4)) +
        scale_y_continuous(expand = expansion(c(0.04, 0.1))) +
        theme_bw() + plot_settings +
        theme(axis.text.x= element_text(angle = 0),
          legend.position = "top")

      # -------------------------
      # SAVE
      # -------------------------
      file_name <- paste0(
        output_folder,
        "dyn_from_2006",
        ifelse(cee9,            "_CEE9", ""),
        ifelse(plot_type == "abs", "_abs", ""),
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
# plots of CHANGE ONLY
# absolute change in pp or relative change compared to baseline yr

local({
  save_plot_flag <- T

  metric_cfg <- list(
    pct = list(
      transform = function(last, base) (last / base - 1) * 100,
      title = "Actual individual consumption as a share of the EU8 average",
      subtitle = "Relative change from 2006 or 2010 baseline, in percent",
      x_lab = "Percent change from baseline",
      file_stub = "pct_change_from_baselines",
      scales = "fixed",
      label = function(change, base, last) {
        paste0(
          ifelse(change > 0, "+", ""),
          round(change), "% (",
          round(base), " to ", round(last), "%)"
        )
      }
    ),
    diff = list(
      transform = function(last, base) last - base,
      title = "Actual individual consumption as a share of the EU8 average",
      subtitle = "Absolute change from 2006 or 2010 baseline, in percentage points",
      x_lab = "Change from baseline (pp)",
      file_stub = "abs_change_from_baselines",
      scales = "free_x",
      label = function(change, base, last) {
        paste0(
          ifelse(change > 0, "+", ""),
          round(change), " pp (",
          round(base), " to ", round(last), "%)"
        )
      }
    )
  )

  last_year <- max(l_act_indiv_consump$norm_values$year, na.rm = T)

  for (cee9 in c(T, F)[1] ) {
    for (metric in names(metric_cfg)) {

      cfg <- metric_cfg[[metric]]

      df_change <- l_act_indiv_consump$norm_values %>%
        filter(currency != "LCU", country %in% l_groups$list_cntrs$CEE) %>%
        select(country, year, currency, current_constant, value = `% of EU8`) %>%
        group_by(country, currency, current_constant) %>%
        filter(year %in% c(2006, 2010, last_year)) %>%
        summarise(
          val_2006 = if (any(year == 2006)) value[year == 2006] else NA_real_,
          val_2010 = if (any(year == 2010)) value[year == 2010] else NA_real_,
          val_last = value[year == last_year],
          change_2006 = if (!is.na(val_2006)) cfg$transform(val_last, val_2006) else NA_real_,
          change_2010 = if (!is.na(val_2010)) cfg$transform(val_last, val_2010) else NA_real_,
          .groups = "drop"
        )

      if (cee9) {
        df_change <- df_change %>%
          filter(!grepl("Czech|Sloven", country))
      }

      country_order <- df_change %>%
        filter(currency == "PPS", current_constant == "constant") %>%
        arrange(change_2010) %>%
        pull(country)

      df_plot <- bind_rows(
        df_change %>%
          transmute(
            country,
            series = paste(currency, current_constant, sep = " - "),
            period = paste0("2006\u2013", last_year),
            change = change_2006,
            base_val = val_2006,
            last_val = val_last ),
        df_change %>%
          transmute(
            country,
            series = paste(currency, current_constant, sep = " - "),
            period = paste0("2010\u2013", last_year),
            change = change_2010,
            base_val = val_2010,
            last_val = val_last
          )
      ) %>%
        mutate(
          country = factor(country, levels = country_order),
          period = factor(period, levels = c(
            paste0("2006\u2013", last_year),
            paste0("2010\u2013", last_year)
          )),
          label_txt = cfg$label(change, base_val, last_val)
        )

      dodge_val <- 0.9
      y_positions <- seq_len(length(levels(df_plot$country))) + 0.5

      p <- ggplot(df_plot, aes(x = change, y = country, group = series)) +
        facet_wrap(~period, scales = cfg$scales) +
        geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
        geom_point(
          aes(color = series),
          size = 4,
          position = position_dodge(width = dodge_val)
        ) +
        geom_text( aes(label = label_txt), hjust = -0.1, size = 4,
          position = position_dodge(width = dodge_val) ) +
        geom_hline(
          yintercept = y_positions,
          linewidth = 0.3,
          linetype = "dashed") +
        labs(
          title = cfg$title,
          subtitle = cfg$subtitle,
          x = cfg$x_lab, y = NULL, color = NULL,
          caption = paste0("Labels show the change metric first;", 
          "values in parentheses show the underlying level",
          "as % of the EU8 weighted average.") ) +
        theme_bw() + plot_settings +
        theme(
          legend.position = "top",
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_blank()
        )

      if (metric == "pct") {
        p <- p + scale_x_continuous(
          breaks = seq(0, 200, by = 20),
          expand = expansion(mult = c(0, 0.45))
        )
      } else {
        p <- p + 
          scale_x_continuous(expand = expansion(mult = c(0, 0.45))
        )
      }

      file_name <- paste0( output_folder, cfg$file_stub,
        ifelse(cee9, "_CEE9", ""), ".png" )

      if (save_plot_flag) {
        ggsave( plot = p, filename = file_name,
          width = 30, height = 24, units = "cm" )
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
periods <- c("2006-2024","2010-2024")
cee_filters <- list(
  full_CEE = l_groups$list_cntrs$CEE,
  CEE9 = setdiff(l_groups$list_cntrs$CEE, c("Czechia","Slovenia"))
)

for(filt_name in names(cee_filters)) {

  df_base <- l_act_indiv_consump$norm_values %>%
    filter(!grepl("LCU", unit) & country %in% cee_filters[[filt_name]]) %>%
    select(country, year, unit, value=`% of EU8`) %>%
    group_by(country, unit) %>%
    filter(year %in% c(2006,2010,2024)) %>%
    summarise(
      val_2006 = if(any(year == 2006)) value[year==2006] else NA_real_,
      val_2010 = if(any(year == 2010)) value[year==2010] else NA_real_,
      val_last = value[year==max(year)],
      .groups="drop") %>%
    filter(!is.na(val_2006) | !is.na(val_2010)) %>%
    mutate(
      ch2006_2024_ratio = ifelse(!is.na(val_2006), val_last / val_2006, NA_real_),
      ch2010_2024_ratio = ifelse(!is.na(val_2010), val_last / val_2010, NA_real_),
      ch2006_2024_diff  = ifelse(!is.na(val_2006), val_last - val_2006, NA_real_),
      ch2010_2024_diff  = ifelse(!is.na(val_2010), val_last - val_2010, NA_real_)
    )

  # ---- FOLD CHANGE TABLE ----
  df_ratio <- df_base %>%
    mutate(label_2006 = paste0(ifelse(ch2006_2024_ratio>1,"+",""),
                          round((ch2006_2024_ratio-1)*100,1),"% (",
                          round(val_2006,1),"→",round(val_last,1),")"),
        label_2010 = paste0(ifelse(ch2010_2024_ratio>1,"+",""),
                          round((ch2010_2024_ratio-1)*100,1),"% (",
                          round(val_2010,1),"→",round(val_last,1),")") ) %>%
    select(country, unit, label_2006, label_2010) %>%
    pivot_longer(!c(country, unit), names_to="period") %>%
    mutate(period=paste0(gsub("label_","",period),"-2024")) %>%
    pivot_wider(values_from=value, names_from=unit)

  # ratio tables
  for(i in seq_along(periods)){
    df_out <- df_ratio %>%
      filter(period==periods[i]) %>%
      mutate(sort_val = as.numeric(str_extract(`constant-PPS`,
                    "-?\\d+\\.?\\d*")) ) %>%
      arrange(desc(sort_val)) %>%
      select(-sort_val) %>%
      mutate(across(c(`constant-PPS`,`constant-euro_2006`,`current-PPS` ),
                    ~ paste0("#",rank(-as.numeric(
                      str_extract(.,"-?\\d+\\.?\\d*"))),": ",.)))
    
    # create html table
    html_table <- format_html_table(df_out)
    writeLines(html_table,
               paste0(output_folder,"html_tables/actual_indiv_consump_foldchange_",
                      periods[i],"_",filt_name,".html"))
  }

  # ---- ABSOLUTE DIFFERENCE TABLE ----
  df_diff <- df_base %>%
    mutate(
      label_2006 = paste0(ifelse(ch2006_2024_diff>0,"+",""),
                          round(ch2006_2024_diff,1)," (",
                          round(val_2006,1),"→",round(val_last,1),")"),
      label_2010 = paste0(ifelse(ch2010_2024_diff>0,"+",""),
                          round(ch2010_2024_diff,1)," (",
                          round(val_2010,1),"→",round(val_last,1),")")
    ) %>%
    select(country, unit, label_2006, label_2010) %>%
    pivot_longer(!c(country, unit), names_to="period") %>%
    mutate(period=paste0(gsub("label_","",period),"-2024")) %>%
    pivot_wider(values_from=value, names_from=unit)

  # View(df_diff)
  
  for(i in seq_along(periods)){
    
  df_out <- df_diff %>%
    filter(period == periods[i]) %>%
    # rank by absolute difference, not fold change
          mutate(sort_val = as.numeric(
            str_extract(`constant-PPS`, "-?\\d+\\.?\\d*"))) %>%  # ← just the diff
    arrange(desc(sort_val)) %>%
    select(-sort_val) %>%
    mutate(across(c(`constant-PPS`, `current-PPS`, `constant-euro_2006`),
                ~ paste0("#", rank(-as.numeric(
                  str_extract(., "-?\\d+\\.?\\d*"))), ": ", .)))
    
    # HTML table
    html_table <- format_html_table(df_out)
    writeLines(html_table,
               paste0(output_folder,"html_tables/actual_indiv_consump_absdiff_",
                 periods[i],"_",filt_name,".html"))
  }

} # end cee filter loop
})

