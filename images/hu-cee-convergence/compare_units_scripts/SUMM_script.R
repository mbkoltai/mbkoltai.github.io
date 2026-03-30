# CLEAN UP
rm(list=ls())
# load settings
source("fcns/functions_settings.R")
# LOAD data, functions, libraries
source("fcns/load_pop_data.R") # ; source("fcns/transl_tables.R")

# load all data by variables
output_folder <- "output/compare_units/summary/"


if (file.exists("output/compare_units/summary/summary_table.csv")) {

df_all_eu8norm_init_final_vals <- local({
# ── folders to load ───────────────────────────────────────────────────────────
var_folders <- c(
  "gdp_per_cap",
  "gdp_per_hr_worked",
  "actual_indiv_consump",
  "median_equiv_net_income",
  "median_hourly_earnings",
  "average_annual_wages",
  "gni_per_cap"
)

# ── load all tables into a named list ─────────────────────────────────────────
l_summ_tables <- var_folders %>%
  set_names() %>%
  map(function(folder) {
    path <- paste0("output/compare_units/", folder, "/summ_table.csv")
    
    if (!file.exists(path)) {
      warning("File not found, skipping: ", path)
      return(NULL)
    }
    
    read_csv(path, show_col_types=F) %>%
      mutate(variable=folder) %>%
      rename(any_of(c(unit="series")))   # <-- rename 'series' to 'unit' if exists
                                           #     no-op if column is already called 'unit'
  }) %>%
  compact()

# ── bind all into one long table ──────────────────────────────────────────────
df_summ_all <- l_summ_tables %>%
  bind_rows()                     # variable col already set correctly per table

df_summ_all
})

# unify unit names
df_all_eu8norm_init_final_vals <- df_all_eu8norm_init_final_vals %>%
  mutate(unit_clean=case_when(
    # current PPP/PPS
    str_detect(unit, regex("current",ignore_case=T)) &
    str_detect(unit, regex("pps|ppp",       ignore_case=T)) ~ "current PPP/PPS",
    
    # constant PPP/PPS
    str_detect(unit, regex("const",         ignore_case=T)) &  # <-- const not constant
    str_detect(unit, regex("pps|ppp",       ignore_case=T)) ~ "constant PPP/PPS",
    
    # volume index / constant price (constant + currency, no PPP/PPS)
    str_detect(unit, regex("const",         ignore_case=T)) &  # <-- const not constant
   !str_detect(unit, regex("pps|ppp",       ignore_case=T)) ~ "constant price",
    
    T ~ NA_character_
  ))

### 

local({
unmapped <- df_all_eu8norm_init_final_vals %>%
  filter(is.na(unit_clean)) %>%
  distinct(unit)

if (nrow(unmapped) > 0) {
  warning("Unmapped units found: ", paste(unmapped$unit, collapse=", "))
} else {print("all mapped!")}

})

} else {
  df_all_eu8norm_init_final_vals <- read_csv(
    "output/compare_units/summary/summary_table.csv")
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# scatter plots per variable
# constant price vs constant PPP | current PPP vs constant PPP

local({
  
  save_plot_flag <- T
  
  legend_ratio <- "growth ratio"
  strip_label_names <- c(
    "Constant price" ,
    "Current PPP/PPS" )
  # "Constant price vs\nConstant PPP/PPS",
      # "Current PPP/PPS vs\nConstant PPP/PPS" 
  
  baseline_labels <- c("from 2004*","from 2010")
  
dataset_labels <- c(
    average_annual_wages="Average annual\nwages\n(OECD)",  
    gni_per_cap ="GNI per\ncapita\n(World Bank)",
    gdp_per_cap ="GDP per\ncapita\n(World Bank)",
    gdp_per_hr_worked   ="GDP per hour\nworked\n(OECD)",
    actual_indiv_consump="Actual Individual\nConsumption\n(Eurostat)",
    median_equiv_net_income="Median equiv.\nnet income\n(Eurostat)",
    median_hourly_earnings="Median hourly\nearnings\n(Eurostat)"
  )
  
  # ── compute ratios ──────────────────────────────────────────────────────────
  df_ratios <- df_all_eu8norm_init_final_vals %>%
    filter(!is.na(unit_clean)) %>%
    mutate(
      ratio_from_init=val_last / val_init,
      ratio_from_2010=val_last / val_2010
    ) %>%
    select(variable, country, unit_clean, ratio_from_init, ratio_from_2010)
  
  # ── pivot wide ──────────────────────────────────────────────────────────────
  df_wide <- df_ratios %>%
    pivot_longer(
      cols   =c(ratio_from_init, ratio_from_2010),
      names_to="period",
      values_to="ratio"
    ) %>%
    mutate(period=recode(period,
      ratio_from_init=baseline_labels[1],
      ratio_from_2010=baseline_labels[2]    )) %>%
    pivot_wider(
      names_from=unit_clean,
      values_from=ratio
    ) %>%
    rename_with(~ str_to_lower(.) %>%
                   str_replace_all("[^a-z0-9]+", "_") %>%
                   str_remove("_$"))
  
  # ── build long format for facet_grid ────────────────────────────────────────
  # constant PPP/PPS always on x-axis, two comparisons as rows
  df_plot <- bind_rows(
    df_wide %>%
      transmute(
        variable, country, period,
        x=constant_ppp_pps,
        y=constant_price,
        comparison=strip_label_names[1] ),
    df_wide %>%
      transmute(
        variable, country, period,
        x=constant_ppp_pps,
        y=current_ppp_pps,
        comparison=strip_label_names[2] )
  ) %>%
  filter(!is.na(x)) %>%
  mutate(
    # ── relabel variable names ───────────────────────────────────────────────
    variable=factor(
      variable,
      levels=names(dataset_labels),   # control order
      labels=dataset_labels            # apply labels
    ),
    comparison=factor(comparison, levels=strip_label_names )
  )
  
  # ── layout dims ─────────────────────────────────────────────────────────────
  n_vars <- n_distinct(df_plot$variable)
  n_comp <- 2   # fixed: two comparison types=two rows
  
  for (log_flag in c(F,T)) {
  p <- ggplot(df_plot, aes(x=x, y=y)) +
    facet_grid(
      rows=vars(comparison),
      cols=vars(variable),
      scales="free" ) +
  geom_abline(slope=1, intercept=0,
                linetype="dashed", color="grey50") +
    # ── layer 1: green stroke ring ───────────────────────────────────────────────
geom_point(
  data=df_plot %>% filter(grepl("Hun", country)),
  aes(shape=period), fill=NA,
  size=4, stroke=1, color="#00CC00",
  show.legend=F) +
# ── layer 2: normal points ───────────────────────────────────────────────────
geom_point(
  aes(fill=period, shape=period),   # <-- fill not color for shapes 21-24
  size=3,
  stroke=0.3,
  color="grey30" ) +
  scale_fill_manual( name=legend_ratio,
            values=setNames( c("#E41A1C", "#377EB8"),
                baseline_labels ) ) +
  scale_shape_manual( name=legend_ratio,
              values=setNames( c(21, 24), baseline_labels ) ) +
  # highlight outliers
  geom_text_repel(
    data=df_plot %>% filter(y/x >=1.2 | x/y >=1.2),
    aes(label=country,color=period),
        size=4,alpha=2/3,color="black",max.overlaps=20, 
  # ── these make it point to the dot ────────────────────────────────────────
  # point.size=3,          # should match your geom_point size
  box.padding=0.5,        # space between label and connector line end
  # point.padding=0.3,        # space between connector line start and dot
  min.segment.length=0,    # always draw segment even if label is close
  segment.size=0.4,        # thickness of connector line
  # segment.alpha=0.6 # transparency of connector line
      ) +
### ### ### ### ### ### ### ### ### ### 
  labs( title="Growth ratios from mid-2000s and 2010 to 2024",
          subtitle=paste0(
            "All values normalised by EU8** weighted average.\n",
            "Green highlights=Hungary.\n",
            "X-axis always constant PPP/PPS.\n",  
            "Ratio=(last value) / (baseline value)"),
      x="Constant PPP/PPS", y=NULL,
      color =legend_ratio, shape =legend_ratio,
      caption=paste0("Dashed line=1:1.\n",
        # "Points above: y-axis measure shows faster growth than x-axis.\n",
        "*Baseline year for median equiv. net income=2006,",
        "for median hourly earnings=2007.\n",
        "Baseline=2004 for all other variables.\n",
        "**EU8=Germany, Austria, France, Netherlands, Belgium, Sweden, Denmark, Finland."
        ) ) +
    theme_bw() + plot_settings +
    theme( legend.position="top",
        legend.title=element_text(size=13),
        strip.text.x=element_text(size=13),   # variable names on top
        strip.text.y=element_text(size=13),   # comparison labels on side
        axis.text=element_text(size=7) )
  
  file_name <- paste0(output_folder, 
    "scatter_ratio_comparisons",ifelse(log_flag,"_log",""),".png")
  
  if (save_plot_flag) {
    ggsave(
      plot   =p,
      filename=file_name,
      width  =40, height=20,     # scale with number of comparisons
      units  ="cm",
      limitsize=F )
  }
  
  print(p)
  }
  
})


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# PLOTTING how RANKING changes by metric

# separate or together from 2004/2006 and from 2010 plots

local({

  save_flag <- T

  # ── labels ──────────────────────────────────────────────────────────────────
  dataset_labels <- c(
    average_annual_wages= "Average annual\nwages\n(OECD)",
    gni_per_cap ="GNI per\ncapita\n(World Bank)",
    gdp_per_cap ="GDP per\ncapita\n(World Bank)",
    gdp_per_hr_worked= "GDP per hour\nworked\n(OECD)",
    actual_indiv_consump= "Actual Individual\nConsumption\n(Eurostat)",
    median_equiv_net_income= "Median equiv.\nnet income\n(Eurostat)",
    median_hourly_earnings="Median hourly\nearnings\n(Eurostat)"
  )

  metric_labels <- c(
    foldchange="Relative change (%)",
    absdiff="Absolute change (pp)"
  )

  # ── geometry constants ───────────────────────────────────────────────────────
  tile_half_h  <- 0.04
  n_series     <- 3
  tile_height  <- tile_half_h * 2
  period_step  <- tile_height * n_series

  series_offsets <- c(
    vol_index= -tile_height,
    ppp_const=  0,
    ppp_current= tile_height
  )

  cee_filters <- list(
    CEE11=l_groups$list_cntrs$CEE,
    CEE9=setdiff(l_groups$list_cntrs$CEE, c("Czechia", "Slovenia"))
  )

  # ── harmonise: keep only countries with ALL units per variable ───────────────
  df_data <- df_all_eu8norm_init_final_vals %>%
    filter(!is.na(unit_clean)) %>%
    group_by(variable, country) %>%
    mutate(country_units=n_distinct(unit_clean)) %>%
    ungroup() %>%
    group_by(variable) %>%
    mutate(target_units=max(country_units)) %>%
    ungroup() %>%
    filter(country_units == target_units) %>%
    select(-country_units, -target_units)

  # ── diagnostic ───────────────────────────────────────────────────────────────
  dropped <- df_all_eu8norm_init_final_vals %>%
    filter(!is.na(unit_clean)) %>%
    group_by(variable, country) %>%
    mutate(country_units=n_distinct(unit_clean)) %>%
    ungroup() %>%
    group_by(variable) %>%
    mutate(target_units=max(country_units)) %>%
    ungroup() %>%
    filter(country_units < target_units) %>%
    distinct(variable, country, country_units, target_units)

  if (nrow(dropped) > 0) {
    message("Dropping these country×variable combos (incomplete units):")
    print(dropped)
  }

  # ── caption: once outside all loops ─────────────────────────────────────────
  start_year_note <- df_data %>%
    distinct(variable, init_yr) %>%
    filter(!init_yr %in% c(2004, 2010)) %>%
    mutate(
      label=gsub("\n",            " ", dataset_labels[variable]),
      label=gsub("\\s*\\(.*?\\)", "", label),
      label=trimws(label)
    ) %>%
    arrange(init_yr) %>%
    group_by(init_yr) %>%
    summarise(note=paste(label, collapse=", "),.groups="drop") %>%
    mutate(line=paste0(note, "=", init_yr)) %>%
    pull(line) %>%
    paste(collapse=", ") %>%
    paste0("Initial year for ",.)

  # ── pre-compute long data with metrics + ranks ───────────────────────────────
  df_long <- map_dfr(names(cee_filters), function(cee_choice) {

    cntrs <- cee_filters[[cee_choice]]

    df_data %>%
      filter(country %in% cntrs) %>%
      mutate(
        series_type=case_when(
          unit_clean == "constant price"   ~ "vol_index",
          unit_clean == "constant PPP/PPS" ~ "ppp_const",
          unit_clean == "current PPP/PPS"  ~ "ppp_current",
          T                             ~ NA_character_
        )
      ) %>%
      filter(!is.na(series_type)) %>%
      pivot_longer(
        cols= c(val_init, val_2010),
        names_to="period_base",
        values_to="base_val"
      ) %>%
      mutate(
        period_base=recode(period_base, val_init="init", val_2010="2010"),
        period_group=ifelse(period_base == "2010", "from 2010", "from\ninitial year"),
        foldchange= (val_last / base_val - 1) * 100,
        absdiff= val_last - base_val
      ) %>%
      pivot_longer(
        cols= c(foldchange, absdiff),
        names_to="metric_type",
        values_to="change"
      ) %>%
      filter(!is.na(change)) %>%
      # ── rank within variable × series × metric × period ──────────────────────
      group_by(variable, series_type, metric_type, period_base) %>%
      mutate(rank=rank(-change, ties.method="min")) %>%
      ungroup() %>%
      mutate(
        cee_filter=cee_choice,
        # ── facet order follows dataset_labels ──────────────────────────────
        variable= factor(variable, levels=names(dataset_labels))
      )
  })

  # ── outer loops ──────────────────────────────────────────────────────────────
  for (country_choice in c("Hungary")) {
    for (cee_choice in c("CEE9", "CEE11") ) {
      for (metric_choice in c("foldchange", "absdiff", "both") ) {
        # <-- replaces period_choice

        # ── always both baseline years ────────────────────────────────────────
        period_levels_plot <- c("from 2010", "from\ninitial year")

        # ── filter to country + cee + metric ─────────────────────────────────
        df_plot <- df_long %>%
          filter(
            country == country_choice,
            cee_filter == cee_choice,
            case_when(
              metric_choice == "foldchange" ~ metric_type == "foldchange",
              metric_choice == "absdiff"    ~ metric_type == "absdiff",
              metric_choice == "both"       ~ T
            )
          ) %>%
          mutate(
            series_type=factor(series_type,
                             levels=c("vol_index", "ppp_const", "ppp_current")),
            metric_type=factor(metric_type,
                             levels=c("foldchange", "absdiff")),
            # ── always generic period_group label ────────────────────────────
            period_group=factor(
              ifelse(period_base == "2010", "from 2010", "from\ninitial year"),
              levels=rev(period_levels_plot)
            ),
            period_y=match(period_group, rev(period_levels_plot)) * period_step,
            y_pos=period_y + series_offsets[as.character(series_type)]
          )

        # ── y axis: always two baseline rows ─────────────────────────────────
        y_limits <- c(period_step   - tile_height - tile_half_h,
                      2*period_step + tile_height + tile_half_h)
        y_breaks <- seq_along(period_levels_plot) * period_step
        y_labels <- period_levels_plot
        hline_y  <- mean(c(1, 2) * period_step)

        n_ranks <- length(cee_filters[[cee_choice]]) # max(df_plot$rank, na.rm=T)

        # ── background grid ───────────────────────────────────────────────────
        df_grid <- df_plot %>%
          distinct(variable, metric_type, y_pos) %>%
          crossing(rank=1:n_ranks) %>%
          mutate(
            xmin=rank - 0.5, xmax=rank + 0.5,
            ymin=y_pos - tile_half_h, ymax=y_pos + tile_half_h
          )

        # ── filled boxes ──────────────────────────────────────────────────────
        df_filled <- df_plot %>%
          filter(!is.na(rank)) %>%
          mutate(
            series_label=case_when(
              grepl("vol",       series_type) ~ "constant price, not PPP (volume index)",
              grepl("ppp_const", series_type) ~ "constant PPP/PPS",
              grepl("ppp_curr",  series_type) ~ "current PPP/PPS"
            ),
            xmin=rank - 0.5, xmax=rank + 0.5,
            ymin=y_pos - tile_half_h, ymax=y_pos + tile_half_h
          )

        # ── title + filename ──────────────────────────────────────────────────
        metric_label <- case_when(
          metric_choice == "foldchange" ~ "relative change",
          metric_choice == "absdiff"    ~ "absolute change",
          metric_choice == "both"       ~ "relative and absolute change"
        )

        

        # ── facet: metric_choice drives rows ─────────────────────────────────
        facet_formula <- if (metric_choice == "both") {
          facet_grid(
            metric_type ~ variable,
            labeller=labeller(
              variable=dataset_labels,
              metric_type=metric_labels
            )
          )
        } else {
          facet_grid(. ~ variable,
            labeller=labeller(variable=dataset_labels)
          )
        }

        # ── plot ──────────────────────────────────────────────────────────────
        p <- ggplot() +

          geom_rect(
            data=df_grid,
            aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),
            fill="grey95", color="grey60", linewidth=0.3, inherit.aes=F
          ) +

          geom_rect(
            data=df_filled,
            aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax,
                fill=series_label),
            color="grey30", linewidth=0.3, alpha=0.85, inherit.aes=F
          ) +

          geom_text(
            data=df_filled,
            aes(x=rank, y=y_pos, label=rank),
            size=5, color="white", fontface="bold", show.legend=F
          ) +

          geom_hline(yintercept=hline_y, linewidth=2) +

          facet_formula +

          scale_x_continuous(
            breaks=seq(1, n_ranks, 2),
            limits=c(0.5, n_ranks + 0.5),
            expand=expansion(mult=c(0, 0))
          ) +
          scale_y_continuous(
            limits=y_limits,
            breaks=y_breaks,
            labels=y_labels,
            expand=expansion(mult=c(0, 0))
          ) +
          scale_fill_manual(
            values=c(
              "constant price, not PPP (volume index)"="#E41A1C",
              "constant PPP/PPS"   ="#4DAF4A",
              "current PPP/PPS"    ="#377EB8"
            )
          ) +

          labs(
            title= paste0(country_choice, "'s convergence rank — ",
                             metric_label, " — ", cee_choice),
            x="Rank (1=strongest convergence)",
            y="",
            fill="",
            caption=paste0(
              # "Fill=series type. Both baseline years always shown.\n",
              ifelse(nchar(start_year_note) > 0,
                     paste0(start_year_note, ""), ""),
              ", 2004 for all other variables.", "\n",
              "All HU and CEE levels normalised to weighted average",
                " of EU8 (DE,FR,NL,BE,SE,DK,FI,AT).",
              ifelse(grepl("9",cee_choice),"\nCEE9 does not include Czechia and Slovenia.","")
            )
          ) +

          theme_bw() + plot_settings +
          theme(
            legend.position="top",
            axis.text.x=element_text(angle=0),
            axis.text.y=element_text(),    # always shown (always 2 baselines)
            axis.ticks.y=element_line(),
            panel.grid.minor= element_blank(),
            panel.grid.major.x=element_blank(),
            panel.grid.major.y=element_blank(),
            strip.text.x=element_text(size=14),
            plot.caption=element_text(hjust=0),
            panel.spacing.y=unit(0.8, "cm") )

        file_name <- paste0(
            "output/compare_units/summary/rank/",
            metric_choice,"/",
            tolower(gsub(" ", "_", country_choice)), "_",
            "ranking_", metric_choice, "_",
            tolower(cee_choice), ".png" )

        # ── save ──────────────────────────────────────────────────────────────
        if (save_flag) {
          ggsave(
            plot= p,
            filename=file_name,
            width=ifelse(metric_choice == "both", 54, 48),
            height=ifelse(metric_choice == "both", 36, 24),
            units="cm",
            limitsize=F
          )
        }

        try(print(p), silent=T)

      } # end metric_choice
    }   # end cee_choice
  }     # end country_choice
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# HU vs CEE CHANGE averages/medians



local({

  save_flag <- T
  
  country_labels_hu <- c(
  "Bulgaria"= "Bulgária",
  "Croatia"= "Horvátország",
  "Czechia"= "Csehország",
  "Estonia"= "Észtország",
  "Hungary"= "Magyaro.",
  "Latvia" = "Lettország",
  "Lithuania"= "Litvánia",
  "Poland" = "Lengyelo.",
  "Romania"= "Románia",
  "Slovakia"= "Szlovákia",
  "Slovenia"= "Szlovénia" )

  
  # ── labels ───────────────────────────────────────────────────────────────────
  dataset_labels <- c(
    average_annual_wages   = "Átlagos éves\nbérek (OECD)",
    gni_per_cap   = "GNI egy főre\n(Világbank)",
    gdp_per_cap   = "GDP egy főre\n(Világbank)",
    gdp_per_hr_worked      = "GDP/munkaóra\n(OECD)",
    actual_indiv_consump   = "Tényleges egyéni\nfogyasztás\n(Eurostat)",
    median_equiv_net_income= "Medián ekviv.\nnettó jövedelem\n(Eurostat)",
    median_hourly_earnings = "Medián órabér\n(Eurostat)"
  )

  metric_labels <- c(
    foldchange = "Relatív változás (%)",
    absdiff    = "Abszolút változás (százalékpont)"
  )

  # ── no constant PPP — only 2 series ──────────────────────────────────────────
  color_fill_vals <- c(
    "Állandó áron (volumenindex, nem PPP)" = "#E41A1C",
    "Folyó PPP/PPS"= "#377EB8"
  )

  metric_label_legend <- ""

  agg_labels <- c(
    wtd_levels  = "szintek súlyozott átlaga → változás",
    wtd_changes = "változások súlyozott átlaga"
  )

  # ── output dir ───────────────────────────────────────────────────────────────
  out_path <- paste0(output_folder, "HU_plots/")
  if (!dir.exists(out_path)) {
    dir.create(out_path, recursive = T)
    message("Created: ", out_path)
  }

  # ── cee filters with Hungarian country names ──────────────────────────────────
  cee_filters <- list(
    KKE11 = recode(l_groups$list_cntrs$CEE, !!!country_labels_hu),
    KKE9  = recode(setdiff(l_groups$list_cntrs$CEE,
                           c("Czechia", "Slovenia")), !!!country_labels_hu)
  )

  # ── harmonise + translate country names ──────────────────────────────────────
  df_data <- df_all_eu8norm_init_final_vals %>%
    mutate(country = recode(country, !!!country_labels_hu)) %>%
    filter(!is.na(unit_clean)) %>%
    group_by(variable, country) %>%
    mutate(n_units = n_distinct(unit_clean)) %>%
    ungroup() %>%
    group_by(variable) %>%
    mutate(max_units = max(n_units)) %>%
    ungroup() %>%
    filter(n_units == max_units) %>%
    select(-n_units, -max_units)

  # ── caption ──────────────────────────────────────────────────────────────────
  start_year_note <- df_data %>%
    distinct(variable, init_yr) %>%
    filter(!init_yr %in% c(2004, 2010)) %>%
    mutate(
      label = gsub("\n",            " ", dataset_labels[variable]),
      label = gsub("\\s*\\(.*?\\)", "", label),
      label = trimws(label)
    ) %>%
    arrange(init_yr) %>%
    group_by(init_yr) %>%
    summarise(note = paste(label, collapse = ", "),.groups = "drop") %>%
    mutate(line = paste0(note, "=", init_yr)) %>%
    pull(line) %>%
    paste(collapse = "\n") %>%
    paste0("Bázisév: ",.)

  # ── population weights ───────────────────────────────────────────────────────
  df_pop_weights <- df_data %>%
    distinct(variable, country, init_yr, last_yr) %>%
    mutate(yr_2010 = 2010L) %>%
    pivot_longer(
      cols      = c(init_yr, yr_2010, last_yr),
      names_to  = "time_point",
      values_to = "year_target"
    ) %>%
    left_join(
      l_pop$total_pop %>%
        filter(year >= 2004) %>%
        mutate(country = recode(country, !!!country_labels_hu)) %>%  # <-- translate pop too
        select(country, year_target = year, pop = value)
    ) %>%
    select(variable, country, time_point, pop) %>%
    pivot_wider(
      names_from   = time_point,
      values_from  = pop,
      names_prefix = "pop_"
    ) %>%
    rename(
      pop_init = pop_init_yr,
      pop_2010 = pop_yr_2010,
      pop_last = pop_last_yr
    )

  # ── pre-compute CEE aggregates ────────────────────────────────────────────────
  df_cee_aggs <- map_dfr(names(cee_filters), function(cee_choice) {

    cntrs <- cee_filters[[cee_choice]]

    df_base <- df_data %>%
      filter(country %in% cntrs, !is.na(unit_clean)) %>%
      mutate(
        series_type = case_when(
          unit_clean == "constant price"  ~ "vol_index",
          unit_clean == "current PPP/PPS" ~ "ppp_current",
          T                            ~ NA_character_   # <-- drop ppp_const
        )
      ) %>%
      filter(!is.na(series_type)) %>%
      left_join(df_pop_weights, by = c("variable", "country"))

    # Approach A: weighted avg of levels → change
    df_A <- df_base %>%
      group_by(variable, series_type) %>%
      summarise(
        wtd_val_init = weighted.mean(val_init, w = pop_init, na.rm = T),
        wtd_val_2010 = weighted.mean(val_2010, w = pop_2010, na.rm = T),
        wtd_val_last = weighted.mean(val_last, w = pop_last, na.rm = T),.groups = "drop"
      ) %>%
      pivot_longer(
        cols      = c(wtd_val_init, wtd_val_2010),
        names_to  = "period_base",
        values_to = "base_val"
      ) %>%
      mutate(
        period_base  = recode(period_base,
                         wtd_val_init = "init",
                         wtd_val_2010 = "2010"),
        period_group = ifelse(period_base == "2010",
                         "2010-től", "a bázisévtől"),
        foldchange   = (wtd_val_last / base_val - 1) * 100,
        absdiff      = wtd_val_last - base_val
      ) %>%
      pivot_longer(
        cols      = c(foldchange, absdiff),
        names_to  = "metric_type",
        values_to = "cee_agg"
      ) %>%
      mutate(agg_method = "wtd_levels")

    # Approach B: change per country → weighted avg
    df_B <- df_base %>%
      pivot_longer(
        cols      = c(val_init, val_2010),
        names_to  = "period_base",
        values_to = "base_val"
      ) %>%
      mutate(
        period_base  = recode(period_base, val_init = "init", val_2010 = "2010"),
        period_group = ifelse(period_base == "2010",
                         "2010-től", "a bázisévtől"),
        weight= case_when(
          period_base == "init" ~ pop_init,
          period_base == "2010" ~ pop_2010
        ),
        foldchange   = (val_last / base_val - 1) * 100,
        absdiff      = val_last - base_val
      ) %>%
      pivot_longer(
        cols      = c(foldchange, absdiff),
        names_to  = "metric_type",
        values_to = "change"
      ) %>%
      group_by(variable, series_type, metric_type, period_base, period_group) %>%
      summarise(
        cee_agg = weighted.mean(change, w = weight, na.rm = T),.groups = "drop"
      ) %>%
      mutate(agg_method = "wtd_changes")

    bind_rows(df_A, df_B) %>%
      mutate(cee_filter = cee_choice)
  })

  # ── Hungary long ─────────────────────────────────────────────────────────────
  country_choice <- "Magyaro."

  df_hu_long <- df_data %>%
    filter(country == country_choice, !is.na(unit_clean)) %>%
    mutate(
      series_type = case_when(
        unit_clean == "constant price"  ~ "vol_index",
        unit_clean == "current PPP/PPS" ~ "ppp_current",
        T                            ~ NA_character_   # <-- drop ppp_const
      )
    ) %>%
    filter(!is.na(series_type)) %>%
    pivot_longer(
      cols      = c(val_init, val_2010),
      names_to  = "period_base",
      values_to = "base_val"
    ) %>%
    mutate(
      period_base  = recode(period_base, val_init = "init", val_2010 = "2010"),
      period_group = ifelse(period_base == "2010",
                       "2010-től", "a bázisévtől"),
      foldchange   = (val_last / base_val - 1) * 100,
      absdiff      = val_last - base_val
    ) %>%
    pivot_longer(
      cols      = c(foldchange, absdiff),
      names_to  = "metric_type",
      values_to = "hu_change"
    )

  # ── outer loops ──────────────────────────────────────────────────────────────
  for (cee_choice in c("KKE9", "KKE11")) {
    for (agg_method in c("wtd_levels","wtd_changes")) {
      for (metric_choice in c("foldchange", "absdiff", "both")) {

        # ── filter Hungary ──────────────────────────────────────────────────────
        df_hu <- df_hu_long %>%
          filter(
            case_when(
              metric_choice == "foldchange" ~ metric_type == "foldchange",
              metric_choice == "absdiff"    ~ metric_type == "absdiff",
              metric_choice == "both"       ~ T
            )
          ) %>%
          mutate(
            variable     = factor(variable, levels = names(dataset_labels)),
            series_type  = factor(series_type,
                             levels = c("vol_index", "ppp_current")),
            metric_type  = factor(metric_type,
                             levels = c("foldchange", "absdiff")),
            period_group = factor(period_group,
                             levels = c("a bázisévtől", "2010-től"))
          )

        # ── filter CEE agg ──────────────────────────────────────────────────────
        df_cee <- df_cee_aggs %>%
          filter(
            cee_filter == cee_choice,
            agg_method == !!agg_method,
            case_when(
              metric_choice == "foldchange" ~ metric_type == "foldchange",
              metric_choice == "absdiff"    ~ metric_type == "absdiff",
              metric_choice == "both"       ~ T
            )
          ) %>%
          mutate(
            variable     = factor(variable, levels = names(dataset_labels)),
            series_type  = factor(series_type,
                             levels = c("vol_index", "ppp_current")),
            metric_type  = factor(metric_type,
                             levels = c("foldchange", "absdiff")),
            period_group = factor(period_group,
                             levels = c("a bázisévtől", "2010-től"))
          )

        # ── join ─────────────────────────────────────────────────────────────────
        df_plot <- left_join(
          df_hu, df_cee,
          by = c("variable", "series_type", "metric_type", "period_group")
        ) %>%
          mutate(
            series_label = case_when(
              grepl("vol",      series_type) ~ "Állandó áron (volumenindex, nem PPP)",
              grepl("ppp_curr", series_type) ~ "Folyó PPP/PPS"
            )
          )

        # ── metric label ──────────────────────────────────────────────────────────
        metric_label <- case_when(
          metric_choice == "foldchange" ~ "relatív változás",
          metric_choice == "absdiff"    ~ "abszolút változás",
          metric_choice == "both"       ~ "relatív és abszolút változás"
        )

        # ── facet formula ─────────────────────────────────────────────────────────
        facet_formula <- if (metric_choice == "both") {
          facet_grid(
            metric_type + period_group ~ variable,
            labeller = labeller(
              variable     = dataset_labels,
              metric_type  = metric_labels,
              period_group = label_value
            ),
            scales = "free_y"
          )
        } else {
          facet_grid(
            period_group ~ variable,
            labeller = labeller(
              variable     = dataset_labels,
              period_group = label_value
            ),
            scales = "free_y"
          )
        }

        # ── plot ──────────────────────────────────────────────────────────────────
        p <- ggplot(df_plot, aes(x = series_label, color = series_label)) +

          # CEE aggregate square
          geom_point(
            aes(y     = cee_agg,
                fill  = series_label,
                shape = cee_choice),
            size = 5, stroke = 0.8, color = "black", alpha = 2/3
          ) +
          geom_text(
            aes(y     = cee_agg,
                label = sprintf("%.1f", cee_agg)),
            vjust = -0.95, hjust = 0.5, size = 4.5, show.legend = F
          ) +

          # Hungary circle
          geom_point(
            aes(y     = hu_change,
                fill  = series_label,
                shape = country_choice),
            size = 5, stroke = 0.8, color = "black", alpha = 2/3
          ) +
          geom_text(
            aes(y = hu_change, label = sprintf("%.1f", hu_change)),
            hjust = -0.45, size = 4.5, show.legend = F
          ) +

          geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
          geom_segment(
            aes(x = series_label, xend = series_label,
                y = hu_change,    yend = cee_agg),
            linewidth = 1, linetype = "dotted", show.legend = F
          ) +

          scale_shape_manual(values = c(
            setNames(22, cee_choice),
            "Magyaro." = 21
          )) +
          scale_fill_manual(values  = color_fill_vals) +
          scale_color_manual(values = color_fill_vals) +
          guides(
            fill  = guide_legend(override.aes = list(shape = 21, color = "black")),
            shape = guide_legend(override.aes = list(fill  = "grey50", color = "black"))
          ) +
          scale_y_continuous(expand = expansion(c(0.02, 0.135))) +
          scale_x_discrete(expand   = expansion(add = c(0.3, 0.6))) +

          facet_formula +

          labs(
            title   = paste0(
              "Magyarország vs ", cee_choice,
              " — ", metric_label, " — 2024-ig"
            ),
            x= "",
            y= case_when(
              metric_choice == "foldchange" ~ "Relatív változás (%)",
              metric_choice == "absdiff"    ~ "Abszolút változás (százalékpont)",
              metric_choice == "both"       ~ "Változás a bázisévhez képest"
            ),
            color   = metric_label_legend,
            fill    = metric_label_legend,
            shape   = "",
            caption = paste0(
              "Karika = Magyarország. ",
              "Négyzet = ", cee_choice,
              " népességgel súlyozott átlag",
              " (", agg_labels[agg_method], ").\n",
              ifelse(nchar(start_year_note) > 0,
                     paste0(gsub("\n", ", ", start_year_note),
                            ", minden más változónál 2004"),
                     ""), "\n",
              "Minden magyarországi és KKE-szintű érték az EU8 súlyozott átlagához viszonyítva",
              " (DE, FR, NL, BE, SE, DK, FI, AT).",
              ifelse(grepl("9", cee_choice),
                     "\nA KKE9 nem tartalmazza Csehországot és Szlovéniát.", "")
            )
          ) +

          theme_bw() + plot_settings +
          theme(
            legend.position    = "top",
            legend.box= "vertical",
            axis.text.x= element_blank(),
            axis.ticks.x= element_blank(),
            panel.grid.minor   = element_blank(),
            panel.grid.major.x = element_blank(),
            strip.text.x= element_text(size = 16),
            strip.text.y= element_text(size = 16),
            plot.caption= element_text(hjust = 0),
            panel.spacing.y    = unit(0.5, "cm")
          )

        # ── save ──────────────────────────────────────────────────────────────────
        file_name <- paste0(
          out_path,"change/",metric_choice,"/",
          "valtozas_", metric_choice, "_",
          tolower(cee_choice), "_",
          gsub("_", "-", agg_method),
          ".png" )

        if (save_flag) {
          ggsave(
            plot      = p,
            filename  = file_name,
            width     = 48,
            height    = case_when(
              metric_choice == "both" ~ 36,
              T ~ 20 ),
            units= "cm", limitsize = F )
        }

        try(print(p), silent = T)

      } # end metric_choice
    }   # end agg_method
  }     # end cee_choice
})
