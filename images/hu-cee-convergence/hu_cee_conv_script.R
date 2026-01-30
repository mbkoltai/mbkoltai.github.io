# load settings
source("functions_settings.R")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# LOAD data, functions, libraries

source("load_data.R")

### PLOTTING 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

# GNI per capita
with(list(all_vars=c("rel_val",grep("value|AT|DE|EU8",
            colnames(l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr),
            value=T)),
          start_yr_vals=c(2004,2010),
          folder_name="output/GNI_per_cap/",
          l_table_save=list(),
          show_plot=F,
          save_plot_flag=F,
          save_table=T), {
  all_vars <- grep("LAT",all_vars,value=T,invert=T)

for (start_yr in start_yr_vals) {
for (sel_var in all_vars) {

  y_txt <- if (grepl("value",sel_var)) {
  "GNI per capita (thousand constant 2021 USD, PPP)" 
    } else {
  paste0("GNI per capita, ", sel_var,"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- paste0("GNI per capita (constant 2021 USD PPP)",
              "\nrelative to first year (",start_yr,"=100)")
    }
  
df_plot <- l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
    group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(value=value/1e3,
    start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        signif(diff_end_start,2)),
    ifelse(sel_var=="value","k USD PPP","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# View(df_plot)

l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }

# caption text
    caption_src <- "source: https://data.worldbank.org/indicator/NY.GNP.PCAP.PP.KD"
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", "),
    grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2019,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
y_breaks <- if (sel_var == "value") { 0:10*10 } else {
                  (0:ceiling(max_val/20))*20 }
hline_vals <- if (sel_var == "value") {
                (1:floor(max_val/10))*10 } else {
                (1:floor(max_val/25))*25 }
if (sel_var == "rel_val") {
  y_breaks <- seq(100,200,50)
  hline_vals <- y_breaks # seq(100,500,100)
}

df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel",sel_var),
              round(value),signif(value,2)), 
                ifelse(sel_var=="value","k USD PPP","%")), 
            paste0(signif(value,2),
                ifelse(sel_var=="value","k","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,3.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(breaks=seq(start_yr,2024,4),
    expand=expansion(mult=c(0.07,0.075))) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(ifelse(sel_var=="rel_val",80,0),NA),
    breaks=y_breaks) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
# folder_name <- "output/GNI_per_cap/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
}

} # end of for loop (start_yr)
  
} # end of for loop (variable)

# SAVE TABLE
if (save_table) {
  
  # FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) ) %>%
    filter(grepl("rel_val|2004",facet_id)) %>%
    filter(!grepl("of DE",facet_id))
  # SAVE
    write_csv(df_save_full, 
      file=paste0(folder_name,"full_table.csv"))

# magyar változat
facet_labels_hu <- c(
  "% of EU8-2004" = "EU8 átlag %-a",
  "value-2004"   = "ezer USD (konstans 2021, PPP)",
  "rel_val-2004" = "2004-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))
  
    
# # SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"full_table_wide.csv"))

# SAVE selected variable
    df_save_full %>%
      filter(facet_id %in% "% of EU8-2004") %>%
      mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) ) %>%
      arrange(country_val_str,year) %>%
      select(country_val_str,country,facet_id,var,year,value) %>%
    write_csv(file = paste0(folder_name,"df_sel_var.csv"))
    
  # summary table (start and end values)
  l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE) %>%
    mutate(value=value/1e3)  %>%
    group_by(country) %>%
    mutate(rel_val=100*value/value[year==min(year)] ) %>%
  # select(!c(`% of LAT_AM`,`% of World`))
    pivot_longer(!c(region,country,year,pop)) %>%
    filter(year %in% c(2004,2010,2019,max(year))) %>%
    select(!pop) %>%
    pivot_wider(names_from = year,values_from=value) %>%
    mutate(diff_2004_2023=`2023`-`2004`,
         diff_2010_2023=`2023`-`2010`) %>%
  write_csv(file = paste0(folder_name,"summ_table.csv"))
  
}
  
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# create HTML tables

with(l_gni_percap, {
df_summ <- GNI_per_cap_2021intUSD_sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE) %>%
  mutate(value=value/1e3)  %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(region,country,year,pop)) %>%
  filter(year %in% c(2004,2010,2019,max(year))) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2004_2023=ifelse(grepl("rel_val",name),
                (`2023`/`2004`-1)*100,`2023`-`2004`),
         diff_2010_2023=ifelse(grepl("rel_val",name),
                (`2023`/`2010`-1)*100,`2023`-`2010`),
    diff_2004_2023=paste0(ifelse(diff_2004_2023>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2004_2023,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2004_2023,1),"k"),
                      paste0(round(diff_2004_2023),"%")) ) ),
    diff_2010_2023=paste0(ifelse(diff_2010_2023>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2023,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2023,1),"k"),
                      paste0(round(diff_2010_2023),"%")) ) ),
    start_2004=ifelse(grepl("%",name),signif(`2004`,2),
                    ifelse(grepl("value",name),round(`2004`,1),
                      round(`2004`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2023`,2),
                    ifelse(grepl("value",name),round(`2023`,1),
                      round(`2023`)) ),
    parenth_2004=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2004),")"),
      "",
      paste0(" (",start_2004,"→",end_val,")" ) ),
    diff_2004_2023=paste0(diff_2004_2023,parenth_2004),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2023=paste0(diff_2010_2023,parenth_2010)
    )

### 
html_tables <- lapply(c("diff_2004_2023","diff_2010_2023"), function(diff_var) {
  make_table(
    data = df_summ %>%
      filter(!grepl("LAT_AM|World|S_EUR|G7|DE", name)) %>%
      select(matches("country|name|diff")),
    diff_var = diff_var
  )
})

# cat(html_tables[[1]])
# cat("\n<br>\n")  # optional separator
# cat(html_tables[[2]])

writeLines(html_tables[[1]],
  "../../_includes/images/hu-cee-convergence/output/GNI_per_cap/table_2004_2023.html")
writeLines(html_tables[[2]],
  "../../_includes/images/hu-cee-convergence/output/GNI_per_cap/table_2010_2023.htm")

} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# GDP per capita

with(list(all_vars=c("rel_val",grep("value|AT|DE|EU8",
            colnames(l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr),
            value=T)),
  start_yr_vals=c(2004,2010),
  show_plot=F,
  save_plot_flag=F,
  save_table=T,
  folder_name="output/GDP_per_cap/",
  l_table_save=list()
  ),
  {
  
  all_vars=grep("LAT",all_vars,value=T,invert=T)

for (start_yr in start_yr_vals) {
for (sel_var in all_vars) {
  
  y_txt <- if (grepl("value",sel_var)) {
  "GDP per capita (thousand constant 2021 USD, PPP)" 
    } else {
  paste0("GDP per capita, ", sel_var,"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- paste0("GDP per capita (constant 2021 USD PPP)",
              "\nrelative to first year (",start_yr,"=100)")
    }
  
df_plot <- l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(value=value/1e3) %>%
  group_by(country) %>%
  mutate(start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        signif(diff_end_start,2)),
    ifelse(sel_var=="value","k USD PPP","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# View(df_plot)

l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }

# caption text
    caption_src <- "source: https://data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD"
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", "),
    grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

sel_yrs <- unique(c(min(df_plot$year),2010,2015,2019,max(df_plot$year)))
if (sel_var=="rel_val") {
sel_yrs <- setdiff(unique(c(min(df_plot$year),
  2010,2015,2019,max(df_plot$year))),min(df_plot$year))
}

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% sel_yrs ) 
  # %>% mutate(dodge_y=year %in% 2010)
# print(df_labels)  

y_breaks <- if (sel_var == "value") { 0:10*10 } else {
                  (0:ceiling(max_val/20))*20 }
hline_vals <- if (sel_var == "value") {
                (1:floor(max_val/10))*10 } else {
                (1:floor(max_val/25))*25 }
if (sel_var == "rel_val") {
  y_breaks <- seq(100,200,50)
  hline_vals <- y_breaks # seq(100,500,100)
}

df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel",sel_var),
              round(value),signif(value,2)), 
                ifelse(sel_var=="value","k USD PPP","%")), 
            paste0(signif(value,2),
                ifelse(sel_var=="value","k","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,3.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(breaks=seq(start_yr,2024,4),
    expand=expansion(mult=c(0.07,0.075))) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(ifelse(sel_var=="rel_val",80,0),NA),
    breaks=y_breaks) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}

} # show plot

}
  
} # end of for loop
  
# SAVE TABLE
if (save_table) {
# FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            start_year = yr,
            var = var) })) }) )
    write_csv(df_save_full, 
      file=paste0(folder_name,"full_table.csv"))
#   View(df_save_full)
    
# magyar változat
facet_labels_hu <- c(
  "% of EU8-2004" = "EU8 átlag %-a",
  "value-2004"= "ezer USD (konstans 2021, PPP)",
  "rel_val-2004" = "2004-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
    filter(grepl("rel_val|2004",facet_id)) %>%
    filter(!grepl("of DE",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))
    
    
# SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"full_table_wide.csv"))

    # selected variable
    # df_save_full %>%
    #   filter(facet_id %in% "% of EU8-2004") %>%
    #         mutate(country_val_str=fct_reorder(
    #       country_val_str,diff_end_start,.desc=T) ) %>%
    #   arrange(country_val_str,year) %>%
    #   select(country_val_str,country,facet_id,var,year,value) %>%
    # write_csv(file = paste0(folder_name,"df_sel_var.csv"))
    
  # summary table (start and end values)
  l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE) %>%
  mutate(value=value/1e3)  %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(region,country,year,pop)) %>%
  filter(year %in% c(2004,2010,2019,max(year))) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2004_2024=`2024`-`2004`,
         diff_2010_2024=`2024`-`2010`  ) %>%
  write_csv(file = paste0(folder_name,"summ_table.csv"))
} # SAVE IF
  
  
})


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# create HTML tables

with(l_GDP_percap, {
df_summ <- gdp_per_cap_2021usdppp_sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE) %>%
  mutate(value=value/1e3)  %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(region,country,year,pop)) %>%
  filter(year %in% c(2004,2010,2019,max(year))) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2004_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2004`-1)*100,`2024`-`2004`),
         diff_2010_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2010`-1)*100,`2024`-`2010`),
    diff_2004_2024=paste0(ifelse(diff_2004_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2004_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2004_2024,1),"k"),
                      paste0(round(diff_2004_2024),"%")) ) ),
    diff_2010_2024=paste0(ifelse(diff_2010_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2024,1),"k"),
                      paste0(round(diff_2010_2024),"%")) ) ),
    start_2004=ifelse(grepl("%",name),signif(`2004`,2),
                    ifelse(grepl("value",name),round(`2004`,1),
                      round(`2004`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2024`,2),
                    ifelse(grepl("value",name),round(`2024`,1),
                      round(`2024`)) ),
    parenth_2004=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2004),")"),
      "",
      paste0(" (",start_2004,"→",end_val,")" ) ),
    diff_2004_2024=paste0(diff_2004_2024,parenth_2004),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2024=paste0(diff_2010_2024,parenth_2010)
    )

