l_packs <- list()
l_packs$packages <- c("tidyverse", "ggh4x", "zoo", "tools","glue") # "lhs", ,"deSolve"
               # "httr", "tictoc", "wpp2019", 
# Check and install missing packages
l_packs$installed <- l_packs$packages %in% installed.packages()[, "Package"]
if (any(!l_packs$installed)) { install.packages(l_packs$packages[!l_packs$installed]) }
# Load the packages
lapply(l_packs$packages, library, character.only=T); rm(l_packs)
# package conflicts
# conflicted::conflict_prefer("select", "dplyr")
# conflicted::conflict_prefer("filter", "dplyr")
# conflicted::conflict_prefer("lag", "dplyr")
lapply(c("select", "filter", "lag"), function(x) conflicted::conflict_prefer(x, "dplyr")) # invisible()
# load functions
# source("functions.R")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# plotting settings
l_plot <- list()
l_plot$standard_theme <- theme( # for publ plots
                        plot.title=element_text(hjust=0.5,size=22),
                        axis.text.x=element_text(size=15,angle=90,vjust=1/2),
                        axis.text.y=element_text(size=15),
                        axis.title.x=element_text(size=20),
                        axis.title.y=element_text(size=20),
                        strip.text=element_text(size=22),
                        legend.text=element_text(size=20),
                        legend.title=element_text(size=22),
                        text=element_text(family="sans") )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

