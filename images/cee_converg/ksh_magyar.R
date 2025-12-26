### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# magyar realjovedelmek/fogyasztas (KSH)

l_magyar <- list()

l_magyar$per_fo_realjov_fogy_1960tol <- read_csv2("data/ksh/stadat-gdp0003-21.1.1.3-hu.csv",skip=2,
        col_names = c(unlist(strsplit(
          read_lines("data/ksh/stadat-gdp0003-21.1.1.3-hu.csv",skip=1,n_max=1,
            locale=locale(encoding="ISO-8859-2")),split = "\"")) %>% 
            .[. != "" & . != ";"]) )

# magyar realber/jovedelem
l_magyar$ksh_realber_realjov <- read_delim(file = "data/ksh/stadat-gdp0035-21.1.1.35-hu.csv",
                                  delim=";", locale=locale(encoding="ISO-8859-2"))

# magyar lakossag
l_magyar$hu_pop <- wb_data(country="HUN",indicator="SP.POP.TOTL", 
            start_date=1960,end_date=2023)

# magyar GDP
l_magyar$ksh_gdp_1960tol <- left_join(
    read_delim(file = "data/ksh/stadat-gdp0002-21.1.1.2-hu.csv", 
                delim = ";", locale=locale(encoding="ISO-8859-2"),skip=1) %>% 
                setNames(nm = c("year","gdp","vegso_fogyasztas","vegso_fogyasztas_haztart",
                                "brutto_felhalm","brutto_felhalm_alloeszkoz")), #  %>% filter()
    l_magyar$hu_pop %>% select(date,SP.POP.TOTL) %>% rename(year=date,pop=SP.POP.TOTL) ) %>%
  # mutate(gdp_per_fo=gdp/pop) %>%
  pivot_longer(!c(year,pop),names_to="valtozo",values_to="absz_ert") %>%
  mutate(per_fo_ert=absz_ert/pop) %>%
  pivot_longer(!c(year,pop,valtozo),names_to = "tipus") %>%
  group_by(valtozo,tipus) %>%
  mutate(val_norm_1989=value/value[year==1989]) 

