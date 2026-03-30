# CLEAN UP
rm(list = ls())
# load settings
source("fcns/functions_settings.R")
# LOAD data, functions, libraries
source("fcns/load_pop_data.R")

output_folder <- "output/compare_units/summary/"

# ── country name translations (global — used in all plot blocks) ───────────────
country_labels_hu <- c(
  "Bulgaria"  = "Bulgária",
  "Croatia"   = "Horvátország",
  "Czechia"   = "Csehország",
  "Estonia"   = "Észtország",
  "Hungary"   = "Magyarország",
  "Latvia"    = "Lettország",
  "Lithuania" = "Litvánia",
  "Poland"    = "Lengyelország",
  "Romania"   = "Románia",
  "Slovakia"  = "Szlovákia",
  "Slovenia"  = "Szlovénia"
)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# LOAD data
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

cache_path <- "output/compare_units/summary/summary_table_with2021.csv"

if (file.exists(cache_path)) {

  df_all_eu8norm_init_final_vals <- read_csv(cache_path, show_col_types = FALSE)

} else {

  df_all_eu8norm_init_final_vals <- local({

    # ── folders to load ─────────────────────────────────────────────────────────
    var_folders <- c(
      "gdp_per_cap",
      "gdp_per_hr_worked",
      "actual_indiv_consump",
      "median_equiv_net_income",
      "median_hourly_earnings",
      "average_annual_wages",
      "gni_per_cap"
    )

    # ── load all tables ──────────────────────────────────────────────────────────
    l_summ_tables <- var_folders %>%
      set_names() %>%
      map(function(folder) {
        path <- paste0("output/compare_units/", folder, "/summ_table.csv")

        if (!file.exists(path)) {
          warning("File not found, skipping: ", path)
          return(NULL)
        }

        read_csv(path, show_col_types = FALSE) %>%
          mutate(variable = folder) %>%
          rename(any_of(c(unit = "series")))
      }) %>%
      compact()

    # ── bind ────────────────────────────────────────────────────────────────────
    bind_rows(l_summ_tables)
  })

  # ── unify unit names ──────────────────────────────────────────────────────────
  df_all_eu8norm_init_final_vals <- df_all_eu8norm_init_final_vals %>%
    mutate(unit_clean = case_when(
      str_detect(unit, regex("current", ignore_case = T)) &
      str_detect(unit, regex("pps|ppp", ignore_case = T)) ~ "current PPP/PPS",

      str_detect(unit, regex("const",   ignore_case = T)) &
      str_detect(unit, regex("pps|ppp", ignore_case = T)) ~ "constant PPP/PPS",

      str_detect(unit, regex("const",   ignore_case = T)) &
     !str_detect(unit, regex("pps|ppp", ignore_case = T)) ~ "constant price",

      TRUE ~ NA_character_
    ))

  # ── save cache ────────────────────────────────────────────────────────────────
  write_csv(df_all_eu8norm_init_final_vals, cache_path)
  message("Saved cache: ", cache_path)
}

# ── diagnostic: unmapped units ────────────────────────────────────────────────
local({
  unmapped <- df_all_eu8norm_init_final_vals %>%
    filter(is.na(unit_clean)) %>%
    distinct(unit)

  if (nrow(unmapped) > 0) {
    warning("Unmapped units: ", paste(unmapped$unit, collapse = ", "))
  } else {
    message("All units mapped OK.")
  }
})

# ── check val_prewar column exists ────────────────────────────────────────────
if (!"val_prewar" %in% names(df_all_eu8norm_init_final_vals)) {
  warning("val_prewar column not found! 2021 baseline will not be available.")
  df_all_eu8norm_init_final_vals <- df_all_eu8norm_init_final_vals %>%
    mutate(val_prewar = NA_real_)   # <-- add as NA so downstream code doesn't break
}

# ── peek ──────────────────────────────────────────────────────────────────────
glimpse(df_all_eu8norm_init_final_vals)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# SCATTER PLOT

