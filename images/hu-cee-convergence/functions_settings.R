# libraries
lapply(c("tidyverse","wbstats", "RColorBrewer", "purrr","zoo","ggh4x",
      "htmlwidgets","plotly","grid","cowplot","ggrepel",
      "fs","rvest",
      "knitr","kableExtra"),
        library, character.only=T)
# ,"jsonlite" , "sf",

# packs=c("tidyverse","ggrepel","plotly") # ,"RcppRoll","scales","lubridate","wpp2019","wesanderson"
# missing_packs=setdiff(packs, as.data.frame(installed.packages()[,c(1,3:4)])$Package)
# if (length(missing_packs)>0){ lapply(missing_packs,install.packages,character.only=TRUE) }
# lapply(packs,library,character.only=TRUE); rm(list=c("packs","missing_packs"))

# GGPLOT SETTINGS
plot_settings <- theme(plot.title=element_text(hjust=0.5,size=16),
                             axis.title.x=element_text(size=17),
                             axis.title.y=element_text(size=17),
                             plot.caption=element_text(size=12),plot.caption.position="plot",
                             axis.text.x=element_text(size=15,angle=90),
                             axis.text.y=element_text(size=15),
                             strip.text=element_text(size=20),
                             legend.title =element_text(size=22),
                             # panel.grid.major.y=element_blank(), 
                             legend.text=element_text(size=15))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

# helper: adapt vlines depending on sel_var and type_scale
make_x_scale_and_vlines <- function(sel_var, type_scale,
                                    log_perc_vline_incr=1,
                                    min_max_val_log_perc=NULL) {
  
  is_percent <- grepl("%", sel_var)
  is_log     <- grepl("log", type_scale)
  is_LAT     <- grepl("LAT", sel_var)
  is_World   <- grepl("World", sel_var)
  
  # ───────────────────────────────
  # LOG SCALE
  # ───────────────────────────────
  if (is_log) {
    
    # special case: log + %
    if (is_percent) {
      return(
        list(
  scale_x_continuous(
          breaks=with(min_max_val_log_perc, seq(min, max(c(ceiling(max),0)), 0.5)),
          expand=expansion(0.03) ),
  if (min_max_val_log_perc$min<0) {
  geom_vline(xintercept=0, linewidth=0.5) } else {NULL},
  geom_vline(xintercept=with(min_max_val_log_perc, seq(min,max,log_perc_vline_incr)),
              linewidth=0.25, linetype="dashed") )
      )
    }
    
    # generic log (non-%)
    return(
      list(
        scale_x_continuous(
          breaks=with(min_max_val_log_perc, seq(min, max, 1)),
          expand=expansion(0.04)),
        geom_vline(
          xintercept=with(min_max_val_log_perc, seq(min, max, 1)),
          linewidth =0.25,
          linetype  ="dashed"
        )
      )
    )
  }
  
  
  # ───────────────────────────────
  # LINEAR SCALE (not log)
  # ───────────────────────────────
  if (is_percent) {
    
    if (is_LAT) {
      return(
        list(
          scale_x_continuous(breaks=(0:12)*50),
          geom_vline(xintercept=1:3 * 100, linewidth=0.5, linetype="dashed")
        )
      )
    }
    
    if (!is_World) {
      return(
        list(
          scale_x_continuous(breaks=(0:7)*20),
          geom_vline(xintercept=100,linewidth=0.5),
          geom_vline(xintercept=c(25,50,75),
            linewidth=0.25, linetype="dashed")
        )
      )
    }
    
    # World
    return(
      list(
        scale_x_continuous(breaks=(0:12)*50),
        geom_vline(xintercept=1:3* 100, linewidth=0.5, linetype="dashed")
      )
    )
  }
  
  # non-% and non-log → no vlines special??
  # if needed add fallback here:
  list()
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# to print HTML tables

fmt_val <- function(x, name) {
  if (grepl("absolute",name) ) {
    paste0(round(x,1), "k")
  } else {
    if (grepl("relative",name) ) {
      paste0(round(x), "%")
    } else {
    paste0(signif(x, 2), "%")
      }
    
  }
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  

make_table <- function(data, 
  diff_var,
  reloc_flag=T,
  name_labels=c(
  "rel_val" = "relative to initial value (%)",
  "value" = "absolute value (thousand USD PPP)",
  "% of EU8" = "% of EU8",
  "% of EU3" = "% of EU3",
  "% of DE" = "% of DE",
  "% of G7" = "% of G7",
  "% of S_EUR4" = "% of S_EUR4"
   ),
  order_col="% of EU8",
  width_val="220px",
  extra_css_val="padding: 3px;"
  ) {
  

  wide_df <- data %>%
    mutate(
      name = recode(name, !!!name_labels),
      formatted = .data[[diff_var]] # mapply(fmt_val, .data[[diff_var]], name)
    ) %>%
    select(country, name, formatted) %>%
    pivot_wider(
      names_from = name,
      values_from = formatted) %>%
    arrange(desc(as.numeric(gsub("([+-]?\\d+).*", "\\1", !!sym(order_col)))) ) %>%
    filter(!if_any(everything(), ~ grepl("NA", ., fixed = T)))
  
  if (reloc_flag) {
    wide_df <- wide_df %>%
      relocate(contains("absolute"),.after=last_col())
  }
  
  print(wide_df)
  
  n_cols <- ncol(wide_df)
  
  # find row index of Hungary
hun_row <- which(wide_df$country == "Hungary")

wide_df %>%
  kable(
    format = "html",
    escape = FALSE,
    align = "c"
  ) %>%
  kable_styling(
    bootstrap_options = "condensed",
    full_width = FALSE,
    position = "left") %>%
    row_spec(0,
    extra_css = "padding: 3px; font-weight: bold;") %>%
  row_spec(hun_row,
    background="#fff1f1",
    color="#b30000") %>% # Hungary highlight
  column_spec(1, width = "120px") %>%
  column_spec(
    2:n_cols,
    width = width_val,
    extra_css = extra_css_val)
  
  # end of function
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  

# Function to extract table from a single file and add folder/file info
extract_table <- function(f) {
  folder_name <- path_file(path_dir(f))  # immediate parent folder
  file_name <- path_file(f)
  
  table <- tryCatch(
    {
      read_html(f, encoding = "UTF-8") %>%
        html_element("table") %>%
        html_table(fill = TRUE) %>%
        as_tibble()
    },
    error = function(e) {
      warning(paste("Failed to read table in:", f))
      return(tibble())
    }
  )
  
  table %>%
    mutate(folder = folder_name, file = file_name)
}
