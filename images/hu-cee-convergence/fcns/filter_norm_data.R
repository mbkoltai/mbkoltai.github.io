### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# LOAD DATA 

# population
# for 2024 downloaded from https://data.worldbank.org/indicator/SP.POP.TOTL

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
    `% of EU8` = 100*value/value[country %in% "EU8"],
    `% of World` = 100*value/value[country %in% "World"],
    `% of LAT_AM` = 100*value/value[country %in% "LAT_AM"]  ) %>% 
  ungroup() %>%
  # join region names
  left_join(df_region) 
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GNI per capita (constant PPP) from 1990
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

# %>%
  # concatenate new worldbank data for 2024?
  # I didnt do this because for several cntrs 2024 data still missing
  # bind_rows(read_csv(
  #   paste0("data/gross-national-income-per-capita-undp/",
  #     "API_NY.GNP.PCAP.PP.KD_DS2_en_csv_v2_1701/",
  #     "API_NY.GNP.PCAP.PP.KD_DS2_en_csv_v2_1701.csv"),
  #   skip=4) %>% 
  #   select_if(~ !all(is.na(.))) %>%
  # rename(country=`Country Name`) %>%
  # mutate(country=case_when(
  #   grepl("Egypt",country) ~ "Egypt",
  #   grepl("Russia",country) ~ "Russia",
  #   grepl("Korea, Rep.",country) ~ "South Korea",
  #   grepl("Viet",country) ~ "Vietnam",
  #   grepl("Slovak",country) ~ "Slovakia",
  #   grepl("Iran",country) ~ "Iran",
  #   grepl("Turk",country) ~ "Turkey",
  #     .default=country)) %>%
  # select(!c(`Country Code`,`Indicator Name`,`Indicator Code`)) %>%
  # pivot_longer(!country,names_to="year") %>%
  # mutate(year=as.numeric(year)) %>%
  # filter(!grepl("Macao|Hong",country)) %>%
  # filter(year==2024) 
  #   ) %>%
  # arrange(country,year)
# source: OurWorldinData, but 2024 missing here

# SELECTED Countries
l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr <- with(
  list(df_region=lapply(names(l_groups$list_cntrs), \(x) 
    data.frame(region=x,country=l_groups$list_cntrs[[x]]) ) %>% 
    bind_rows(),
    sel_comps=c("Germany",names(l_groups$comp_groups),"World") ), {
      
df_join <- left_join(
    l_gni_percap$GNI_per_cap_2021intUSD,
    l_pop$total_pop %>% select(!Code) %>% rename(pop=value))
      
bind_rows(
# countries
df_join,
  # calc averages of groupings
lapply(names(l_groups$comp_groups), \(x)
 df_join %>%
  filter(country %in% l_groups$comp_groups[[x]]) %>%
  group_by(year) %>% 
  mutate(prop_pop=pop/sum(pop)) %>%
  summarise(country=x,
    value=sum(value*prop_pop,na.rm=T),
    pop=sum(pop,na.rm = T)) ) %>%
  bind_rows()
  ) %>%
  # filter for cntrs analysed + cntrs standards of comparison
  filter(country %in% c(sel_comps, as.character(unlist(l_groups$list_cntrs))) )  %>%
  mutate(year=as.numeric(year)) %>%
  group_by(year) %>%
  mutate(`% of DE` = 100*value/value[country %in% "Germany"],
    # `% of W_EUR3` = 100*value/value[country %in% "W_EUR3"],
    `% of G7` = 100*value/value[country %in% "G7"],
    `% of EU8` = 100*value/value[country %in% "EU8"],
    `% of S_EUR4` = 100*value/value[country %in% "S_EUR4"],
    # `% of High income` = 100*value/value[country %in% "High income"],
    `% of LAT_AM` = 100*value/value[country %in% "LAT_AM"],
    `% of World` = 100*value/value[country %in% "World"]) %>% 
  ungroup() %>%
  # join region names
  left_join(df_region) %>%
  relocate(region,.before=country)
})



### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# labour productivity (output per hour of work)

# 2 productivity data sources: OECD, OWID
# per-hour-of-work: OWID always has more data
# per-person-employed: before 1990 OECD has data for western cnts, 
# after 1990, same data availability

l_product <- list()

