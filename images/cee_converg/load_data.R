### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# LOAD DATA 

# population
# for 2024 downloaded from https://data.worldbank.org/indicator/SP.POP.TOTL

l_pop <- list()
l_pop$total_pop <- with(list(cntr_list=read_csv("data/population/population.csv") %>%
  rename(country=Entity,year=Year,value=`Population (historical)`) %>%
  filter(year>=1800 & !is.na(Code))), {
full_join(
  read_csv(paste0("data/population/API_SP.POP.TOTL_DS2_en_csv_v2_246068/",
                  "API_SP.POP.TOTL_DS2_en_csv_v2_246068.csv"),skip=4) %>% 
    select_if(~ !all(is.na(.))) %>%
  rename(country=`Country Name`) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("Viet",country) ~ "Vietnam",
    grepl("Slovak",country) ~ "Slovakia",
    grepl("Iran",country) ~ "Iran",
      .default=country)) %>%
  select(!c(`Indicator Name`,`Indicator Code`)) %>%
  pivot_longer(!c(country,`Country Code`),names_to="year") %>%
  mutate(year=as.numeric(year)) %>%
  rename(Code=`Country Code`) %>%
  filter(!grepl("Macao|Hong",country) & year>2023), 
  #####
cntr_list ) %>% 
      distinct() %>% arrange(country,year) %>%
      filter(country %in% unique(cntr_list$country))
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# load GDP/cap data
# from https://data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD

l_GDP_percap <- list()
l_GDP_percap$gdp_per_cap_2021usdppp <- read_csv(
    paste0("data/gdp-per-capita-worldbank/API_NY.GDP.PCAP.PP.KD_DS2_en_csv_v2_130128/",
    "API_NY.GDP.PCAP.PP.KD_DS2_en_csv_v2_130128.csv"),
    skip=4) %>% 
    select_if(~ !all(is.na(.))) %>%
  rename(country=`Country Name`) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("Korea, Rep.",country) ~ "South Korea",
    grepl("Viet",country) ~ "Vietnam",
    grepl("Slovak",country) ~ "Slovakia",
    grepl("Iran",country) ~ "Iran",
    grepl("Turk",country) ~ "Turkey",
      .default=country)) %>%
  select(!c(`Country Code`,`Indicator Name`,`Indicator Code`)) %>%
  pivot_longer(!country,names_to="year") %>%
  mutate(year=as.numeric(year)) %>%
  filter(!grepl("Macao|Hong",country))


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# IDENTIFY what countries we want to analyse!!

l_groups <- list()

l_groups$list_cntrs$CEE=c("Hungary","Poland","Czechia","Slovakia","Slovenia",
                "Estonia","Latvia","Lithuania","Croatia","Romania","Bulgaria")

# We compare to countries that had a gdp/cap in EITHER 1990 or 2024
# in the range of 2x smaller or larger than CEE (weighted) average
# AND a population of at least 2 million (to remove mini-states)
# add 3 more African countries, that are almost within this limit and 
# highest GDP/cap in Africa, to have 5 (and not 2) African comparator countries
l_groups$flat_cntr_list <- unlist(array(
  local({
  year_val <- c(range(l_GDP_percap$gdp_per_cap_2021usdppp$year),2023)
  
  # these are the core cntrs we are comparing to, so don't include in our to-be-compared group
  # we also remove Iraq and Libya bc of wars
  core_cntrs_filter <- paste0(c(
                "Austr|Canada|Denmark|Finland|Germ|France|Belgium|United",
                "Ireland|Japan|New Z|Sweden|Netherlands|Switzerland",
                "Kuwait|Oman|Saudi",
                "Iraq|Libya"    ),collapse="|")
  
df <- with(list(scale_fact=2,
  cee_mean_end=left_join(
    l_GDP_percap$gdp_per_cap_2021usdppp,
    l_pop$total_pop %>% rename(pop=value) ) %>%
    filter(country %in% l_groups$list_cntrs$CEE & year %in% year_val ) %>%
    group_by(year) %>%
    summarise(w_mean_val=sum((pop/sum(pop))*value)) 
  ), {

left_join(
  left_join(l_GDP_percap$gdp_per_cap_2021usdppp %>%
            filter(!country %in% l_groups$list_cntrs$CEE),
            l_pop$total_pop %>% rename(pop=value)), 
    cee_mean_end) %>%
  filter( ((!country %in% "World") & 
          year %in% year_val &
          value>=w_mean_val/scale_fact & 
          value<=w_mean_val*scale_fact & 
      pop>=2e6) |
        grepl("Egypt|Tunis|Moroc",country)
    ) %>%
      arrange(country)
    })

# View(df %>% filter(!grepl(core_cntrs_filter,country) ))
  df %>% 
  filter(!grepl(core_cntrs_filter,country) ) %>%
  select(country) %>% distinct()
  }) 
))