### 
html_tables <- lapply(c("diff_2004_2024","diff_2010_2024"), function(diff_var) {
  make_table(
    data = df_summ %>%
      filter(!grepl("LAT_AM|World|S_EUR|G7|DE|W_EUR", name)) %>%
      select(matches("country|name|diff")),
    diff_var = diff_var
  )
})

# cat(html_tables[[1]])
# cat("\n<br>\n")  # optional separator
# cat(html_tables[[2]])

writeLines(html_tables[[1]], 
  "../../_includes/images/hu-cee-convergence/output/GDP_per_cap/table_2004_2024.html")
writeLines(html_tables[[2]], 
  "../../_includes/images/hu-cee-convergence/output/GDP_per_cap/table_2010_2024.html")

} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ANNUAL AVERAGE WAGE

with(list(all_vars=c("rel_val",grep("DE|EU8|value",
            colnames(l_wages$oecd$sel_cntrs$annual_aver_wage),
            value=T)),
  start_yr_vals=c(2004,2010),
  folder_name="output/wages/annual_aver_wage/",
  l_table_save=list(),
  show_plot=F,
  save_plot_flag=F,
  save_table=T), {
  
for (sel_var in all_vars) {
for (start_yr in start_yr_vals) {
  
  y_txt <- if (grepl("value",sel_var)) {
  "Annual average wage (2024 constant USD PPP)" 
    } else {
  paste0("Annual average wage, ", sel_var,"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- paste0("Annual average wage (constant USD PPP)", 
              "\nrelative to first year (=100)") }
  
df_plot <- l_wages$oecd$sel_cntrs$annual_aver_wage %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(value=value/1e3,
         start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
         diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        signif(diff_end_start,2)),
    ifelse(sel_var=="value","k USD PPP","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# View(df_plot)
l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }

# caption text
    caption_src <- "source: https://data-explorer.oecd.org/s/1p0"
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", "),
    grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2020,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
y_breaks <- if (sel_var == "value") { 0:10*10 } else {
                  (0:floor(max_val/20))*20 }
hline_vals <- if (sel_var == "value") {
                (1:floor(max_val/10))*10 } else {
                (1:floor(max_val/25))*25 }
if (sel_var == "rel_val") {
  y_breaks <- seq(100,250,50)
  hline_vals <- y_breaks # seq(100,500,100)
}

df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel",sel_var),
              round(value),signif(value,2)), 
                ifelse(sel_var=="value","k PPS","%")), 
            paste0(signif(value,2),
                ifelse(sel_var=="value","k","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,3.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(expand=expansion(mult=c(0.07,0.075))) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(ifelse(sel_var=="rel_val",90,0),NA),
    breaks=y_breaks
    ) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
# folder_name <- "output/wages/annual_aver_wage/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
} # show PLOT  

# SAVE TABLE
if (save_table) {
    df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) )
    write_csv(df_save_full, 
      file=paste0(folder_name,"data_table.csv"))

# magyar változat
facet_labels_hu <- c(
  "% of EU8-2004" = "EU8 átlag %-a",
  "value-2004"= "ezer USD (konstans 2021, PPP)",
  "rel_val-2004" = "2004-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
    filter(grepl("rel_val|2004",facet_id)) %>%
    filter(!grepl("of DE",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))
  
# SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"data_table_wide.csv"))
# 
# # SAVE selected variable
#     df_save_full %>%
#       filter(facet_id %in% "% of EU8-2004") %>%
#       mutate(country_val_str=fct_reorder(
#           country_val_str,diff_end_start,.desc=T) ) %>%
#       arrange(country_val_str,year) %>%
#       select(country_val_str,country,facet_id,var,year,value) %>%
#     write_csv(file = paste0(folder_name,"df_sel_var.csv"))

    
}

}
  
} # end of for loop
            
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# create HTML tables

with(l_wages$oecd$sel_cntrs, {
df_summ <- annual_aver_wage %>%
  filter(country %in% l_groups$list_cntrs$CEE) %>%
  select(!c(REF_AREA,Measure,`Price base`,UNIT_MEASURE)) %>%
  mutate(value=value/1e3)  %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(region,country,year,pop)) %>%
  filter(year %in% c(2004,2010,2019,max(year))) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2004_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2004`-1)*100,`2024`-`2004`),
         diff_2010_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2010`-1)*100,`2024`-`2010`),
    diff_2004_2024=paste0(ifelse(diff_2004_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2004_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2004_2024,1),"k"),
                      paste0(round(diff_2004_2024),"%")) ) ),
    diff_2010_2024=paste0(ifelse(diff_2010_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2024,1),"k"),
                      paste0(round(diff_2010_2024),"%")) ) ),
    start_2004=ifelse(grepl("%",name),signif(`2004`,2),
                    ifelse(grepl("value",name),round(`2004`,1),
                      round(`2004`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2024`,2),
                    ifelse(grepl("value",name),round(`2024`,1),
                      round(`2024`)) ),
    parenth_2004=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2004),")"),
      "",
      paste0(" (",start_2004,"→",end_val,")" ) ),
    diff_2004_2024=paste0(diff_2004_2024,parenth_2004),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2024=paste0(diff_2010_2024,parenth_2010)
    )

### 
html_tables <- lapply(c("diff_2004_2024","diff_2010_2024"), function(diff_var) {
  make_table(
    data = df_summ %>%
      filter(!grepl("LAT_AM|World|S_EUR|W_EUR|G7|DE", name)) %>%
      select(matches("country|name|diff")),
    diff_var = diff_var
  )
})

# cat(html_tables[[1]])
# cat("\n<br>\n")  # optional separator
# cat(html_tables[[2]])

writeLines(html_tables[[1]], 
  "../../_includes/images/hu-cee-convergence/output/wages/annual_aver_wage/table_2004_2024.html")
writeLines(html_tables[[2]],
  "../../_includes/images/hu-cee-convergence/output/wages/annual_aver_wage/table_2010_2024.html")

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# MINIMUM WAGE

with(list(all_vars=c("rel_val",grep("S_EUR|EU8|value",
            colnames(l_wages$oecd$sel_cntrs$annual_min_wage),
            value=T)),
  start_yr_vals=c(2004,2010),
  folder_name="output/wages/min_wage/",
  l_table_save=list(),
  show_plot=F,
  save_plot_flag=F,
  save_table=T), {
    
  all_vars <- grep("LAT",all_vars,value=T,invert=T)
  # print(all_vars)
  
for (sel_var in all_vars) {
for (start_yr in start_yr_vals) {

  y_txt <- if (grepl("value",sel_var)) {
  "Minimum wage (constant 2024 USD PPP, thousand)" 
    } else {
  paste0("Minimum wage, ", gsub("EU8","EU3",sel_var),"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- "Minimum wage (constant 2024 USD PPP), relative to first year (=100)" 
    }
  
df_plot  <- l_wages$oecd$sel_cntrs$annual_min_wage %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(value=value/1e3,
    start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        signif(diff_end_start,2)),
    ifelse(sel_var=="value","k USD PPP","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# View(df_plot)

l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }

# caption text
    caption_src <- paste0("source: https://data-explorer.oecd.org/",
    "vis?df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_EARNINGS@RMW&df[ag]=OECD.ELS.SAE")
    
    EU8_min_wage <- grep("Germany",intersect(unique(l_wages$oecd$all$annual_min_wage$country),
              l_groups$comp_groups$EU8),value=T,invert=T)
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(EU8_min_wage,collapse=", "),
    grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2020,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
y_breaks <- if (sel_var == "value") { 0:10*10 } else {
                  (0:floor(max_val/20))*20 }
hline_vals <- if (sel_var == "value") {
                (1:floor(max_val/10))*10 } else {
                (1:floor(max_val/25))*25 }
if (sel_var == "rel_val") {
  y_breaks <- (1:floor(max_val/100))*100
  hline_vals <- y_breaks # seq(100,500,100)
}

df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel",sel_var),
              round(value),signif(value,2)), 
                ifelse(sel_var=="value","k USD PPP","%")), 
            paste0(signif(value,2),
                ifelse(sel_var=="value","k","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,3.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(expand=expansion(mult=c(0.07,0.075)),
    breaks = seq(min(df_plot$year),2024,4)) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(ifelse(sel_var=="rel_val",90,0),NA),
    breaks=y_breaks
    ) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
# folder_name <- "output/wages/min_wage/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
} # show plot


# SAVE TABLE
if (save_table) {
    # FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) )
    write_csv(df_save_full, 
      file=paste0(folder_name,"data_table.csv"))
# magyar változat
facet_labels_hu <- c(
  "% of EU8-2004" = "EU3 átlag %-a",
  "value-2004"= "ezer USD (konstans 2021, PPP)",
  "rel_val-2004" = "2004-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
    filter(grepl("rel_val|2004",facet_id)) %>%
    filter(!grepl("of DE|S_EUR",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))

}

}
  
} # end of for loop
            
})


        
# SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"data_table_wide.csv"))
# 
# # SAVE selected variable
#     df_save_full %>%
#       filter(facet_id %in% "% of EU8-2004") %>%
#       mutate(country_val_str=fct_reorder(
#           country_val_str,diff_end_start,.desc=T) ) %>%
#       arrange(country_val_str,year) %>%
#       select(country_val_str,country,facet_id,var,year,value) %>%
#     write_csv(file = paste0(folder_name,"df_sel_var.csv"))


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# create HTML tables

with(l_wages$oecd$sel_cntrs, {
df_summ <- annual_min_wage %>%
  filter(country %in% l_groups$list_cntrs$CEE) %>%
  select(!c(REF_AREA,Measure,`Price base`,UNIT_MEASURE)) %>%
  mutate(value=value/1e3)  %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(region,country,year,pop)) %>%
  filter(year %in% c(2004,2010,2019,max(year))) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2004_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2004`-1)*100,`2024`-`2004`),
         diff_2010_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2010`-1)*100,`2024`-`2010`),
    diff_2004_2024=paste0(ifelse(diff_2004_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2004_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2004_2024,1),"k"),
                      paste0(round(diff_2004_2024),"%")) ) ),
    diff_2010_2024=paste0(ifelse(diff_2010_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2024,1),"k"),
                      paste0(round(diff_2010_2024),"%")) ) ),
    start_2004=ifelse(grepl("%",name),signif(`2004`,2),
                    ifelse(grepl("value",name),round(`2004`,1),
                      round(`2004`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2024`,2),
                    ifelse(grepl("value",name),round(`2024`,1),
                      round(`2024`)) ),
    parenth_2004=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2004),")"),
      "",
      paste0(" (",start_2004,"→",end_val,")" ) ),
    diff_2004_2024=paste0(diff_2004_2024,parenth_2004),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2024=paste0(diff_2010_2024,parenth_2010)
    )