# l_product$oecd$all <- read_csv(paste0(
#   "data/productivity/OECD.SDD.TPS,DSD_PDB@DF_PDB_LV,1.0+.A.HRSAV+GDPEMP+GDPHRS..",
#   "USD_PPP_H+USD_PPP_PS.Q....csv")) %>%
#   select(TIME_PERIOD,`Reference area`,REF_AREA,
#     OBS_VALUE,Measure,`Price base`,UNIT_MEASURE) %>%
#   arrange(Measure,`Reference area`,TIME_PERIOD) %>%
#   rename(country=`Reference area`,year=TIME_PERIOD,value=OBS_VALUE) %>%
#   mutate(country=case_when(
#     grepl("Egypt",country) ~ "Egypt",
#     grepl("Russia",country) ~ "Russia",
#     grepl("China",country) ~ "China",
#     grepl("Korea",country) ~ "South Korea",
#     grepl("Viet",country) ~ "Vietnam",
#     grepl("Slovak",country) ~ "Slovakia",
#     grepl("Iran",country) ~ "Iran",
#     grepl("Turkey|Türkiye",country) ~ "Turkey",
#       .default=country))

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
    `% of EU8` = 100*value/value[country %in% "EU8"],
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
  mutate(
    `% of DE` = if ("Germany" %in% country) {
                        100*value/value[country=="Germany"]}
                      else {NA_real_},
    `% of W_EUR3` = 100*value/value[country %in% "W_EUR3"],
    `% of S_EUR4` = 100*value/value[country %in% "S_EUR4"],
    `% of G7` = 100*value/value[country %in% "G7"],
    `% of EU8` = 100*value/value[country %in% "EU8"], 
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
    `% of EU8` = value*100/value[country %in% "EU8"],
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
lapply( l_groups$comp_groups[c("W_EUR3","EU8","S_EUR4")],
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
              `% of EU8`=100*value/value[grepl("EU8",country)],
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
             `% of EU8`=100*value/value[match("EU8", country)],
             `% of W_EUR3`=100*value / value[match("W_EUR3", country)],
             `% of S_EUR4`=100 * value / value[match("S_EUR4", country)]
        ) %>%
      left_join(
        l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>% 
          select(country,region) %>% distinct())
} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Actual individual consumption (AIC) (Eurostat)

l_cons=list()
l_cons$all <- read_csv(
         "data/actual_indiv_consump/prc_ppp_ind_page_linear.csv")

l_cons$sel_cntr <- with(
  list(), {
    df_sel <- l_cons$all %>%
  select(!c(OBS_FLAG,CONF_STATUS,DATAFLOW,`LAST UPDATE`,
            freq  )) %>%
  # filter(sex %in% "Total" & grepl("PPS",unit)) %>%
  filter(geo %in% c("Austria",unlist(l_groups$list_cntrs),
                    array(unlist(l_groups$comp_groups))) ) %>% 
  arrange(geo, TIME_PERIOD) %>%
  rename(country=geo,year=TIME_PERIOD,value=OBS_VALUE) %>%
  left_join(l_pop$total_pop %>% rename(pop=value))
    
bind_rows(               
df_sel,
lapply( l_groups$comp_groups[c("W_EUR3","EU8","S_EUR4")],
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
             `% of EU8`=100*value/value[grepl("EU8",country)],
             `% of S_EUR4`=100*value/value[grepl("S_EUR",country)] ) %>%
      left_join(
        l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>% 
          select(country,region) %>% distinct())
} )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Employment ratio

l_empl_rate <- list()

l_empl_rate$all <- read_csv(
  "data/employment-to-population-ratio/employment-to-population-ratio.csv") %>%
rename(country=Entity,year=Year,
       value=`Employment to population ratio, 15+, total (%) (modeled ILO estimate)`  ) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("Viet",country) ~ "Vietnam",
    .default = country)) %>%
  filter(!grepl("Macao|Hong",country)) 

# for the cntrs analysed and normalised to benchmarks
l_empl_rate$sel_cntrs <- bind_rows(
# countries
  left_join(
  l_empl_rate$all,
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)),
  # calc averages of groupings
lapply(names(l_groups$comp_groups), \(x)
 left_join(
  l_empl_rate$all,
  l_pop$total_pop %>% select(!Code) %>% rename(pop=value)) %>%
  filter(country %in% l_groups$comp_groups[[x]]) %>%
  group_by(year) %>% 
  mutate(prop_pop=pop/sum(pop)) %>%
  summarise(country=x,value=sum(value*prop_pop),pop=sum(pop)) ) %>%
  bind_rows() ) %>%
  filter(grepl( paste0(c(names(l_groups$comp_groups),
    "Germany","United States", # "World",
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
    # `% of W_EUR3` = value*100/value[country %in% "W_EUR3"],
    `% of S_EUR4` = value*100/value[country %in% "S_EUR4"],
    # `% of G7` = value*100/value[country %in% "G7"],
    `% of EU8` = value*100/value[country %in% "EU8"],
    # `% of LAT_AM` = value*100/value[country %in% "LAT_AM"],
    # `% of World` = {ref <- value[match("World", country)]
      # if (is.na(ref)) NA_real_ else value * 100 / ref } 
) %>%
  relocate(region,.after = Code) %>%
  relocate(pop,.after = last_col())