if (length(l_groups$list_cntrs)==1 & names(l_groups$list_cntrs)=="CEE") {
l_groups$list_cntrs <- c(l_groups$list_cntrs,
  list("Southern Europe"=grep(paste0(c("Italy","Spain","Portugal","Greece"),collapse="|"),
                      l_groups$flat_cntr_list,value=T),
       "ex-USSR/Balkans"=grep(paste0(
          c("Azerbaijan","Belarus","Georgia","Kazakhstan",
            "Moldova","Russia","Ukraine",
            "Serbia","North Macedonia"),collapse="|"),
                      l_groups$flat_cntr_list,value=T),
       "Latin America"=grep(paste0(
          c("Argentina", "Brazil", "Chile", "Colombia", 
            "Costa Rica", "Dominican Republic", "Ecuador", 
            "Jamaica", "Mexico", "Panama", "Paraguay", "Uruguay"),collapse="|"),
          l_groups$flat_cntr_list,value=T),
       "Africa"=grep(paste0(
                c("Algeria","Egypt","Libya","Morocco","Tunisia", "South Africa"),
                  collapse="|"),
                l_groups$flat_cntr_list,value=T),
       "Asia"=grep(paste0(c("China","Iran","Iraq","Israel","Malaysia","South Korea","Thailand"),
          collapse="|"),l_groups$flat_cntr_list,value=T) )
  )
} else {
  message("check list!")
}

# colors
l_groups$color_vals <- c(
      "CEE"="steelblue",
      "ex-USSR/Balkans"="red",
      "Southern Europe"="darkorange",
      "Latin America"="darkgreen",
      "Asia"="black",
      "Africa"="darkgrey")

# create some composite measures for comparisons,
# eg. DE+UK+FR, DE+UK+FR+IT+ES, IT+ES+GR+PT, Latin-Am
l_groups$comp_groups <- list(
    "W_EUR3"=c("Germany","France","Italy"),
    "LAT_AM"=l_groups$list_cntrs$`Latin America`,
    "G7"=c("United States","Canada","United Kingdom",
           "Germany", "France", "Italy", "Japan"),
    "S_EUR4"=c("Italy", "Spain", "Greece", "Portugal")  ) 


# sel countries for popul  
l_pop$pop_sel_cnts <- left_join(
  l_pop$total_pop %>% 
        filter(country %in% unlist(l_groups$list_cntrs)),
  lapply(names(l_groups$list_cntrs), \(x) 
    data.frame(country=l_groups$list_cntrs[[x]],region=x) ) %>% 
    bind_rows() ) %>% 
  group_by(region,year) %>%
  mutate(prop=value/sum(value))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# selected countries for GDP/cap (World Bank, from 1990)

