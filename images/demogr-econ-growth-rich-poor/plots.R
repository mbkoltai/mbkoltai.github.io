# LOAD PACKAGES
l_packs <- list()
l_packs$packages <- c("tidyverse", "zoo", "tools","lhs", "httr", "tictoc", "wpp2019")

# Check and install missing packages
l_packs$installed <- l_packs$packages %in% installed.packages()[, "Package"]
if (any(!l_packs$installed)) {
  install.packages(l_packs$packages[!l_packs$installed])
}

# Load the packages
lapply(l_packs$packages, library, character.only = TRUE)
rm(l_packs)

# package conflicts
conflicted::conflict_prefer("select", "dplyr")
conflicted::conflict_prefer("filter", "dplyr")
conflicted::conflict_prefer("lag", "dplyr")

# plotting settings
l_proc_data <- list()
l_proc_data$standard_theme <- theme( # for publ plots
                        plot.title=element_text(hjust=0.5,size=22),
                        axis.text.x=element_text(size=15,angle=90,vjust=1/2),
                        axis.text.y=element_text(size=15),
                        axis.title.x=element_text(size=20),
                        axis.title.y=element_text(size=20),
                        strip.text=element_text(size=22),
                        legend.text=element_text(size=20),
                        legend.title=element_text(size=22),
                        text=element_text(family="sans") )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# LOAD DATA

l_proc_data$gdp_per_capita_maddison <- read_csv(
  "../../data/gdp-per-capita-maddison-project-database/gdp-per-capita-maddison-project-database.csv") %>%
  select(1:4)

l_proc_data$hist_pop <- read_csv("../../data/population/population.csv")

# join GDP and popul data
l_proc_data$joint_pop_gdp <- with(l_proc_data, full_join(
hist_pop,
gdp_per_capita_maddison)) %>% 
  group_by(Entity) %>%
  filter(any(Year == 2022) & !grepl("OWID",Code) & 
        !all(is.na(`GDP per capita`)) &
         !is.na(Code) & !grepl("World",Entity)) %>%
  mutate(max_yr=max(Year[!is.na(`Population (historical)`) & 
                    !is.na(`GDP per capita`)],na.rm=T),
         max_gdp=`GDP per capita`[Year %in% max_yr],
         max_gdp_discr=case_when(
                        max_gdp<5e3 ~ "<5k",
                        max_gdp>=5e3 & max_gdp<10e3 ~ "5-10k",
                        max_gdp>=10e3 & max_gdp<20e3 ~ "10-20k",
                        max_gdp>=20e3 & max_gdp<30e3 ~ "20-30k",
                        max_gdp>30e3 ~ ">30k"),
        max_gdp_discr=factor(max_gdp_discr,
                  levels=c("<5k","5-10k","10-20k","20-30k",">30k"))) %>%
  ungroup() %>%
  arrange(Entity,Year)

# FOLD CHANGES
l_proc_data$fold_change_from1800 <- l_proc_data$joint_pop_gdp %>%
  group_by(Entity,Code,max_gdp_discr) %>%
  mutate(min_yr=ifelse(
            any(Year %in% 1800) & 
            !is.na(`Population (historical)`[Year==1800]) & 
            !is.na(`GDP per capita`[Year==1800]), 1800, 
        min(Year[Year>=1800 & !is.na(`Population (historical)`) & 
                 !is.na(`GDP per capita`)]) )) %>% 
  filter(Year>=min_yr) %>%
  summarise(min_yr=unique(min_yr),
            max_yr=max(Year[!is.na(`Population (historical)`) & !is.na(`GDP per capita`)]),
            min_pop=`Population (historical)`[Year %in% min_yr],
            max_pop=`Population (historical)`[Year %in% max_yr],
            min_gdp=`GDP per capita`[Year %in% min_yr],
            max_gdp=`GDP per capita`[Year %in% max_yr],
            t_dur=max_yr-min_yr) %>%
  mutate(ratio_pop=max_pop/min_pop,
         ratio_gdp_per_cap=max_gdp/min_gdp ) %>%
  filter(!is.infinite(min_yr))

