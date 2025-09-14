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