# PLOT
with(list(), {
  save_flag=F
p_ksh_gdp_1960tol <- l_magyar$ksh_gdp_1960tol %>%
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
  scale_y_continuous(limits = c(0.5,2)) +
  theme_bw() + plot_settings
print(p_ksh_gdp_1960tol)

# as plotly
if (save_flag) {
saveWidget(
  ggplotly(p_ksh_gdp_1960tol), #  + theme(legend.position="none")
  file = "output/magyar_makro/ksh_gdp_1960tol.html")
}

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# concat w/ real wage data
l_magyar$ksh_gdp_realber_fogyasztas <- bind_rows(
l_magyar$ksh_gdp_1960tol %>%
  filter(!grepl("felhalm",valtozo) & # year>=1980 & 
           grepl("gdp",valtozo) & grepl("per",tipus) ) %>%
  mutate(tipus=ifelse(grepl("absz",tipus),"abszolút","per fő"),
         valtozo=ifelse(grepl("gdp",valtozo),"GDP (per fő)","NA") ) %>%
  ungroup() %>%
  select(-tipus,-pop), 
l_magyar$per_fo_realjov_fogy_1960tol %>% 
    setNames(c("year","reáljövedelem (per fő)", "fogyasztás (per fő)")) %>%
    pivot_longer(!year,names_to = "valtozo") %>%
    group_by(valtozo) %>%
    mutate(val_norm_1989=value/value[year==1989])   )  

### ### ### ### ### ### ### 
# plot

with(list(), {
  save_flag=F
p_ksh_gdp_realber_fogyasztas <- l_magyar$ksh_gdp_realber_fogyasztas %>%
    filter(year>=1980) %>%
  mutate(val_norm_1989=signif(val_norm_1989,3)) %>%
ggplot(aes(x=year,y=val_norm_1989,group=valtozo,color=valtozo)) + 
  geom_line(linewidth=1.2) + geom_point(size=3,alpha=1/3) + 
  xlab("") + ylab("érték 1989-hez (=1) képest") +
  labs(color="",caption="forrás: ksh.hu/stadat_files/gdp/hu/gdp0002.html
       ksh.hu/stadat_files/gdp/hu/gdp0035.html") + 
  geom_hline(yintercept = 1,linewidth=1/2) +
  scale_x_continuous(breaks=seq(1980,2020,5)) +
  scale_y_continuous(breaks=seq(0.6,2,0.2),limits=c(0.5,2)) +
  theme_bw() + plot_settings + 
  theme(plot.caption=element_text(size=11),
        legend.position=c(0.03,1),legend.text = element_text(size=18),
        legend.background=element_rect(fill=NA),
        # legend.box.background = element_rect(fill = NA),
        legend.justification=c("left", "top"))
print(p_ksh_gdp_realber_fogyasztas)
if (save_flag) {
  "output/magyar_makro/p_ksh_gdp_realber_fogyasztas.png" %>%
    ggsave(width=30,height=24,units="cm")

# as plotly
saveWidget(
  ggplotly(p_ksh_gdp_realber_fogyasztas), #  + theme(legend.position="none")
  file="output/magyar_makro/ksh_gdp_realber_fogyasztas.html")
}

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

# correlation?
l_magyar$gdp_realber_fogy_nov_rata <- l_magyar$ksh_gdp_realber_fogyasztas %>%
  group_by(valtozo) %>%  # Group by the variable
  arrange(year) %>%      # Ensure data is ordered by year
  mutate(yoy_change = 100*(value-lag(value))/lag(value)) %>%  
  # Calculate YoY percentage change
  ungroup() %>%
  select(year, valtozo, yoy_change) %>%
  pivot_wider(names_from=valtozo, values_from=yoy_change)

# Generate the plots

l_magyar$pairs_gdp_realber_fogy_nov_rata <- lapply(
  list(c(2,3),c(2,4),c(3,4)), function(x) 
  l_magyar$gdp_realber_fogy_nov_rata[,c(1,x)] %>% 
    setNames(c("year","var1","var2")) %>%
    mutate(var_pair=paste0(
      colnames(l_magyar$gdp_realber_fogy_nov_rata[,x]),collapse=" - "),
           var_pair=gsub("em \\(per fő\\)","em",var_pair),
           var_pair=gsub("s \\(per fő\\)","s",var_pair),
      x_var=strsplit(var_pair," - ")[[1]][1],
      y_var=strsplit(var_pair," - ")[[1]][2] ) ) %>%
  bind_rows()

### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### 
# PLOT

with(list(), {
  save_flag=T
  df_plot <- l_magyar$pairs_gdp_realber_fogy_nov_rata %>%
  mutate(var_pair=paste0("x: ",gsub(" - ",", y: ",var_pair)),
    decade=floor(year/10)*10) 

  df_text <- df_plot %>%
    filter(!is.na(var_pair)) %>%
    group_by(var_pair) %>%
    summarise(corr=cor(var1,var2,use="complete.obs"),
      slope=coef(lm(var2~var1))[2],
      var1=mean(var1,na.rm=T),
      var2=max(var2, na.rm=T)*0.9)

  df_aver <- df_plot %>%
    group_by(decade,var_pair) %>%
    summarise(var1=100*((prod(var1/100+1,na.rm=T))^(1/9)-1),
              var2=100*((prod(var2/100+1,na.rm=T))^(1/9)-1) )

p_realber_gdp_korr <- df_plot %>%
  filter(!(var1<=(-5) | var2<=(-5))) %>%
ggplot(aes(x=var1,y=var2)) + facet_wrap(~var_pair) + # ,color=year
  geom_point(aes(color=factor(decade),shape="éves"),size=2,alpha=1/3) + 
  geom_smooth(data=df_plot,method="lm",
    color="grey22",se=F,alpha=1/3) +  # 
  geom_text(data=df_text, 
            aes(label=paste0("korr=",signif(corr,2),
                      "\nslope=",signif(slope,2))),
            x=-3,size=6) + # color="red",
  geom_point(data=df_aver,aes(color=factor(decade),
              shape="évtized-atlag"),size=3.5,stroke=1) +
  scale_shape_manual(values = c("évtized-atlag"=5,"éves"=19)) +
  geom_text(data=df_aver,
    aes(label=decade,x=var1+ifelse(decade %in% c(1970,2000),0,
              ifelse(decade==1960,-1,1)*0.8),
        y=var2+ifelse(decade %in% c(1970,2000),0.25,0))) +
  geom_vline(xintercept=0,linewidth=1/2,color="darkgrey") + 
  geom_hline(yintercept=0,linewidth=1/2,color="darkgrey") + 
  scale_x_continuous(limits=c(-5,NA),breaks=(-5:5)*2) +
  scale_y_continuous(limits=c(-5,NA),breaks=(-5:5)*2) +
  # geom_abline(slope=1,linewidth=1/2,color="darkgrey") +
  labs(x="% változás",y="% változás",
    caption="values below -5% not shown, but included in correlation and trendline",
    color="",shape="") +
  scale_color_manual(values=colorRampPalette(c("red", "blue"))(7)) +
  theme_bw() + plot_settings + theme(axis.text.x=element_text(angle=0),
    legend.position="top")

print(p_realber_gdp_korr)

if (save_flag) {
  "output/magyar_makro/ksh_gdp_realber_fogyasztas_nov_korrelacio.png" %>%
    ggsave(width=44,height=24,units="cm")
}

} 
)