# PLOT
with(l_proc_data,
  fold_change_from1800 %>% 
  filter(min_yr<1960) %>%
ggplot(aes(x=ratio_pop,ratio_gdp_per_cap)) + 
  geom_point(aes(color=max_gdp_discr,size=max_pop/1e6),alpha=2/3) + 
  geom_abline(slope=1,intercept=0,color="red",linetype="dashed") +
  geom_text(aes(label=ifelse(max_pop>=5e6, Code,"")),size=3) +
  labs(color="GDPpc (2022, USD ppp)",size="popul. (million)") +
  scale_x_log10(limits=c(2,90),breaks=c(1/2,1,2,3:5,10,20,30,50,100)) +
  scale_y_log10(limits=c(0.5,90),breaks=c(1/2,1,2,3:5,10,20,30,50,100)) +
  xlab("fold change in population") + ylab("fold change in GDP/cap") +
  labs(caption="Fold change from 1800 or earliest timepoint before 1960.
                Circle size ~ population. Country code for popul.>5e6.") +
  scale_size(range=c(4,25)) +
  theme_bw() + l_proc_data$standard_theme + theme(legend.position="top") +
  guides(size="none",color=guide_legend(override.aes=list(size=6),nrow=2))  )
if (F) {
ggsave("pop_gdp_percap_foldchange.pdf",
  width=25,height=20,units="cm",device=cairo_pdf)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# per unit of time

with(l_proc_data,
  fold_change_from1800 %>% filter(min_yr<1960) %>%
ggplot(aes(x=ratio_pop/t_dur,ratio_gdp_per_cap/t_dur)) + 
  geom_point(aes(color=max_gdp_discr,size=max_pop/1e6),alpha=2/3) + 
  geom_abline(slope=1,intercept=0,color="red",linetype="dashed") +
  geom_text(aes(label=ifelse(max_pop>=5e6, Code,"")),size=3) +
  labs(color="GDPpc (2022, USD ppp)",size="popul. (million)") +
  scale_x_log10(limits=c(0.009,1/2)) + scale_y_log10(limits=c(0.009,1/2)) +
  xlab("fold change in popul. per year") + ylab("fold change in GDP/cap per year") +
  guides(size="none",color=guide_legend(nrow=2,override.aes=list(size=5))) +
  labs(caption="Fold change from 1800 or earliest timepoint before 1960 (normalised by length of time).
                Circle size ~ population in 2022") +
  scale_size(range=c(4,25)) +
  theme_bw() + l_proc_data$standard_theme + theme(legend.position="top")   )
if (F) {
ggsave("pop_gdp_percap_foldchange_per_year.pdf",
   width=25,height=20,units="cm",device=cairo_pdf)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# 'fold change imbalance' vs final gdp-per-cap

with(l_proc_data,
  fold_change_from1800 %>% 
    filter(min_yr<1960 & !Code %in% c("IRL","ARE","QAT","KWT") ) %>% # 
ggplot(aes(x=(ratio_gdp_per_cap)/(ratio_pop),y=max_gdp)) + 
  geom_point(aes(color=max_gdp_discr,size=max_pop/1e6),alpha=2/3) + 
  geom_smooth(alpha=1/3,color="black") +
  geom_text(aes(label=ifelse(max_pop>=2e6,Code,"")),size=3) +
  geom_vline(xintercept=1,color="red",linetype="dashed") +
  labs(color="GDPpc (2022, USD ppp)",size="popul. (million)") +
  scale_x_log10(breaks=c(0.005,0.05,0.1,0.2,0.5,1,2,4,5,10,20,50)) + 
  scale_y_log10(breaks=c(1e3,2e3,5e3,1e4,2e4,3e4,5e4,1e5)) +
  xlab("ratio of fold changes: GDPpc/population") + ylab("GDPpc in 2022 (USD PPP)") +
  guides(size="none",color=guide_legend(override.aes=list(size=5),nrow=2)) +
  labs(caption="Fold changes from 1800 (or earliest timepoint before 1960) to present.
                Country codes for popul.≥5e6. Ireland,ARE,QAT,KWT (Gulf states) removed.") +
  scale_size(range=c(4,25)) +
  theme_bw() + l_proc_data$standard_theme + theme(legend.position="top")     )
if (F) {
  ggsave("pop_GDPpc_foldchange_ratios_vs_GDPpc.pdf",
    width=25,height=20,units="cm",device=cairo_pdf)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# 'fold change imbalance' vs final gdp-per-cap, time-normalised

with(l_proc_data,
  fold_change_from1800 %>% 
    filter(min_yr<=1960 & !Code %in% c("IRL","ARE","QAT","KWT") ) %>% 
ggplot(aes(x=(ratio_gdp_per_cap/t_dur)/(ratio_pop/t_dur),y=max_gdp)) + 
  geom_point(aes(color=max_gdp_discr,size=max_pop/1e6),alpha=2/3) + 
  geom_smooth(alpha=1/3,color="black") +
  geom_text(aes(label=ifelse(max_pop>=5e6,Code,"")),size=3) +
  geom_vline(xintercept = 1,color="red",linetype="dashed") +
  labs(color="GDPpc (2022, USD ppp)",size="popul. (million)") +
  scale_x_log10(breaks=c(0.05,0.1,0.2,0.5,1,2,4,5,10,20,50,80)) + 
  scale_y_log10(breaks=c(1e3,2e3,5e3,1e4,2e4,3e4,5e4)) +
  xlab("ratio of fold changes: GDPpc/population") + ylab("GDPpc in 2022 (USD PPP)") +
  guides(size="none",color=guide_legend(override.aes=list(size=5),nrow=2)) +
  labs(caption="Fold changes from 1800 (or earliest timepoint with available data) to present. 
                Normalised by length of time.
                Country code for popul.≥5e6. Ireland,ARE,QAT,KWT (Gulf states) removed.") +
  scale_size(range=c(4,25)) +
  theme_bw() + l_proc_data$standard_theme + theme(legend.position="top")     )
if (F) {
  ggsave("pop_GDPpc_timenorm_foldchange_ratios_vs_GDPpc.pdf",
    width=25,height=20,units="cm",device=cairo_pdf)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# dynamics of norm'd GDPpc and pop

# l_proc_data$joint_pop_gdp %>%
#   group_by(Entity,Code) %>%
#   mutate(min_year=min(Year[!is.na(`Population (historical)`) & !is.na(`GDP per capita`)])) %>%
#   filter(Year>=min_year ) %>% # & `Population (historical)`[Year==2022]>=5e6
#   mutate(GDPpc_norm=`GDP per capita`/`GDP per capita`[Year %in% 2022],
#         pop_norm=`Population (historical)`/`Population (historical)`[Year %in% 2022] ) %>%
#   filter(!is.na(max_gdp_discr)) %>%
# ggplot(aes(x=pop_norm,y=GDPpc_norm,group=Entity,color=Year)) + # ,color=max_gdp_discr
#   geom_path(alpha=1/2) + facet_wrap(~max_gdp_discr) +
#   geom_abline(slope=1,intercept=0,color="red",linetype="dashed") +
#   geom_vline(xintercept=1,linewidth=1/3) + geom_hline(yintercept=1,linewidth=1/3) +
#   scale_x_log10() + scale_y_log10() + # limits=c(0.01,3)
#   xlab("population as proportion of 2022 value") + 
#   ylab("GDPpc as proportion of 2022 value") +
#   theme_bw() + l_proc_data$standard_theme # + theme(legend.position="top")
# if (F) {
#   ggsave("pop_GDPpc_norm_byfinalvalue.pdf",
#     width=25,height=20,units="cm",device=cairo_pdf)
# }

###
# l_proc_data$joint_pop_gdp %>%
#   group_by(Entity,Code) %>%
#   mutate(min_year=min(Year[!is.na(`Population (historical)`) & 
#                           !is.na(`GDP per capita`) & 
#                           Year>=1750])) %>%
#   filter(Year>=min_year & `Population (historical)`[Year %in% 2022]>=5e6) %>%
#   mutate(GDPpc_norm=`GDP per capita`/`GDP per capita`[Year %in% min_year],
#         pop_norm=`Population (historical)`/`Population (historical)`[Year %in% min_year] ) %>%
#   filter(!is.na(max_gdp_discr)) %>%
# ggplot(aes(x=pop_norm,y=GDPpc_norm,group=Entity,color=Year)) + # ,color=max_gdp_discr
#   geom_path(alpha=1/2) + facet_wrap(~max_gdp_discr) +
#   geom_abline(slope=1,intercept=0,color="red",linetype="dashed") +
#   geom_vline(xintercept=1,linewidth=1/3) + geom_hline(yintercept=1,linewidth=1/3) +
#   scale_x_log10(breaks=c(1/2,1,2,5,10,20,50,100,200)) + 
#   scale_y_log10(breaks=c(1/2,1,2,5,10,20,50,100)) +
#   xlab("population as proportion of initial value") + 
#   ylab("GDPpc as proportion of initial value") +
#   theme_bw() + l_proc_data$standard_theme
# if (F) {
#   ggsave("pop_GDPpc_norm_byinitvalue.pdf",
#     width=28,height=20,units="cm",device=cairo_pdf)
# }

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# dynamics of ratio of normalised GDPpc/pop values, by length of time since initial value

# l_proc_data$joint_pop_gdp %>%
#   group_by(Entity,Code) %>%
#   mutate(min_year=min(Year[!is.na(`Population (historical)`) & 
#           !is.na(`GDP per capita`)& Year>=1750])) %>%
#   filter(Year>=min_year & `Population (historical)`[Year %in% 2022]>=5e6) %>%
#   mutate(GDPpc_norm=`GDP per capita`/`GDP per capita`[Year %in% min_year],
#         pop_norm=`Population (historical)`/`Population (historical)`[Year %in% min_year],
#         ratio=GDPpc_norm/pop_norm,
#         t_dur=Year-min_year ) %>%
#   filter(!is.na(max_gdp_discr) ) %>%
# ggplot(aes(x=t_dur,y=ratio,colour=min_year,group=Entity)) + 
#   facet_wrap(~max_gdp_discr,scales="free_x") + geom_path(alpha=1/3) + 
#   scale_y_log10() + 
#   geom_hline(yintercept = 1,linewidth=1/4) +
#   xlab("years since initial value (>1750)") + 
#   ylab("ratio of GDPpc to population (normalised to initial value)") +
#   theme_bw() + l_proc_data$standard_theme
# if (F) {
#   ggsave("pop_GDPpc_norm_byinitvalue_bytdur.pdf",
#     width=26,height=20,units="cm",device=cairo_pdf)
# }

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
#  norm pop dynamics from initial year

# l_proc_data$init_yr <- 1750
#   
# with(l_proc_data,
#   joint_pop_gdp %>%
#   group_by(Entity,Code) %>%
#   mutate(min_year=min(Year[!is.na(`Population (historical)`) & 
#           !is.na(`GDP per capita`)& Year>=init_yr])) %>%
#   filter(Year>=min_year & `Population (historical)`[Year %in% 2022]>=5e6) %>%
#   mutate(GDPpc_norm=`GDP per capita`/`GDP per capita`[Year %in% min_year],
#         pop_norm=`Population (historical)`/`Population (historical)`[Year %in% min_year],
#         t_dur=Year-min_year ) %>%
#   filter(!is.na(max_gdp_discr) ) %>%
# ggplot(aes(x=t_dur,y=pop_norm,colour=min_year,group=Entity)) + 
#   facet_wrap(~max_gdp_discr,scales="free_x") + geom_path(alpha=1/3) + 
#   scale_y_log10() + # geom_hline(yintercept=1,linewidth=1/4) +
#   xlab("years since initial value (>1750)") + 
#   ylab("population normalised to initial value") +
#   theme_bw() + l_proc_data$standard_theme )
# 
# if (F) {
#   ggsave("pop_GDPpc_norm_byinitvalue_bytdur.pdf",
#     width=26,height=20,units="cm",device=cairo_pdf)
# }

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# #  how many yrs ago was x% of current value reached: population
# 
# with(list(df_full=l_proc_data$joint_pop_gdp %>%
#   group_by(Entity,Code) %>%
#   mutate(max_yr=max(Year,na.rm=T),
#         min_yr=min(Year,na.rm=T),
#         t_dur=max_yr-Year,
#         pop_norm=`Population (historical)`/`Population (historical)`[Year %in% max_yr]) %>%
#   filter(!is.na(max_gdp_discr) & pop_norm>0.01 & Year>=1200 & # t_dur<=1e3 &  
#       Year<max_yr & min_yr<=1950 & !Entity %in% "Ireland") ), 
#   with(list(df_full=df_full,
#        df_mean_med=df_full %>% group_by(max_gdp_discr,Year) %>%
#             summarise(mean_val=mean(pop_norm,na.rm=T),
#                       med_val=median(pop_norm,na.rm=T),
#                       perc25=quantile(pop_norm,0.25,na.rm=T),
#                       perc75=quantile(pop_norm,0.75,na.rm=T)),
#       df_thresholds=df_full %>% group_by(max_gdp_discr,Year) %>%
#             summarise(mean_val=mean(pop_norm,na.rm=T)) %>% 
#             mutate(diff_mean10pt=abs(0.1-mean_val),
#                    diff_mean25pt=abs(0.25-mean_val),
#                    diff_mean50pt=abs(0.5-mean_val)) %>% 
#             pivot_longer(contains("diff"),names_to = "diff") %>% 
#             group_by(max_gdp_discr,diff) %>% filter(value %in% min(value)) %>%
#             mutate(yval=as.numeric(gsub("\\D","",diff))/100 ) ),
#     df_full %>%
# ggplot(aes(x=Year,y=pop_norm,group=Entity)) + 
#   facet_wrap(~max_gdp_discr) + # ,scales="free_x"
#   geom_path(alpha=1/4) + 
#   geom_line(data=df_mean_med,aes(y=mean_val,group=1),color="red",linewidth=1,alpha=2/3) +
#   geom_point(data=df_thresholds,aes(x=Year,y=yval,group=1),color="blue",show.legend=T) +
#   geom_ribbon(data=df_mean_med,aes(y=mean_val,ymin=perc25,ymax=perc75,group=1),alpha=1/4,fill="red") +
#   geom_text(data=df_thresholds, aes(x=Year,y=yval+0.1,label=Year,group=1),color="blue") +
#   # scale_x_continuous(trans=c("log10","reverse"),breaks=c(1e3,3e2,1e2,30,10,1)) +
#   scale_x_continuous(breaks=seq(1e3,2e3,200)) + # trans=c("reverse")
#   xlab("") + ylab("population normalised to present (2023) value") + # years from present (2023)
#   theme_bw() + l_proc_data$standard_theme ) )
# if (F) {
#   ggsave("pop_dyn_norm_bypresentvalue_year.pdf",
#     width=26,height=20,units="cm",device=cairo_pdf)
# }
# 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# #  how many yrs ago was x% of current value reached: GDPpc
# 
# with(list(df_full=l_proc_data$joint_pop_gdp %>%
#   group_by(Entity,Code) %>%
#   mutate(max_yr=max(Year[!is.na(`GDP per capita`)],na.rm=T),
#         min_yr=min(Year[!is.na(`GDP per capita`)],na.rm=T),
#         t_dur=max_yr-Year,
#         GDPpc_norm=`GDP per capita`/`GDP per capita`[Year %in% max_yr],
#         max_GDPpc_norm=max(GDPpc_norm,na.rm = T)) %>%
#   filter(!is.na(max_gdp_discr) & 
#       GDPpc_norm>0.01 & max_GDPpc_norm<=2 &
#       Year>=1870 & Year<max_yr & min_yr<=1950) ), 
#   with(list( df_full=df_full,
#              df_mean_med=df_full %>% 
#                   group_by(max_gdp_discr,Year) %>%
#                   summarise(
#                       mean_val=mean(GDPpc_norm,na.rm=T),
#                       med_val=median(GDPpc_norm,na.rm=T),
#                       perc25=quantile(GDPpc_norm,0.25,na.rm=T),
#                       perc75=quantile(GDPpc_norm,0.75,na.rm=T)),
#             df_thresholds=df_full %>% 
#               group_by(max_gdp_discr,Year) %>%
#               summarise(mean_val=mean(GDPpc_norm,na.rm=T)) %>%
#               mutate(diff_mean25pt=abs(0.25-mean_val),
#                    diff_mean50pt=abs(0.5-mean_val)) %>%
#               pivot_longer(c(diff_mean25pt,diff_mean50pt),names_to="diff") %>%
#               group_by(max_gdp_discr,diff) %>% 
#               filter(value %in% min(value,na.rm=T)) %>%
#               mutate(yval=ifelse(grepl("50",diff),0.5,0.25))    ),
#     df_full %>%
# ggplot(aes(x=Year,y=GDPpc_norm,group=Entity)) + 
#   facet_wrap(~max_gdp_discr,scales="free_y") + # 
#   geom_path(alpha=1/4) + 
#   geom_line(data=df_mean_med,aes(y=mean_val,group=1),color="red",linewidth=1) +
#   geom_ribbon(data=df_mean_med,aes(y=mean_val,ymin=perc25,ymax=perc75,group=1),alpha=1/4,fill="red") +
#   geom_point(data=df_thresholds,aes(x=Year,y=yval,group=1),color="blue") +
#   geom_text(data=df_thresholds, aes(x=Year,y=yval+0.1,label=Year,group=1),color="blue") +
#   geom_hline(yintercept=1,linewidth=1/3) +
#   # scale_x_continuous(trans=c("log10","reverse"),breaks=c(1e3,3e2,1e2,30,10,1)) +
#   # scale_x_continuous(trans=c("reverse")) + # ,breaks=c(1e3,750,500,250,100,50)
#   scale_y_continuous(limits=c(0,NA)) +
#   xlab("") +  ylab("GDP per cap. normalised to 2022 value") + # years before 2022
#   theme_bw() + l_proc_data$standard_theme ) )
# 
# if (F) {
#   ggsave("GDPpc_dyn_norm_bypresentvalue_byyear.pdf",
#     width=26,height=20,units="cm",device=cairo_pdf)
# }

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# both GDPpc and popul normalised to 2019 value, on one plot

with(list(n_min_sample=5,
  df_full=l_proc_data$joint_pop_gdp %>%
      filter(Year<2020) %>%
      group_by(Entity,Code) %>%
      mutate(min_yr_gdp=min(Year[!is.na(`GDP per capita`)],na.rm=T),
            max_yr=max(Year)) %>%
      filter(min_yr_gdp<1960) %>%
      mutate(
        t_dur=max_yr-Year,
        GDPpc_norm=`GDP per capita`/`GDP per capita`[Year %in% max_yr],
        max_GDPpc_norm=max(GDPpc_norm,na.rm=T),
        pop_norm=`Population (historical)`/`Population (historical)`[Year %in% max_yr]) %>%
      filter(!is.na(max_gdp_discr) ) %>%
      group_by(Year,max_gdp_discr) %>%
      mutate(weight=`Population (historical)`/sum(`Population (historical)`)) %>%
      select(Entity,Year,max_gdp_discr,GDPpc_norm,pop_norm,weight) %>%
      pivot_longer(cols=c(pop_norm,GDPpc_norm)) %>%
      mutate(name=ifelse(grepl("GDP",name),"GDP per capita","population") ) %>%
      filter(!is.na(value))
    ),
with(list(
      df_full=df_full, 
      df_mean_med=df_full %>%
        group_by(max_gdp_discr,Year,name) %>%
        summarise(
            n_val=n(),
            weight_mean=sum(weight*value),
            mean_val=mean(value,na.rm=T),
            # med_val=ifelse(sum(!is.na(value))>=n_min_sample,median(value,na.rm=T),NA),
            perc25=quantile(value,1/4,na.rm=T),
            perc75=quantile(value,3/4,na.rm=T) ) %>%
            filter(!(is.na(mean_val) | is.nan(mean_val)) ) %>% 
            mutate(across(c(weight_mean,mean_val,perc25,perc75), ~ ifelse(n_val<10,NA,.))) ), 
with(list(
  plot_min_yr=1840,
  plot_max_yr=2019,
  df_full=df_full,
  df_mean_med=df_mean_med,
  df_thresholds=df_mean_med %>% 
            mutate(diff_mean10pt=abs(0.1-mean_val),
                   diff_mean25pt=abs(0.25-mean_val),
                   diff_mean50pt=abs(0.5-mean_val)) %>% 
            pivot_longer(contains("diff"),names_to="diff") %>%
            filter(value<0.05) %>%
            group_by(max_gdp_discr,name,diff) %>% 
            filter(value %in% min(value)) %>%
            mutate(yval=as.numeric(gsub("\\D","",diff))/100 )    ),
  df_full %>% 
    filter( Year>=plot_min_yr & Year<plot_max_yr & value<=1.25 ) %>%
    group_by(Entity,name) %>%
    filter(sum(!is.na(value))>20) %>%
ggplot(aes(x=Year,y=value,group=Entity)) + 
  facet_grid(name~max_gdp_discr,scales="free") + # 
  geom_path(alpha=1/5,aes(color="indiv. countries")) + 
  geom_line(data=df_mean_med %>% filter(Year>=plot_min_yr),
    aes(y=mean_val,group=1,color="mean"),linewidth=2/3) +
  geom_line(data=df_mean_med %>% filter(Year>=plot_min_yr),
    aes(y=weight_mean,group=1,color="weighted mean"),linewidth=2/3) +
  geom_ribbon(data=df_mean_med %>% filter(Year>=plot_min_yr),
    aes(y=mean_val,ymin=perc25,ymax=perc75,group=1,fill="IQR"),alpha=1/4) +
  geom_point(data=df_thresholds %>% filter(Year>=plot_min_yr),
    aes(x=Year,y=yval,group=1),color="blue") +
  geom_text(data=df_thresholds %>% filter(Year>=plot_min_yr),
    aes(x=Year,y=yval+0.1,label=Year,group=1),color="blue") +
  geom_hline(yintercept=1,linewidth=1/3) +
  scale_x_continuous(breaks=c(seq(1700,2000,50))) +
  # scale_y_log10() + # breaks=c(0.03,0.05,0.1,0.2,0.4,0.5,0.75,1)
  scale_y_continuous(breaks=seq(0,5/4,1/4)) +
  scale_color_manual(values=c("indiv. countries"="black","mean"="red","weighted mean"="darkred")) +
  scale_fill_manual(values = c("IQR"="red")) +
  xlab("") + ylab(paste0("normalised to ",plot_max_yr, " value")) + 
  labs(color="",fill="",
    caption="Countries with less than 20 datapoints,
            or with normalised values>1.25 not shown,
            but included in averages/IQRs. 
    Average/IQR calculated for years with at least 10 data points (countries).") +
  theme_bw() + l_proc_data$standard_theme  + theme(legend.position="top") 
    )
  ) 
)

if (F) {
  ggsave("GDPpc_pop_dyn_norm_bypresentvalue_byyear.pdf",
    width=30,height=20,units="cm",device=cairo_pdf)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# show only the averages

with(list(df_mean_med=l_proc_data$joint_pop_gdp %>%
      filter(Year<2020) %>%
      group_by(Entity,Code) %>%
      mutate(min_yr_gdp=min(Year[!is.na(`GDP per capita`)],na.rm=T),
        max_yr=max(Year),
        t_dur=max_yr-Year,
        GDPpc_norm=`GDP per capita`/`GDP per capita`[Year %in% max_yr],
        max_GDPpc_norm=max(GDPpc_norm,na.rm=T),
        pop_norm=`Population (historical)`/`Population (historical)`[Year %in% max_yr]) %>%
      filter(!is.na(max_gdp_discr)) %>%
      group_by(Year,max_gdp_discr) %>%
      mutate(weight=`Population (historical)`/sum(`Population (historical)`)) %>%
      select(Year,max_gdp_discr,GDPpc_norm,pop_norm,weight) %>%
      group_by(Year,max_gdp_discr) %>%
      pivot_longer(cols=c(pop_norm,GDPpc_norm)) %>%
      filter(!is.na(value)) %>%
      group_by(max_gdp_discr,Year,name) %>%
      # mutate(# weight=value/sum(value),) %>%
      summarise(
            n_data=n(),
            mean_val=mean(value),
            weight_mean=sum(weight*value),
            med_val=median(value,na.rm=T),
            perc25=quantile(value,0.25,na.rm=T),
            perc75=quantile(value,0.75,na.rm=T) ) %>% 
      mutate(across(c(weight_mean,mean_val,med_val,perc25,perc75), ~ ifelse(n_data<10,NA,.))) ),
  df_mean_med %>% 
    filter( ( (grepl("GDP",name) & Year>1820) | 
            (grepl("pop",name) & Year>=1700) ) # & 
            # !is.na(mean_val) & !is.nan(mean_val) 
      ) %>%
    mutate(name=ifelse(grepl("GDP",name),"GDP per capita","population")) %>%
ggplot(aes(x=Year,y=weight_mean,group=max_gdp_discr,color=max_gdp_discr)) + 
  facet_wrap(~name,scales="free_x") + # 
  geom_path() + geom_point(alpha=1/2,shape=21) + 
  scale_x_continuous(breaks=c(seq(1700,2000,50),2020)) +
  # scale_y_log10(breaks=c(0.03,0.05,0.1,0.2,0.25,0.4,0.5,0.75,1)) +
  scale_y_continuous(breaks=seq(0,1,1/5)) +
  scale_color_manual(values=c("black","darkgrey","darkgreen","darkorange","red") ) + 
  xlab("") + ylab("normalised to 2019 value") + labs(color="GDP per cap. (2019 USD PPP)") +
  theme_bw() + l_proc_data$standard_theme  + theme(legend.position="top") 
  )

if (F) {
  ggsave("GDPpc_pop_dyn_norm_weight_aver_cntr_groups_ylin.pdf",
    width=30,height=20,units="cm",device=cairo_pdf)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# growth rates in time

with(list(df_full=l_proc_data$joint_pop_gdp %>%
      group_by(Entity,Code) %>%
      filter(!is.na(max_gdp_discr) ) %>% 
      select(Year,max_gdp_discr,`GDP per capita`,`Population (historical)`) %>%
      pivot_longer(cols=c(`GDP per capita`,`Population (historical)`)) %>%
      group_by(max_gdp_discr,Entity,name) %>% # ,Year
      mutate(ratio_curr_prev_val=value/lag(value,n=1),
             t_diff=Year-lag(Year,n=1),
             ann_perc_change=((ratio_curr_prev_val^(1/t_diff))-1)*100) %>% 
      filter(!is.na(ann_perc_change)) %>%
      group_by(max_gdp_discr,Year,name) %>% # 
      mutate(weight_in_group=value/sum(value,na.rm=T)) %>%
      group_by(max_gdp_discr,Year) %>%
      mutate(weight_in_group=ifelse(grepl('Pop',name),
              weight_in_group[grepl('Pop',name)],1/n_distinct(Entity)) )   ), 
with(list(df_full=df_full,
      df_mean_med=df_full %>% 
          group_by(max_gdp_discr,name,Year) %>%
          summarise(mean_val=mean(ann_perc_change,na.rm=T),
              weighted_mean=sum(weight_in_group*ann_perc_change),
              perc25=quantile(ann_perc_change,probs=0.25,na.rm=T), # ,weights=weight_in_group
              perc75=quantile(ann_perc_change,probs=0.75,na.rm=T),
              st_dev=sd(ann_perc_change,na.rm=T)) %>%
          group_by(max_gdp_discr,name) %>%
          mutate(smooth_weigh_mean=rollmean(weighted_mean,fill=NA,k=10),
                 smooth_mean=rollmean(mean_val,fill=NA,k=10),
                 perc25=rollmean(perc25,fill=NA,k=10),
                 perc75=rollmean(perc75,fill=NA,k=10),
                 st_dev=rollmean(st_dev,fill=NA,k=10)) ) , 
df_mean_med %>% 
    mutate(name=ifelse(grepl("Popul",name),"Population",name)) %>%
ggplot(aes(x=Year,group=1)) + 
  facet_grid(name~max_gdp_discr,scales="free") +
  geom_path(aes(y=smooth_weigh_mean,linetype="Weighted mean"),alpha=1/2) + 
  geom_path(aes(y=smooth_mean,linetype="Mean")) + # ,alpha=2/3
  geom_ribbon(aes(y=smooth_mean,ymin=perc25,ymax=perc75,group=1,fill="IQR (unweighted)"),alpha=1/4) +
  # geom_ribbon(aes(y=smooth_mean,ymin=smooth_mean-st_dev,ymax=smooth_mean+st_dev,
  #             group=1,fill="IQR (unweighted)"),alpha=1/4) +
  geom_hline(yintercept=0,color="blue",linewidth=1/3) +
  scale_x_continuous(limits=c(1750,2020),expand=expansion(0,0)) +
  scale_y_continuous(breaks=c(seq(-10,10,2),1,3),expand=expansion(0,0)) + # limits=c(-1,NA),
  scale_linetype_manual(values=c("Weighted mean"="dashed","Mean"="solid")) +
  scale_fill_manual(values = c("IQR (unweighted)"="red")) +
  labs(linetype="",fill="",caption = "10-year smoothing.\nWeighted by population size.") +
  xlab("") + ylab("annual growth rate") + # years before 2022
  theme_bw() + l_proc_data$standard_theme + theme(legend.position="top")  )   )
if (F) {
  ggsave("GDPpc_pop_annual_growth_rates.pdf", 
    width=30,height=20,units="cm",device=cairo_pdf)
}