### 
html_tables <- lapply(c("diff_2004_2024","diff_2010_2024"), function(diff_var) {
  make_table(
    data = df_summ %>%
      filter(!grepl("LAT_AM|World|S_EUR|W_EUR|G7|DE", name)) %>%
      select(matches("country|name|diff")),
    diff_var = diff_var
  )
})

# cat(html_tables[[1]])
# cat("\n<br>\n")  # optional separator
# cat(html_tables[[2]])

writeLines(html_tables[[1]], 
  "../../_includes/images/hu-cee-convergence/output/wages/min_wage/table_2004_2024.html")
writeLines(html_tables[[2]],
  "../../_includes/images/hu-cee-convergence/output/wages/min_wage/table_2010_2024.html")

} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# MEDIAN EQUIVALISED NET INCOME

with(list(all_vars=c("rel_val",grep("%|value",
            colnames(l_wages$eurostat$median_equiv_net_income$sel_cntr),
            value=T)),
  start_yr_vals=c(2005,2010),
  folder_name="output/wages/median_equiv_net_income/",
  l_table_save=list(),
  show_plot=F,
  save_plot_flag=F,
  save_table=T), {
  
for (sel_var in all_vars) {
for (start_yr in start_yr_vals) {
  
  y_txt <- if (grepl("value",sel_var)) {
  "Median equivalised net income (thousand PPS)" 
    } else {
  paste0("Median equivalised net income, ", sel_var,"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- paste0("Median equivalised net income in PPS",
    "\nrelative to first year (=100)")
    }
  
df_plot <- l_wages$eurostat$median_equiv_net_income$sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(value=value/1e3,
    start_val=(!!sym(sel_var))[year==min(year)],
    end_val=(!!sym(sel_var))[year==max(year)],
    diff_end_start=end_val-start_val) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        signif(diff_end_start,2)),
    ifelse(sel_var=="value","k PPS","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# View(df_plot)
print(start_yr); print(sel_var)
  
# to save
l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }

# caption text
    caption_src <- "source: https://ec.europa.eu/eurostat/databrowser/view/ilc_di03/"
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", "),
    grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2020,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
y_breaks <- if (sel_var == "value") {0:5*5} else {
                  (0:ceiling(max_val/20))*20 }
hline_vals <- if (sel_var == "value") {(1:floor(max_val/5))*5} else {
                  (1:floor(max_val/25))*25}
if (sel_var == "rel_val") {
  y_breaks <- seq(100,ceiling(max_val/100)*100,100)
  hline_vals <- seq(100,ceiling(max_val/100)*100,100)
}

df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel",sel_var),
              round(value),signif(value,2)), 
                ifelse(sel_var=="value","k PPS","%")), 
            paste0(signif(value,2),
                ifelse(sel_var=="value","k","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,3.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(expand=expansion(mult=c(0.07,0.075)),
    breaks=seq(start_yr,2024,4)) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(ifelse(sel_var=="rel_val",80,0),NA),breaks=y_breaks) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
# folder_name <- "output/wages/median_equiv_net_income/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
} # show plot

# SAVE TABLE
if (save_table) {
  
  # FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) )
    write_csv(df_save_full, 
          file=paste0(folder_name,"data_table.csv"))
### ### ### ### ### ### ### ### ### ### ### ### ### 
# magyar változat
facet_labels_hu <- c(
  "% of EU8-2005" = "EU8 átlag %-a",
  "value-2005"= "ezer PPS",
  "rel_val-2005" = "2005-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
    filter(grepl("rel_val|2005",facet_id)) %>%
    filter(!grepl("of DE|of AT|W_EUR",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))
    
}

}
} # end of for loop
            
})

# # SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"data_table_wide.csv"))
# 
# # SAVE selected variable
#     df_save_full %>%
#       filter(facet_id %in% "% of EU8-2004") %>%
#       mutate(country_val_str=fct_reorder(
#           country_val_str,diff_end_start,.desc=T) ) %>%
#       arrange(country_val_str,year) %>%
#       select(country_val_str,country,facet_id,var,year,value) %>%
#     write_csv(file = paste0(folder_name,"df_sel_var.csv"))
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# HTML tables

