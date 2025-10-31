# libraries
lapply(c("tidyverse","wbstats", "RColorBrewer", "purrr", # ,"jsonlite" , "sf",
        "htmlwidgets","plotly","grid","cowplot"), 
       library, character.only=T)

# packs=c("tidyverse","ggrepel","plotly") # ,"RcppRoll","scales","lubridate","wpp2019","wesanderson"
# missing_packs = setdiff(packs, as.data.frame(installed.packages()[,c(1,3:4)])$Package)
# if (length(missing_packs)>0){ lapply(missing_packs,install.packages,character.only=TRUE) }
# lapply(packs,library,character.only=TRUE); rm(list = c("packs","missing_packs"))

# GGPLOT SETTINGS
standard_plot_theme <- theme(plot.title=element_text(hjust=0.5,size=16),
                             axis.title.x=element_text(size=17),
                             axis.title.y=element_text(size=17),
                             plot.caption=element_text(size=12),plot.caption.position="plot",
                             axis.text.x=element_text(size=15,angle=90),
                             axis.text.y=element_text(size=15),
                             strip.text = element_text(size=20),
                             legend.title =element_text(size=22),
                             # panel.grid.major.y=element_blank(), 
                             legend.text=element_text(size=15))

# load data
gdp_per_cap_2021usdppp <- read_csv(
    paste0("data/API_NY.GDP.PCAP.PP.KD_DS2_en_csv_v2_1772/",
    "API_NY.GDP.PCAP.PP.KD_DS2_en_csv_v2_1772.csv"),
    skip=4) %>% 
    select_if(~ !all(is.na(.)))

# cntrs of interest
list_cntrs <- list(
        "CEE"=c("Hungary","Poland","Czechia","Slovak","Lithua","Croatia","Romania","Bulgaria"),
        "Southern Europe"=c("Italy","Spain","Portugal","Greece"),
        "Eastern Europe (non-EU)"=c("Ukraine","Belarus","Serbia","Russia"),
        "Latin America"=c("Mexico","Brazil","Argentina","Colombia"),
        "Africa"=c("Algeria","South Africa","Egypt","Tunisia","Morocco"),
        "Asia"=c("Malaysia","China","Thailand","Indonesia","Vietnam") )

# filter data
gdp_per_cap_sel <- gdp_per_cap_2021usdppp %>%
  rename(country=`Country Name`) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("Viet",country) ~ "Vietnam",
    grepl("Slovak",country) ~ "Slovakia",
    .default = country)) %>%
  filter(grepl( paste0(c("Germany", unlist(list_cntrs)), collapse="|"), country) ) %>%
  filter(!grepl("Macao|Hong",country)) %>%
  select(!c(`Country Code`,`Indicator Name`,`Indicator Code`)) %>%
  pivot_longer(!country,names_to="year") %>%
  mutate(year=as.numeric(year)) %>%
  group_by(year) %>%
  mutate(germany_value = value[country == "Germany"],  # Extract Germany's value per year
         `% of DE` = signif(value*100/germany_value,3)) %>% # Normalize by Germany's value
  ungroup() %>% select(-germany_value) %>%
  group_by(country) %>%
  mutate(prop_1990_val=value/first(value[!is.na(value)]) ) %>%
  ungroup() %>%
  mutate(categ=case_when(
            grepl(paste0(list_cntrs$Africa, collapse="|"),country) ~ "Africa",
            grepl(paste0(list_cntrs$`Latin America`,collapse="|"),country) ~ "Latin America",
            grepl(paste0(list_cntrs$`Southern Europe`,collapse="|"),country) ~ "Southern Europe",
            grepl(paste0(list_cntrs$`Eastern Europe (non-EU)`,collapse="|"),country) ~ "Eastern Europe (non-EU)",
            grepl(paste0(list_cntrs$Asia,collapse="|"), country) ~ "Asia",
            .default="CEE")) %>%
  group_by(categ) %>%
  mutate(color_cntr=factor(as.numeric(factor(country)))) %>%
  filter(!country %in% "Germany") 