local({

  save_plot_flag <- T

  legend_ratio    <- "növekedési arány"
  baseline_labels <- c("2004-től*", "2010-től", "2021-től")

  dataset_labels <- c(
    average_annual_wages   = "Átlagos éves bérek (OECD)",
    gni_per_cap            = "GNI egy főre (Világbank)",
    gdp_per_cap            = "GDP egy főre (Világbank)",
    gdp_per_hr_worked      = "GDP ledolgozott munkaóránként (OECD)",
    actual_indiv_consump   = "Tényleges egyéni fogyasztás (Eurostat)",
    median_equiv_net_income= "Medián ekviv. nettó jövedelem (Eurostat)",
    median_hourly_earnings = "Medián órabér (Eurostat)"
  )

  # ── harmonise ────────────────────────────────────────────────────────────────
  df_data <- df_all_eu8norm_init_final_vals %>%
    filter(!is.na(unit_clean)) %>%
    group_by(variable, country) %>%
    mutate(country_units = n_distinct(unit_clean)) %>%
    ungroup() %>%
    group_by(variable) %>%
    mutate(target_units = max(country_units)) %>%
    ungroup() %>%
    filter(country_units == target_units) %>%
    select(-country_units, -target_units) %>%
    mutate(country = recode(country, !!!country_labels_hu))

  # ── compute ratios — THREE baselines ─────────────────────────────────────────
  df_ratios <- df_data %>%
    mutate(
      ratio_from_init   = val_last / val_init,
      ratio_from_2010   = val_last / val_2010,
      ratio_from_prewar = val_last / val_prewar
    ) %>%
    select(variable, country, unit_clean,
           ratio_from_init, ratio_from_2010, ratio_from_prewar)

  # ── pivot wide ───────────────────────────────────────────────────────────────
  df_wide <- df_ratios %>%
    pivot_longer(
      cols      = c(ratio_from_init, ratio_from_2010, ratio_from_prewar),
      names_to  = "period",
      values_to = "ratio"
    ) %>%
    mutate(period = recode(period,
      ratio_from_init   = baseline_labels[1],
      ratio_from_2010   = baseline_labels[2],
      ratio_from_prewar = baseline_labels[3]
    )) %>%
    pivot_wider(
      names_from  = unit_clean,
      values_from = ratio
    ) %>%
    rename_with(~ str_to_lower(.) %>%
                   str_replace_all("[^a-z0-9]+", "_") %>%
                   str_remove("_$"))

  # ── build plot dataframe ─────────────────────────────────────────────────────
  df_plot <- df_wide %>%
    transmute(
      variable, country, period,
      x = constant_price,
      y = current_ppp_pps
    ) %>%
    filter(!is.na(x), !is.na(y)) %>%
    mutate(
      variable = factor(variable,
                   levels = names(dataset_labels),
                   labels = dataset_labels),
      period   = factor(period, levels = baseline_labels)
    )

  # ── compute per-panel R² labels ──────────────────────────────────────────────
  # One R² across ALL periods pooled within each facet panel.
  # If you prefer per-period R² lines, see the note below.
  df_r2 <- df_plot %>%
    group_by(variable) %>%
    summarise(
      r2    = cor(x, y, use = "complete.obs")^2,
      label = paste0("R² = ", round(r2, 3)),.groups = "drop"
    )

  # ── loop over log / linear ───────────────────────────────────────────────────
  for (log_flag in c(FALSE, TRUE)) {

    # Recompute R² in log space when log_flag is TRUE so the label
    # reflects the scale actually shown in the panel.
    df_r2_scaled <- if (log_flag) {
      df_plot %>%
        filter(x > 0, y > 0) %>%
        group_by(variable) %>%
        summarise(
          r2    = cor(log10(x), log10(y), use = "complete.obs")^2,
          label = paste0("R² = ", round(r2, 3)),.groups = "drop"
        )
    } else {
      df_r2
    }

    p <- ggplot(df_plot, aes(x = x, y = y)) +
      facet_wrap(~ variable, scales = "free") +
      geom_abline(slope    = 1, intercept = 0,
                  linetype = "dashed", color = "grey50") +
      # Hungary highlight ring
      geom_point(
        data        = df_plot %>% filter(grepl("Magy", country)),
        aes(shape   = period),
        fill        = NA,
        size        = 4,
        stroke      = 1,
        color       = "#00CC00",
        show.legend = FALSE
      ) +
      # all points
      geom_point(
        aes(fill = period, shape = period),
        size   = 4,
        alpha  = 2/3,
        stroke = 0.3,
        color  = "grey30"
      ) +
      # outlier labels
      geom_text_repel(
        data               = df_plot %>% filter(y/x >= 1.2 | x/y >= 1.2),
        aes(label          = country),
        color              = "black",
        size               = 4,
        alpha              = 2/3,
        max.overlaps       = 20,
        box.padding        = 0.5,
        min.segment.length = 0,
        segment.size       = 0.4
      ) +
      # ── R² annotation ───────────────────────────────────────────────────────
      geom_text(
        data  = df_r2_scaled,
        aes(label = label),
        x     = Inf,          # right edge of each panel
        y     = -Inf,         # bottom edge of each panel
        hjust = 1.1,          # nudge inward from right
        vjust = -0.5,         # nudge inward from bottom
        size  = 4.5,
        color = "grey20",
        fontface = "italic",
        inherit.aes = FALSE
      ) +
      scale_fill_manual(
        name   = legend_ratio,
        values = setNames(
          c("#E41A1C", "#377EB8", "#FF8C00"),
          baseline_labels
        )
      ) +
      scale_shape_manual(
        name   = legend_ratio,
        values = setNames(
          c(21, 24, 23),
          baseline_labels
        )
      ) +
      { if (log_flag) scale_x_log10() } +
      { if (log_flag) scale_y_log10() } +
      labs(
        title    = "Növekedési arányok a 2000-es évek közepétől, 2010-től illetve 2021-től 2024-ig",
        subtitle = paste0(
          "Minden érték az EU8** súlyozott átlagához viszonyítva.\n",
          "Zöld kiemelés = Magyarország.\n",
          "Arány = (utolsó érték) / (bázisév értéke)",
          if (log_flag) " — logaritmikus skála" else ""
        ),
        x       = "Állandó áron (volumenindex)",
        y       = "Folyó PPP/PPS",
        fill    = legend_ratio,
        shape   = legend_ratio,
        caption = paste0(
          "Szaggatott vonal = 1:1.\n",
          "*Bázisév a medián ekviv. nettó jövedelemnél = 2007, ",
          "medián órabérnél = 2006.\n",
          "Bázisév = 2004 minden más változónál.\n",
          "**EU8 = Németország, Ausztria, Franciaország, Hollandia, ",
          "Belgium, Svédország, Dánia, Finnország.\n",
          "R² = a konstans áras és a folyó PPP/PPS arányok közötti korreláció négyzetén alapul."
        )
      ) +
      theme_bw() + plot_settings +
      theme(
        legend.position = "top",
        legend.title    = element_text(size = 15),
        strip.text.x    = element_text(size = 15),
        axis.text       = element_text(size = 7)
      )

    # ── output dir ───────────────────────────────────────────────────────────
    out_path <- paste0(output_folder, "HU_plots/incl2021/")
    if (!dir.exists(out_path)) {
      dir.create(out_path, recursive = TRUE)
      message("Created: ", out_path)
    }

    file_name <- paste0(
      out_path,
      "scatter_arany_osszehasonlitas",
      ifelse(log_flag, "_log", ""),
      ".png"
    )

    if (save_plot_flag) {
      ggsave(
        plot      = p,
        filename  = file_name,
        width     = 36,
        height    = 25,
        units     = "cm",
        limitsize = FALSE
      )
    }

    try(print(p), silent = TRUE)

  } # end log_flag loop
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# RANK PLOTS

local({

  save_flag <- T

  # ── labels ───────────────────────────────────────────────────────────────────
  dataset_labels <- c(
    average_annual_wages   = "Átlagos éves\nbérek (OECD)",
    gni_per_cap            = "GNI egy főre\n(Világbank)",
    gdp_per_cap            = "GDP egy főre\n(Világbank)",
    gdp_per_hr_worked      = "GDP/munkaóra\n(OECD)",
    actual_indiv_consump   = "Tényleges egyéni\nfogyasztás (Eurostat)",
    median_equiv_net_income= "Medián ekviv. nettó\njövedelem (Eurostat)",
    median_hourly_earnings = "Medián órabér\n(Eurostat)"
  )

  metric_labels <- c(
    foldchange = "Relatív változás (%)",
    absdiff    = "Abszolút változás (százalékpont)"
  )

  # ── geometry: 2 series × 3 periods ──────────────────────────────────────────
  tile_half_h <- 0.06          # same as before — fills space for 2 series
  n_series    <- 2
  tile_height <- tile_half_h * 2    # = 0.12
  period_step <- 0.24               # same as before — distance between period rows

  series_offsets <- c(
    vol_index   = -tile_half_h,     # = -0.06
    ppp_current =  tile_half_h      # = +0.06
  )

  # ── always 3 period rows now ──────────────────────────────────────────────────
  period_levels_plot <- c("bázisévtől","2010-től", "2021-től")  # <-- 3 levels

  y_limits <- c(
    period_step     - tile_height - 0.002,      # bottom of lowest row
    3 * period_step + tile_height + 0.002        # <-- 3× instead of 2×
  )
  y_breaks <- seq_along(period_levels_plot) * period_step   # c(0.24, 0.48, 0.72)
  y_labels <- rev(period_levels_plot)
  
  hline_y  <- c(
    mean(c(1, 2) * period_step),   # between row 1 and 2
    mean(c(2, 3) * period_step)    # between row 2 and 3
  )

  # ── cee filters ──────────────────────────────────────────────────────────────
  cee_filters <- list(
    KKE11 = recode(l_groups$list_cntrs$CEE, !!!country_labels_hu),
    KKE9  = recode(setdiff(l_groups$list_cntrs$CEE,
                           c("Czechia", "Slovenia")), !!!country_labels_hu)
  )

  # ── harmonise + translate ─────────────────────────────────────────────────────
  df_data <- df_all_eu8norm_init_final_vals %>%
    mutate(country = recode(country, !!!country_labels_hu)) %>%
    filter(!is.na(unit_clean)) %>%
    group_by(variable, country) %>%
    mutate(country_units = n_distinct(unit_clean)) %>%
    ungroup() %>%
    group_by(variable) %>%
    mutate(target_units = max(country_units)) %>%
    ungroup() %>%
    filter(country_units == target_units) %>%
    select(-country_units, -target_units) %>%
    filter(!grepl("average",variable))

  cee_filters <- map(cee_filters, ~ recode(., !!!country_labels_hu))

  # ── diagnostic ───────────────────────────────────────────────────────────────
  dropped <- df_all_eu8norm_init_final_vals %>%
    mutate(country = recode(country, !!!country_labels_hu)) %>%
    filter(!is.na(unit_clean)) %>%
    group_by(variable, country) %>%
    mutate(country_units = n_distinct(unit_clean)) %>%
    ungroup() %>%
    group_by(variable) %>%
    mutate(target_units = max(country_units)) %>%
    ungroup() %>%
    filter(country_units < target_units) %>%
    distinct(variable, country, country_units, target_units)

  if (nrow(dropped) > 0) {
    message("Dropping: ")
    print(dropped)
  }

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
    paste(collapse = ", ") %>%
    paste0("Bázisév: ",.)

  # ── pre-compute long data: NOW 3 baselines ────────────────────────────────────
  df_long <- map_dfr(names(cee_filters), function(cee_choice) {

    cntrs <- cee_filters[[cee_choice]]

    df_data %>%
      filter(country %in% cntrs) %>%
      mutate(
        series_type = case_when(
          unit_clean == "constant price"  ~ "vol_index",
          unit_clean == "current PPP/PPS" ~ "ppp_current",
          TRUE                            ~ NA_character_
        )
      ) %>%
      filter(!is.na(series_type)) %>%
      # ── THREE baselines ───────────────────────────────────────────────────────
      pivot_longer(
        cols      = c(val_init, val_2010, val_prewar),   # <-- added val_prewar
        names_to  = "period_base",
        values_to = "base_val"
      ) %>%
      mutate(
        period_base  = recode(period_base,
                         val_init   = "init",
                         val_2010   = "2010",
                         val_prewar = "prewar"),          # <-- new level
        period_group = case_when(
          period_base == "init"   ~ "bázisévtől",
          period_base == "2010"   ~ "2010-től",
          period_base == "prewar" ~ "2021-től"           # <-- new label
          
        ),
        foldchange = (val_last / base_val - 1) * 100,
        absdiff    = val_last - base_val
      ) %>%
      filter(!is.na(base_val), !is.na(val_last)) %>%     # <-- drop if prewar missing
      pivot_longer(
        cols      = c(foldchange, absdiff),
        names_to  = "metric_type",
        values_to = "change"
      ) %>%
      filter(!is.na(change)) %>%
      group_by(variable, series_type, metric_type, period_base) %>%
      mutate(rank = rank(-change, ties.method = "min")) %>%
      ungroup() %>%
      mutate(
        cee_filter = cee_choice,
        variable   = factor(variable, levels = names(dataset_labels))
      )
  })

  # ── outer loops ──────────────────────────────────────────────────────────────
  country_choice <- "Magyarország"

  for (cee_choice in c("KKE9", "KKE11")) {
    for (metric_choice in c("foldchange", "absdiff", "both")) {

      # ── filter ───────────────────────────────────────────────────────────────
      df_plot <- df_long %>%
        filter(
          country    == country_choice,
          cee_filter == cee_choice,
          case_when(
            metric_choice == "foldchange" ~ metric_type == "foldchange",
            metric_choice == "absdiff"    ~ metric_type == "absdiff",
            metric_choice == "both"       ~ TRUE
          )
        ) %>%
        mutate(
          series_type  = factor(series_type,
                           levels = c("vol_index", "ppp_current")),
          metric_type  = factor(metric_type,
                           levels = c("foldchange", "absdiff")),
          period_group = factor(
            period_group,
            levels = period_levels_plot   # <-- 3 levels
          ),
          period_y = match(period_group, rev(period_levels_plot)) * period_step,
          y_pos    = period_y + series_offsets[as.character(series_type)]
        )
      
      # View(df_plot)
      
      n_ranks <- length(cee_filters[[cee_choice]])

      # ── background grid ───────────────────────────────────────────────────────
      df_grid <- df_plot %>%
        distinct(variable, metric_type, y_pos) %>%
        crossing(rank = 1:n_ranks) %>%
        mutate(
          xmin = rank - 0.5, xmax = rank + 0.5,
          ymin = y_pos - tile_half_h, ymax = y_pos + tile_half_h
        )

      # ── filled boxes ──────────────────────────────────────────────────────────
      df_filled <- df_plot %>%
        filter(!is.na(rank)) %>%
        mutate(
          series_label = case_when(
            grepl("vol",      series_type) ~ "Állandó áron (volumenindex, nem PPP)",
            grepl("ppp_curr", series_type) ~ "Folyó PPP/PPS"
          ),
          xmin = rank - 0.5, xmax = rank + 0.5,
          ymin = y_pos - tile_half_h, ymax = y_pos + tile_half_h
        )

      # ── metric label ─────────────────────────────────────────────────────────
      metric_label <- case_when(
        metric_choice == "foldchange" ~ "relatív változás",
        metric_choice == "absdiff"    ~ "abszolút változás",
        metric_choice == "both"       ~ "relatív és abszolút változás"
      )

      # ── facet ────────────────────────────────────────────────────────────────
      facet_formula <- if (metric_choice == "both") {
        facet_grid(
          metric_type ~ variable,
          labeller = labeller(
            variable    = dataset_labels,
            metric_type = metric_labels
          )
        )
      } else {
        facet_grid(. ~ variable,
          labeller = labeller(variable = dataset_labels)
        )
      }

      # ── plot ──────────────────────────────────────────────────────────────────
      p <- ggplot() +

        geom_rect(
          data = df_grid,
          aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
          fill = "grey95", color = "grey60", linewidth = 0.3, inherit.aes = FALSE
        ) +

        geom_rect(
          data = df_filled,
          aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
              fill = series_label),
          color = "grey30", linewidth = 0.3, alpha = 0.85, inherit.aes = FALSE
        ) +

        geom_text(
          data = df_filled,
          aes(x = rank, y = y_pos, label = rank),
          size = 5, color = "white", fontface = "bold", show.legend = FALSE
        ) +

        # ── TWO hlines now — between each pair of period rows ─────────────────
        geom_hline(yintercept = hline_y, linewidth = 2) +

        facet_formula +

        scale_x_continuous(
          breaks = seq(1, n_ranks, 2),
          limits = c(0.5, n_ranks + 0.5),
          expand = expansion(mult = c(0, 0))
        ) +
        scale_y_continuous(
          limits = y_limits,
          breaks = y_breaks,
          labels = y_labels,
          expand = expansion(mult = c(0, 0))
        ) +
        scale_fill_manual(
          values = c(
            "Állandó áron (volumenindex, nem PPP)" = "#E41A1C",
            "Folyó PPP/PPS"                        = "#377EB8"
          )
        ) +

        labs(
          title   = paste0(
            "Magyarország felzárkózási helyezése — ",
            metric_label, " — ", cee_choice
          ),
          x       = "Helyezés (1=legerősebb felzárkózás)",
          y       = "",
          fill    = "",
          caption = paste0(
            ifelse(nchar(start_year_note) > 0,
                   paste0(start_year_note, ""), ""),
            ", 2004 minden más változónál.\n",
            "Minden magyarországi és KKE-szintű érték az EU8 súlyozott átlagához viszonyítva",
            " (DE, FR, NL, BE, SE, DK, FI, AT).",
            ifelse(grepl("9", cee_choice),
                   "\nA KKE9 nem tartalmazza Csehországot és Szlovéniát.", "")
          )
        ) +

        theme_bw() + plot_settings +
        theme(
          legend.position    = "top",
          plot.title= element_text(size = 20),
          legend.title       = element_text(size=14),
          axis.text.x        = element_text(angle = 0),
          axis.text.y        = element_text(),
          axis.ticks.y       = element_line(),
          panel.grid.minor   = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_blank(),
          strip.text.x       = element_text(size = 16),
          plot.caption       = element_text(hjust = 0),
          panel.spacing.y    = unit(0.8, "cm")
        )

      # ── output dir ───────────────────────────────────────────────────────────────
  out_path <- paste0(output_folder, "HU_plots/incl2021/")
  if (!dir.exists(out_path)) dir.create(out_path, recursive = TRUE)

  rank_path <- paste0(out_path, "rank/")
  if (!dir.exists(rank_path)) dir.create(rank_path, recursive = TRUE)

  file_name <- paste0(
        rank_path,
        "helyezes_", metric_choice, "_",
        tolower(cee_choice), ".png" )
  
      if (save_flag) {
        ggsave(
          plot      = p,
          filename  = file_name,
          width     = ifelse(metric_choice == "both", 54, 48),
          height    = ifelse(metric_choice == "both", 42, 30),  # <-- taller for 3 rows
          units     = "cm",
          limitsize = FALSE
        )
      }

      try(print(p), silent = TRUE)

    } # end metric_choice
  }   # end cee_choice
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# CHANGE PLOTS


local({

  save_flag <- T

  country_labels_hu <- c(
    "Bulgaria"  = "Bulgária",
    "Croatia"   = "Horvátország",
    "Czechia"   = "Csehország",
    "Estonia"   = "Észtország",
    "Hungary"   = "Magyaro.",
    "Latvia"    = "Lettország",
    "Lithuania" = "Litvánia",
    "Poland"    = "Lengyelo.",
    "Romania"   = "Románia",
    "Slovakia"  = "Szlovákia",
    "Slovenia"  = "Szlovénia"
  )

  # ── labels ───────────────────────────────────────────────────────────────────
  dataset_labels <- c(
    average_annual_wages   = "Átlagos éves\nbérek (OECD)",
    gni_per_cap            = "GNI egy főre\n(Világbank)",
    gdp_per_cap            = "GDP egy főre\n(Világbank)",
    gdp_per_hr_worked      = "GDP/munkaóra\n(OECD)",
    actual_indiv_consump   = "Tényleges egyéni\nfogyasztás\n(Eurostat)",
    median_equiv_net_income= "Medián ekviv.\nnettó jövedelem\n(Eurostat)",
    median_hourly_earnings = "Medián órabér\n(Eurostat)"
  )

  metric_labels <- c(
    foldchange = "Relatív változás (%)",
    absdiff    = "Abszolút változás (százalékpont)"
  )

  color_fill_vals <- c(
    "Állandó áron (volumenindex, nem PPP)" = "#E41A1C",
    "Folyó PPP/PPS"                        = "#377EB8"
  )

  metric_label_legend <- ""

  agg_labels <- c(
    wtd_levels  = "szintek súlyozott átlaga → változás",
    wtd_changes = "változások súlyozott átlaga"
  )

  # ── period group levels: TOP → BOTTOM ────────────────────────────────────────
  # facet rows will appear in this order top to bottom
  period_group_levels <- c("a bázisévtől", "2010-től", "2021-től")

  # ── cee filters ──────────────────────────────────────────────────────────────
  cee_filters <- list(
    KKE11 = recode(l_groups$list_cntrs$CEE, !!!country_labels_hu),
    KKE9  = recode(setdiff(l_groups$list_cntrs$CEE,
                           c("Czechia", "Slovenia")), !!!country_labels_hu)
  )

  # ── harmonise + translate ─────────────────────────────────────────────────────
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

  # ── population weights: FOUR time points now ─────────────────────────────────
  df_pop_weights <- df_data %>%
    distinct(variable, country, init_yr, last_yr) %>%
    mutate(yr_2010   = 2010L,
           yr_prewar = 2021L) %>%          # <-- added
    pivot_longer(
      cols      = c(init_yr, yr_2010, yr_prewar, last_yr),   # <-- added
      names_to  = "time_point",
      values_to = "year_target"
    ) %>%
    left_join(
      l_pop$total_pop %>%
        filter(year >= 2004) %>%
        mutate(country = recode(country, !!!country_labels_hu)) %>%
        select(country, year_target = year, pop = value)
    ) %>%
    select(variable, country, time_point, pop) %>%
    pivot_wider(
      names_from   = time_point,
      values_from  = pop,
      names_prefix = "pop_"
    ) %>%
    rename(
      pop_init   = pop_init_yr,
      pop_2010   = pop_yr_2010,
      pop_prewar = pop_yr_prewar,           # <-- added
      pop_last   = pop_last_yr
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
          TRUE                            ~ NA_character_
        )
      ) %>%
      filter(!is.na(series_type)) %>%
      left_join(df_pop_weights, by = c("variable", "country"))

    # ── Approach A: weighted avg of LEVELS → change ───────────────────────────
    df_A <- df_base %>%
      group_by(variable, series_type) %>%
      summarise(
        wtd_val_init   = weighted.mean(val_init,   w = pop_init,   na.rm = TRUE),
        wtd_val_2010   = weighted.mean(val_2010,   w = pop_2010,   na.rm = TRUE),
        wtd_val_prewar = weighted.mean(val_prewar, w = pop_prewar, na.rm = TRUE), # <--
        wtd_val_last   = weighted.mean(val_last,   w = pop_last,   na.rm = TRUE),.groups = "drop"
      ) %>%
      pivot_longer(
        cols      = c(wtd_val_init, wtd_val_2010, wtd_val_prewar),  # <-- added
        names_to  = "period_base",
        values_to = "base_val"
      ) %>%
      mutate(
        period_base  = recode(period_base,
                         wtd_val_init   = "init",
                         wtd_val_2010   = "2010",
                         wtd_val_prewar = "prewar"),                # <-- added
        period_group = case_when(
          period_base == "init"   ~ "a bázisévtől",
          period_base == "2010"   ~ "2010-től",
          period_base == "prewar" ~ "2021-től"
        ),
        foldchange = (wtd_val_last / base_val - 1) * 100,
        absdiff    = wtd_val_last - base_val
      ) %>%
      pivot_longer(
        cols      = c(foldchange, absdiff),
        names_to  = "metric_type",
        values_to = "cee_agg"
      ) %>%
      mutate(agg_method = "wtd_levels")

    # ── Approach B: change per country → weighted avg ─────────────────────────
    df_B <- df_base %>%
      pivot_longer(
        cols      = c(val_init, val_2010, val_prewar),              # <-- added
        names_to  = "period_base",
        values_to = "base_val"
      ) %>%
      mutate(
        period_base  = recode(period_base,
                         val_init   = "init",
                         val_2010   = "2010",
                         val_prewar = "prewar"),                    # <-- added
        period_group = case_when(
          period_base == "init"   ~ "a bázisévtől",
          period_base == "2010"   ~ "2010-től",
          period_base == "prewar" ~ "2021-től"
        ),
        weight = case_when(
          period_base == "init"   ~ pop_init,
          period_base == "2010"   ~ pop_2010,
          period_base == "prewar" ~ pop_prewar                      # <-- added
        ),
        foldchange = (val_last / base_val - 1) * 100,
        absdiff    = val_last - base_val
      ) %>%
      filter(!is.na(base_val)) %>%                                  # drop missing prewar
      pivot_longer(
        cols      = c(foldchange, absdiff),
        names_to  = "metric_type",
        values_to = "change"
      ) %>%
      group_by(variable, series_type, metric_type, period_base, period_group) %>%
      summarise(
        cee_agg = weighted.mean(change, w = weight, na.rm = TRUE),.groups = "drop"
      ) %>%
      mutate(agg_method = "wtd_changes")

    bind_rows(df_A, df_B) %>%
      mutate(cee_filter = cee_choice)
  })

  # ── Hungary long: THREE baselines ────────────────────────────────────────────
  country_choice <- "Magyaro."

  df_hu_long <- df_data %>%
    filter(country == country_choice, !is.na(unit_clean)) %>%
    mutate(
      series_type = case_when(
        unit_clean == "constant price"  ~ "vol_index",
        unit_clean == "current PPP/PPS" ~ "ppp_current",
        TRUE                            ~ NA_character_
      )
    ) %>%
    filter(!is.na(series_type)) %>%
    pivot_longer(
      cols      = c(val_init, val_2010, val_prewar),               # <-- added
      names_to  = "period_base",
      values_to = "base_val"
    ) %>%
    mutate(
      period_base  = recode(period_base,
                       val_init   = "init",
                       val_2010   = "2010",
                       val_prewar = "prewar"),
      period_group = case_when(
        period_base == "init"   ~ "a bázisévtől",
        period_base == "2010"   ~ "2010-től",
        period_base == "prewar" ~ "2021-től"
      ),
      foldchange = (val_last / base_val - 1) * 100,
      absdiff    = val_last - base_val
    ) %>%
    filter(!is.na(base_val)) %>%                                   # drop missing prewar
    pivot_longer(
      cols      = c(foldchange, absdiff),
      names_to  = "metric_type",
      values_to = "hu_change"
    )

  # ── outer loops ──────────────────────────────────────────────────────────────
  for (cee_choice in c("KKE9", "KKE11")) {
    for (agg_method in c("wtd_levels", "wtd_changes")) {
      for (metric_choice in c("foldchange", "absdiff", "both")) {

        # ── filter Hungary ──────────────────────────────────────────────────────
        df_hu <- df_hu_long %>%
          filter(case_when(
            metric_choice == "foldchange" ~ metric_type == "foldchange",
            metric_choice == "absdiff"    ~ metric_type == "absdiff",
            metric_choice == "both"       ~ TRUE
          )) %>%
          mutate(
            variable     = factor(variable, levels = names(dataset_labels)),
            series_type  = factor(series_type,
                             levels = c("vol_index", "ppp_current")),
            metric_type  = factor(metric_type,
                             levels = c("foldchange", "absdiff")),
            # ── TOP → BOTTOM: bázisévtől, 2010-től, 2021-től ─────────────────
            period_group = factor(period_group,
                             levels = period_group_levels)
          )

        # ── filter CEE agg ──────────────────────────────────────────────────────
        df_cee <- df_cee_aggs %>%
          filter(
            cee_filter == cee_choice,
            agg_method == !!agg_method,
            case_when(
              metric_choice == "foldchange" ~ metric_type == "foldchange",
              metric_choice == "absdiff"    ~ metric_type == "absdiff",
              metric_choice == "both"       ~ TRUE
            )
          ) %>%
          mutate(
            variable     = factor(variable, levels = names(dataset_labels)),
            series_type  = factor(series_type,
                             levels = c("vol_index", "ppp_current")),
            metric_type  = factor(metric_type,
                             levels = c("foldchange", "absdiff")),
            period_group = factor(period_group,
                             levels = period_group_levels)          # <-- same levels
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
        # period_group always shown as rows (3 rows now)
        # metric_type added as extra row dimension when metric_choice == "both"
        facet_formula <- if (metric_choice == "both") {
          facet_grid(
            metric_type + period_group ~ variable,
            labeller = labeller(
              variable     = dataset_labels,
              metric_type  = metric_labels,
              period_group = label_value      # <-- show period_group label as-is
            ),
            scales = "free_y"
          )
        } else {
          facet_grid(
            period_group ~ variable,
            labeller = labeller(
              variable     = dataset_labels,
              period_group = label_value      # <-- show period_group label as-is
            ),
            scales = "free_y"
          )
        }

        # ── plot ──────────────────────────────────────────────────────────────────
        p <- ggplot(df_plot, aes(x = series_label, color = series_label)) +

          geom_point(
            aes(y     = cee_agg,
                fill  = series_label,
                shape = cee_choice),
            size = 5, stroke = 0.8, color = "black", alpha = 2/3
          ) +
          geom_text(
            aes(y     = cee_agg,
                label = sprintf("%.1f", cee_agg)),
            vjust = -0.95, hjust = 0.5, size = 4.5, show.legend = FALSE
          ) +

          geom_point(
            aes(y     = hu_change,
                fill  = series_label,
                shape = country_choice),
            size = 5, stroke = 0.8, color = "black", alpha = 2/3
          ) +
          geom_text(
            aes(y = hu_change, label = sprintf("%.1f", hu_change)),
            hjust = -0.45, size = 4.5, show.legend = FALSE
          ) +

          geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
          geom_segment(
            aes(x = series_label, xend = series_label,
                y = hu_change,    yend = cee_agg),
            linewidth = 1, linetype = "dotted", show.legend = FALSE
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
          scale_y_continuous(expand = expansion(c(0.1, 0.16))) +
          scale_x_discrete(expand   = expansion(add = c(0.3, 0.6))) +

          facet_formula +

          labs(
            title   = paste0(
              "Magyarország vs ", cee_choice,
              " — ", metric_label, " — 2024-ig"
            ),
            x       = "",
            y       = case_when(
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
            legend.box         = "vertical",
            axis.text.x        = element_blank(),
            axis.ticks.x       = element_blank(),
            panel.grid.minor   = element_blank(),
            panel.grid.major.x = element_blank(),
            strip.text.x       = element_text(size = 16),
            strip.text.y       = element_text(size = 16),
            plot.caption       = element_text(hjust = 0),
            panel.spacing.y    = unit(0.5, "cm")
          )

        # ── output dir ───────────────────────────────────────────────────────────────
  out_path <- paste0(output_folder, "HU_plots/incl2021/change/")
  if (!dir.exists(out_path)) {
    dir.create(out_path, recursive = TRUE)
    message("Created: ", out_path)
  }
        
        # ── save ──────────────────────────────────────────────────────────────────
        file_name <- paste0(
          out_path,
          "valtozas_", metric_choice, "_",
          tolower(cee_choice), "_",
          gsub("_", "-", agg_method),
          ".png"
        )

        if (save_flag) {
          ggsave(
            plot      = p,
            filename  = file_name,
            width     = 48,
            height    = case_when(
              metric_choice == "both" ~ 48,   # <-- taller: 3 period rows × 2 metrics
              TRUE                    ~ 28    # <-- taller: 3 period rows
            ),
            units     = "cm",
            limitsize = FALSE
          )
        }

        try(print(p), silent = TRUE)

      } # end metric_choice
    }   # end agg_method
  }     # end cee_choice
})