with(l_wages$eurostat, {
df_summ <- median_equiv_net_income$sel_cntr %>%
  filter(country %in% l_groups$list_cntrs$CEE) %>%
  select(!c(sex,unit,Code,age,indic_il)) %>%
  mutate(value=value/1e3) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(region,country,year,pop)) %>%
  filter(year %in% c(2007,2010,2019,max(year)) & 
      !grepl("S_EUR| AT|W_EUR3",name)) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2007_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2007`-1)*100,`2024`-`2007`),
         diff_2010_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2010`-1)*100,`2024`-`2010`),
    diff_2007_2024=paste0(ifelse(diff_2007_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2007_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2007_2024,1),"k"),
                      paste0(round(diff_2007_2024),"%")) ) ),
    diff_2010_2024=paste0(ifelse(diff_2010_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2024,1),"k"),
                      paste0(round(diff_2010_2024),"%")) ) ),
    start_2007=ifelse(grepl("%",name),signif(`2007`,2),
                    ifelse(grepl("value",name),round(`2007`,1),
                      round(`2007`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2024`,2),
                    ifelse(grepl("value",name),round(`2024`,1),
                      round(`2024`)) ),
    parenth_2007=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2007),")"),
      "",
      paste0(" (",start_2007,"→",end_val,")" ) ),
    diff_2007_2024=paste0(diff_2007_2024,parenth_2007),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2024=paste0(diff_2010_2024,parenth_2010)
    ) 

### 
html_tables <- lapply(c("diff_2007_2024","diff_2010_2024"), function(diff_var) {
  make_table(
    data = df_summ %>%
      filter(!grepl("LAT_AM|World|S_EUR|W_EUR|G7|DE|AT", name)) %>%
      select(matches("country|name|diff")),
    diff_var = diff_var
  )
})

writeLines(html_tables[[1]], 
"../../_includes/images/hu-cee-convergence/output/wages/median_equiv_net_income/table_2007_2024.html")
writeLines(html_tables[[2]],
"../../_includes/images/hu-cee-convergence/output/wages/median_equiv_net_income/table_2010_2024.html")

} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# REAL MEDIAN HOURLY EARNINGS (EUROSTAT)

with(list(all_vars=c("rel_val",
      grep("DE|EU8|value",
      colnames(l_wages$eurostat$real_median_hr_earning$sel_cntr),value=T)),
      start_yr_vals=c(2006,2010),
      folder_name="output/wages/real_median_hourly/",
      l_table_save=list(),
      show_plot=F,
      save_plot_flag=F,
      save_table=T), {
  
for (sel_var in all_vars) {
for (start_yr in start_yr_vals ) {
  
  x_txt <- if (grepl("value",sel_var)) {
  "Real median hourly earnings (PPS)" } else {
  paste0("Real median hourly earnings, ", sel_var,"*")
    }
  if (sel_var=="rel_val") {
    x_txt <- "Real median hourly earnings (PPS), relative to first year (=100)" }
  
df_plot <- l_wages$eurostat$real_median_hr_earning$sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE &
        year >= start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(
    year_end=lead(year),
    value_end=lead(!!sym(sel_var))  ) %>%
  # keep only rows that have a next year
  filter(!is.na(year_end)) %>%
  ungroup() %>% 
  mutate(era=paste0(year,"-",year_end),
        era=factor(era,levels=rev(unique(era))) ) %>%
  group_by(country) %>%
  mutate(start_val=(!!sym(sel_var))[year==min(year)],
         end_val=value_end[year_end==max(year_end)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country,
    " (", ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        signif(diff_end_start,2)),
    ifelse(sel_var=="value","k PPS","%"),
    ")" )) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) ) %>%
  group_by(country) %>%
  filter(any(year==start_yr))
# View(df_plot)

l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }


# caption text
    caption_src <- "source: https://ec.europa.eu/eurostat/databrowser/view/earn_ses_pub2s/"
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
      str_wrap(case_when(
    # grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    # grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany",
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", ")
        ),    
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_summ <- df_plot %>% 
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(value=ifelse(year_fact==1, 
    unique(sum(!!sym(sel_var)*pop/sum(pop))),
    unique(sum(value_end*pop/sum(pop))) ) ) %>%
  distinct() %>%
  ungroup() %>%
  mutate(str_yr=ifelse(year_fact==2,
            paste0(signif(value,2), ifelse(sel_var=="value","k PPS","%")), 
            paste0(signif(value,2), ifelse(sel_var=="value","k","%"))  ))
  
title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))
# View(df_summ)

break_vals <- if (sel_var == "value") {0:10*2} else {
            0:10*ifelse(grepl("S_EUR",sel_var),20,10) }
if (sel_var == "rel_val") {
  break_vals <- seq(100,400,50)
  # hline_vals <- seq(100,500,100)
}

x_vlines <- if (sel_var == "value") {
              c(5,10,15)} else { (1:floor(max_val/25))*25 }
if (sel_var == "rel_val") { 
  x_vlines <- seq(100,ceiling(max_val/100)*100,50)
  }

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=get(sel_var),xend=value_end,y=era,yend=era)) + # group = era
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) + 
  geom_segment(arrow=arrow(length=unit(0.3, "cm")),linewidth=1) +
  geom_text(
  data = . %>% group_by(country) %>% filter(year == min(year)),
  aes( x = get(sel_var), y = era,
    label = paste0(
      round(get(sel_var), round_val),
      ifelse(grepl("%", sel_var), "%", "")    )  ),
  hjust=1,          # right-justify text
  nudge_x= -1,    # move left (adjust scale as needed)
  size=6) +
geom_text(
  # data = . %>% filter(year_end == 2022),
  aes(x=value_end,y=era,label=paste0(
      round(value_end, round_val),
      ifelse(grepl("%", sel_var), "%", "")    )  ),
  hjust = 0,          # left-justify text
  nudge_x = 1,     # move right
  size = 6)  +
  scale_x_continuous(limits=c(ifelse(sel_var=="rel_val",100,0),NA),
    expand=expansion(mult=c(0.02,0.15)),
    breaks=break_vals) +
  geom_vline(xintercept=x_vlines,
              linewidth=1/4,linetype="dashed") +
  labs(x=x_txt,y="",caption=caption_txt,title = title_str) +
  theme_bw() + plot_settings + theme(
    plot.title=element_text(size=22),
    axis.text.x=element_text(angle=0))

print(p)

# SAVE PLOT
folder_name <- "output/wages/real_median_hourly/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
} # show plot

# SAVE TABLE
if (save_table) {
  
  # FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) )
    write_csv(df_save_full, 
      file=paste0(folder_name,"data_table.csv"))
### ### ### ### ### ### ### ### ### ### ### ### ### 
# magyar változat
facet_labels_hu <- c(
  "% of EU8-2006" = "EU8 átlag %-a",
  "value-2006"= "PPS",
  "rel_val-2006" = "2006-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
read_csv("output/wages/real_median_hourly/data_table.csv") %>%
  select(country, year, value, year_end,
    value_end,country_val_str,facet_id,var,diff_end_start) %>%
  pivot_longer(
    cols = c(value, value_end),
    names_to = "point",
    values_to = "value"
  ) %>%
  mutate(
    year = ifelse(point == "value", year, year_end)
  ) %>%
  select(!c(point,year_end)) %>%
  distinct() %>%
    filter(grepl("rel_val|2006",facet_id)) %>%
    filter(!grepl("of DE|of AT|W_EUR",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))

    }

  } # start yr
} # end of for loop
            
})

# # SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"data_table_wide.csv"))
# 
# # SAVE selected variable
#     df_save_full %>%
#       filter(facet_id %in% "% of EU8-2004") %>%
#       mutate(country_val_str=fct_reorder(
#           country_val_str,diff_end_start,.desc=T) ) %>%
#       arrange(country_val_str,year) %>%
#       select(country_val_str,country,facet_id,var,year,value) %>%
#     write_csv(file = paste0(folder_name,"df_sel_var.csv"))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# HTML tables

with(l_wages$eurostat, {
df_summ <- real_median_hr_earning$sel_cntr %>%
  filter(country %in% l_groups$list_cntrs$CEE) %>%
  select(!c(sex,unit,Code)) %>%
  mutate(value=value) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(region,country,year,pop)) %>%
  filter(year %in% c(2006,2010,2019,max(year)) & 
      !grepl("S_EUR| AT|W_EUR3",name)) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2006_2022=ifelse(grepl("rel_val",name),
                (`2022`/`2006`-1)*100,`2022`-`2006`),
         diff_2010_2022=ifelse(grepl("rel_val",name),
                (`2022`/`2010`-1)*100,`2022`-`2010`),
    diff_2006_2022=paste0(ifelse(diff_2006_2022>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2006_2022,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2006_2022,1),""),
                      paste0(round(diff_2006_2022),"%")) ) ),
    diff_2010_2022=paste0(ifelse(diff_2010_2022>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2022,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2022,1),""),
                      paste0(round(diff_2010_2022),"%")) ) ),
    start_2006=ifelse(grepl("%",name),signif(`2006`,2),
                    ifelse(grepl("value",name),round(`2006`,1),
                      round(`2006`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2022`,2),
                    ifelse(grepl("value",name),round(`2022`,1),
                      round(`2022`)) ),
    parenth_2006=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2006),")"),
      "",
      paste0(" (",start_2006,"→",end_val,")" ) ),
    diff_2006_2022=paste0(diff_2006_2022,parenth_2006),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2022=paste0(diff_2010_2022,parenth_2010)
    ) 
# View(df_summ)

### 
html_tables <- lapply(c("diff_2006_2022","diff_2010_2022"), function(diff_var) {
  make_table(
    data = df_summ %>%
      filter(!grepl("LAT_AM|World|S_EUR|W_EUR|G7|DE|AT", name)) %>%
      select(matches("country|name|diff")),
    diff_var = diff_var,
    name_labels=c(
  "rel_val" = "relative to initial value (%)",
  "value" = "absolute value (PPS)",
  "% of EU8" = "% of EU8",
  "% of EU3" = "% of EU3",
  "% of DE" = "% of DE",
  "% of G7" = "% of G7",
  "% of S_EUR4" = "% of S_EUR4"
   )
  )
})

writeLines(html_tables[[1]],
  "../../_includes/images/hu-cee-convergence/output/wages/real_median_hourly/table_2006_2022.html")
writeLines(html_tables[[2]],
  "../../_includes/images/hu-cee-convergence/output/wages/real_median_hourly/table_2010_2022.html")

} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ACTUAL INDIVIDUAL CONSUMPTION (EUROSTAT)

with(list(all_vars=c(
  "rel_val",grep("%|value",colnames(l_cons$sel_cntr),value=T)),
  start_yr_vals=c(2004,2010),
  folder_name="output/actual_indiv_consump/",
  l_table_save=list(),
  show_plot=F,        
  save_plot_flag=F,
  save_table=T), {
  
for (sel_var in all_vars) {
for (start_yr in start_yr_vals) {
  
  y_txt <- if (grepl("value",sel_var)) {
  "Actual individual consumption (thousand PPS)" 
    } else {
  paste0("Actual individual consumption, ", sel_var,"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- paste0("Actual individual consumption in PPS",
    "\nrelative to first year (=100)")
    }
  
df_plot  <- l_cons$sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(value=value/1e3,
    start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        signif(diff_end_start,2)),
    ifelse(sel_var=="value","k PPS","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# View(df_plot)
# TO SAVE
l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }

# caption text
    caption_src <- 
      "source: https://ec.europa.eu/eurostat/databrowser/view/prc_ppp_ind/"
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", "),
    grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2020,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
y_breaks <- if (sel_var == "value") {0:5*5} else {
                  (0:ceiling(max_val/20))*20 }
hline_vals <- if (sel_var == "value") {(1:floor(max_val/5))*5} else {
                  (1:floor(max_val/25))*25}
if (sel_var == "rel_val") {
  y_breaks <- seq(100,ceiling(max_val/100)*100,100)
  hline_vals <- seq(100,ceiling(max_val/100)*100,100)
}


df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel",sel_var),
              round(value),signif(value,2)), 
                ifelse(sel_var=="value","k PPS","%")), 
            paste0(signif(value,2),
                ifelse(sel_var=="value","k","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,3.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(expand=expansion(mult=c(0.07,0.075)),
    breaks=seq(start_yr,2024,4)) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(ifelse(sel_var=="rel_val",80,0),NA),breaks=y_breaks) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
folder_name <- "output/actual_indiv_consump/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
}