# PLOT GDP/cap trends
with(list(), {

# averages by region
df_mean <- gdp_per_cap_sel %>%
  group_by(year,categ) %>%
  summarise(`mean value`=mean(`% of DE`,na.rm=T))

# legends
legend_df <- gdp_per_cap_sel %>%
  distinct(categ, country, color_cntr) %>%
  group_by(categ) %>%
  mutate(x=min(gdp_per_cap_sel$year,na.rm=T)+3, 
         y=case_when(grepl("South",categ) ~ 
             seq(min(gdp_per_cap_sel$`% of DE`,na.rm=T),by=7,length.out=n()),
           .default=seq(max(gdp_per_cap_sel$`% of DE`,na.rm=T),by=-7,length.out=n()) ) )

# plot
p_gdp_cap_vs_DE <- gdp_per_cap_sel %>%
ggplot(aes(x=year,y=`% of DE`,group=country,color=color_cntr,text=paste0(
      "Country: ", country,"<br>Year: ",year,
      "<br>% of DE: ", round(`% of DE`,2)) )) + 
  facet_wrap(~categ) + 
  geom_line(alpha=1/2) + geom_point(alpha=1/4,size=1) +
  geom_line(data = df_mean,inherit.aes=F,aes(x=year,y=`mean value`)) + # ,linewidth=1
  geom_text(data=legend_df, aes(x=x, y=y, label=country, color=color_cntr),
    inherit.aes=F, hjust = 0) +
  xlab("") + ylab("GDP per cap (2021 USD PPP) as % of Germany ") + 
  scale_color_manual(values=c("1"="red","2"="blue",
    "3"="darkgreen","4"="darkgrey","5"="darkorange",
    "6"="steelblue", "7"="violet" ) ) + 
  scale_x_continuous(breaks=seq(1992,2026,4)) +
  scale_y_continuous(breaks=(0:10)*10) + # ,limits = c(NA,100)
  labs(color="",caption="source: data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD") + 
  theme_bw() + standard_plot_theme + theme(legend.position = "none") 

  print(p_gdp_cap_vs_DE)

# PNG
  if (T) {
  "output/gdp_per_cap_vs_DE_trend.png" %>%
    ggsave(width=30,height=24,units="cm")
}
  
# as plotly
if (T) {
  saveWidget( ggplotly(p_gdp_cap_vs_DE,tooltip="text"),
           "output/gdp_per_cap_vs_DE_trend.html")
}
  
}
)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# plot change from start to end only