l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr <- with(
  list(df_region=lapply(names(l_groups$list_cntrs), \(x) 
    data.frame(region=x,country=l_groups$list_cntrs[[x]]) ) %>% 
    bind_rows(),
    sel_comps=c("Germany",names(l_groups$comp_groups), "World")), {
      
bind_rows(
# countries
left_join(
    l_GDP_percap$gdp_per_cap_2021usdppp,
    l_pop$total_pop %>% select(!Code) %>% rename(pop=value)),
  # calc averages of groupings
lapply(names(l_groups$comp_groups), \(x)
 left_join(
  l_GDP_percap$gdp_per_cap_2021usdppp,
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)) %>%
  filter(country %in% l_groups$comp_groups[[x]]) %>%
  group_by(year) %>% 
  mutate(prop_pop=pop/sum(pop)) %>%
  summarise(country=x,value=sum(value*prop_pop),pop=sum(pop)) ) %>%
  bind_rows()
  ) %>%
  # filter for cntrs analysed + cntrs standards of comparison
  filter(country %in% c(sel_comps, as.character(unlist(l_groups$list_cntrs))) )  %>%
  mutate(year=as.numeric(year)) %>%
  group_by(year) %>%
  mutate(`% of DE` = 100*value/value[country %in% "Germany"],
    `% of W_EUR3` = 100*value/value[country %in% "W_EUR3"],
    `% of S_EUR4` = 100*value/value[country %in% "S_EUR4"],
    `% of G7` = 100*value/value[country %in% "G7"],
    `% of World` = 100*value/value[country %in% "World"],
    `% of LAT_AM` = 100*value/value[country %in% "LAT_AM"]  ) %>% 
  ungroup() %>%
  # join region names
  left_join(df_region) 
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GNI per capita (PPP) from 1990
# from https://ourworldindata.org/grapher/gross-national-income-per-capita-undp
# 2021 internat usd (ppp+inflation-adjusted)

l_gni_percap <- list()
l_gni_percap$GNI_per_cap_2021intUSD <- read_csv(
"data/gross-national-income-per-capita-undp/gross-national-income-per-capita-undp.csv") %>%
rename(country=Entity,year=Year,
       value=`Gross national income per capita`  ) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("Viet",country) ~ "Vietnam",
    .default = country)) %>%
  filter(!grepl("Macao|Hong",country)) %>%
  select(c(country,value,year)) 
# source: OurWorldinData

l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr <- with(
  list(df_region=lapply(names(l_groups$list_cntrs), \(x) 
    data.frame(region=x,country=l_groups$list_cntrs[[x]]) ) %>% 
    bind_rows(),
    sel_comps=c("Germany",names(l_groups$comp_groups),"World") ), {
      
bind_rows(
# countries
left_join(
    l_gni_percap$GNI_per_cap_2021intUSD,
    l_pop$total_pop %>% select(!Code) %>% rename(pop=value)),
  # calc averages of groupings
lapply(names(l_groups$comp_groups), \(x)
 left_join(
  l_gni_percap$GNI_per_cap_2021intUSD,
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)) %>%
  filter(country %in% l_groups$comp_groups[[x]]) %>%
  group_by(year) %>% 
  mutate(prop_pop=pop/sum(pop)) %>%
  summarise(country=x,value=sum(value*prop_pop),pop=sum(pop)) ) %>%
  bind_rows()
  ) %>%
  # filter for cntrs analysed + cntrs standards of comparison
  filter(country %in% c(sel_comps, as.character(unlist(l_groups$list_cntrs))) )  %>%
  mutate(year=as.numeric(year)) %>%
  group_by(year) %>%
  mutate(`% of DE` = 100*value/value[country %in% "Germany"],
    `% of W_EUR3` = 100*value/value[country %in% "W_EUR3"],
    `% of S_EUR4` = 100*value/value[country %in% "S_EUR4"],
    `% of G7` = 100*value/value[country %in% "G7"],
    `% of World` = 100*value/value[country %in% "World"],
    # `% of High income` = 100*value/value[country %in% "High income"],
    `% of LAT_AM` = 100*value/value[country %in% "LAT_AM"]  ) %>% 
  ungroup() %>%
  # join region names
  left_join(df_region) %>%
  relocate(region,.before=country)
})


### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### 
# LONG-TERM GDP/cap Maddison database (2011 int USD)

l_GDP_percap$gdp_per_cap_longterm_2011usd <- read_csv(
  paste0("data/gdp-per-capita-maddison-project-database/",
  "gdp-per-capita-maddison-project-database.csv")) %>%
  select(!c(`900793-annotations`)) %>%
  rename(country=Entity,year=Year,value=`GDP per capita`) %>%
  filter(year>=1900)

if (!any(grepl("W_EUR",l_GDP_percap$gdp_per_cap_longterm_2011usd$country))) {
l_GDP_percap$gdp_per_cap_longterm_2011usd <- bind_rows(
# countries
  left_join(
  l_GDP_percap$gdp_per_cap_longterm_2011usd,
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)),
  # calc averages of groupings
lapply(names(l_groups$comp_groups), \(x)
 left_join(
  l_GDP_percap$gdp_per_cap_longterm_2011usd,
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)) %>%
  filter(country %in% l_groups$comp_groups[[x]]) %>%
  group_by(year) %>% 
  mutate(prop_pop=pop/sum(pop)) %>%
  summarise(country=x,value=sum(value*prop_pop),pop=sum(pop)) ) %>%
  bind_rows() )

}

