# libraries
lapply(c("tidyverse","wbstats", "RColorBrewer", "purrr","zoo",
        "htmlwidgets","plotly","grid","cowplot","ggrepel"),
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