with(list(df=gdp_per_cap_sel), {
df_summary <- df %>%
  filter(!is.na(value)) %>%
  group_by(country) %>%
  summarise(
    categ=unique(categ),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=`% of DE`[year == start_yr],
    end=`% of DE`[year == end_yr],
    .groups="drop") %>%
  filter(start_yr<1994) %>%
  mutate(change=end-start) %>%
  arrange(desc(change)) %>%
  mutate(country=factor(country, levels=unique(country)),
         label_color = ifelse(change < 0, "red", "black")  )
# render plot
arrow_plot <- df_summary %>% 
  ggplot(aes(y=country, x=start, xend=end, yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",round(change,1),"%"))) +
  geom_segment(aes(x=start, xend=end, y=country, yend=country, color=categ),
    arrow=arrow(length=unit(0.3, "cm")),linewidth=2) + # 
  geom_text(aes(x=(start+end)/2,y=as.numeric(rev(country))+1/3,
    label=paste0(ifelse(change>0,"+",""),round(change),"%") ),
    color=df_summary$label_color,size=5) + # scale_color_identity() +
  labs(x="% of DE", y=NULL, color="",
    caption="source: data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD",
    title="change in GDP/capita (USD 2021, PPP), 1990 → 2024 (◇), as a % of Germany's level",
    subtitle = "◇: most recent (2024) value"  ) + 
  scale_x_continuous(breaks=(0:10)*10) +
  scale_y_discrete(limits=rev,expand = expansion(0.03))  +
  theme_bw() + standard_plot_theme +
  theme(legend.position="top")

print(arrow_plot)

if (T) {
  "output/gdp_per_cap_vs_DE_change_levels.png" %>%
    ggsave(width=30,height=24,units="cm")
}

arrow_plot <- arrow_plot + 
  geom_point(aes(x = end, color = categ),shape=23,size=3,color="black")
if (T) {
  saveWidget(ggplotly(arrow_plot,tooltip="text"),
           "output/gdp_per_cap_vs_DE_change_levels.html")
}

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# plot the change only 

with(list(df=gdp_per_cap_sel), {
df_summary <- df %>%
  filter(!is.na(value)) %>%
  group_by(country) %>%
  summarise(
    categ=unique(categ),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=`% of DE`[year == start_yr],
    end=`% of DE`[year == end_yr],
    .groups="drop") %>%
  filter(start_yr<1994) %>%
  mutate(change=end-start) %>%
  arrange(desc(change)) %>%
  mutate(country=factor(country, levels=unique(country)),
         label_color = ifelse(change < 0, "red", "black")  )
# render plot
arrow_plot <- df_summary %>% 
  ggplot(aes(y=country, x=0, xend=change, yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",
      round(start),"% → ",round(end),"%"))) + # ifelse(change>0,"+",""), 
  geom_segment(aes(color=categ),
    arrow=arrow(length=unit(0.3, "cm")),linewidth=2) +
  geom_text(aes(x=change, # y=as.numeric(rev(country))+1/3,
    label=paste0(ifelse(change>0,"+",""),round(change),"%") ),
    color=df_summary$label_color,size=5, nudge_x=ifelse(df_summary$change<0,-3,3) ) + 
  labs(x="% of DE", y=NULL, color="",
    title="change in GDP/capita (USD 2021, PPP), 1990 → 2024 (◇), as a % of Germany's level",
    subtitle = "◇: most recent (2024) value",
    caption="source: data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD") +
  scale_x_continuous(breaks=(-5:10)*10) +
  scale_y_discrete(limits=rev,expand=expansion(0.03)) +
  theme_bw() + standard_plot_theme +
  theme(legend.position="top")
print(arrow_plot)

if (T) {
  "output/gdp_per_cap_vs_DE_change_only.png" %>%
    ggsave(width=30,height=24,units="cm")
}

arrow_plot <- arrow_plot + geom_point(
  aes(x=change,color=categ),shape=23,size=3,color="black")

if (F) {
  saveWidget( ggplotly(arrow_plot,tooltip="text"),
           "output/gdp_per_cap_vs_DE_change_only.html")
}

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GNI per capita (PPP)

GNI_per_capita_undp <- read_csv(
"data/gross-national-income-per-capita-undp/gross-national-income-per-capita-undp.csv")

gni_per_cap_sel <- GNI_per_capita_undp %>%
rename(country=Entity,year=Year,
       gni_per_cap=`Gross national income per capita`  ) %>%
  mutate(country=case_when(
    grepl("Egypt",country) ~ "Egypt",
    grepl("Russia",country) ~ "Russia",
    grepl("Viet",country) ~ "Vietnam",
    .default = country)) %>%
  filter(grepl( paste0(c("Germany", unlist(list_cntrs)), collapse="|"), country) ) %>%
  filter(!grepl("Macao|Hong",country)) %>%
  select(c(country,gni_per_cap,year)) %>%
  group_by(year) %>%
  mutate(germany_value = gni_per_cap[country == "Germany"],  # Extract Germany's value per year
         `% of DE` = signif(gni_per_cap*100/germany_value,3)) %>% # Normalize by Germany's value
  ungroup() %>% select(-germany_value) %>%
  mutate(categ=case_when(
            grepl(paste0(list_cntrs$Africa, collapse="|"),country) ~ "Africa",
            grepl(paste0(list_cntrs$`Latin America`,collapse="|"),country) ~ "Latin America",
            grepl(paste0(list_cntrs$`Southern Europe`,collapse="|"),country) ~ "Southern Europe",
            grepl(paste0(list_cntrs$`Eastern Europe (non-EU)`,collapse="|"),country) ~ "Eastern Europe (non-EU)",
            grepl(paste0(list_cntrs$Asia,collapse="|"), country) ~ "Asia",
            .default="CEE")) %>%
  group_by(categ) %>%
  mutate(color_cntr=factor(as.numeric(factor(country)))) %>%
  filter(!country %in% "Germany") 

# PLOT CHANGE including levels
with(list(df=gni_per_cap_sel), {
df_summary <- df %>%
  filter(!is.na(gni_per_cap)) %>%
  group_by(country) %>%
  summarise(
    categ=unique(categ),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=`% of DE`[year == start_yr],
    end=`% of DE`[year == end_yr],
    .groups="drop") %>%
  filter(start_yr<1994) %>%
  mutate(change=end-start) %>%
  arrange(desc(change)) %>%
  mutate(country=factor(country, levels=unique(country)),
         label_color = ifelse(change < 0, "red", "black") )

# render plot
arrow_plot <- df_summary %>% 
  ggplot(aes(y=country, x=start, xend=end, yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",round(change,1),"%"))) +
  geom_segment(aes(x=start, xend=end, y=country, yend=country, color=categ),
    arrow=arrow(length=unit(0.3, "cm")),linewidth=2) + # 
  geom_text(aes(x=(start+end)/2,y=as.numeric(rev(country))+1/3,
    label=paste0(ifelse(change>0,"+",""),round(change),"%") ),
    color=df_summary$label_color,size=5) + # scale_color_identity() +
  labs(x="% of DE", y=NULL, color="",
    caption="source: https://ourworldindata.org/grapher/gross-national-income-per-capita-undp",
    title="change in GNI/capita (internat USD 2017, PPP), 1990 → 2023 (◇), as a % of Germany's level") + 
  scale_x_continuous(breaks=(0:10)*10) +
  scale_y_discrete(limits=rev,expand = expansion(0.03))  +
  theme_bw() + standard_plot_theme +
  theme(legend.position="top")

print(arrow_plot)

if (T) {
  "output/gni_per_cap_vs_DE_change_levels.png" %>%
    ggsave(width=30,height=24,units="cm")
}

arrow_plot <- arrow_plot + 
  labs(subtitle="◇: most recent (2023) value") +
  geom_point(aes(x=end,color=categ),shape=23,size=3,color="black")
if (T) {
  saveWidget(ggplotly(arrow_plot,tooltip="text"),
           "output/gni_per_cap_vs_DE_change_levels.html")
}

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GNI/cap - GDP/cap combined plot (change, level)

with(list(df_gni=gni_per_cap_sel,
          df_gdp=gdp_per_cap_sel), {
            
df_gni_summary <- df_gni %>%
  filter(!is.na(gni_per_cap)) %>%
  group_by(country) %>%
  summarise(
    categ=unique(categ),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=`% of DE`[year == start_yr],
    end=`% of DE`[year == end_yr],
    .groups="drop") %>%
  filter(start_yr<1994) %>%
  mutate(change=end-start) %>%
  arrange(desc(change)) %>%
  mutate(country=factor(country, levels=unique(country)),
         label_color = ifelse(change < 0, "red", "black"),
         type="gni"  )
# gdp
df_gdp_summary <- df_gdp %>%
  filter(!is.na(value)) %>%
  group_by(country) %>%
  summarise(
    categ=unique(categ),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=`% of DE`[year == start_yr],
    end=`% of DE`[year == end_yr],
    .groups="drop") %>%
  filter(start_yr<1994) %>%
  mutate(change=end-start) %>%
  arrange(desc(change)) %>%
  mutate(country=factor(country, levels=unique(country)),
         label_color = ifelse(change < 0, "red", "black"),
         type="gdp")

# render plot
combined_gni_gdp <- bind_rows(df_gni_summary,
          df_gdp_summary) %>%
  pivot_wider(
    names_from=type,
    values_from=c(start,end,change),
    names_sep="_") %>%
  group_by(categ) %>%
  mutate(color_cntr=factor(as.numeric(factor(country)))) %>%
  ungroup() %>%
  mutate(text_str=paste0(country," ΔGNI/cap: ",round(change_gni),
            "%. ΔGDP/cap: ",round(change_gdp),"%") )

# means
df_means <- combined_gni_gdp %>%
  group_by(categ) %>%
  summarise(start_gni=mean(start_gni,na.rm=T),end_gni=mean(end_gni,na.rm=T),
    start_gdp=mean(start_gdp,na.rm=T), end_gdp=mean(end_gdp,na.rm=T),
    change_gdp=mean(change_gdp,na.rm=T),change_gni=mean(change_gni,na.rm=T),
    country="group average") %>%
  mutate(text_str=paste0(country," ΔGNI/cap: ",round(change_gni),
            "%. ΔGDP/cap: ",round(change_gdp),"%") )

# captions
caption_str = paste0(
  "source: https://ourworldindata.org/grapher/gross-national-income-per-capita-undp","\n",
  "data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD") 
    # ,"\n","(GNI: , PPP. GDP: USD 2021, PPP)")

# render plot
p_comb <- combined_gni_gdp  %>%
ggplot(aes(x=start_gni,xend=end_gni,y=start_gdp,yend=end_gdp,text=text_str)) +
  geom_segment(aes(color=color_cntr),arrow=arrow(length=unit(0.2,"cm")),linewidth=1,alpha=1/2) +
  geom_abline(linewidth=1/2,color="darkgrey") +
  geom_segment(data=df_means,color="black",arrow=arrow(length=unit(0.2,"cm")),linewidth=1) +
  facet_wrap(~categ) +
  geom_text(x=9, aes(y=100-as.numeric(color_cntr)*7,color=color_cntr,label=country),
    inherit.aes=F, hjust = 0) +
  labs(x="GNI/cap as % of DE (internat USD 2017, PPP)",
      y="GDP/cap as % of DE (USD 2021, PPP)", color="",
    caption=caption_str,
    title="change in GNI/capita vs GDP/capita, 1990 → 2023 (◇), as a % of Germany's level") +
  scale_x_continuous(breaks=(0:10)*10) +
  scale_y_continuous(breaks=(0:10)*10) +
  scale_color_manual(values = c( "1" = "red","2" = "blue",
    "3" = "darkgreen","4" = "darkgrey","5"="darkorange",
    "6"="steelblue", "7"="violet" ) ) +
  theme_bw() + standard_plot_theme +
  theme(legend.position="none")

print(p_comb)
# PNG
  if (T) {
  "output/gni_gdp_change_diagonal.png" %>%
    ggsave(width=30,height=24,units="cm")
  }

p_comb <- p_comb  + geom_point(aes(x=end_gni,y=end_gdp,color=color_cntr),
  shape=23,size=1.5,color="black")

if (T) {
  saveWidget(ggplotly(p_comb,tooltip="text"),
           "output/gni_gdp_change_diagonal.html")
}

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# change only (scatterplot)

with(list(df_gni=gni_per_cap_sel,
          df_gdp=gdp_per_cap_sel), {
    
facet_tr_val <- c(T,F)[1]
# create dataframes                    
df_gni_summary <- df_gni %>%
  filter(!is.na(gni_per_cap)) %>%
  group_by(country) %>%
  summarise(
    categ=unique(categ),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=`% of DE`[year == start_yr],
    end=`% of DE`[year == end_yr],
    .groups="drop") %>%
    filter(start_yr<1994) %>%
  mutate(change=end-start) %>%
  arrange(desc(change)) %>%
  mutate(country=factor(country, levels=unique(country)),
         label_color=ifelse(change < 0, "red", "black"),
         type="gni"  )
# gdp
df_gdp_summary <- df_gdp %>%
  filter(!is.na(value)) %>%
  group_by(country) %>%
  summarise(
    categ=unique(categ),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=`% of DE`[year == start_yr],
    end=`% of DE`[year == end_yr],
    .groups="drop") %>%
  filter(start_yr<1994) %>%
  mutate(change=end-start) %>%
  arrange(desc(change)) %>%
  mutate(country=factor(country, levels=unique(country)),
         label_color=ifelse(change < 0, "red", "black"),
         type="gdp")

# render plot
combined_gni_gdp <- bind_rows(df_gni_summary,
          df_gdp_summary) %>%
  pivot_wider(
    names_from=type,
    values_from=c(start,end,change),
    names_sep="_") %>%
  group_by(categ) %>%
  mutate(color_cntr=factor(as.numeric(factor(country)))) %>%
  ungroup() %>%
  mutate(text_str=paste0(country,"\nΔGNI/cap: ",round(change_gni),
            "%\nΔGDP/cap: ",round(change_gdp),"%") )
# means
df_means <- combined_gni_gdp %>%
  group_by(categ) %>%
  summarise(start_gni=mean(start_gni,na.rm=T),end_gni=mean(end_gni,na.rm=T),
    start_gdp=mean(start_gdp,na.rm=T), end_gdp=mean(end_gdp,na.rm=T),
    change_gdp=mean(change_gdp,na.rm=T),change_gni=mean(change_gni,na.rm=T)) %>%
  mutate(text_str=paste0(categ ,"\nΔGNI/cap: ",round(change_gni),
            "%\nΔGDP/cap: ",round(change_gdp),"%") )

# captions
caption_str=paste0(
  "source: https://ourworldindata.org/grapher/gross-national-income-per-capita-undp","\n",
  "data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD") 
# View(combined_gni_gdp)

# render plot
p_comb <- combined_gni_gdp  %>%
ggplot(aes(x=change_gni,y=change_gdp,text=text_str)) + # facet_wrap(~categ) +
  geom_point(aes(color=categ),size=4,alpha=1/2) +
  geom_point(data=df_means,shape=22,
    aes(fill=categ),color="black",size=6,show.legend=F) +
  geom_abline(linewidth=1/2,color="grey25") +
  geom_vline(xintercept=0,color="grey35") + 
  geom_hline(yintercept=0,color="grey35") +
  labs(x="GNI/cap as % of DE (internat USD 2017, PPP)",
      y="GDP/cap as % of DE (USD 2021, PPP)", color="",
    caption=caption_str,
    title="change in GNI/capita vs GDP/capita, 1990 → 2023, as a % of Germany's level") +
  scale_x_continuous(breaks=(-3:10)*10,limits = c(NA,43)) +
  scale_y_continuous(breaks=(-3:10)*10,limits = c(NA,43)) +
  theme_bw() + standard_plot_theme +
  theme(legend.position="top",title=element_text(size = 25))

if (facet_tr_val) {
  p_comb <- p_comb + facet_wrap(~categ) + theme(legend.position = "none")
}

print(p_comb)
# PNG
  if (T) {
  paste0("output/gni_gdp_changeonly_diagonal",
    ifelse(facet_tr_val,"_faceted",""),".png") %>%
    ggsave(width=30,height=24,units="cm")
  }

if (T) {
  saveWidget(
    ggplotly(p_comb,tooltip="text") %>% layout(
    margin = list(
      l = 100,  # left
      r = 50,   # right
      b = 100,  # bottom
      t = 100   # top
    )  ),
           paste0("output/gni_gdp_changeonly_diagonal",
             ifelse(facet_tr_val,"_faceted",""),".html"))
}

})


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# compared to 1990 level
if (F) {
p_gdp_cap_vs_1990 <- gdp_per_cap_sel %>%
  # filter(!country %in% c("Italy","Spain")) %>%
  filter(!country %in% c("Germany","Serbia")) %>%
ggplot(aes(x=year,y=prop_1990_val,group=country,color=country)) + 
  facet_wrap(~categ) + 
  geom_line() + geom_point(alpha=1/4,size=2) +
  xlab("") + ylab("GDP per cap (2021 USD PPP) compared to 1990 value") + 
  scale_x_continuous(breaks=seq(1990,2022,2)) +
  scale_y_continuous(breaks=seq(0.4,4,0.2)) +
  labs(color="") + theme_bw() + 
  standard_plot_theme; p_gdp_cap_vs_1990

saveWidget(
  ggplotly(p_gdp_cap_vs_1990 + theme(legend.position="none")),
  "output/p_gdp_cap_vs_1990.html")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# OECD average annual wages

oecd_aver_ann_wages <- read_csv(
  paste0("data/oecd/",
  "OECD.ELS.SAE,DSD_EARNINGS@AV_AN_WAGE,+CHL+COL+CRI+GRC+PRT+EST+LTU+LVA+CZE+MEX+ITA+POL+DEU+ESP+SVK+HUN..USD_PPP..Q...csv"
    )) %>%
  arrange(`Reference area`,TIME_PERIOD)

# plot
with(list(),{
  title_str <- "Average annual wages (% of DE, 2021 USD PPP)"
  df_plot <- oecd_aver_ann_wages %>%
  select(`Reference area`,TIME_PERIOD,OBS_VALUE,STRUCTURE_NAME,UNIT_MEASURE) %>% 
  rename(country=`Reference area`,year=TIME_PERIOD,value=OBS_VALUE) %>%
  filter(year>1990) %>%
  group_by(year) %>%
  mutate(germany_value = value[country == "Germany"],  # Extract Germany's value per year
         `% of DE` = signif(value*100 / germany_value,3)) %>% # Normalize by Germany's value
  ungroup() %>% select(-germany_value) %>%
  group_by(country) %>%
  mutate(
    min_year=min(year),
    prop_1990_val=value/value[year==min_year]) %>%
  filter(!country %in% "Germany") %>%
  mutate(categ=case_when(
    grepl("Brazil|Mex|Argent|Chile|Colom|Costa",country) ~ "Latin-America",
                         country %in% c("Greece","Portugal","Spain","Italy") ~ "Southern Europe",
                         grepl("United|Germany",country) ~ "Western Europe",
                         .default = "CEE")) %>%
  filter(!grepl("Western",categ)) %>%
  group_by(categ) %>%
  mutate(color_cntr=factor(as.numeric(factor(country))))
  
  df_summ <- df_plot %>% group_by(categ,year) %>% 
      summarise(n_cntr=n(),mean_val=mean(`% of DE`,na.rm=T)) %>%
      mutate(`average (%)`=ifelse(n_cntr<3,NA,round(mean_val,1)))
    
  p_oecd_aver_ann_wages <- df_plot %>%
ggplot(aes(x=year,y=`% of DE`,group=country,color=color_cntr)) + 
  facet_wrap(~categ) + 
  geom_line(alpha=2/3) +
  geom_line(data=df_summ,aes(x=year,y=`average (%)`),color="black",inherit.aes=F) +
  geom_point(data=df_summ,aes(x=year,y=`average (%)`),color="black",inherit.aes=F,alpha=1/4) +
  xlab("") + ylab(title_str) + 
  scale_x_continuous(breaks=seq(1992,2026,4)) +
  scale_y_continuous(breaks=(0:10)*10,limits=c(4,NA)) +
  scale_color_manual(values = c( "1" = "red","2" = "blue",
    "3" = "darkgreen","4" = "darkgrey","5"="darkorange",
    "6"="steelblue", "7"="violet" ) ) +
  labs(color="") + theme_bw() + standard_plot_theme
  print(p_oecd_aver_ann_wages)

# # as PNG
# if (T) {
# saveWidget(
#   ggplotly(p_oecd_aver_ann_wages + theme(legend.position="none")),
#   file="output/aver_ann_wages_vs_DE.html") }
# as plotly
if (T) {
saveWidget(
  ggplotly(p_oecd_aver_ann_wages + theme(legend.position="none")),
  file="output/aver_ann_wages_vs_DE.html") }
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# magyar realjovedelmek/fogyasztas (KSH)

per_fo_realjov_fogy_1960tol <- read_csv2("data/ksh/stadat-gdp0003-21.1.1.3-hu.csv",skip=2,
        col_names = c(unlist(strsplit(
          read_lines("data/ksh/stadat-gdp0003-21.1.1.3-hu.csv",skip=1,n_max=1,
            locale=locale(encoding="ISO-8859-2")),split = "\"")) %>% 
            .[. != "" & . != ";"]) )

# magyar realber/jovedelem
ksh_realber_realjov <- read_delim(file = "data/ksh/stadat-gdp0035-21.1.1.35-hu.csv",
                                  delim=";", locale=locale(encoding="ISO-8859-2"))

# magyar lakossag
hu_pop <- wb_data(country="HUN",indicator="SP.POP.TOTL", start_date = 1960,end_date = 2023)

# magyar GDP
ksh_gdp_1960tol <- left_join(
    read_delim(file = "data/ksh/stadat-gdp0002-21.1.1.2-hu.csv", 
                delim = ";", locale=locale(encoding="ISO-8859-2"),skip=1) %>% 
                setNames(nm = c("year","gdp","vegso_fogyasztas","vegso_fogyasztas_haztart",
                                "brutto_felhalm","brutto_felhalm_alloeszkoz")), #  %>% filter()
    hu_pop %>% select(date,SP.POP.TOTL) %>% rename(year=date,pop=SP.POP.TOTL) ) %>%
  # mutate(gdp_per_fo=gdp/pop) %>%
  pivot_longer(!c(year,pop),names_to="valtozo",values_to="absz_ert") %>%
  mutate(per_fo_ert=absz_ert/pop) %>%
  pivot_longer(!c(year,pop,valtozo),names_to = "tipus") %>%
  group_by(valtozo,tipus) %>%
  mutate(val_norm_1989=value/value[year==1989]) 

# PLOT
p_ksh_gdp_1960tol <- ksh_gdp_1960tol %>%
  filter(!grepl("felhalm",valtozo) & year>=1980 & grepl("gdp|haztart",valtozo)) %>%
  mutate(tipus=ifelse(grepl("absz",tipus),"abszolút","per fő"),
         valtozo=ifelse(grepl("gdp",valtozo),"GDP","háztartások végső fogyasztása"),
         val_norm_1989=signif(val_norm_1989,3)) %>%
ggplot(aes(x=year,y=val_norm_1989,group=tipus,color=tipus)) + 
  facet_wrap(~valtozo) + 
  geom_line() + geom_point(size=2,alpha=1/3) + 
  xlab("") + ylab("érték 1989-hez (=1) képest") +
  labs(color="",caption="forrás: ksh.hu/stadat_files/gdp/hu/gdp0002.html") + 
  geom_hline(yintercept = 1,linewidth=1/2) +
  theme_bw() + standard_plot_theme; p_ksh_gdp_1960tol

# as plotly
saveWidget(
  ggplotly(p_ksh_gdp_1960tol), #  + theme(legend.position="none")
  file = "output/magyar_makro/ksh_gdp_1960tol.html")


# concat w/ real wage data
ksh_gdp_realber_fogyasztas <- bind_rows(
ksh_gdp_1960tol %>%
  filter(!grepl("felhalm",valtozo) & # year>=1980 & 
           grepl("gdp",valtozo) & grepl("per",tipus) ) %>%
  mutate(tipus=ifelse(grepl("absz",tipus),"abszolút","per fő"),
         valtozo=ifelse(grepl("gdp",valtozo),"GDP (per fő)","NA") ) %>%
  ungroup() %>%
  select(-tipus,-pop), 
per_fo_realjov_fogy_1960tol %>% 
    setNames(c("year","reáljövedelem (per fő)", "fogyasztás (per fő)")) %>%
    pivot_longer(!year,names_to = "valtozo") %>%
    group_by(valtozo) %>%
    mutate(val_norm_1989=value/value[year==1989])   )  

# plot
p_ksh_gdp_realber_fogyasztas <- ksh_gdp_realber_fogyasztas %>%
    filter(year>=1980) %>%
  mutate(val_norm_1989=signif(val_norm_1989,3)) %>%
ggplot(aes(x=year,y=val_norm_1989,group=valtozo,color=valtozo)) + 
  geom_line(size=1.2) + geom_point(size=3,alpha=1/3) + 
  xlab("") + ylab("érték 1989-hez (=1) képest") +
  labs(color="",caption="forrás: ksh.hu/stadat_files/gdp/hu/gdp0002.html
       ksh.hu/stadat_files/gdp/hu/gdp0035.html") + 
  geom_hline(yintercept = 1,linewidth=1/2) +
  scale_x_continuous(breaks=seq(1980,2020,5)) +
  scale_y_continuous(breaks=seq(0.6,2,0.2)) +
  theme_bw() + standard_plot_theme + 
  theme(plot.caption=element_text(size=11),
        legend.position=c(0.03,1),legend.text = element_text(size=18),
        legend.background=element_rect(fill=NA),
        # legend.box.background = element_rect(fill = NA),
        legend.justification=c("left", "top")); p_ksh_gdp_realber_fogyasztas
if (F) {
  "output/magyar_makro/p_ksh_gdp_realber_fogyasztas.png" %>%
    ggsave(width=30,height=24,units="cm")
}


# as plotly
saveWidget(
  ggplotly(p_ksh_gdp_realber_fogyasztas), #  + theme(legend.position="none")
  file = "../../website/mbkoltai.github.io/images/magyar_makro/ksh_gdp_realber_fogyasztas.html")

# correlation?
gdp_realber_fogyasztas_novek_ratak <- ksh_gdp_realber_fogyasztas %>%
  group_by(valtozo) %>%  # Group by the variable
  arrange(year) %>%      # Ensure data is ordered by year
  mutate(yoy_change = 100*(value-lag(value))/lag(value)) %>%  # Calculate YoY percentage change
  ungroup() %>%
  select(year, valtozo, yoy_change) %>%
  pivot_wider(names_from = valtozo, values_from = yoy_change)

# Generate the plots

pairs_gdp_realber_fogyasztas_novek_ratak <- lapply(list(c(2,3),c(2,4),c(3,4)), function(x) 
  gdp_realber_fogyasztas_novek_ratak[,c(1,x)] %>% 
    setNames(c("year","var1","var2")) %>%
    mutate(var_pair=paste0(colnames(gdp_realber_fogyasztas_novek_ratak[,x]),collapse=" - "),
           var_pair=gsub("em \\(per fő\\)","em",var_pair),
           var_pair=gsub("s \\(per fő\\)","s",var_pair),
      x_var=strsplit(var_pair," - ")[[1]][1],
      y_var=strsplit(var_pair," - ")[[1]][2] ) ) %>%
  bind_rows() 

# PLOT
pairs_gdp_realber_fogyasztas_novek_ratak %>%
  filter(!(var1<(-5) | var2<(-5))) %>%
ggplot(aes(x=var1,y=var2)) + facet_wrap(~var_pair) + 
  geom_point(size=3,alpha=1/3) + 
  geom_smooth(method="lm",color="red",se=FALSE,alpha=1/3) +  # Linear trend line
  xlab("% változás (y-o-y)") + ylab("% változás (y-o-y)") +
  geom_text(data=pairs_gdp_realber_fogyasztas_novek_ratak %>%
              filter(!is.na(var_pair)) %>%
              group_by(var_pair) %>%
              summarise(corr=cor(var1,var2, use = "complete.obs"),
                        var1=mean(var1,na.rm = T),var2=max(var2,na.rm=T)),
            aes(label=paste0("korr=",signif(corr,3))),color="red",size=6) +
  theme_bw() + standard_plot_theme
if (F) {
  "plots/ksh_gdp_realber_fogyasztas_nov_korrelacio.png" %>%
    ggsave(width=36,height=24,units="cm")
}

}