# for czechia and slovakia no separate data before 1970 and 1985 (resp'ly)
# but there is for Czechoslovakia.
# i took ratios of SK to CZSK and CZ to CZSK in the 1st year where both are presents
# and scale the CZSK time series with these, to get an estimate for pre-1970/1985
df_cz_sk <- l_GDP_percap$gdp_per_cap_longterm_2011usd %>% 
            filter(grepl("Czech|Slovak",country) & year>=1950)
  
df_ratio <- df_cz_sk %>%
    mutate(n_cntr=n()) %>%
    filter(n_cntr>1) %>%
    select(!c(Code,pop,n_cntr)) %>%
    pivot_wider(names_from=country,values_from=value) %>%
    # group_by(year) %>%
    mutate(ratio_cz_to_czsk=Czechia/Czechoslovakia,
           ratio_sk_to_czsk=Slovakia/Czechoslovakia) %>%
    pivot_longer(!c(year)) %>%
    filter(!is.na(value)) %>%
    group_by(name) %>%
    filter(year == min(year) & grepl("ratio",name)) %>% 
    ungroup() %>%
    mutate(country=ifelse(grepl("cz_to",name),"Czechia","Slovakia")) %>%
    rename(ratio=value,start_yr=year)
    
df_cz_sk <- df_cz_sk %>%
    complete(year,country,fill=list(value=NA)) %>%
    arrange(country) %>% 
    filter(is.na(value)) %>%
    select(!c(value,Code,pop)) %>%
    left_join(df_cz_sk %>% filter(grepl("Czecho",country)) %>%
              select(year,value) %>%
              rename(value_CZSK=value)  ) %>%
    left_join(df_ratio %>% select(!name)) %>%
    arrange(year,country) %>%
    mutate(value=value_CZSK*ratio) %>%
    left_join(df_cz_sk %>% select(country,Code) %>% distinct()) %>%
    left_join(l_pop$total_pop %>% rename(pop=value)) %>%
    select(country,Code,year,value,pop) %>%
    mutate(synth=T)


# selected countries, averages by cntr groupings 
l_GDP_percap$gdp_per_cap_longterm_2011usd_sel_cntr <- 
  l_GDP_percap$gdp_per_cap_longterm_2011usd %>%
  bind_rows(df_cz_sk) %>%
  filter(grepl( paste0(c(names(l_groups$comp_groups),
    "Germany","United States","World",
    unlist(l_groups$list_cntrs)), collapse="|"), country) & 
      year>=1900 ) %>%
  mutate(region=case_when(
            grepl(paste0(l_groups$list_cntrs$Africa, collapse="|"),country) ~ "Africa",
            grepl(paste0(l_groups$list_cntrs$`Latin America`,
              collapse="|"),country) ~ "Latin America",
            grepl(paste0(l_groups$list_cntrs$`Southern Europe`,collapse="|"),
              country) ~ "Southern Europe",
            grepl(paste0(l_groups$list_cntrs$`ex-USSR/Balkans`,
              collapse="|"),country) ~ "ex-USSR/Balkans",
            grepl(paste0(l_groups$list_cntrs$Asia,collapse="|"), country) ~ "Asia",
            .default="CEE")) %>%
  group_by(year) %>%
  mutate(
    # `% of US` = value*100/value[country %in% "United States"],
    `% of DE` = value*100/value[country %in% "Germany"],
    `% of W_EUR3` = value*100/value[country %in% "W_EUR3"],
    `% of S_EUR4` = value*100/value[country %in% "S_EUR4"],
    `% of G7` = value*100/value[country %in% "G7"],
    `% of LAT_AM` = value*100/value[country %in% "LAT_AM"],
    `% of World` = {ref <- value[match("World", country)]
      if (is.na(ref)) NA_real_ else value * 100 / ref }
    ) %>%
  rename(intusd2011ppp=value) %>%
  relocate(synth,.after=last_col())

rm(df_cz_sk,df_ratio)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# labour productivity (output per hour of work)

# 2 productivity data sources: OECD, OWID
# per-hour-of-work: OWID always has more data
# per-person-employed: before 1990 OECD has data for western cnts, 
# after 1990, same data availability

