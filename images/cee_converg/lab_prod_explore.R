local({
  
df_regions <- full_join(lapply(names(l_groups$list_cntrs), \(x) 
    data.frame(country=l_groups$list_cntrs[[x]],region=x) ) %>% 
    bind_rows(),
    lapply(names(l_groups$comp_groups), \(x) 
    data.frame(country=l_groups$comp_groups[[x]],region_abbr=x) ) %>% 
    bind_rows()) %>%
    group_by(country) %>%
    summarise(country=unique(country),
      region=ifelse(is.na(unique(region)),
            unique(region_abbr),unique(region) ))

all_sel_cntrs <- unique(c(as.character(unlist(l_groups$list_cntrs)),
                        as.character(unlist(l_groups$comp_groups)) ))

# plot per hr work
if (T) {

  df_per_hr <- full_join(
l_product$oecd %>% filter(grepl("hour",Measure)) %>%
    select(year,country,value) %>%
  rename(value_oecd=value),
l_product$owid %>% 
  filter(grepl("hour",measure)) %>% 
  select(year,country,value) %>%
  rename(value_owid=value) 
    ) %>% 
  filter(country %in% all_sel_cntrs ) %>%
  mutate(cee=country %in% l_groups$list_cntrs$CEE ) %>%
  pivot_longer(c(value_oecd,value_owid),names_to="data source") %>%
  filter(!is.na(value)) %>%
  group_by(country,`data source`) %>%
  mutate(
    baseline_yr=min(year[year>=1990],na.rm=T),
    end_yr=max(year,na.rm=T),
    baseline = value[year==baseline_yr],
    fold_ch = value[year==end_yr] / baseline) %>%
  ungroup() %>%
  arrange(desc(fold_ch)) %>%
  mutate(country=factor(country,levels=unique(country)) )

df_summ <- df_per_hr %>%
  filter(year %in% baseline_yr | year %in% end_yr) %>%
  group_by(country,`data source`) %>%
  summarise(year_start=min(year),
            year_end=max(year),
            value_start=value[year==year_start],
            value_end=value[year==year_end]) %>%
  mutate(diff=value_end-value_start,
        fold_ch=value_end/value_start,
        CAGR=(fold_ch^(1/(year_end-year_start))-1)*100,
        label_txt = paste0(
          round(fold_ch, 2), " ",
          ifelse( year_start == 1990 & year_end %in% c(2023,2024),
          "", paste0("(", ifelse(year_start == 1990, "", year_start),
          "-", ifelse(year_end %in% c(2023,2024), "", year_end), ")" ) )   )
          )
    
# View(df_summ)
    
if (F) {
p <- df_per_hr %>%
  ggplot(aes(x=year,y=value,color=`data source`)) + 
  facet_wrap(~country) + 
  geom_rect(data= . %>% filter(cee) %>% select(country) %>% distinct(),
    xmin=-Inf,xmax=Inf,ymin=-Inf,ymax=Inf,inherit.aes=F,
    fill="steelblue",alpha=0.15,show.legend=F) +
  geom_line() + 
  geom_vline(xintercept=1990,linewidth=1/2) +
  geom_text(data=df_summ %>% filter(grepl("oecd",`data source`)),hjust=0,
              aes(label=label_txt),x=1950,y=60,size=3,show.legend=F) +
  geom_text(data=df_summ %>% filter(grepl("owid",`data source`)),hjust=0,
              aes(label=label_txt),x=1950,y=80,size=3,show.legend=F) +
  # scale_y_log10() +
  xlab("") + ylab("output per hr work (intUSD 2021 PPP)") +
  theme_bw()

print(p)

ggsave("data/productivity/sel_cntrs_per_hr_worked.png",
  device="png",,width=44,height=25,units="cm")
}

}

# plot per person employed
if (T) {

df_prod_pers_empl <- full_join(
l_product$oecd %>% 
    filter(grepl("person",Measure)) %>%
    select(year,country,value) %>%
  rename(value_oecd=value),
l_product$owid %>% 
  filter(grepl("pers",measure)) %>% 
  select(year,country,value) %>%
  rename(value_owid=value) ) %>% 
  filter(country %in% all_sel_cntrs ) %>%
  mutate(cee=country %in% l_groups$list_cntrs$CEE ) %>%
  pivot_longer(c(value_oecd,value_owid),names_to="data source") %>%
  filter(!is.na(value)) %>%
  group_by(country,`data source`) %>%
  mutate(
    baseline_yr=min(year[year>=1990],na.rm=T),
    end_yr=max(year,na.rm=T),
    baseline = value[year==baseline_yr],
    fold_ch = value[year==end_yr] / baseline) %>%
  ungroup() %>%
  arrange(desc(fold_ch)) %>%
  mutate(country=factor(country,levels=unique(country)) ) # 

df_summ_prod_per_empl <- df_prod_pers_empl %>%
  filter(year %in% baseline_yr | year %in% end_yr) %>%
  group_by(country,`data source`) %>%
  summarise(year_start=min(year),
            year_end=max(year),
            value_start=value[year==year_start],
            value_end=value[year==year_end]) %>%
  mutate(diff=value_end-value_start,
        fold_ch=value_end/value_start,
        CAGR=(fold_ch^(1/(year_end-year_start))-1)*100,
        label_txt = paste0(
          round(fold_ch, 2), "x ",
          ifelse( year_start %in% c(1990,1991) & year_end %in% c(2023,2024),
          "", paste0("(", ifelse(year_start %in% c(1990,1991), "", year_start),
          "-", ifelse(year_end %in% c(2023,2024), "", year_end), ")" ) )   )
          )

p <- df_prod_pers_empl %>%
ggplot(aes(x=year,y=value/1e3,color=`data source`,
           linetype=`data source`)) + 
  facet_wrap(~country) + 
  geom_rect(data= . %>% filter(cee) %>% select(country) %>% distinct(),
    xmin=-Inf,xmax=Inf,ymin=-Inf,ymax=Inf,inherit.aes=F,
    fill="steelblue",alpha=0.15,show.legend=F) +
  geom_line(linewidth=4/5) + 
  geom_vline(xintercept=1990,linewidth=1/3) +
  geom_text(data=df_summ_prod_per_empl %>% 
              filter(grepl("oecd",`data source`)),hjust=0,
              aes(label=label_txt),x=1960,y=130,size=3,show.legend=F) +
  geom_text(data=df_summ_prod_per_empl %>% 
              filter(grepl("owid",`data source`)),hjust=0,
              aes(label=label_txt),x=1960,y=100,size=3,show.legend=F) +
  # scale_y_log10() +
  xlab("") + ylab("output per empl. person (thous. USD PPP 2021)") +
  theme_bw()
print(p)

# SAVE
if (F) {
ggsave("data/productivity/sel_cntrs_per_person_empl_log.png",
  device="png",width=44,height=25,units="cm")
}

}

})


# # OECD data
# if (F) {
# left_join(l_product$oecd,
#   df_regions) %>%
#   filter(!is.na(region)) %>%
# ggplot(aes(x=year,y=value,color=country)) + 
#   facet_grid(Measure~region,scales="free") +
#   geom_line() + 
#   xlab("") + theme_bw()
# }
# 
# if (F) {
# l_product$owid %>% 
#   filter(grepl("pers",measure)) %>%
#     left_join(df_regions) %>%
#   filter(!is.na(region)) %>%
# ggplot(aes(x=year,y=value/1e3,color=country)) + 
#   facet_wrap(~region,scales="free_x") +
#   geom_line() + 
#   scale_y_continuous(limits=c(0,NA)) +
#   xlab("") + ylab("thousand intUSD 2021 PPP") + 
#   theme_bw()
# }