convert_hu_date <- function(x) {
  months_hu <- c(
  január="01", február="02", március="03", április="04",
  május="05", június="06", július="07", augusztus="08",
  szeptember="09", október="10", november="11", december="12" )
  m <- str_match(x, "([0-9]{4})\\.\\s*([[:alpha:]]+)")[,2:3]
  sprintf("%s/%s", m[,1], months_hu[m[,2]])
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ---- helpers -----------------------------------------------------------

median_demog_file <- function(period) {
  # e.g. "2025_06" -> "input_files/median_2025_06_nem_vegzettseg_telepules_vegzettseg.csv"
  paste0("input_files/median_", period, "_nem_vegzettseg_telepules_vegzettseg.csv")
}

median_fullpop_file <- function(period) {
  # e.g. "2025_06" -> "input_files/median_2025_06_teljes_nepesseg.csv"
  paste0("input_files/median_", period, "_teljes_nepesseg.csv")
}

load_median_demog <- function(period) {
  file <- median_demog_file(period)
  
  if (period == "2025_06") {
    # special structure
    read_csv(file) %>%
      select(!url) %>%
      pivot_longer(!c(kateg_tipus, kateg, datum), names_to = "part") %>%
      mutate(
        arány = value / 100,
        part  = gsub("\\*", "", part),
        kateg = tolower(kateg),
        kateg = gsub(
          "/vagy idősebb", "\\+",
          gsub(" éves", "",
          gsub(" végzettség", "",
          gsub("\\, ", "/", kateg)))
        )
      ) %>%
      select(!value) %>%
      group_by(kateg_tipus) %>%
      { set_names(group_split(.,.keep = FALSE), group_keys(.)$kateg_tipus) } %>%
      as.list()
    
  } else if (period == "2025_08") {
    # 2025_08 layout
    read_csv(file) %>%
      rename(tipus = filter) %>%
      pivot_longer(!c(tipus, kateg), names_to = "part") %>%
      mutate(
        arány = value / 100,
        kateg = tolower(kateg),
        datum = gsub("_", "/", period)
      ) %>%
      select(!value) %>%
      group_by(tipus) %>%
      { set_names(group_split(.,.keep = FALSE), group_keys(.)$tipus) } %>%
      as.list()
    
  } else {
    # 2025_11, 2026_01 etc. (your existing loop pattern)
    read_csv(file) %>%
      rename(tipus = filter) %>%
      pivot_longer(!c(tipus, kateg, url), names_to = "part") %>%
      mutate(
        arány = value / 100,
        kateg = tolower(kateg),
        datum = gsub("_", "/", period)
      ) %>%
      select(!c(value, url)) %>%
      group_by(tipus) %>%
      { set_names(group_split(.,.keep=F), group_keys(.)$tipus) } %>%
      as.list()
  }
}

load_median_fullpop <- function(period) {
  file <- median_fullpop_file(period)
  
  if (period == "2025_06") {
    read_csv(file) %>%
      rename(part = Párt) %>%
      select(part, `teljes népesség`) %>%
      pivot_longer(!part, names_to = "kateg") %>%
      mutate(
        arány = value / 100,
        datum = "2025/06"
      ) %>%
      select(!value)
    
  } else {
    read_csv(file) %>%
      pivot_longer(!c(kateg, url, datum), names_to = "part") %>%
      filter(grepl("Teljes", kateg)) %>%
      mutate(
        kateg = tolower(kateg),
        arány = value / 100
      ) %>%
      select(!c(value, url)) %>%
      relocate(datum,.after = last_col()) %>%
      bind_rows(
        data.frame(
          kateg = "teljes népesség",
          part  = "Jobbik",
          datum = gsub("_", "/", period)
          # arány assumed 0 as in comment
        )
      )
  }
}



### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
## dustbin of history

# # MEDIAN 2025/06, tobb demogr kateg
# # https://datawrapper.dwcdn.net/Ns8XR/10/
# l_part_data[["median"]][["2025_06"]] = list()
# l_part_data[["median"]][["2025_06"]] <- read_csv(
#   "input_files/median_2025_06_nem_vegzettseg_telepules_vegzettseg.csv") %>%
#   select(!url) %>%
#   pivot_longer(!c(kateg_tipus,kateg,datum),names_to="part") %>%
#   mutate(arány=value/100,
#         part=gsub("\\*","",part),
#         kateg=tolower(kateg),
#         kateg=gsub("/vagy idősebb","\\+",gsub(" éves","",gsub(" végzettség","",gsub("\\, ","/",
#                 kateg))))  ) %>% 
#   select(!value) %>%
#   group_by(kateg_tipus) %>% { 
#     set_names(group_split(.,.keep=F), group_keys(.)$kateg_tipus) } %>%
#   as.list()
# 
# # l_part_data[["median"]][["2025_06"]]$KORCSOPORT
# # l_part_data[["median"]][["2025_08"]]$ÉLETKOR
# names(l_part_data[["median"]][["2025_06"]])[
#   names(l_part_data[["median"]][["2025_06"]]) %in% "KORCSOPORT"] <- "ÉLETKOR"
# 
# # teljes nepesseg
# # datawrapper.dwcdn.net/RLw52/2/
# l_part_data[["median"]][["2025_06"]]$telj_nepesseg_partok <- read_csv(
#   "input_files/median_2025_06_teljes_nepesseg.csv") %>% 
#   rename(part=Párt) %>%
#   select(part,`teljes népesség`) %>%
#   pivot_longer(!part,names_to = "kateg") %>%
#   mutate(arány=value/100,datum="2025/06") %>%
#   select(!value)
# 
# l_part_data$median$`2025_06`$TELEPÜLÉS <- l_part_data$median$`2025_06`$TELEPÜLÉSTÍPUS
# l_part_data$median$`2025_06`$TELEPÜLÉSTÍPUS=NULL
# 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# # MEDIAN 2025/08, tobb demogr kateg
# # source: https://flo.uri.sh/visualisation/25049528/embed?auto=1
# 
# l_part_data[["median"]][["2025_08"]] <- list()
# l_part_data[["median"]][["2025_08"]] <- read_csv(
#   "input_files/median_2025_08_nem_vegzettseg_telepules_vegzettseg.csv") %>%
#   rename(tipus=filter) %>%
#   pivot_longer(!c(tipus,kateg),names_to="part") %>%
#   mutate(arány=value/100,
#          kateg=tolower(kateg),
#          datum="2025/08"  ) %>% 
#   select(!value) %>%
#   group_by(tipus) %>% { set_names(group_split(.,.keep=F), group_keys(.)$tipus) } %>%
#   as.list()
# 
# # teljes nepesseg partokra bontva
# # https://flo.uri.sh/visualisation/25049245/embed?auto=1
# l_part_data[["median"]][["2025_08"]]$telj_nepesseg_partok <- read_csv(
#   "input_files/median_2025_08_teljes_nepesseg.csv") %>% 
#   pivot_longer(!c(kateg,url,datum),names_to="part") %>%
#   filter(grepl("Teljes",kateg)) %>%
#   mutate(kateg=tolower(kateg),arány=value/100) %>%
#   select(!c(value,url)) %>%
#   relocate(c(datum),.after=last_col()) %>%
#   bind_rows(data.frame(kateg="teljes népesség",
#     part="Jobbik",datum="2025/08")) # arány=0,
# 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# # MEDIAN 2025/11, tobb demogr kateg
# # source: https://flo.uri.sh/visualisation/26553099/embed?auto=1
# 
# # MEDIAN 2025/11, tobb demogr kateg
# # source: https://flo.uri.sh/visualisation/26553099/embed?auto=1
# 
# for (k_yr in c("2025_11","2026_01")) {
# l_part_data[["median"]][[k_yr]] <- list()
# l_part_data[["median"]][[k_yr]] <- read_csv(
#   paste0("input_files/median_",k_yr,"_nem_vegzettseg_telepules_vegzettseg.csv")) %>%
#   rename(tipus=filter) %>%
#   pivot_longer(!c(tipus,kateg,url),names_to="part") %>%
#   mutate(arány=value/100,
#          kateg=tolower(kateg),
#          datum=gsub("_","/",k_yr)) %>% 
#   select(!c(value,url)) %>%
#   group_by(tipus) %>% { 
#     set_names(group_split(.,.keep=F), group_keys(.)$tipus) } %>%
#   as.list()
# }
# rm(k_yr)
# # Median teljes nepesseg (partokra bontva)
# # https://flo.uri.sh/visualisation/25049245/embed?auto=1
# for (period_name in c("2025_11","2026_01") ) {
# 
# l_part_data[["median"]][[period_name]]$telj_nepesseg_partok <- read_csv(
#   paste0("input_files/median_",period_name,"_teljes_nepesseg.csv")) %>% 
#   pivot_longer(!c(kateg,url,datum),names_to="part") %>%
#   filter(grepl("Teljes",kateg)) %>%
#   mutate(kateg=tolower(kateg),arány=value/100) %>%
#   select(!c(value,url)) %>%
#   relocate(c(datum),.after=last_col()) %>%
#   bind_rows(data.frame(kateg="teljes népesség",
#     part="Jobbik",datum=gsub("_","/",period_name))) # arány=0,
# 
# }
# rm(period_name)

