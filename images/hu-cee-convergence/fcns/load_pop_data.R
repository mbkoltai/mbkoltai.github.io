
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
    paste0("data/gdp-per-capita/API_NY.GDP.PCAP.PP.KD_DS2_en_csv_v2_4572/",
    "API_NY.GDP.PCAP.PP.KD_DS2_en_csv_v2_4572.csv"),
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
    "EU8"=c("Denmark","Netherlands","Austria","Sweden","Belgium", "Germany",
                "Finland","France"),
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

rm(l_GDP_percap)