l_product <- list()
l_product$oecd$all <- read_csv(paste0(
  "data/productivity/OECD.SDD.TPS,DSD_PDB@DF_PDB_LV,1.0+.A.HRSAV+GDPEMP+GDPHRS..",
  "USD_PPP_H+USD_PPP_PS.Q....csv")) %>%
  select(TIME_PERIOD,`Reference area`,REF_AREA,
    OBS_VALUE,Measure,`Price base`,UNIT_MEASURE) %>%
  arrange(Measure,`Reference area`,TIME_PERIOD) %>%
  rename(country=`Reference area`,year=TIME_PERIOD,value=OBS_VALUE) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("China",country) ~ "China",
    grepl("Korea",country) ~ "South Korea",
    grepl("Viet",country) ~ "Vietnam",
    grepl("Slovak",country) ~ "Slovakia",
    grepl("Iran",country) ~ "Iran",
    grepl("Turkey|Türkiye",country) ~ "Turkey",
      .default=country))

# ourworldindata (int USD 2021, PPP)
l_product$owid$all <- bind_rows(
read_csv(paste0(
  "data/productivity/labor-productivity-per-hour-pennworldtable/",
  "labor-productivity-per-hour-pennworldtable.csv")) %>%
  rename(year=Year,country=Entity,
         value=`Productivity: output per hour worked`) %>%
  mutate(measure="output per hour worked",
        unit="const intUSD 2021 PPP"), 
read_csv(paste0(
  "data/productivity/gdp-per-person-employed-constant-ppp/",
  "gdp-per-person-employed-constant-ppp.csv") ) %>%
    rename(year=Year,country=Entity,
      value=`GDP per person employed (constant 2021 PPP $)`) %>%
    mutate(measure="output per employed person",
          unit="const intUSD 2021 PPP")
)

# generate for selected countries, normalise by benchmark groups
if (any(!grepl("per person|per hour",names(l_product$owid)))) {
l_product$owid <- c(l_product, setNames(
  nm=c("per person","per hour of work"),
  object=with(
  list(df_region=lapply(names(l_groups$list_cntrs), \(x) 
    data.frame(region=x,country=l_groups$list_cntrs[[x]]) ) %>% 
    bind_rows(),
    sel_comps=c("Germany",names(l_groups$comp_groups)) ), {
      
      lapply(c("person","hour"), \(sel_var) {
bind_rows(
# countries
left_join(
    l_product$owid$all %>% filter(grepl(sel_var,measure)),
    l_pop$total_pop %>% select(!Code) %>% rename(pop=value)),
  # calc averages of groupings
lapply(names(l_groups$comp_groups), \(x)
 left_join(
  l_product$owid$all %>% filter(grepl(sel_var,measure)),
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)) %>%
  filter(country %in% l_groups$comp_groups[[x]]) %>%
  group_by(year) %>% 
  mutate(prop_pop=pop/sum(pop)) %>%
  summarise(country=x,
            value=sum(value*prop_pop),
            pop=sum(pop)) ) %>%
  bind_rows()
  ) %>%
  # filter for cntrs analysed + cntrs standards of comparison
  filter(country %in% c(sel_comps, as.character(unlist(l_groups$list_cntrs))) )  %>%
  mutate(year=as.numeric(year)) %>%
  group_by(year) %>%
  mutate(`% of DE` = 100*value/value[country %in% "Germany"],
    `% of W_EUR3` = 100*value/value[country %in% "W_EUR3"],
    `% of S_EUR4` = 100*value/value[country %in% "S_EUR4"],
    `% of G7` = 100*value/value[country %in% "G7"],
    # `% of World` = 100*value/value[country %in% "World"],
    `% of LAT_AM` = 100*value/value[country %in% "LAT_AM"]  ) %>% 
  ungroup() %>%
  # join region names
  left_join(df_region) %>%
  relocate(region,.before=country) %>%
  mutate(`data source`="owid")        
        }
) # lapply of variable (per-hr/per-person) end
    })
  ) # end of setNames
  )
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# wages/earnings

l_wages <- list()