# SAVE TABLE
if (save_table) {
        # FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) )
    write_csv(df_save_full, 
      file=paste0(folder_name,"data_table.csv"))

    # magyar változat
facet_labels_hu <- c(
  "% of EU8-2004" = "EU8 átlag %-a",
  "value-2004"= "PPS",
  "rel_val-2004" = "2004-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
    filter(grepl("rel_val|2004",facet_id)) %>%
    filter(!grepl("of DE|of AT|S_EUR|W_EUR",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))

    
# # SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"data_table_wide.csv"))
# 
# # SAVE selected variable
#     df_save_full %>%
#       filter(facet_id %in% "% of EU8-2004") %>%
#       mutate(country_val_str=fct_reorder(
#           country_val_str,diff_end_start,.desc=T) ) %>%
#       arrange(country_val_str,year) %>%
#       select(country_val_str,country,facet_id,var,year,value) %>%
#     write_csv(file = paste0(folder_name,"df_sel_var.csv"))

}

}
} # end of for loop
            
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# PRODUCTIVITY: output per hour worked

with(list(all_vars=c("rel_val",grep("value|DE|EU8|S_EUR4",
            colnames(l_product$owid$`per hour of work`),
            value=T)),
  start_yr_vals=c(2004,2010),
  folder_name="output/productivity/per_hr_work/",
  l_table_save=list(),
  show_plot=F,
          save_plot_flag=F,
          save_table=T), {
  
for (sel_var in all_vars) {
for (start_yr in start_yr_vals) {
  
  y_txt <- if (grepl("value",sel_var)) {
  "GDP per hour worked (constant 2020 USD, PPP)" 
    } else {
  paste0("GDP per hour worked (constant 2020 USD, PPP), ", sel_var,"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- paste0("GDP per hour worked (constant 2020 USD, PPP)",
    "\nrelative to first year (=100)")
    }
  
df_plot  <- l_product$owid$`per hour of work` %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(# value=value/1e3,
    start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(sel_var=="value","$",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        signif(diff_end_start,2)),
    ifelse(sel_var=="value","","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# TO SAVE
l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }

# caption text
    caption_src <- paste0("source: ",
    "ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable")
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    # grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", "),
    # grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2020,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
y_breaks <- if (sel_var == "value") {
     seq(0,ceiling(max_val/10)*10,10)
} else {
    (0:ceiling(max_val/20))*20 }
# horiz lines
hline_vals <- if (sel_var == "value") {
  seq(10,floor(max_val/10)*10,10)
  } else {
  (1:floor(max_val/25))*25}
if (sel_var == "rel_val") {
  y_breaks <- seq(50,ceiling(max_val/50)*50,50)
  hline_vals <- seq(100,floor(max_val/50)*50,50)
}

# summary table
df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel",sel_var),
              round(value),signif(value,2)), 
                ifelse(sel_var=="value","","%")), 
            paste0(signif(value,2),
                ifelse(sel_var=="value","","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(ifelse(sel_var=="value","$",""),df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,3.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(expand=expansion(mult=c(0.07,0.075)),
    breaks=seq(start_yr,2024,4)) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(ifelse(sel_var=="rel_val",80,0),NA),breaks=y_breaks) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
folder_name <- "output/productivity/per_hr_work/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
}

# SAVE TABLE
if (save_table) {
        # FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) )
    write_csv(df_save_full, 
      file=paste0(folder_name,"data_table.csv"))

    # magyar változat
facet_labels_hu <- c(
  "% of EU8-2004" = "EU8 átlag %-a",
  "value-2004"= "USD (konstans 2021, PPP)",
  "rel_val-2004" = "2004-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
    filter(grepl("rel_val|2004",facet_id)) %>%
    filter(!grepl("of DE|of AT|S_EUR",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))

# # SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"data_table_wide.csv"))
# 
# # SAVE selected variable
#     df_save_full %>%
#       filter(facet_id %in% "% of EU8-2004") %>%
#       mutate(country_val_str=fct_reorder(
#           country_val_str,diff_end_start,.desc=T) ) %>%
#       arrange(country_val_str,year) %>%
#       select(country_val_str,country,facet_id,var,year,value) %>%
#     write_csv(file=paste0(folder_name,"df_sel_var.csv"))

}

}
} # end of for loop
            
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# HTML tables

with(l_product, {

df_summ <- owid$`per hour of work` %>%
  filter(country %in% l_groups$list_cntrs$CEE) %>%
  select(!c(region,measure,unit,Code,`data source`)) %>%
  mutate(value=value) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(country,year,pop)) %>%
  filter(year %in% c(2004,2010,2019,max(year)) & 
      !grepl("S_EUR| AT|W_EUR3|LAT|G7",name)) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2004_2023=ifelse(grepl("rel_val",name),
                (`2023`/`2004`-1)*100,`2023`-`2004`),
         diff_2010_2023=ifelse(grepl("rel_val",name),
                (`2023`/`2010`-1)*100,`2023`-`2010`),
    diff_2004_2023=paste0(ifelse(diff_2004_2023>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2004_2023,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2004_2023,1),""),
                      paste0(round(diff_2004_2023),"%")) ) ),
    diff_2010_2023=paste0(ifelse(diff_2010_2023>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2023,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2023,1),""),
                      paste0(round(diff_2010_2023),"%")) ) ),
    start_2004=ifelse(grepl("%",name),signif(`2004`,2),
                    ifelse(grepl("value",name),round(`2004`,1),
                      round(`2004`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2023`,2),
                    ifelse(grepl("value",name),round(`2023`,1),
                      round(`2023`)) ),
    parenth_2004=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2004),")"),
      "",
      paste0(" (",start_2004,"→",end_val,")" ) ),
    diff_2004_2023=paste0(diff_2004_2023,parenth_2004),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2023=paste0(diff_2010_2023,parenth_2010)
    ) 
# View(df_summ)

### 
html_tables <- lapply(c("diff_2004_2023","diff_2010_2023"), function(diff_var) {
  make_table(
    data = df_summ %>%
      filter(!grepl("LAT_AM|World|S_EUR|W_EUR|G7|DE|AT", name)) %>%
      select(matches("country|name|diff")),
    diff_var = diff_var,
    name_labels=c(
  "rel_val" = "relative to initial value (%)",
  "value" = "absolute value (PPS)",
  "% of EU8" = "% of EU8",
  "% of DE" = "% of DE",
  "% of S_EUR4" = "% of S_EUR4"
   )
  )
})

writeLines(html_tables[[1]], 
  "../../_includes/images/hu-cee-convergence/output/productivity/per_hr_work/table_2004_2023.html")
writeLines(html_tables[[2]], 
  "../../_includes/images/hu-cee-convergence/output/productivity/per_hr_work/table_2010_2023.html")

} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# EMPLOYMENT RATIO

with(list(all_vars=c("rel_val",grep("value|DE|EU8|S_EUR4",
            colnames(l_empl_rate$sel_cntrs),
            value=T)),
  start_yr_vals=c(2004,2010),
  folder_name="output/employment/",
  l_table_save=list(),
  show_plot=F,
          save_plot_flag=F,
          save_table=T), {
  
for (sel_var in all_vars) {
for (start_yr in start_yr_vals) {

  y_txt <- if (grepl("value",sel_var)) {
  "Employment-to-population ratio (% of 15+ population, ILO estimates)" 
    } else {
  paste0("Employment-to-population ratio (15+ population, ILO estimates), ", sel_var,"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- paste0("Employment-to-population ratio (15+ popul, ILO estimates)",
    "\nrelative to first year (=100)")
    }
  
df_plot  <- l_empl_rate$sel_cntrs %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        round(diff_end_start,1)),
    ifelse(sel_var=="value","","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# TO SAVE
l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }

# caption text
    caption_src <- paste0("source: ",
              "https://ourworldindata.org/grapher/employment-to-population-ratio")
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    # grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", "),
    # grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2020,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
# horiz lines
hline_vals <- if (sel_var == "value") {
  seq(10,floor(max_val/10)*10,10)
  } else {
  (1:ceiling(max_val/10))*10
}

# y axis breaks
y_breaks <- if (sel_var == "value") {
     seq(0,ceiling(max_val/10)*10,10)
} else {
    (0:ceiling(max_val/10))*10 }
if (sel_var == "rel_val") {
  y_breaks <- seq(20,ceiling(max_val/10)*10,10)
  hline_vals <- seq(100,ceiling(max_val/10)*10,10)
}

# y axis min
y_min_val <- ifelse(sel_var=="rel_val",90,0)
y_min_val <- ifelse(sel_var=="value",40,y_min_val)
y_min_val <- ifelse(grepl("% of",sel_var),70,y_min_val)

# summary table
df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel_val",sel_var),
                    round(value),signif(value,2)), 
                ifelse(sel_var=="value","","%")), 
            paste0(signif(value,2),
                ifelse(sel_var=="value","","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,3.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(expand=expansion(mult=c(0.07,0.075)),
    breaks=seq(start_yr,2024,4)) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(y_min_val,NA),breaks=y_breaks) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
folder_name <- "output/employment/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
}

# SAVE TABLE
if (save_table) {
        # FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) )
    write_csv(df_save_full, 
      file=paste0(folder_name,"data_table.csv"))

    # magyar változat
facet_labels_hu <- c(
  "value-2004"= "15+ lakosság százaléka",
  "% of EU8-2004" = "EU8 átlag %-a",
  "rel_val-2004" = "2004-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
    filter(grepl("rel_val|2004",facet_id)) %>%
    filter(!grepl("of DE|of AT|S_EUR",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))

    
# # SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"data_table_wide.csv"))
# 
# # SAVE selected variable
# df_save_full %>%
#       filter(facet_id %in% "value-2004") %>%
#       mutate(country_val_str=fct_reorder(
#           country_val_str,diff_end_start,.desc=T) ) %>%
#       arrange(country_val_str,year) %>%
#       select(country_val_str,country,facet_id,var,year,value) %>%
#     write_csv(file = paste0(folder_name,"df_sel_var.csv"))
#     # df_save_full %>%
#     #   filter(facet_id %in% "value-2004") %>%
#     # write_csv(file = paste0(folder_name,"df_sel_var.csv"))
}

}
} # end of for loop
            
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# HTML table

with(l_empl_rate, {
df_summ <- sel_cntrs %>%
  filter(country %in% l_groups$list_cntrs$CEE) %>%
  select(!c(region,Code)) %>%
  mutate(value=value) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(country,year,pop)) %>%
  filter(year %in% c(2004,2010,2019,max(year)) & 
      !grepl("S_EUR| AT|W_EUR3|LAT|G7",name)) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2004_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2004`-1)*100,`2024`-`2004`),
         diff_2010_2024=ifelse(grepl("rel_val",name),
                (`2024`/`2010`-1)*100,`2024`-`2010`),
    diff_2004_2024=paste0(ifelse(diff_2004_2024>0,"+",""),
            ifelse(grepl("%",name),
              paste0(signif(diff_2004_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2004_2024,1),"%"),
                      paste0(round(diff_2004_2024),"%")) ) ),
    diff_2010_2024=paste0(ifelse(diff_2010_2024>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2024,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2024,1),"%"),
                      paste0(round(diff_2010_2024),"%")) ) ),
    start_2004=ifelse(grepl("%",name),signif(`2004`,2),
                    ifelse(grepl("value",name),round(`2004`,1),
                      round(`2004`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2024`,2),
                    ifelse(grepl("value",name),round(`2024`,1),
                      round(`2024`)) ),
    parenth_2004=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2004),")"),
      "",
      paste0(" (",start_2004,"→",end_val,")" ) ),
    diff_2004_2024=paste0(diff_2004_2024,parenth_2004),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2024=paste0(diff_2010_2024,parenth_2010)
    ) 
# View(df_summ)

### 
html_tables <- lapply(c("diff_2004_2024","diff_2010_2024"), function(diff_var) {
  make_table(
    data = df_summ %>%
      filter(!grepl("LAT_AM|World|S_EUR|W_EUR|G7|DE|AT", name)) %>%
      select(matches("country|name|diff")),
    diff_var = diff_var,
    order_col = "absolute value (% of 15+ popul.)",
    name_labels=c("rel_val" = "relative to initial value (%)",
          "value" = "absolute value (% of 15+ popul.)",
          "% of EU8" = "% of EU8",
          "% of DE" = "% of DE",
          "% of S_EUR4" = "% of S_EUR4"),
    reloc_flag=F
  )
})

writeLines(html_tables[[1]],
  "../../_includes/images/hu-cee-convergence/output/employment/table_2004_2024.html")
writeLines(html_tables[[2]],
  "../../_includes/images/hu-cee-convergence/output/employment/table_2010_2024.html")

} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# life expectancy

with(list(all_vars=c("rel_val",grep("value|DE|EU8|S_EUR4",
            colnames(l_life_exp$sel_cntrs),
            value=T)),
  start_yr_vals=c(2004,2010),
  folder_name="output/life_exp/",
  l_table_save=list(),
  show_plot=F,
          save_plot_flag=T,
          save_table=T), {
  
for (sel_var in all_vars) {
for (start_yr in start_yr_vals) {

  y_txt <- if (grepl("value",sel_var)) {
  "Period life expectancy (years)" 
    } else {
  paste0(
    "Period life expectancy ",
    sel_var,"*")
    }
  if (sel_var=="rel_val") {
    y_txt <- paste0("Period life expectancy",
    "\nrelative to first year (=100%)")
    }
  
df_plot  <- l_life_exp$sel_cntrs %>%
    filter(country %in% l_groups$list_cntrs$CEE 
      & year>=start_yr) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)]) %>%
  select(country,year,value,!!sym(sel_var),pop) %>%
  mutate(start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(country_val_str=paste0(country," (", 
    ifelse(diff_end_start>0,"+",""),
    ifelse(grepl("rel",sel_var),
        round(diff_end_start),
        round(diff_end_start,1)),
    ifelse(sel_var=="value","","%"),
    ")" ) ) %>%
  ungroup() %>%
  mutate(country_val_str=fct_reorder(
          country_val_str,diff_end_start,.desc=T) )
# TO SAVE
l_table_save[[sel_var]][[as.character(start_yr)]] <- df_plot %>% 
  mutate(facet_id=paste0(sel_var,"-",start_yr)) 
  if (sel_var!="value") {
    l_table_save[[sel_var]][[as.character(start_yr)]] <-
      l_table_save[[sel_var]][[as.character(start_yr)]] %>%
      select(!value) %>%
      rename(value=!!sym(sel_var))    
  }


# caption text
    caption_src <- paste0("source: ",
              "https://ourworldindata.org/grapher/life-expectancy")
    
    caption_txt <- if (!grepl("World|usd|value|rel_val",sel_var)) {
    paste0(
      ifelse(grepl("DE|AT",sel_var),"*","*weighted average of "), 
        str_wrap(case_when(
    # grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("EU8",sel_var) ~ paste0(l_groups$comp_groups$EU8,collapse=", "),
    # grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%|rel_val",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2020,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
# horiz lines
hline_vals <- if (sel_var == "value") {
  seq(10,floor(max_val/5)*5,5)
  } else {
  (1:ceiling(max_val/5))*5
}

# y axis breaks
y_breaks <- if (sel_var == "value") {
     seq(0,ceiling(max_val/5)*5,5)
} else {
    (0:ceiling(max_val/5))*5 }
if (sel_var == "rel_val") {
  y_breaks <- seq(20,ceiling(max_val/5)*5,5)
  hline_vals <- seq(50,ceiling(max_val/5)*5,5)
}

# y axis min
y_min_val <- ifelse(sel_var=="rel_val",90,0)
y_min_val <- ifelse(sel_var=="value",65,y_min_val)
y_min_val <- ifelse(grepl("% of",sel_var),85,y_min_val)

# summary table
df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) ) %>%
  distinct() %>%
  ungroup() %>%
  rowwise() %>%
  mutate(str_yr=ifelse(year_fact==2,
          paste0(
            ifelse(grepl("rel_val",sel_var),
                    round(value),round(value,1)), 
                ifelse(sel_var=="value","","%")), 
            paste0(ifelse(grepl("rel_val",sel_var),
                    round(value),round(value,1)),
                ifelse(sel_var=="value","","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

if (show_plot) {
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  # facet_wrap(~country_val_str) +
  facet_wrap2(~country_val_str,
  strip=strip_themed(text_x=elem_list_text(colour=ifelse(
    grepl("Hungary",levels(df_plot$country_val_str)),"red3","black"),
    face=ifelse(grepl("Hungary",levels(df_plot$country_val_str))
      ,"bold","plain")))) +
  geom_point(shape=21) + geom_line() +
  geom_point(data = df_labels,color="red") +
  geom_text(data=df_labels,
    aes(label=paste0(round(get(sel_var),round_val),
        ifelse(grepl("%",sel_var),"%","") )),
        vjust=0,nudge_y=ifelse(grepl("val",sel_var),1,1.5),size=5) +
  geom_hline(yintercept=hline_vals,
              linewidth=1/4,linetype="dashed") +
  scale_x_continuous(expand=expansion(mult=c(0.07,0.075)),
    breaks=seq(start_yr,2024,4)) +
  scale_y_continuous(expand=expansion(mult=c(0.01,0.15)),
    limits=c(y_min_val,NA),breaks=y_breaks) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
folder_name <- "output/life_exp/"
file_name <- paste0(folder_name,start_yr,"/",gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}
}

# SAVE TABLE
if (save_table) {
# FULL DATA
  df_save_full <- bind_rows(
  lapply(names(l_table_save), function(var) {
    bind_rows(
      lapply(names(l_table_save[[var]]), function(yr) {
        l_table_save[[var]][[yr]] |>
          mutate(
            var = var,
            start_year = yr) })) }) )
    write_csv(df_save_full, 
      file=paste0(folder_name,"data_table.csv"))
# magyar változat
facet_labels_hu <- c(
  "value-2004"= "év",
  "% of EU8-2004" = "EU8 átlag %-a",
  "rel_val-2004" = "2004-hez (=100) képest",
  "rel_val-2010" = "2010-hez (=100) képest")
df_save_full %>%
    filter(grepl("rel_val|2004",facet_id)) %>%
    filter(!grepl("of DE|of AT|S_EUR",facet_id)) %>%
  mutate(facet_id = factor(
      facet_labels_hu[facet_id],
      levels = facet_labels_hu),
    country = countries_hu[country],
    country_val_str=str_replace_all(
      country_val_str,
      setNames(countries_hu,paste0("^", names(countries_hu))) ) ) %>%
  arrange(facet_id,desc(diff_end_start),year) %>%
  write_csv(file=paste0(folder_name,"data_table_HU.csv"))

    
    
# # SAVE in wide format
# df_save_full %>%
#   select(country,year,facet_id,value) %>% # country_val_str,
#   pivot_wider(names_from = facet_id,values_from = value) %>%
#   select(country,year,matches("rel_val|2004")) %>%
#   mutate(var_name=str_extract(folder_name, "(?<=/)[^/]+(?=/$|$)") ) %>%
#   write_csv(file = paste0(folder_name,"data_table_wide.csv"))
# 
# # SAVE selected variable
# df_save_full %>%
#       filter(facet_id %in% "value-2004") %>%
#       mutate(country_val_str=fct_reorder(
#           country_val_str,diff_end_start,.desc=T) ) %>%
#       arrange(country_val_str,year) %>%
#       select(country_val_str,country,facet_id,var,year,value) %>%
#     write_csv(file = paste0(folder_name,"df_sel_var.csv"))
}

}
} # end of for loop
            
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# HTML table

with(l_life_exp, {
  
df_summ <- sel_cntrs %>%
  filter(country %in% l_groups$list_cntrs$CEE) %>%
  select(!c(region,Code)) %>%
  mutate(value=value) %>%
  group_by(country) %>%
  mutate(rel_val=100*value/value[year==min(year)] ) %>%
  pivot_longer(!c(country,year,pop)) %>%
  filter(year %in% c(2004,2010,2019,max(year)) & 
      !grepl("S_EUR| AT|W_EUR3|LAT|G7",name)) %>%
  select(!pop) %>%
  pivot_wider(names_from = year,values_from=value) %>%
  mutate(diff_2004_2023=ifelse(grepl("rel_val",name),
                (`2023`/`2004`-1)*100,`2023`-`2004`),
         diff_2010_2023=ifelse(grepl("rel_val",name),
                (`2023`/`2010`-1)*100,`2023`-`2010`),
    diff_2004_2023=paste0(ifelse(diff_2004_2023>0,"+",""),
            ifelse(grepl("%",name),
              paste0(signif(diff_2004_2023,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2004_2023,1),"y"),
                      paste0(round(diff_2004_2023,1),"%")) ) ),
    diff_2010_2023=paste0(ifelse(diff_2010_2023>0,"+",""),
            ifelse(grepl("%",name),paste0(signif(diff_2010_2023,2),"%"),
                    ifelse(grepl("value",name),
                      paste0(round(diff_2010_2023,1),"y"),
                      paste0(round(diff_2010_2023,1),"%")) ) ),
    start_2004=ifelse(grepl("%",name),signif(`2004`,2),
                    ifelse(grepl("value",name),round(`2004`,1),
                      round(`2004`)) ),
    start_2010=ifelse(grepl("%",name),signif(`2010`,2),
                    ifelse(grepl("value",name),round(`2010`,1),
                      round(`2010`)) ),
    end_val=ifelse(grepl("%",name),signif(`2023`,2),
                    ifelse(grepl("value",name),round(`2023`,1),
                      round(`2023`)) ),
    parenth_2004=ifelse( grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2004),")"),
      "",
      paste0(" (",start_2004,"→",end_val,")" ) ),
    diff_2004_2023=paste0(diff_2004_2023,parenth_2004),
    parenth_2010=ifelse(grepl("rel_val",name),
      # paste0(" (100→",round(100*end_val/start_2010),")"),
      "",
      paste0(" (",start_2010,"→",end_val,")" ) ),
    diff_2010_2023=paste0(diff_2010_2023,parenth_2010)
    ) %>%
      filter(!grepl("LAT_AM|World|S_EUR|W_EUR|G7|DE|AT", name)) %>%
      select(matches("country|name|diff"))

# View(df_summ)

### 
html_tables <- lapply(c("diff_2004_2023","diff_2010_2023"), function(diff_var) {
  make_table(
    data = df_summ,
    diff_var = diff_var,
    reloc_flag = F,
    order_col = "absolute value (years)",
    name_labels=c(
  "rel_val" = "relative to initial value (%)",
  "value" = "absolute value (years)",
  "% of EU8" = "% of EU8",
  "% of DE" = "% of DE",
  "% of S_EUR4" = "% of S_EUR4"
   )
  )
})

writeLines(html_tables[[1]],
  "../../_includes/images/hu-cee-convergence/output/life_exp/table_2004_2023.html")
writeLines(html_tables[[2]],
  "../../_includes/images/hu-cee-convergence/output/life_exp/table_2010_2023.html")

} )


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# extract data from all HTML tables

# lapply(c("rvest","purrr", "fs"), library, character.only = TRUE)

# Main directory containing your folders
with(list(main_dir="output/"), {

# Get all subfolders
# List all HTML files in main folders and immediate subfolders
# html_files <- dir_ls("output/", recurse=T, type="file", glob="*.html")

# Extract all tables and combine into one data frame
df_all <- map_dfr(dir_ls("output/", recurse=T, type="file", glob="*.html"), 
              extract_table)

# Write to CSV
write_csv(df_all, "output/combined_HTML_tables.csv")

cat("Combined CSV written to combined_tables.csv\n")

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# create one summary table from all this

df_summ <- read_csv("output/combined_HTML_tables.csv") %>%
  pivot_longer(!c(folder,file,country),names_to = "metric") %>% # table_index,
  rename(period=file,variable=folder) %>%
  filter(!is.na(value) & grepl("EU8|absolute",metric) &
    ((variable %in% c("life_exp", "employment") & 
        str_detect(metric, "absolute")) |
    (!variable %in% c("life_exp", "employment") & 
        str_detect(metric, "% of EU8")))
  ) %>%
  mutate(period=gsub("table_|\\.html","",period),
    # Extract the "change" number before the parenthesis
    change = str_extract(value, "[+-]?\\d+\\.?\\d*") %>% as.numeric(),
    # Extract the first number inside parentheses
    start_val = str_extract(value, "(?<=\\()[^→]+") %>% as.numeric(),
    # Extract the second number inside parentheses
    final_val = str_extract(value, "(?<=→)[^\\)]+") %>% as.numeric(),
    start_yr=as.numeric(gsub("_.*","",period)),
    end_yr=as.numeric(gsub(".*_","",period))
    ) %>%
  rename(delta_start_end_string=value) 

if (!any(grepl("CEE",df_summ$country))) {
df_summ <- df_summ %>% bind_rows(
  left_join(
    df_summ,
    l_pop$pop_sel_cnts %>% 
        filter(country %in% l_groups$list_cntrs$CEE & year %in% c(2004,2010,2024)) %>%
        ungroup() %>%
        select(country,year,prop) %>%
        pivot_wider(names_from = year,values_from = prop,names_prefix = "pop_weight_")) %>%
  group_by(period,variable,metric,start_yr) %>%
  summarise(
    end_yr=unique(end_yr),
    start_val=sum(start_val*ifelse(start_yr==2004,pop_weight_2004,pop_weight_2010)),
    final_val=sum(final_val*pop_weight_2024)) %>%
  mutate(country="CEE", 
    change=final_val-start_val,
    delta_start_end_string=paste0(ifelse(change>0,"+",""),
      round(change,1), " (",
      round(start_val,1),"→",round(final_val,1),")" ) 
    ) %>%
  relocate(country,.before=period) 
  ) %>%
  arrange(variable,metric,country)
}


# filter for Hungary
l_HU_summ <- list()
for (k_ver in c("all","no_CZ_SI")) {

  if (nchar(k_ver)>3) {
    df_HU_summ <- df_summ %>%
      filter(!grepl("Czech|Sloven",country))
  } else {
    df_HU_summ <- df_summ
  }
  
l_HU_summ[[k_ver]] <- df_HU_summ %>%
  # pivot_longer(c(change,start_val,final_val)) %>%
  group_by(variable,period,start_yr) %>%
  mutate(
    rank_start = if_else( country == "CEE",NA_real_,
      min_rank(desc(if_else(country == "CEE", NA_real_, start_val))) ),
    rank_final = if_else( country == "CEE",NA_real_,
      min_rank(desc(if_else(country == "CEE", NA_real_, final_val))) ),
    rank_change = if_else( country == "CEE",NA_real_,
      min_rank(desc(if_else(country == "CEE", NA_real_, change))) ),
    n_cntr = sum(!grepl("CEE", country)),
    CEE_string=delta_start_end_string[country %in% "CEE"]
    ) %>%
  filter(country %in% "Hungary") %>%
  #####
  mutate(
    CEE_change = as.numeric(str_extract(CEE_string, "[-+]?\\d+\\.?\\d*")),
    CEE_start  = as.numeric(str_extract(CEE_string, "\\(([-+]?\\d+\\.?\\d*)", group = 1)),
    CEE_final  = as.numeric(str_extract(CEE_string, "→([-+]?\\d+\\.?\\d*)", group = 1))
  ) %>%
  group_by(variable, metric) %>%
  mutate(
    baseline_yr = min(start_yr, na.rm = TRUE),
    max_yr = max(end_yr, na.rm = T)
  ) %>%
  ungroup() %>%
  mutate(
    rank_level_start = if_else(
      start_yr == baseline_yr,
      paste0(rank_start, "/", n_cntr,
             " (HU: ", start_val, "%, CEE: ", CEE_start, "%)"),
      NA_character_    ),
    rank_level_2010 = if_else(
      start_yr == 2010,
      paste0(rank_start, "/", n_cntr,
             " (HU: ", start_val, "%, CEE: ", CEE_start, "%)"),
      NA_character_    ),
    rank_level_end = paste0(
      rank_final, "/", n_cntr,
      " (HU: ", final_val, "%, CEE: ", CEE_final, "%)"
    ) ,
    rank_change_from_start = if_else(
      start_yr == baseline_yr,
      paste0(rank_change, "/", n_cntr,
             " (HU: ", change, "%, CEE: ", CEE_change, "%)"),
      NA_character_    ),
    rank_change_from_2010 = if_else(
      start_yr == 2010,
      paste0(rank_change, "/", n_cntr,
             " (HU: ", change, "%, CEE: ", CEE_change, "%)"),
      NA_character_    )
    ) %>%
  select(country,variable,metric,start_yr,end_yr,n_cntr,
    matches("rank_lev|rank_change_from")) %>% 
  pivot_longer(!c(country,variable,metric,start_yr,end_yr,n_cntr)) %>%
  filter(!is.na(value)) %>% 
  distinct() %>%
  mutate(column_name=case_when(
    grepl("level_start",name) ~ "Rank by level at start",
    grepl("level_2010",name)~ "Rank by level in 2010",
    grepl("level_end",name) ~ "Rank by level in last year",
    grepl("change_from_2010",name) ~ 
      "Rank by cumulative change since 2010",
    grepl("change_from_start",name) ~ 
      "Rank by cumulative change since start"
    ),
    period=paste0(start_yr,"-",end_yr),
    start_yr=ifelse(grepl("level",name),NA,start_yr),
    period=ifelse(grepl("level",name),NA,period)
    ) %>%
  distinct() %>% 
  group_by(variable,column_name) %>%
  filter(n_cntr==max(n_cntr)) %>%
  ungroup() %>%
  mutate(value=case_when(
    grepl("level_start",name) & start_yr>2004 ~ paste0(value," [",start_yr,"]"),
    grepl("level_end",name) & end_yr<2024 ~ paste0(value," [",end_yr,"]"),
    grepl("rank_change_from_st",name) & (start_yr>2004 | end_yr<2024) ~ 
      paste0(value," [",period,"]"),
    grepl("rank_change_from_2010",name) & end_yr<2024 ~ paste0(value," [",period,"]"),
    .default = value) ,
    value=ifelse(grepl("life",variable),gsub("%","y",value),value))
# SAVE as csv
write_csv(x = l_HU_summ[[k_ver]],
  file = paste0("output/df_HU_summ_table_",k_ver,".csv"))
rm(k_ver)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# save as HTML

with(list(), {
  
for (k_metric in 2:3) {
  for (k_name in names(l_HU_summ)) {
  
  var_labels <- c(
GDP_per_cap= "<b>GDP per capita</b> <br> (% of EU8)",
GNI_per_cap=paste0("<b>GNI per capita</b> <br> (% of EU8)  ",
  "<span style='font-size:0.75em'>[2004-2023]</span>"),
per_hr_work =
  "<b>GDP per hour worked</b> <br> (% of EU8) <span style='font-size:0.75em'>[2004-2023]</span>",
annual_aver_wage = "<b>Average annual wage</b> <br> (% of EU8)",
real_median_hourly=
 "<b>Median hourly earnings</b> <br> (% of EU8) <span style='font-size:0.75em'>[2006-2022]</span>",
min_wage=
  "<b>Statutory minimum wage</b> <br> (% of EU8) <span style='font-size:0.75em'>[2007-2024]</span>",
median_equiv_net_income="<b>Median equivalised<br>net household income</b> <br> (% of EU8)",
actual_indiv_consump="<b>Actual individual consumption</b> <br> (% of EU8)",
employment="<b>Employment-to-<br>population ratio</b> <br> (% of 15+ population)",
life_exp="<b>Life expectancy</b><br>at birth (years) <span style='font-size:0.75em'>[2004-2023]</span>"
    )
    
  df_temp <- l_HU_summ[[k_name]] %>%
          select(!c(name,start_yr,end_yr,period,n_cntr)) %>%
          pivot_wider(names_from=column_name,values_from=value)
  # View(df_temp)
  # View(df_temp[c(1,2,8,3,9,7,6,4,5),c(1:4,7,5,6,8)])
  
    df_hu <- df_temp[c(1,2,8,3,9,10,7,6,4,5),c(1:4,7,5,6,8)] |> 
          mutate(variable = var_labels[variable],
            variable=factor(variable,levels=var_labels)) %>%
          select(!c(country,metric)) %>%
      arrange(variable)
    # View(df_hu)
    
    # rank
  if (k_metric == 2) {
  df_hu <- df_hu %>%
    mutate(across(
        contains("rank", ignore.case = TRUE),
        ~ str_remove(.x, "\\([^)]*\\)") ) ) %>%
    mutate(across(
        contains("rank", ignore.case = TRUE),
        ~ str_remove_all(.x, "\\[.*?\\]") ) )
}
    # value
    if (k_metric==3) {
  df_hu <- df_hu %>%
    mutate(
      across(
        contains("rank", ignore.case=T),
        ~ str_replace(.x, "^.*?\\(([^)]*)\\)", "\\1") ) ) %>%
  rename_with(~ str_remove(.x, "Rank by "), contains("Rank by ")) %>%
  mutate(across(
    c(contains("level", ignore.case = TRUE), contains("change", ignore.case = TRUE)),
    ~ str_replace_all(.x, ", ", "<br>") )) %>%
      mutate(
    across(
      c(contains("level", ignore.case = TRUE), contains("change", ignore.case = TRUE)),
       ~ str_remove_all(.x, "\\[.*?\\]")
    )
  )
}

    colnames(df_hu) <- str_wrap(colnames(df_hu), width=22)  # wrap after ~15 characters
    colnames(df_hu) <- str_replace_all(colnames(df_hu), "\n", "<br>")
    colnames(df_hu) <- gsub("at<br>","at ",colnames(df_hu))
    colnames(df_hu) <- gsub("last<br>","last ",colnames(df_hu))
    # View(df_hu)
    
    html_table <- df_hu %>%
  kable(format = "html", escape = FALSE) %>%
  kable_styling(
    bootstrap_options=c("striped", "condensed"),
    full_width=F) %>%
    row_spec(0,bold=T,extra_css="padding: 8px 8px;") %>%   # header row padding
  column_spec(1:ncol(df_hu), 
    extra_css="padding-left: 8px; padding-right: 8px;") # lateral padding

    # SAVE AS HTML
    writeLines(html_table, paste0(
      "../../_includes/images/hu-cee-convergence/output/df_hu_",
      c("all","rank","value")[k_metric],"_",
      k_name, ".html"))
    
  } # for end
  } # for end
  rm(k_metric,k_name)
}) # with end


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# summary table with mean/median ranks

with(list(), {

df_rank_means <- lapply(names(l_HU_summ), \(x)
(l_HU_summ[[x]] %>%
           select(!c(name,start_yr,end_yr,period,n_cntr)) %>%
           pivot_wider(names_from=column_name,values_from=value)
               )[c(1,2,8,3,9,7,6,4,5),c(1:4,7,5,6,8)] %>%
  pivot_longer(
    cols = contains("Rank"),
    names_to = "rank_column",
    values_to = "rank_raw") %>%
  mutate(
    rank_num = as.numeric(str_extract(rank_raw, "^\\d+")),
    rank_den = as.numeric(str_extract(rank_raw, "(?<=/)\\d+")),
    rank_scaled = rank_num*(ifelse(grepl("all",x),11,9) / rank_den)
  ) %>%
  group_by(rank_column) %>%
  summarise(
    `Mean rank`   = mean(rank_scaled, na.rm = TRUE),
    `Median rank` = median(rank_scaled, na.rm = TRUE),
    .groups = "drop") %>%
  mutate(
    `Mean rank`= paste0(round(`Mean rank`, 1), "/", ifelse(grepl("all",x),11,9) ),
    `Median rank` = paste0(round(`Median rank`, 1), "/", ifelse(grepl("all",x),11,9) ),
    type=gsub("no_CZ_SI","no CZ/SI",x))
) %>% bind_rows() %>%
  pivot_wider(
    id_cols = rank_column,
    names_from = type,
    values_from = c(`Mean rank`, `Median rank`),
    names_glue = "{.value} ({type})"
  ) %>%
  mutate(rank_column=gsub("start","start (2004)",rank_column),
    rank_column=gsub("last year","last year (2024)",rank_column) ) %>%
  rename(metric=rank_column) %>%
  relocate(matches("Median rank \\(al"),.after = `Mean rank (all)`) 
  
  df_rank_means <- df_rank_means[c(3:5,2,1),] 
  df_rank_means %>%
  write_csv("output/median_mean_ranking.csv")
  
  html_table <- df_rank_means  %>%
  kable(format = "html", escape = FALSE) %>%
  kable_styling(
    bootstrap_options=c("striped", "condensed"),
    full_width=F) %>%
    row_spec(0,bold=T,extra_css="padding: 8px 8px;") %>%   # header row padding
    row_spec(row = c(3,nrow(df_rank_means)),
    background = "#FADBD8") %>%
  column_spec(1:ncol(df_rank_means ),
    extra_css="padding-left: 8px; padding-right: 8px;") # lateral padding
    # SAVE AS HTML
    writeLines(html_table, paste0(
      "../../_includes/images/hu-cee-convergence/output/rank_mean_median.html"))
  
})