# ILO
# average hourly earnings: very sparse data, only after 1990, but mostly after 2015/2018
# l_wages$ILO$hourly_earnings <- read_csv(
#   URLencode(paste0("https://rplumber.ilo.org/data/indicator/",
#   "?id=EAR_4HRL_SEX_CUR_NB_A&sex=SEX_T&classif1=CUR_TYPE_PPP&",
#   "timefrom=1969&timeto=2025&type=label&format=.csv"))) %>%
#   arrange( ref_area.label, time)
# monthly earnings
# l_wages$ILO$monthly_earnings <- read_csv(
#   URLencode(paste0("https://rplumber.ilo.org/data/indicator/",
#   "?id=EAR_4MTH_SEX_CUR_NB_A&sex=SEX_T&classif1=CUR_TYPE_PPP&",
#   "timefrom=1969&timeto=2025&type=label&format=.csv"))) %>%
#   arrange(ref_area.label, time)
# plot(1990:2025, (l_wages$ILO$monthly_earnings %>% 
#     group_by(time) %>% summarise(n=n()))$n,type="b")
# range(l_wages$ILO$monthly_earnings$time)

# OECD average annual wages
# download from: https://data-explorer.oecd.org/s/1p0

l_wages$oecd$all$annual_aver_wage <- paste0("data/wages/",
  "OECD.ELS.SAE,DSD_EARNINGS@AV_AN_WAGE,1.0",
  "+AUS+AUT+BEL+CAN+CHL+COL+CRI+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ISR+ITA+JPN+",
  "KOR+LVA+LTU+LUX+MEX+NLD+NZL+NOR+POL+PRT+SVK+SVN+.csv") %>% read_csv() %>%
  select(TIME_PERIOD,`Reference area`,REF_AREA,
    OBS_VALUE,Measure,`Price base`,UNIT_MEASURE) %>%
  arrange(Measure,`Reference area`,TIME_PERIOD) %>%
  rename(country=`Reference area`,year=TIME_PERIOD,value=OBS_VALUE) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("China",country) ~ "China",
    grepl("Korea",country) ~ "South Korea",
    grepl("Viet",country) ~ "Vietnam",
    grepl("Slovak",country) ~ "Slovakia",
    grepl("Iran",country) ~ "Iran",
    grepl("Turkey|Türkiye",country) ~ "Turkey",
      .default=country))

# OECD minimum wages (Real minimum wages at constant prices - HOURLY!)
# download from: https://data-explorer.oecd.org/s/28d
l_wages$oecd$all$annual_min_wage <- paste0("data/wages/",
  "OECD.ELS.SAE,DSD_EARNINGS@RMW,1.0",
  "+AUS+BEL+CAN+CHL+COL+CRI+CZE+EST+FRA+DEU+GRC+HUN+IRL+ISR+JPN+KOR+",
  "LVA+LTU+LUX+MEX+NLD+NZL+POL+PRT+SVK+SVN+ESP+TUR+GBR+USA+BRA+BGR+HRV+MLT-1.csv"
  ) %>% read_csv() %>%
  select(TIME_PERIOD,`Reference area`,REF_AREA,
    OBS_VALUE,Measure,`Price base`,UNIT_MEASURE) %>%
  arrange(Measure,`Reference area`,TIME_PERIOD) %>%
  rename(country=`Reference area`,year=TIME_PERIOD,value=OBS_VALUE) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("China",country) ~ "China",
    grepl("Korea",country) ~ "South Korea",
    grepl("Viet",country) ~ "Vietnam",
    grepl("Slovak",country) ~ "Slovakia",
    grepl("Iran",country) ~ "Iran",
    grepl("Turkey|Türkiye",country) ~ "Turkey",
      .default=country)
    )

# calculate as %s of benchmark countries/regions
l_wages$oecd$sel_cntrs <- setNames(
  nm=names(l_wages$oecd$all),
  object=with(
  list(df_region=lapply(names(l_groups$list_cntrs), \(x) 
    data.frame(region=x,country=l_groups$list_cntrs[[x]]) ) %>% 
    bind_rows(),
    sel_comps=c("Germany",names(l_groups$comp_groups)) ), {
      
      lapply(names(l_wages$oecd$all), \(sel_var) {
bind_rows(
# countries
left_join(
    l_wages$oecd$all[[sel_var]],
    l_pop$total_pop %>% select(!Code) %>% rename(pop=value)),
  # calc averages of groupings
lapply(names(l_groups$comp_groups), \(x)
 left_join(
  l_wages$oecd$all[[sel_var]],
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)) %>%
  filter(country %in% l_groups$comp_groups[[x]]) %>%
  group_by(year) %>% 
  mutate(prop_pop=pop/sum(pop)) %>%
  summarise(country=x,
            value=sum(value*prop_pop),
            pop=sum(pop)) ) %>%
  bind_rows()
  ) %>%
  # filter for cntrs analysed + cntrs standards of comparison
  filter(country %in% c(sel_comps, as.character(unlist(l_groups$list_cntrs))) )  %>%
  group_by(year) %>%
  mutate(`% of DE` = if ("Germany" %in% country) {
                        100*value/value[country=="Germany"]}
                      else {NA_real_},
    `% of W_EUR3` = 100*value/value[country %in% "W_EUR3"],
    `% of S_EUR4` = 100*value/value[country %in% "S_EUR4"],
    `% of G7` = 100*value/value[country %in% "G7"],
    `% of LAT_AM` = if ("LAT_AM" %in% country) {
                        100*value/value[country=="LAT_AM"]}
                      else {NA_real_}  ) %>% 
  ungroup() %>%
  # join region names
  left_join(df_region) %>%
  relocate(region,.before=country)
        }
) # lapply of variable (per-hr/per-person) end
    })
  ) # end of setNames


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# LIFE EXPECTANCY

l_life_exp <- list()
l_life_exp$all <- read_csv("data/life-expectancy/life-expectancy.csv") %>%
rename(country=Entity,year=Year,
       value=`Period life expectancy at birth`  ) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("Viet",country) ~ "Vietnam",
    .default = country)) %>%
  filter(!grepl("Macao|Hong",country)) 

# for the cntrs analysed and normalised to benchmarks
l_life_exp$sel_cntrs <- bind_rows(
# countries
  left_join(
  l_life_exp$all,
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)),
  # calc averages of groupings
lapply(names(l_groups$comp_groups), \(x)
 left_join(
  l_life_exp$all,
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)) %>%
  filter(country %in% l_groups$comp_groups[[x]]) %>%
  group_by(year) %>% 
  mutate(prop_pop=pop/sum(pop)) %>%
  summarise(country=x,value=sum(value*prop_pop),pop=sum(pop)) ) %>%
  bind_rows() ) %>%
  filter(grepl( paste0(c(names(l_groups$comp_groups),
    "Germany","United States","World",
    unlist(l_groups$list_cntrs)), collapse="|"), country) & 
      year>=1950 ) %>%
  mutate(region=case_when(
            grepl(paste0(l_groups$list_cntrs$Africa, collapse="|"),country) ~ "Africa",
            grepl(paste0(l_groups$list_cntrs$`Latin America`,
              collapse="|"),country) ~ "Latin America",
            grepl(paste0(l_groups$list_cntrs$`Southern Europe`,collapse="|"),
              country) ~ "Southern Europe",
            grepl(paste0(l_groups$list_cntrs$`ex-USSR/Balkans`,
              collapse="|"),country) ~ "ex-USSR/Balkans",
            grepl(paste0(l_groups$list_cntrs$Asia,collapse="|"), country) ~ "Asia",
            .default="CEE")) %>%
  group_by(year) %>%
  mutate(
    `% of DE` = value*100/value[country %in% "Germany"],
    `% of W_EUR3` = value*100/value[country %in% "W_EUR3"],
    `% of S_EUR4` = value*100/value[country %in% "S_EUR4"],
    `% of G7` = value*100/value[country %in% "G7"],
    `% of LAT_AM` = value*100/value[country %in% "LAT_AM"],
    `% of World` = {ref <- value[match("World", country)]
      if (is.na(ref)) NA_real_ else value * 100 / ref } ) %>%
  relocate(region,.after = Code) %>%
  relocate(pop,.after = last_col())

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# REAL MEDIAN HOURLY earnings

l_wages$eurostat$real_median_hr_earning$all <- read_csv(
         "data/wages/earn_ses_pub2s$defaultview_linear.csv")


l_wages$eurostat$real_median_hr_earning$sel_cntr <- with(
  list(df_sel=l_wages$eurostat$real_median_hr_earning$all %>%
  select(!c(OBS_FLAG,CONF_STATUS,DATAFLOW,`LAST UPDATE`,
            freq,sizeclas  )) %>%
  filter(sex %in% "Total" & grepl("PPS",unit)) %>%
  filter(geo %in% c("Austria",unlist(l_groups$list_cntrs),
                    array(unlist(l_groups$comp_groups))) ) %>% 
  arrange(geo, TIME_PERIOD) %>%
  rename(country=geo,year=TIME_PERIOD,value=OBS_VALUE) %>%
  left_join(l_pop$total_pop %>% rename(pop=value)) ), {
       
bind_rows(               
df_sel,
lapply( l_groups$comp_groups[c(1,4)],
  \(x) {
  df_sel %>%
  filter(country %in% x) %>%
  group_by(year) %>%
  summarise(value=sum(value*pop/sum(pop)),
          pop=sum(pop))
} ) %>% bind_rows(.id = "country")
) %>% 
  group_by(year) %>%
      mutate(`% of DE`=100*value/value[grepl("Germany",country)],
             `% of AT`=100*value/value[grepl("Austria",country)],
             `% of W_EUR3`=100*value/value[grepl("W_EUR",country)],
             `% of S_EUR4`=100*value/value[grepl("S_EUR",country)] ) %>%
      left_join(
        l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>% 
          select(country,region) %>% distinct())
} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# MEDIAN EQUIVALISED NET INCOME (Eurostat)

l_wages$eurostat$median_equiv_net_income$all <- gzcon(url(paste0(
"https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/ilc_di03/",
"1.0/*.*.*.*.*.*?c[freq]=A&c[age]=TOTAL,Y_LT6,Y6-10,Y6-11,Y11-15,Y12-17,Y_LT16,Y16-24,Y16-64,",
"Y_GE16,Y_LT18,Y18-24,Y18-64,Y_GE18,Y25-49,Y25-54,Y50-64,Y55-64,Y_LT60,Y_GE60,Y_LT65,Y65-74,Y_GE65,",
"Y_LT75,Y_GE75&c[sex]=T&c[indic_il]=MED_E&c[unit]=EUR,NAC,PPS&c[geo]=EU,EU27_2020,EU28,EU27_2007,",
"EU15,EA,EA20,EA19,EA18,BE,BG,CZ,DK,DE,EE,IE,EL,ES,FR,HR,IT,CY,LV,LT,LU,HU,MT,NL,AT,PL,PT,RO,",
"SI,SK,FI,SE,IS,NO,CH,UK,ME,MK,AL,RS,TR,XK&c[TIME_PERIOD]=",
"2024,2023,2022,2021,2020,2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,",
"2009,2008,2007,2006,2005,2004,2003,2001,2000,1999,1998,1997,1996,1995&",
"compress=true&format=csvdata&formatVersion=1.0&lang=en&labels=label_only"))) %>%
  read_csv()

l_wages$eurostat$median_equiv_net_income$sel_cntr <- with(
  list(df_sel=l_wages$eurostat$median_equiv_net_income$all %>%
  select(!c(OBS_FLAG,CONF_STATUS,
            DATAFLOW,`LAST UPDATE`,freq)) %>%
  filter(sex %in% "Total" & age %in% "Total" & grepl("PPS",unit)) %>%
  filter(geo %in% c("Austria",unlist(l_groups$list_cntrs),
                    array(unlist(l_groups$comp_groups))) ) %>% 
  arrange(geo, TIME_PERIOD) %>%
  rename(country=geo,year=TIME_PERIOD,value=OBS_VALUE) %>%
  left_join(l_pop$total_pop %>% rename(pop=value))
    ), {
### with       
bind_rows(               
df_sel,
lapply( l_groups$comp_groups[c(1,4)],
  \(x) {
  df_sel %>%
  filter(country %in% x) %>%
  group_by(year) %>%
  summarise(value=sum(value*pop/sum(pop)),
          pop=sum(pop))
} ) %>% bind_rows(.id = "country")
) %>% 
  group_by(year) %>%
      mutate(`% of DE`=100*value/value[match("Germany", country)],
             `% of AT`=100*value/value[match("Austria", country)],
             `% of W_EUR3`=100*value / value[match("W_EUR3", country)],
             `% of S_EUR4`=100 * value / value[match("S_EUR4", country)]
        ) %>%
      left_join(
        l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>% 
          select(country,region) %>% distinct())
} )