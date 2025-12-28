# load settings
source("functions_settings.R")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# LOAD data, functions, libraries

source("load_data.R")

### PLOTTING 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# LONG-TERM gdp/cap
# TIME TRACE: long-term gdp/cap trends from 1950 to present
# CEE compared to diff standards

with(list(
  save_plot_flag=T,
  save_table=F,
  all_vars=c("% of DE", # ""intusd2011ppp",
        paste0("% of ",names(l_groups$comp_groups)),
        "% of World") ), {

  for (sel_var in all_vars) {
    
    ylab_txt <- gsub("LAT_AM","Latin America",paste0("GDP/capita ",
                  ifelse(grepl("%",sel_var),sel_var,""),
                  " (2011 int. USD, PPP)"))
        
    caption_src <- "source: https://ourworldindata.org/grapher/gdp-per-capita-maddison-project-database"
    caption_txt <- if (!grepl("World|usd",sel_var)) {
    paste0(ifelse(grepl("DE",sel_var),"*","*weighted average of "), 
      str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("LAT_AM",sel_var) ~ paste0(l_groups$list_cntrs$`Latin America`,collapse=", "),
    grepl("G7",sel_var) ~ paste0(l_groups$comp_groups$G7,collapse=", "),
    grepl("DE",sel_var) ~ "Germany"),width=55),
      "\n",caption_src)
  } else {
      caption_src
    }
    
    
  df_plot <- l_GDP_percap$gdp_per_cap_longterm_2011usd_sel_cntr %>%
  filter(year>=1950 ) %>%
  filter(region %in% "CEE" | 
         grepl("Russia|Serbia|Ukr|Belarus",country) ) %>% # 
  filter(!grepl("Germ|World|United",country) & 
         !country %in% names(l_groups$comp_groups)) %>%
  mutate(cntr_group=case_when(
    grepl("Eston|Lith|Latv",country) ~ "Baltics",
    grepl("Czech|Slovak",country) ~ "Czechoslovakia (Czechia, Slovakia)",
    grepl("Croat|Sloven|Serb",country) ~ "Yugoslavia (Slovenia, Croatia, Serbia)",
    grepl("Russia|Ukra|Belar",country) ~ "USSR (Russia, Ukraine, Belarus)",
    .default=country) ) %>%
  group_by(cntr_group) %>%
  mutate(cntr_rank=dense_rank(country)) %>%
  ungroup() %>%
  mutate(synth=ifelse(is.na(synth),F,synth))
  
  # View(df_plot)
  
  df_yrs <- df_plot %>% 
    group_by(country) %>%
    mutate(min_yr=min(year),
           trans_rec_end_yr=case_when(
             grepl("Baltic",cntr_group) ~ 1994,
             grepl("Ukr",country) ~ 1998,
             grepl("Belarus",country) ~ 1995,
             grepl("Russia",country) ~ 1998,
             grepl("Poland",country) ~ 1991,
             grepl("Sloven",country) ~ 1992,
             grepl("Croat",country) ~ 1993,
             grepl("Serbia",country) ~ 1993,
             grepl("Bulg",cntr_group) ~ 1999,
             .default=1992)  ) %>%
    filter(year %in% c(
        ifelse(grepl("Yug",cntr_group),1979,1975),
        ifelse(grepl("World",sel_var),1980,NA),
        ifelse(grepl("World",sel_var),1990,1989),
          2022) | 
        year==min_yr | year==trans_rec_end_yr) %>%
    group_by(cntr_group) %>% # filter( ) %>%
    mutate(label_perc=ifelse( max(cntr_rank) > 1 & year==2022,
            paste0(round(!!sym(sel_var))," (",Code,")"),
            as.character(round(!!sym(sel_var))) ) ) %>%
    select(year,!!sym(sel_var),country,Code,label_perc)
  # View(df_yrs)
  
  df_rect <- data.frame(
  xmin=c(1948, 1989, 1993), # ,2008
  xmax=c(1989, 1993, 2025),
  ymin =-Inf,ymax =Inf,
  fill=c("socialism"="red",
      "transition recession"="black",
      "capitalism"="darkgreen"), # ,"after GFC"="darkgreen"
  alpha=c(0.1,0.1,0.1) ) # 0.2,

  hline_vals <- lapply(all_vars, function(n) 
      if (grepl("LAT_AM|World",n)) {c(100,200)} else {100})
  names(hline_vals) <- all_vars
  # print(hline_vals[[sel_var]])
      
# render plot
p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var),group=interaction(country,synth),
  text=paste0(Code,", ",year,", ",
      round(get(sel_var)), sel_var)) ) + # W_EUR4_noUK
  facet_wrap(~cntr_group) + # ,scales="free_y"
  geom_line(alpha=1/2,linewidth=1,aes(color=synth),show.legend=F) + # +cntr_rank/20),
  geom_point(data=df_yrs %>% mutate(synth=F),alpha=1/2) +
  geom_text_repel(data=df_yrs %>% mutate(synth=F),
      aes(y=get(sel_var),label=label_perc),color="darkblue",
      size=4,direction="both",nudge_y=0,min.segment.length=0) +
  geom_hline(yintercept=hline_vals[[sel_var]],
          linewidth=1/2,linetype="dashed") +
  geom_rect(data=df_rect,
        aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,
              fill=fill,alpha=alpha),inherit.aes=F) + # ,show.legend=F
  scale_fill_identity() + scale_alpha_identity()  +
  xlab("") + ylab(ylab_txt) +
  labs(fill="",alpha="",caption=caption_txt) +
  scale_x_continuous(breaks=seq(1950,2020,10),expand=expansion(0.01) ) +
  # scale_linetype_manual(values = c("solid","dotted")) +
  scale_color_manual(values = c("black","blue")) +
  scale_y_continuous(limits=c(0,NA),
          breaks=0:10*ifelse(grepl("LAT|World",sel_var),50,20) ) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0)) 

if (grepl("World",sel_var)) {
  p <- p + geom_point(data=. %>% filter(year<=2010),shape=21)
}

# PNG
 print(p)
  folder_name <- "output/CEE_vs_centre_dyn/"
  file_name <- paste0(folder_name,gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
  }

} # end of for loop
  
          if (save_table) {
  write_csv(df_plot,file=paste0(folder_name, "df_plot.csv"))
  write_csv(df_yrs,file=paste0(folder_name, "df_yrs.csv"))
          }
          
}) # end of with


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GDP/CAP 1950 -> 2022: cumulative change (%) only, by *country*

# PLOT
with(list(save_plot_flag=T,
      plot_show=T,
      save_table=T,
      all_var_list=c("intusd2011ppp","% of DE",
            paste0("% of ",names(l_groups$comp_groups))) ), {
    
    k_cntr<-0; l_print<-list()
    
  for (type_scale in c("lin","log")) {
  for (sel_var in all_var_list) {
  
      x_lab_txt <- if (grepl("%",sel_var)) {
          paste0("GDP/capita as ",
              gsub("LAT_AM","Latin America",sel_var),
              "* (const 2011 int. USD, PPP)")
    } else {
        paste0("GDP/capita",
          ifelse(grepl("log",type_scale),"",", thousand"),
          " (const 2011 int. USD, PPP)")   }
    # if log
    if (grepl("log",type_scale)) {
            x_lab_txt <- gsub("%","proportion",paste0("log of ",x_lab_txt) )
        }

  caption_txt <- if (!grepl("World|usd",sel_var)) {
    paste0(ifelse(grepl("DE",sel_var),"*","*weighted average of "), 
      str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("LAT_AM",sel_var) ~ paste0(l_groups$list_cntrs$`Latin America`,collapse=", "),
    grepl("G7",sel_var) ~ paste0(l_groups$comp_groups$G7,collapse=", "),
    grepl("DE",sel_var) ~ "Germany"),width=50),
      "\nsource: https://ourworldindata.org/grapher/gdp-per-capita-maddison-project-database")
  } else {
      "source: https://ourworldindata.org/grapher/gdp-per-capita-maddison-project-database"
    }
    
  df_intermed <- l_GDP_percap$gdp_per_cap_longterm_2011usd_sel_cntr %>%
  filter(year>=1950 ) %>%
  filter(region %in% "CEE" | grepl("Russia|Serbia|Ukr|Belarus",country) ) %>% # 
  filter(!grepl(paste0(c("Germ","World","United S",
                  names(l_groups$comp_groups)),collapse="|"),country)) %>%
  mutate(cntr_group=case_when(
    grepl("Eston|Lith|Latv",country) ~ "Baltics",
    grepl("Croat|Sloven|Serb",country) ~ "Yugosl.",
    grepl("Russia|Ukra|Belar",country) ~ "USSR",
    .default="CEE") ) %>%
    relocate(c(cntr_group,region),.before=country) 
  
df_yrs <- df_intermed %>% 
    group_by(country) %>%
    mutate(min_yr=min(year),
           trans_rec_end_yr=case_when(
             grepl("Baltic",cntr_group) ~ 1994,
             grepl("Ukr",country) ~ 1998,
             grepl("Belarus",country) ~ 1995,
             grepl("Russia",country) ~ 1998,
             grepl("Poland",country) ~ 1991,
             grepl("Sloven",country) ~ 1992,
             grepl("Croat",country) ~ 1993,
             grepl("Serbia",country) ~ 1993,
             grepl("Bulg",country) ~ 1999,
             .default=1992)  ) %>%
    filter(year %in% c(
        ifelse(grepl("Yug",cntr_group),1979,1975),
        1989,2022) | year==min_yr | year==trans_rec_end_yr) %>%
    pivot_longer(cols=c("intusd2011ppp",all_var_list),
      names_to="varname") %>%
  arrange(country,varname, year) %>%
  group_by(varname) %>%
  mutate(year_end=lead(year),
        value_end=lead(value)  ) %>%
  filter(!is.na(year_end)) %>%
  ungroup() %>%
  relocate(c(year,year_end,varname,value,value_end), .after=Code) %>%
  filter(year_end>=year) %>%
  filter( # !grepl("",varname) & 
         grepl(sel_var,varname)  ) %>%
  mutate(era=paste0(year,"-",year_end),
         era_col=case_when(
           year<1989 ~ "socialism",
           year==1989 ~ "transition",
           year>1989 ~ "capitalism")) %>%
    group_by(country) %>%
    mutate(era_num=as.numeric(factor(era)),
          era_low=era_num-1/2,
          era_high=era_num+1/2) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(cntr_region=paste0(cntr_group,": ",country),
    scaling=ifelse(grepl("usd",sel_var),1e-3,
                ifelse(grepl("log",type_scale),1e-2,1)),
    value=ifelse(type_scale=="log",log(value*scaling),value*scaling),
    value_end=ifelse(type_scale=="log",log(value_end*scaling),value_end*scaling),
    change_val=(value_end-value),
    change_val_lab=ifelse(!grepl("log",type_scale),
                      round(change_val),round(change_val,2)),
    change_lab=paste0(ifelse(change_val_lab<0,"","+"),
                      change_val_lab),
    change_sign=ifelse(grepl("usd",sel_var),
                      case_when(change_val_lab<0 ~ "decrease",
                                  change_val_lab>0 ~  "increase",
                                  change_val_lab==0 ~  "no change"),
                      case_when(change_val_lab<0 ~ "divergence",
                              change_val_lab>0 ~  "convergence",
                              change_val_lab==0 ~  "no change")
           )
    ) %>%
  ungroup() %>%
  select(!c(`% of World`,min_yr,year,year_end,cntr_group,region)) %>%
  mutate(scale_type=type_scale) %>%
  relocate(c(cntr_region,era,era_col,scale_type),.after=varname) %>%
  relocate(change_val,.after=value_end)

k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_yrs

if (plot_show) {
# render plot
p <- df_yrs  %>%
  ggplot(aes(y=era,yend=era,
            x=value,xend=value_end,
            group=era)) + # color=era_col,
  facet_wrap(~cntr_region,scales="free_y") +
  geom_segment(aes(color=change_sign), # alpha=0.6,
        arrow=arrow(length=unit(0.25,"cm")),linewidth=1.5) +
  geom_text(aes(x=(value+value_end)/2,label=change_lab),
              color="black",nudge_y=0.3) +
  geom_rect(aes(xmin=-Inf,xmax=Inf,ymin=era_low,ymax=era_high,
      fill=era_col), inherit.aes=F,alpha=0.2) +
  labs(x=x_lab_txt,y="",caption = caption_txt,
       title="",color="",fill="") + 
  scale_fill_manual(values=c("capitalism"="darkgreen",
    "transition"="grey","socialism"="red")) +
  theme_bw() + plot_settings + theme(legend.position="top",
    axis.text.x=element_text(angle=0))

if (!grepl("usd",sel_var) & grepl("lin",type_scale)) {
  p <- p + geom_vline(xintercept = 100,linewidth=1/3)
} 
if (!grepl("usd",sel_var) & grepl("log",type_scale)) {
  p <- p + geom_vline(xintercept = 0,linewidth=1/3)
} 

if (grepl("usd",sel_var)) {
p <- p + scale_color_manual(values=c("increase"="blue","decrease"="red",
        "no change"="black"))
} else {
p <- p + scale_color_manual(values=c("convergence"="blue","divergence"="red",
        "no change"="black"))
}


# PNG
print(p) 
}
 
folder_name <- "output/CEE_vs_centre_cumulchange/bycntr/"
 
 # SAVE as PNG
if (save_plot_flag) {
  file_name <- paste0(
    folder_name,
    ifelse(grepl("log",type_scale),"log/",""),
    "CEE_vs_",
    gsub("% of ","",sel_var),".png")
  file_name %>% ggsave(width=42,height=24,units="cm")
}

} # end of all_var loop

} # end of 'type_scale' loop  

# SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
    
})


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# GDP/CAP 1950 to 2022: cumulative change (%) only, by *country GROUP*

with(list(
  save_plot_flag=T,
  era_names=str_wrap(c("early socialism (1950-1973/75)",
           "late socialism (1973/75-1989)",
           "transition (1989-1991/92)",
            "capitalism (1992-2022)"),15),
  era_str_list="1950-1975|1973-1989|1975-1989|1989-1992|1989-1991|1992-2022|1991-2022",
  l_trans_rec_end_yr=list(
  "Baltic" = 1994,
  "Ukraine" = 1998,
  "Belarus" = 1995,
  "Russia" = 1998,
  "Poland" = 1991,
  "Slovenia" = 1992,
  "Croatia" = 1993,
  "Serbia" = 1993,
  "Bulgaria" = 1999),
  save_table=T
  ), {
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
    
    l_print <- list(); k_cntr=0
    all_var_list=c("intusd2011ppp","% of DE", paste0("% of ",names(l_groups$comp_groups)) )
    
  for (type_scale in c("lin","log") ) {
  for (sel_var in all_var_list) { # 
      
      x_pos_div <- 2.05
        
      x_lab_txt <- if (grepl("%",sel_var)) {
          paste0("GDP/capita as ",
              gsub("LAT_AM","Latin America",sel_var),
              "* (const 2011 int. USD, PPP)")
    } else {
        paste0("GDP/capita",
          ifelse(grepl("log",type_scale),"",", thousand"),
          " (const 2011 int. USD, PPP)")   }
    # if log
    if (grepl("log",type_scale)) {
            x_lab_txt <- gsub("%","proportion",paste0("log of ",x_lab_txt) )
        }
  
  caption_txt <- if (!grepl("World|usd",sel_var)) {
    paste0(ifelse(grepl("DE",sel_var),"*","*weighted average of "), 
      str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("LAT_AM",sel_var) ~ paste0(l_groups$list_cntrs$`Latin America`,collapse=", "),
    grepl("G7",sel_var) ~ paste0(l_groups$comp_groups$G7,collapse=", "),
    grepl("DE",sel_var) ~ "Germany"),width=50),
      "\nsource: https://ourworldindata.org/grapher/gdp-per-capita-maddison-project-database")
  } else {
      "source: https://ourworldindata.org/grapher/gdp-per-capita-maddison-project-database"
    }
    
  df_prev <- l_GDP_percap$gdp_per_cap_longterm_2011usd_sel_cntr %>%
    filter(year>=1950 ) %>%
    filter(region %in% "CEE" | grepl("Russia|Serbia|Ukr|Belarus",country) ) %>% # 
    filter(!grepl("Germ|W_EUR|S_EUR4|G7|World|United|LAT_AM",country)) %>%
    mutate(cntr_group=case_when(
      grepl("Eston|Lith|Latv",country) ~ "Baltics",
      grepl("Croat|Sloven|Serb",country) ~ "Yugosl.",
      grepl("Russia|Ukra|Belar",country) ~ "USSR",
      .default="CEE") ) %>%
    select(!region) %>%
    relocate(c(cntr_group),.before=country) %>%
    group_by(cntr_group) %>%
    mutate(cntr_rank=dense_rank(country))
  
  df_intermed <- df_prev %>% 
    group_by(country) %>%
    mutate(min_yr=min(year),
           trans_rec_end_yr=case_when(
    grepl("Baltic", cntr_group) ~ l_trans_rec_end_yr$Baltic,
    grepl("Ukr", country)     ~ l_trans_rec_end_yr$Ukraine,
    grepl("Belarus", country) ~ l_trans_rec_end_yr$Belarus,
    grepl("Russia", country)  ~ l_trans_rec_end_yr$Russia,
    grepl("Poland", country)  ~ l_trans_rec_end_yr$Poland,
    grepl("Sloven", country)  ~ l_trans_rec_end_yr$Slovenia,
    grepl("Croat", country)   ~ l_trans_rec_end_yr$Croatia,
    grepl("Serbia", country)  ~ l_trans_rec_end_yr$Serbia,
    grepl("Bulg", country)    ~ l_trans_rec_end_yr$Bulgaria,
             .default=1992)  ) %>%
    filter(year %in% c(
        ifelse(grepl("Yug",cntr_group),1979,1975),
        1989,2022) | year==min_yr | year==trans_rec_end_yr) %>%
    group_by(cntr_group) %>% # filter( ) %>%
    mutate(label_perc_end=ifelse( max(cntr_rank) > 1 & year==2022,
            paste0(round(!!sym(sel_var))," (",Code,")"),
            as.character(round(!!sym(sel_var))) ) ) %>%
    pivot_longer(cols=c("intusd2011ppp",all_var_list),
      names_to="varname") %>%
  arrange(country,varname, year) %>%
  group_by(varname) %>%
  mutate(year_end=lead(year), value_end=lead(value)  ) %>%
  filter(!is.na(year_end)) %>%
  ungroup() %>%
  filter(year_end>=year) %>%
  filter( grepl(sel_var,varname)  ) %>%
  mutate(era_yrs=paste0(year,"-",year_end),
         era_col=case_when(
           year<1973 ~ era_names[1],
           year>=1973 & year<1989 ~ era_names[2],
           year==1989 ~ era_names[3],
           year>1989 ~ era_names[4]),
    era_col=factor(era_col,levels=era_names)) %>%
    mutate(era_num=as.numeric(factor(era_col)),
           era_low =era_num-1/2,
           era_high=era_num+1/2) %>%
    relocate(c(year,year_end,era_yrs,era_col,varname,value,value_end),
      .after=Code) 
    
    df_yrs <- df_intermed %>%
    ungroup() %>% rowwise() %>%
  mutate(
    cntr_region=paste0(cntr_group,": ",country),
    scaling=ifelse(grepl("usd",sel_var), ifelse(grepl("log",type_scale),1,1e-3),
                ifelse(grepl("log",type_scale),1e-2,1)),
    value=ifelse(type_scale=="log",log(value*scaling),value*scaling),
    value_end=ifelse(type_scale=="log",log(value_end*scaling),value_end*scaling),
    change_val=(value_end-value),
    change_val_lab=ifelse(!grepl("log",type_scale),
                      round(change_val),round(change_val,2)),
    change_lab=paste0(Code,": ",ifelse(change_val_lab<0,"","+"),
                      change_val_lab),
    change_sign=ifelse(grepl("usd",sel_var),
                      case_when(change_val_lab<0 ~ "decrease",
                                  change_val_lab>0 ~  "increase",
                                  change_val_lab==0 ~  "no change"),
                      case_when(change_val_lab<0 ~ "divergence",
                              change_val_lab>0 ~  "convergence",
                              change_val_lab==0 ~  "no change")
           )
    ) %>%
  ungroup() %>%
  select(!c(`% of World`,min_yr,year,year_end)) %>%
  # mutate(scale_type=type_scale) %>%
  relocate(c(cntr_region,era_col),.after=varname) %>%
  relocate(change_val,.after=value_end)

# to save as csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_yrs
  
# render plot
dodge_w <- 0.9
max_val <- max(c(df_yrs$value_end,df_yrs$value),na.rm = T)
x_dodge <- ifelse(grepl("usd",sel_var),0.04,0.08)
p <- df_yrs %>%
  ggplot(aes(y=era_col, # ymin=era_col,ymax=era_col,
            xmin=value,xmax=value_end,
            group=country,
            text=paste0(round(value),"% -> ",round(value_end),"%")    )) + # color=era_col,
  facet_wrap(~cntr_group,1) + # ,scales="free_y"
  geom_linerange(aes(color=change_sign),
    position=position_dodge(width=dodge_w),linewidth=1.5,alpha=1/2) +
  geom_point(aes(x=value_end,color=change_sign),shape=5,
            position=position_dodge(width=dodge_w),size=2.5,
            show.legend=F)

if (!grepl("usd",sel_var) & grepl("lin",type_scale)) {
  p <- p + geom_vline(xintercept = 100,linewidth=1/3)
} 
if (!grepl("usd",sel_var) & grepl("log",type_scale)) {
  p <- p + geom_vline(xintercept = 0,linewidth=1/3)
} 

if (grepl("usd",sel_var)) {
p <- p + scale_color_manual(values=c("increase"="blue","decrease"="red",
        "no change"="black"))
} else {
p <- p + scale_color_manual(values=c("convergence"="blue","divergence"="red",
        "no change"="black"))
}

p <- p +
  geom_text(aes(x=(value+value_end)/x_pos_div, # , # +ifelse(grepl("usd",sel_var),0,3),
            y=era_num+0.05,label=change_lab), # hjust=0,
            size=4.5,position=position_dodge(width=dodge_w),
            color="black") +
  geom_hline(aes(yintercept=ifelse(grepl("1950",era_col),NA,era_num-1/2)),
            linewidth=3/4) +
  labs(x=x_lab_txt,y="",
    title="",caption=paste0("◇︎ symbol = value at the end of period",
              "\n",caption_txt),
       color="") + # ,fill="era"
  # scale_color_manual(values=c("catch-up"="blue","divergence"="red","no change"="black")) +
  scale_x_continuous(expand=expansion(0.12)) +
  scale_y_discrete(expand=expansion(0.01/2)) +
  theme_bw() + plot_settings + theme(
    legend.position="top",legend.box="vertical",
    axis.text.x=element_text(angle=0) )

# PNG
 print(p)
 
 folder_name <- "output/CEE_vs_centre_cumulchange/cntrgroup/"
if (save_plot_flag) {
  file_name <- paste0(
    folder_name,
    ifelse(type_scale=="log","log/",""),
    gsub("% of ","",sel_var),".png")
  file_name %>% ggsave(width=40,height=32,units="cm")
  
  # saveWidget(ggplotly(p,tooltip="text"), gsub("png","html",file_name))
} # save close

} # end of for loop for sel_var
} # end of for loop for scale
    
    # SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
  
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# log of fold-changes in LONG-TERM GDP/cap, long-term (1913-2022)

with(list(save_plot_flag=T,
    save_table=T,
    l_year_pairs=list(
        pre_1950_soc=list( 
          c(1913,1939), c(1913,1950), c(1913,1955),
          c(1926,1939), c(1926,1950), c(1926,1955) ),
        post_1950_soc=list(c(1950,1989), c(1950,1975),c(1975,1989) ),
        post_1990=list( c(1989,2022), c(1992,2022), c(1989,2008), c(2008,2022)) ),
    color_vals=c(
      "CEE"="steelblue",
      "USSR/other E Eur"="red",
      "E Asia (soc.)"="red",
      "Southern Europe"="darkorange",
      "Latin America"="darkgreen",
      "E Asia (cap.)"="black",
      "W Europe/offshoots"="green",  
      "Africa"="black",
      "South Asia"="black"),
  shape_vals=c("Russia"=15,"E Asia (soc.)"=17,"Yugoslavia"=18,
                  "CEE"=19,"E Asia (cap.)"=19,"W Europe/offshoots"=19,
                  "Latin America"=19,"Southern Europe"=19,
                  "Africa"=3,"South Asia"=9),
  # 
  l_country_region=with(list(df=read_csv("data/cntrs_region_pop_lt5m.csv")),
            split(df$Country, df$Region) )
  ) ,{
  
    
  l_print <- list(); k_cntr=0
    
  year_pair_list_order <-  lapply(l_year_pairs, function(grp) {
        sapply(grp, function(x) paste(x, collapse="-"))
          }) %>% unlist() %>% as.character()
    df1 <- lapply(names(l_groups$list_cntrs), \(x) 
            data.frame(country=l_groups$list_cntrs[[x]],region=x) ) %>% 
            bind_rows()
  df2 <- lapply(names(l_country_region), \(x) 
            data.frame(country=l_country_region[[x]],region=x) ) %>% 
            bind_rows()
  
df_regions <-  bind_rows(
  # rows from df2 (always keep)
    df2,
    # rows from df1 that are NOT in df2
    anti_join(df1,df2,by="country") )
  
    sel_cntrs_list <- paste0(as.character(unlist(l_groups$list_cntrs)), collapse="|")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
  for (pair_group_name in names(l_year_pairs)) {

  df_sel_cntr <- l_GDP_percap$gdp_per_cap_longterm_2011usd %>%
  group_by(country) %>%
  filter( (any(year==1989) && pop[year==1989] > 1e7) |  
          grepl(sel_cntrs_list,country) ) %>%
  filter(year %in% unlist(l_year_pairs) ) %>%
  filter(!country %in% c(names(l_groups$comp_groups),"USSR") ) %>%
  arrange(country,year)
  
  pairs_tbl <- enframe(l_year_pairs, 
          name="pair_group", value="pairs") %>%
          unnest_longer(pairs) %>% # each entry becomes a row
          unnest_wider(pairs,names_sep="_") %>%   # convert c(a,b) to pairs_1, pairs_2
          rename(year_start=pairs_1, year_end=pairs_2)
  
  df1 <- df_sel_cntr %>% 
      select(country, Code, year, value,pop) %>%
      rename(pop_start=pop)
  df2 <- df_sel_cntr %>% 
      select(country, Code, year, value,pop)  %>%
      rename(pop_end=pop)
  
  tbl_fold_change <- left_join(
    left_join(
      pairs_tbl, df1, 
            by=c("year_start"="year"),
            relationship="many-to-many" ) %>%
        rename(value_start=value),
    df2, by=c("country","Code","year_end"="year")) %>%
  rename(value_end=value) %>%
  arrange(country,year_start) %>%
  left_join(df_regions,by="country",relationship="many-to-many") %>%
  mutate(
    region=case_when(
          country %in% unlist(l_groups$list_cntrs$CEE) ~ "CEE",
          country %in% unlist(l_groups$list_cntrs$`Latin America`) ~ "Latin America",
          .default=region),
    shape_var=case_when(
              grepl("Russia",country) ~ country,
              grepl("E Asia \\(soc.\\)",region) ~ region,
              grepl("Serb|Croat|Sloven|Yugo",country) ~ "Yugoslavia",
              grepl("Africa",region) ~ region,
              grepl("South Asia",region) ~ region,
              .default=region),
    fold_change=value_end/value_start,
    year_pair=paste0(year_start,"-",year_end)    ) %>%
    relocate(c(region,country,Code,shape_var,year_pair),.after=pair_group) %>%
    filter(!is.na(fold_change)) %>%
    mutate(year_pair=factor(year_pair,levels=year_pair_list_order)) %>%
  filter(pair_group %in% pair_group_name )

# to save as csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- tbl_fold_change

  
p_foldchange <- tbl_fold_change %>%
ggplot(aes(x=value_end/1e3,y=fold_change,
           color=region,shape=shape_var,
           text=paste0(country,", change: ",
                      round(fold_change,1),"x, level: $",
                      round(value_end/1e3),"k "))) +
    facet_wrap(~year_pair) + # ,scales="free",shrink=F
    geom_point(size=2.5,alpha=2/3) + # size=p_size
    geom_hline(yintercept=1) +
    xlab("GDP/cap at end of period, thousand (intUSD, PPP, 2011)") + 
    ylab("end-to-start ratio of GDP/cap (intUSD, PPP, 2011)") + 
    scale_shape_manual(values=shape_vals) +
    labs(color="",shape="") +
    scale_color_manual(values=color_vals) +
    scale_x_log10(breaks=c(1e2,5e2,1e3,2e3,3e3,5e3,1e4,2e4,3e4,5e4,8e4)/1e3) +
    scale_y_log10(breaks=c(0.5,1,1.25,1.5,2,3,5,10) ) +
    guides(color=guide_legend(nrow=3,override.aes=list(shape=21,stroke=2,alpha=1)),
           shape=guide_legend(nrow=3,override.aes=list(color="black"))) +
    theme_bw() + plot_settings + theme(
      legend.position="top",legend.box="horizontal",
      legend.text=element_text(size=12),
      legend.title=element_text(size=12),
      strip.text = element_text(size=13),
      axis.text.x=element_text(angle=0,size=12),
      axis.text.y=element_text(size=12),
      axis.title.x=element_text(size=13),
      axis.title.y=element_text(size=13) ) # panel.spacing = unit(0,units = "cm")

print(p_foldchange)

folder_name <- "output/GDPpp_longterm_logratio/"
if (save_plot_flag) {
  
  file_name <- paste0(folder_name,pair_group_name,".png")
  file_name %>% ggsave(plot=p_foldchange, width=36,height=24,units="cm")
  
  # plotly
  p_plotly <- ggplotly(p_foldchange, tooltip="text") %>%
  layout(margin=list(
      l=90,r=20,   # L/Right padding
      t=5,b=5),   # top/bottom
    # grid = list(rows=NULL,columns=NULL),
    legend=list(orientation="h",
      xanchor="center",x=0.5,y=1.25) )
  
  saveWidget( p_plotly,gsub("png","html",file_name), selfcontained=T)
  
       } # save
    } # end of for loop
    
    # SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }

  } # end of with
  )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GDP/capita (worldbank) from 1990 to present
# plot change from start to end only
# all regions on one plot, color coded

with(list(
  save_plot_flag=F,
  save_table=T,
  df=l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr,
  all_vars=c("value",
                colnames(l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>% 
                ungroup() %>% select(contains("% of"))) )), {

  l_print <- list(); k_cntr=0
                  
  for (type_scale in c("linear","logratio")) {
  for (sel_var in all_vars) {
  
  comp_cntrs <- if (grepl("%",sel_var)) {
    c(names(l_groups$comp_groups),
        l_groups$comp_groups[[gsub("% of ","",sel_var)]],
        "Germany","World") } else {
      comp_cntrs <- c(names(l_groups$comp_groups),"Germany","World") }
  
    x_lab_txt <- if (grepl("%",sel_var)) {
    paste0("GDP/capita as ",
      gsub("LAT_AM","Latin America",sel_var),
      "* (2011 int. USD, PPP), change 1995 → 2024")
    
    } else {
        paste0("GDP/capita",ifelse(grepl("log",type_scale),"",", thousand"),
        " (2011 int. USD, PPP), change 1995 → 2024")
    }
  if (grepl("log",type_scale)) {
  x_lab_txt <- gsub("%","proportion",paste0("log of ",x_lab_txt) )
  }
    
  
  comp_expl_caption <- if (grepl("%",sel_var)) { 
    paste0("\n*",case_when(
      grepl("W_EUR",sel_var) ~ paste0("weighted average of ",
                                  paste0(l_groups$comp_groups$W_EUR3,collapse=", ")),
      grepl("S_EUR",sel_var) ~ paste0("weighted average of ",
                                  paste0(l_groups$comp_groups$S_EUR4,collapse=", ")),
      grepl("LAT_AM",sel_var) ~ paste0("weighted average of ",
                                      paste0(l_groups$list_cntrs$`Latin America`,collapse=", ")),
      grepl("G7",sel_var) ~ paste0("weighted average of ",
                              paste0(l_groups$comp_groups$G7,collapse=", ")),
      grepl("DE",sel_var) ~ "Germany",
      grepl("World",sel_var) ~ "World average"
      )) } else {""}
  caption_txt <- paste0("source: data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD",
    comp_expl_caption)
  
df_summary <- df %>%
  filter(!is.na(value)) %>%
  group_by(country) %>%
  summarise(
    region=unique(region),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=(!!sym(sel_var))[year==start_yr],
    end=(!!sym(sel_var))[year==end_yr],
    .groups="drop") %>%
  filter(start_yr==1990) %>%
  ungroup() %>%
  # calculate metric
  rowwise() %>%
  mutate(
  scale_for_log=ifelse(grepl("%",sel_var),100,1),
  start=ifelse(grepl("log",type_scale),log(start/scale_for_log),start),
  end=ifelse(grepl("log",type_scale),log(end/scale_for_log),end),
  scaling=ifelse(grepl("value",sel_var) & !grepl("log",type_scale),1e-3,1),
  end=scaling*end,
  start=scaling*start,
  change=end-start) %>%
  arrange(desc(change)) %>%
  filter(!country %in% comp_cntrs ) %>%
  rowwise() %>%
  mutate(
    country=factor(country, levels=unique(country)),
    label_color=ifelse(change<0,"red","black"),
    label_txt_linear=ifelse(grepl("%",sel_var),
      paste0(ifelse(change>0,"+",""),round(change),"%"),
      paste0("$",round(change),"k")),
    label_txt_log=paste0(round(change,2),""),
    label_final=ifelse(grepl("log",type_scale),label_txt_log,label_txt_linear)
    ) 
# View(df_summary)

k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_summary %>% mutate(sel_var=sel_var,scale_type=type_scale)

min_max_val_log_perc <- list(
                   min=floor(min(c(df_summary$start,df_summary$end))/0.5)*0.5,
                   max=floor(max(c(df_summary$start,df_summary$end))/1)*1 )

# render plot
arrow_plot <- df_summary %>% 
  ggplot(aes(y=country, x=start, xend=end, yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",round(change,1),"%"))) +
  geom_segment(aes(x=start, xend=end, y=country, yend=country, color=region),
    arrow=arrow(length=unit(0.3, "cm")),linewidth=1.5) + # 
  geom_text(aes(x=(start+end)/2,y=as.numeric(rev(country))+1/2,
    label=label_final),
    color=df_summary$label_color,size=4.5) + # scale_color_identity() +
  labs(x=x_lab_txt, y=NULL, color="",caption=caption_txt) + # title=title_str
  scale_y_discrete(limits=rev,expand=expansion(0.03)) +
  scale_color_manual(values=l_groups$color_vals) +
  theme_bw() + plot_settings +
  theme(axis.text.x = element_text(angle=0),legend.position="top") + 
  make_x_scale_and_vlines(sel_var=sel_var,type_scale=type_scale,
                          log_perc_vline_incr=0.5,
                            min_max_val_log_perc=min_max_val_log_perc)
print(arrow_plot)

folder_name <- "output/gdp_per_cap_1990_perc_change_level/"
if (save_plot_flag) {
  paste0(
    folder_name,
    "all_on_one/",
    ifelse(grepl("log",type_scale),"log_ratio/",""),
    gsub("% of ","",sel_var),".png") %>%
    ggsave(plot=arrow_plot, width=35,height=24,units="cm")
}

} # end of for loop for comp_group

} # end of forloop for scales
  
  # SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
  
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GDP/capita (worldbank) from 1990 to present
# plot change from start to end only
# FACETED BY REGION

with(list(df=l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr,
          all_vars=c("value",
                colnames(l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>% 
                ungroup() %>% select(contains("% of"))) ),
          save_plot_flag=F,
          save_table=T), {
  
  l_print <- list(); k_cntr=0
            
  for (type_scale in c("linear","logratio")) {
  for (sel_var in all_vars) {
  
  comp_cntrs <- if (grepl("%",sel_var)) {
    c(names(l_groups$comp_groups),
        l_groups$comp_groups[[gsub("% of ","",sel_var)]],
        "Germany","World") } else {
      comp_cntrs <- c(names(l_groups$comp_groups),"Germany","World") }
  
    x_lab_txt <- if (grepl("%",sel_var)) {
    paste0("GDP/capita as ",
      gsub("LAT_AM","Latin America",sel_var),
      "* (const 2021 int. USD, PPP), change 1990 → 2024")
    
    } else {
        paste0("GDP/capita",ifelse(grepl("log",type_scale),"",", thousand"),
        " (const 2021 int. USD, PPP), change 1990 → 2024")
    }
  if (grepl("log",type_scale)) {
  x_lab_txt <- gsub("%","proportion",paste0("log of ",x_lab_txt) )
  }
  
  comp_expl_caption <- if (grepl("%",sel_var)) { 
    paste0("\n*",str_wrap(case_when(
      grepl("W_EUR",sel_var) ~ paste0("weighted average of ",
                                  paste0(l_groups$comp_groups$W_EUR3,collapse=", ")),
      grepl("S_EUR",sel_var) ~ paste0("weighted average of ",
                                  paste0(l_groups$comp_groups$S_EUR4,collapse=", ")),
      grepl("LAT_AM",sel_var) ~ paste0("weighted average of ",
                                      paste0(l_groups$list_cntrs$`Latin America`,collapse=", ")),
      grepl("G7",sel_var) ~ paste0("weighted average of ",
                              paste0(l_groups$comp_groups$G7,collapse=", ")),
      grepl("DE",sel_var) ~ "Germany",
      grepl("World",sel_var) ~ "World average"),
      width=40) ) } else {""}
  caption_txt <- paste0(
    "source: data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD",
    comp_expl_caption)
  
  # print(comp_cntrs)
  
xx <- left_join(df,
  l_pop$pop_sel_cnts %>% rename(pop=value) ) %>%
  filter(!is.na(value)) %>%
  filter(!country %in% comp_cntrs ) %>%
  group_by(country) %>%
  summarise(
    region=unique(region),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=(!!sym(sel_var))[year==start_yr],
    end=(!!sym(sel_var))[year==end_yr],
    pop_start=unique(pop[year==start_yr]),
    pop_end=unique(pop[year==end_yr]),
    .groups="drop") %>%
  filter(start_yr==1990) %>%
  group_by(region) %>%
  mutate(
    mean_end=sum(end*pop_end/sum(pop_end)),
    mean_start=sum(start*pop_start/sum(pop_start))) %>%
  ungroup() %>%
  filter(!country %in% comp_cntrs) %>%
  # calculate metric
  rowwise() %>%
  mutate(
    scaling=ifelse(grepl("%",sel_var),1,
      ifelse(grepl("log",type_scale),1,1e-3)),
    scaling=ifelse(grepl("%",sel_var) & grepl("log",type_scale),1/100,scaling),
    start=start*scaling,
    end=end*scaling,
    change=end-start,
    log_change=log(end/start),
    mean_lin_diff=(mean_end-mean_start)*scaling,
    mean_log_diff=log(mean_end/mean_start)) %>%
  # group_by(region) %>%
  arrange(desc(if (grepl("log", type_scale)) {
    log_change} else {change}),.by_group=T) %>%
  mutate(country=str_wrap(country,width=10),
    country=factor(country, levels=country) ) %>%
  ungroup() # %>%
  # rowwise() %>%
  

# View(xx)

df_summary <- xx %>% 
  rowwise() %>%
  mutate(
    label_color=ifelse(change<0,"red","black"),
      label_txt_linear=ifelse(grepl("%",sel_var),
      paste0(ifelse(change>0,"+",""),round(change),"%"),
      paste0("$",round(change),"k")),
    label_txt_log=paste0(round(log_change,2),""),
    label_final=ifelse(grepl("log",type_scale),
              label_txt_log,label_txt_linear),
    x_text=ifelse(grepl("log",type_scale),
                (log(end)+log(start))/2,(start+end)/2), # 
    mean_start_end_lin=paste0(round(mean_start*scaling)," → ",
                        round(mean_end*scaling)),
    mean_start_end_log=paste0(round(log(mean_start*scaling),2)," → ",
                        round(log(mean_end*scaling),2)),
    mean_label_val=ifelse(grepl("log",type_scale),
              round(mean_log_diff,2),
              round(mean_lin_diff) ),
    mean_label_txt=paste0(ifelse(mean_label_val>0,"+",""),
      case_when(
            grepl("log", type_scale) ~ 
                      as.character(mean_label_val),
            grepl("lin", type_scale) & grepl("%", sel_var) ~ 
                    paste0(mean_label_val, "%"),
            grepl("lin", type_scale) & !grepl("%", sel_var) ~ 
                  paste0(mean_label_val, "k"))),
    mean_label_txt=ifelse(grepl("log",type_scale),
              paste0(mean_label_txt," (",mean_start_end_log,")"), # , " (log ratio)"
              paste0(mean_label_txt," (",mean_start_end_lin,")") ),
    region_lab=paste0(region,"\n",mean_label_txt)) %>%
  mutate(
    x_start=if (grepl("log", type_scale)) {log(start)} else {start},
    x_end= if (grepl("log", type_scale)) {log(end)} else {end} )
  
# View(df_summary)

min_max_val_log_perc <- if (grepl(type_scale,"lin")) {
  list(min=ceiling(min(c(df_summary$start,df_summary$end))/0.5)*0.5,
       max=floor(max(c(df_summary$start,df_summary$end))/0.5)*0.5)
} else {
    list(min=ceiling(min(log(c(df_summary$start,df_summary$end)))),
         max=max(c(0,floor(max(log(c(df_summary$start,df_summary$end)))))) )
  }

#save csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_summary %>% mutate(type_scale=type_scale,sel_var=sel_var)

# render plot
arrow_plot <- df_summary %>%
  ggplot(aes(x=x_start, xend=x_end, 
    y=country,yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",round(change,1),"%"))) +
  facet_wrap(~region_lab,scales="free_y") +
  geom_segment(arrow=arrow(length=unit(0.3,"cm"))) + # ,linewidth=1.5
  geom_text(aes(x=x_text,label=label_final),
    color=df_summary$label_color,size=4.5,
    vjust=-0.3) + # scale_color_identity() +
  labs(x=x_lab_txt,y=NULL,color="",caption=caption_txt) + # title=title_str
  scale_y_discrete(limits=rev,expand=expansion(0.01,3/5)) +
  theme_bw() + plot_settings +
  theme(axis.text.x = element_text(angle=0),legend.position="top")+ 
  make_x_scale_and_vlines(sel_var,type_scale,log_perc_vline_incr = 1,min_max_val_log_perc)

print(arrow_plot)

folder_name <- "output/gdp_per_cap_1990_perc_change_level/faceted/"
if (save_plot_flag) {
  paste0(
    folder_name,
    ifelse(grepl("log",type_scale),"log_ratio/",""),
    gsub("% of ","",sel_var),".png") %>%
    ggsave(plot=arrow_plot, width=35,height=24,units="cm")
}

} # end of for loop for comp_group

} # end of forloop for scales
  
  # SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
  
})


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GNI/capita (worldbank) from 1990 to present
# plot change from start to end only
# FACETED BY REGION

with(list(df=l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr,
          all_vars=c("value",
                colnames(l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr %>% 
                ungroup() %>% select(contains("% of"))) ),
          save_plot_flag=F,
          save_table=T), {
  
  l_print <- list(); k_cntr=0
            
  for (type_scale in c("linear","logratio") ) {
  for (sel_var in all_vars ) {
  
    print(sel_var)
  comp_cntrs <- if (grepl("%",sel_var)) {
    c(names(l_groups$comp_groups),
        l_groups$comp_groups[[gsub("% of ","",sel_var)]],
        "Germany","World") } else {
      comp_cntrs <- c(names(l_groups$comp_groups),"Germany","World") }
  
    x_lab_txt <- if (grepl("%",sel_var)) {
    paste0("GNI/capita as ",
      gsub("LAT_AM","Latin America",sel_var),
      "* (const 2021 int. USD, PPP), change 1990 → 2023")
    
    } else {
        paste0("GNI/capita",ifelse(grepl("log",type_scale),"",", thousand"),
        " (const 2021 int. USD, PPP), change 1990 → 2023")
    }
  if (grepl("log",type_scale)) {
  x_lab_txt <- gsub("%","proportion",paste0("log of ",x_lab_txt) )
  }
  
  comp_expl_caption <- if (grepl("%",sel_var)) { 
    paste0("\n*",str_wrap(case_when(
      grepl("W_EUR",sel_var) ~ paste0("weighted average of ",
                  paste0(l_groups$comp_groups$W_EUR3,collapse=", ")),
      grepl("S_EUR",sel_var) ~ paste0("weighted average of ",
                    paste0(l_groups$comp_groups$S_EUR4,collapse=", ")),
      grepl("LAT_AM",sel_var) ~ paste0("weighted average of ",
                      paste0(l_groups$list_cntrs$`Latin America`,collapse=", ")),
      grepl("G7",sel_var) ~ paste0("weighted average of ",
                    paste0(l_groups$comp_groups$G7,collapse=", ")),
      grepl("DE",sel_var) ~ "Germany",
      grepl("World",sel_var) ~ "World average"),
      width=40) ) } else {""}
  caption_txt <- paste0(
    "source: data.worldbank.org/indicator/NY.GNI.PCAP.PP.KD",
    comp_expl_caption)
  
  # print(comp_cntrs)
  
  df_start <- left_join(df ,
  l_pop$pop_sel_cnts %>% rename(pop=value) ) %>%
  filter(!country %in% comp_cntrs ) %>%
  filter(!is.na(value) & !is.na(pop)) %>%
  group_by(country) %>%
  summarise(
    region=unique(region),
    start_yr=min(year[!is.na(value)],na.rm=T),
    end_yr=max(year[!is.na(value) & !is.na(pop) ]),
    start=(!!sym(sel_var))[year==start_yr],
    end=(!!sym(sel_var))[year==end_yr],
    pop_start=unique(pop[year==start_yr]),
    pop_end=unique(pop[year==end_yr]),
    .groups="drop")
  
  # View(df_start)
  
xx <- df_start %>%
  # filter(start_yr==1990) %>%
  group_by(region) %>%
  mutate(
    mean_start=sum(start*pop_start/sum(pop_start,na.rm=T)),
    mean_end=sum(end*pop_end/sum(pop_end,na.rm=T))
    ) %>%
  ungroup() %>%
  filter(!country %in% comp_cntrs) %>%
  # calculate metric
  rowwise() %>%
  mutate(
    scaling=ifelse(grepl("%",sel_var),1,
      ifelse(grepl("log",type_scale),1,1e-3)),
    scaling=ifelse(grepl("%",sel_var) & grepl("log",type_scale),1/100,scaling),
    start=start*scaling,
    end=end*scaling,
    change=end-start,
    log_change=log(end/start),
    mean_lin_diff=(mean_end-mean_start)*scaling,
    mean_log_diff=log(mean_end/mean_start)) %>%
  # group_by(region) %>%
  arrange(desc(if (grepl("log", type_scale)) {
    log_change} else {change}),.by_group=T) %>%
  mutate(country=str_wrap(country,width=10),
    country=factor(country, levels=country) ) %>%
  ungroup() # %>%
  # rowwise() %>%
  
# View(xx)

df_summary <- xx %>% 
  rowwise() %>%
  mutate(
    label_color=ifelse(change<0,"red","black"),
      label_txt_linear=ifelse(grepl("%",sel_var),
      paste0(ifelse(change>0,"+",""),round(change),"%"),
      paste0("$",round(change),"k")),
    label_txt_log=paste0(round(log_change,2),""),
    label_final=ifelse(grepl("log",type_scale),
              label_txt_log,label_txt_linear),
    x_text=ifelse(grepl("log",type_scale),
                (log(end)+log(start))/2,(start+end)/2), # 
    mean_start_end_lin=paste0(round(mean_start*scaling)," → ",
                        round(mean_end*scaling)),
    mean_start_end_log=paste0(round(log(mean_start*scaling),2)," → ",
                        round(log(mean_end*scaling),2)),
    mean_label_val=ifelse(grepl("log",type_scale),
              round(mean_log_diff,2),
              round(mean_lin_diff) ),
    mean_label_txt=paste0(ifelse(mean_label_val>0,"+",""),
      case_when(
            grepl("log", type_scale) ~ 
                      as.character(mean_label_val),
            grepl("lin", type_scale) & grepl("%", sel_var) ~ 
                    paste0(mean_label_val, "%"),
            grepl("lin", type_scale) & !grepl("%", sel_var) ~ 
                  paste0(mean_label_val, "k"))),
    mean_label_txt=ifelse(grepl("log",type_scale),
              paste0(mean_label_txt," (",mean_start_end_log,")"), # , " (log ratio)"
              paste0(mean_label_txt," (",mean_start_end_lin,")") ),
    region_lab=paste0(region,"\n",mean_label_txt)) %>%
  mutate(
    x_start=if (grepl("log", type_scale)) {log(start)} else {start},
    x_end= if (grepl("log", type_scale)) {log(end)} else {end} )
  
# View(df_summary)

min_max_val_log_perc <- if (grepl(type_scale,"lin")) {
  list(min=ceiling(min(c(df_summary$start,df_summary$end))/0.5)*0.5,
       max=floor(max(c(df_summary$start,df_summary$end))/0.5)*0.5)
} else {
    list(min=ceiling(min(log(c(df_summary$start,df_summary$end)))),
         max=max(c(0,floor(max(log(c(df_summary$start,df_summary$end)))))) )
  }

#save csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_summary %>% mutate(type_scale=type_scale,sel_var=sel_var)

# render plot
arrow_plot <- df_summary %>%
  ggplot(aes(x=x_start, xend=x_end, 
    y=country,yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",round(change,1),"%"))) +
  facet_wrap(~region_lab,scales="free_y") +
  geom_segment(arrow=arrow(length=unit(0.3,"cm"))) + # ,linewidth=1.5
  geom_text(aes(x=x_text,label=label_final),
    color=df_summary$label_color,size=4.5,
    vjust=-0.3) + # scale_color_identity() +
  labs(x=x_lab_txt,y=NULL,color="",caption=caption_txt) + # title=title_str
  scale_y_discrete(limits=rev,expand=expansion(0.01,3/5)) +
  theme_bw() + plot_settings +
  theme(axis.text.x = element_text(angle=0),legend.position="top")+ 
  make_x_scale_and_vlines(sel_var,type_scale,log_perc_vline_incr = 1,min_max_val_log_perc)

print(arrow_plot)

folder_name <- "output/GNI_per_cap_1990_perc_change_level/faceted/"
if (save_plot_flag) {
  paste0(
    folder_name,
    ifelse(grepl("log",type_scale),"log_ratio/",""),
    gsub("% of ","",sel_var),".png") %>%
    ggsave(plot=arrow_plot, width=35,height=24,units="cm")
}

} # end of for loop for comp_group

} # end of forloop for scales
  
  # SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
  
})



### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# GNI per capita cumul change and growth rate (figure not in the article)

if (F) {
  with(list(sel_cntrs=c(
  "China","Malaysia","South Korea",
  "Czechia","Poland","Romania",
  "Argentina","Brazil","Mexico",
  "Algeria","Egypt","South Africa")), { # ,"Lithuania"

df_plot <- l_gni_percap$GNI_per_cap_2021intUSD %>% # [,1:5]
  filter(grepl(paste0(sel_cntrs,collapse="|"),country) ) %>%
   group_by(country) %>%               # do calculations within country
  mutate(
    value_change_abs=value-lag(value),
    value_change_pct = (value/lag(value)-1)*100,
    value_change_pct_roll = rollmean(value_change_pct,
      k=5,fill=NA,align="right") ) %>%
  ungroup() %>%   # filter(year>=1993) 
  mutate(country=factor(country,levels=sel_cntrs))
# View(df_plot)

df_summ <- df_plot %>% 
  filter(year %in% c(1990,2023)) %>%
  group_by(country) %>%
  summarise(
    startval=value[year==1990],
    endval=value[year==2023],
    diff=endval-startval,
    ratio=endval/startval) %>%
  ungroup() %>%
  mutate(str=paste0(
    # round(startval/1e3,1),"k→",
    # round(endval/1e3,1), "k (+",
    "+",round(diff/1e3,1),"k usd, ",
    round(ratio,1),"x" ))
# View(df_summ)

df_plot %>%
ggplot(aes(x=value/1e3,group=country,color=year)) + # ,color=country
  facet_wrap(~country,ncol=3) + # , scale="free_x"
  geom_path(aes(y=value_change_pct_roll,linewidth=year),alpha=2/3) +
  # geom_path(aes(y=value_change_pct),linewidth=1/4,linetype = "dashed") + 
  geom_point(aes(y=value_change_pct),alpha=1/3,size=2) +
  geom_text(data=df_summ,aes(x=startval/1e3,label=str),hjust=0,
    y=15,inherit.aes=F) +
  geom_vline(data=. %>% filter(year %in% c(1990,2023)),
    aes(xintercept=value/1e3),linewidth=1/4,linetype="dashed",show.legend=F) +
  # scale_x_log10(breaks=c(1e3,2e3,3e3,5e3,1e4,2e4,3e4,4e4,5e4)) + 
  scale_y_continuous(limits=c(-2,NA)) + # breaks = -5:10*2
  scale_linewidth_continuous(range=c(0.3,2)) +
  # geom_hline(yintercept = 0,linewidth=1/4) +
  labs(x="GNI per capita (thousand constant 2021 USD, PPP)",y="% annual change",
    color="",linewidth="5-yr rolling average growth rate",
    caption="dashed vertical lines show GNI/cap level in 1990 and 2023") +
  guides(colour = guide_colorbar(barwidth=20,barheight=0.6)) +
  ggtitle("GNI per capita trends, 1990-2023") +
  theme_bw() + plot_settings +
  theme(axis.text.x=element_text(angle=0),
    legend.position="top",legend.title = element_text(size = 17))
# save
ggsave("output/GNI_per_cap_1990_perc_change_level/change_growth_rate.png", 
  width=35,height=24,units="cm")

}
)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# 1990 to 2024 change only (scatterplot), compared to ...
# GDP/cap vs GNI/cap

with(list(df_gni=l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr,
          df_gdp=l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr,
          save_plot_flag=T,
          save_table=F), {

all_vars <- c("value",
    colnames(l_gni_percap$GNI_per_cap_2021intUSD_sel_cntr %>% 
    ungroup() %>% select(contains("% of"))))

l_print <- list(); k_cntr=0

# create dataframes            
for (type_scale in c("lin","log")) {
for (sel_var in all_vars) { # [length(all_vars)-1]

  log_str <- ifelse(grepl("log",type_scale),"log of ","")
  xlab_str <- paste0("change in ", log_str,"GNI/cap, ",
                  sel_var, ifelse(grepl("value",sel_var),"","*"),
                  " (internat USD 2021, PPP)")
  ylab_str <- paste0("change in ", log_str, "GDP/cap, ",
                  sel_var,ifelse(grepl("value",sel_var),"","*"),
                  " (USD 2021, PPP)")
  if (grepl("log",type_scale)) {
    xlab_str <- gsub("%","as a proportion",xlab_str)
    ylab_str <- gsub("%","as a proportion",ylab_str)
  }
  
  if (grepl("value",sel_var)) {
    xlab_str <- gsub(" value", " thousand $",xlab_str)
    ylab_str <- gsub(" value", " thousand $",ylab_str)
  }
    
  w_aver_str <- "weighted average of "
  comp_expl_caption <- if (grepl("%",sel_var)) { 
    paste0("*",
      str_wrap(case_when(
      grepl("W_EUR",sel_var) ~ paste0(w_aver_str,
                                  paste0(l_groups$comp_groups$W_EUR3,collapse=", ")),
      grepl("S_EUR",sel_var) ~ paste0(w_aver_str,
                                  paste0(l_groups$comp_groups$S_EUR4,collapse=", ")),
      grepl("LAT_AM",sel_var) ~ paste0(w_aver_str,
                                      paste0(l_groups$list_cntrs$`Latin America`,collapse=", ")),
      grepl("G7",sel_var) ~ paste0(w_aver_str,
                              paste0(l_groups$comp_groups$G7,collapse=", ")),
      grepl("DE",sel_var) ~ "Germany",
      grepl("World",sel_var) ~ "World average"
      ),width = 50)) } else {""}
  

df_gni_summary <- df_gni %>%
  filter(!is.na(value)) %>%
  group_by(country) %>%
  summarise(
    region=unique(region),
    start_yr=min(year,na.rm=T),
    end_yr_gni=max(year,na.rm=T),
    start=(!!sym(sel_var))[year == start_yr],
    end=(!!sym(sel_var))[year == end_yr_gni],
    .groups="drop") %>%
  filter(start_yr==1990) %>%
  ungroup() %>% rowwise() %>%
  mutate(change_gni=ifelse(grepl("log",type_scale),
              log(end)-log(start),end-start),
        log_ratio_gni=log(end/start) ) %>%
  arrange(desc(change_gni)) %>%
  select(country,region, start_yr,end_yr_gni,start,end,change_gni) %>%
  rename(start_gni=start,end_gni=end)
# View(df_gni_summary)

# gdp
df_gdp_summary <- df_gdp %>%
  filter(!is.na(value)) %>%
  group_by(country) %>%
  summarise(
    region=unique(region),
    start_yr=min(year,na.rm=T),
    end_yr_gdp=max(year,na.rm=T),
    start=(!!sym(sel_var))[year==start_yr],
    end=(!!sym(sel_var))[year==end_yr_gdp],
    .groups="drop") %>%
  filter(start_yr==1990) %>%
  ungroup() %>% rowwise() %>%
  mutate(change_gdp=ifelse(grepl("log",type_scale),
            log(end)-log(start),end-start)  ) %>%
  arrange(desc(change_gdp)) %>%
  select(country,region, start_yr,end_yr_gdp,start,end,change_gdp) %>%
  rename(start_gdp=start,end_gdp=end)

if (grepl("lin",type_scale)) {
  scale_fact <- ifelse(grepl("%",sel_var),1,1/1e3) } else {
  scale_fact <- 1
}

# render plot
combined_gni_gdp <- left_join(
          df_gni_summary,
          df_gdp_summary) %>%
  filter(!country %in% c(names(l_groups$comp_groups),"World","Germany")) %>%
  # dont compare selected group to itself
  filter(!country %in% l_groups$comp_groups[[gsub("% of ","",sel_var)]] ) %>%
  group_by(region) %>%
  mutate(color_cntr=factor(as.numeric(factor(country)))) %>%
  rowwise() %>%
  # mutate() %>%
  left_join(l_pop$total_pop %>% 
              filter(country %in% unique(df_gni_summary$country) ) %>%
              group_by(country) %>%
              filter(year %in% max(year)) %>% 
              rename(pop=value) %>% select(country,pop) ) %>%
  mutate(change_gni=change_gni*scale_fact,
        change_gdp=change_gdp*scale_fact) %>%
  ungroup() %>% 
  rowwise() %>%
  mutate(
    text_str_lin=paste0(country,
             ", ΔGNI/cap: ",round(change_gni),
              ifelse(grepl("%",sel_var),"%","k"),
            ", ΔGDP/cap: ",round(change_gdp),
              ifelse(grepl("%",sel_var),"%","k") ),
    text_str_log=paste0(country,
             ", logratio(GNI/cap): ",round(change_gni,1),
            ", logratio(GDP/cap): ",round(change_gdp,1) ),
    text_str=ifelse(grepl("lin",type_scale),
              text_str_lin,text_str_log) )

# View(combined_gni_gdp)

# means
df_means <- left_join(
  combined_gni_gdp,
  l_pop$total_pop %>% rename(pop=value) ) %>%
  group_by(region) %>%
  summarise(
    change_gdp=sum(change_gdp*pop/sum(pop),na.rm=T),
    change_gni=sum(change_gni*pop/sum(pop),na.rm=T),
    start_gni=sum(start_gni*pop/sum(pop),na.rm=T),
    end_gni=sum(end_gni*pop/sum(pop),na.rm=T),
    log_ratio_gni=log(end_gni/start_gni),
    start_gdp=sum(start_gdp*pop/sum(pop),na.rm=T),
    end_gdp=sum(end_gdp*pop/sum(pop),na.rm=T),
    log_ratio_gdp=log(end_gdp/start_gdp) ) %>%
  rowwise() %>%
  mutate(change_gni=ifelse(grepl("lin",type_scale),
                change_gni,log_ratio_gni),
        change_gdp=ifelse(grepl("lin",type_scale),
                change_gdp,log_ratio_gdp) ) %>%
  mutate(means_str_lin=paste0("weighted average (○):\n",
                  "ΔGNI/cap: ",ifelse(change_gni>0,"+",""),
                    round(change_gni),
                    ifelse(grepl("%",sel_var),"%","k"), "\n",
                  "ΔGDP/cap: ",
                   ifelse(change_gdp>0,"+",""),
                      round(change_gdp),
                    ifelse(grepl("%",sel_var),"%","k")  ),
        means_str_log=paste0("weighted average (○):\n",
                  "logratio(GNI/cap): ",
                  ifelse(change_gni>0,"+",""),
                    round(change_gni,1), "\n",
                  "logratio(GDP/cap): ",
                   ifelse(change_gdp>0,"+",""),
                      round(change_gdp,1)  )
    ) %>%
  rowwise() %>%
  mutate(means_str=ifelse(grepl("lin",type_scale),means_str_lin,means_str_log)  ) 

# View(df_means)

# captions
caption_str=paste0(comp_expl_caption,"\n",
  "source: ourworldindata.org/grapher/gross-national-income-per-capita-undp","\n",
  "data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD") 

if (grepl("lin",type_scale)) {
  rect_coord <- list(xmin=-10,xmax=10,ymin=-10,ymax=10) } else {
  rect_coord <- list(xmin=-1,xmax=1,ymin=-1,ymax=1)
}

k_cntr <- k_cntr+1
l_print[[k_cntr]] <- combined_gni_gdp %>% 
  mutate(type_scale=type_scale,sel_var=sel_var)

# render plot
p_comb <- combined_gni_gdp  %>%
ggplot(aes(x=change_gni,y=change_gdp)) + 
  facet_wrap(~region) +
  geom_point(aes(color=color_cntr,text=text_str),
        alpha=2/3,size=2,show.legend=F) + # size=3, size=pop
  geom_point(data=df_means,color="black", # fill="black",
        size=3,shape=21,stroke=2/3,
        show.legend=F) +
  geom_abline(linewidth=1/2,color="grey") +
  geom_vline(xintercept=0,color="grey") + 
  geom_hline(yintercept=0,color="grey") +
  geom_text(data=df_means, aes(label=means_str,
      x=min(change_gni),
      y=max(change_gdp)*ifelse(grepl("World",sel_var),1.01,1.15)),
      hjust=0,nudge_x=ifelse(grepl("log",type_scale),0.55,
                  ifelse(grepl("World|LAT",sel_var),24,4) ),
    size=3.25) +
  # geom_rect(xmin=rect_coord$xmin,xmax=rect_coord$xmax,
  #                 ymin=rect_coord$ymin,ymax=rect_coord$ymax,
  #         fill=NA,color="black",linetype="dashed") + 
  labs(x=xlab_str,y=ylab_str, color="",
      caption=caption_str) + # ,title=title_str
  theme_bw() + plot_settings +
  theme(axis.text.x=element_text(size=11,angle=0),
        axis.text.y=element_text(size=11),
        axis.title.x=element_text(size=13),
        axis.title.y=element_text(size=13))

if (grepl("log",type_scale)) {
  p_comb <- p_comb + 
    scale_x_continuous(breaks=seq(-2,2,0.5)) +
    scale_y_continuous(breaks=seq(-2,2,0.5))
} else {
  if (grepl("World|LAT",sel_var)) {
  p_comb <- p_comb + 
    scale_x_continuous(breaks=seq(-300,300,50)) +
    scale_y_continuous(breaks=seq(-300,300,50))  
  }  else {
  p_comb <- p_comb + 
    scale_x_continuous(breaks=seq(-100,100,10)) +
    scale_y_continuous(breaks=seq(-100,100,10))
  }
}

print(p_comb)
# PNG
  folder_name <- "output/gni_gdp_change_scatter/"
  if (save_plot_flag) {
  filename <- paste0(folder_name,
    ifelse(grepl("log",type_scale),"log/",""),
    gsub("% of ","",sel_var), ".png")
  print(filename)
  filename %>% ggsave(width=30,height=24,units="cm")
    
    saveWidget(
    ggplotly(p_comb,tooltip="text") %>% layout(
    showlegend=F, 
    xaxis = list(automargin=F,title = list(standoff = 200)),
    margin = list( l=60,r=50,b=60,t=50)  ),
           gsub(".png",".html",filename))
  }

} # end of for loop for sel_var
} # end of for loop for type_scale

    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }

}) # end of with

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# productivity (output per employee OR hour of work)
# 2 productivity data sources: OECD, OWID
# per-hour-of-work: OWID always has more data
# per-person-employed: before 1990 OECD has data for western cnts, 
# after 1990, same data availability
# PER PERSON EMPLOYED
with(list(df=l_product$owid$`per person`,
          all_vars=c("value",
                colnames(l_product$owid$`per person` %>% 
                ungroup() %>% select(contains("% of"))) ),
          save_plot_flag=T,
          save_table=T), {
  
  l_print <- list(); k_cntr=0
            
  for (type_scale in c("linear","logratio") ) {
  for (sel_var in all_vars) {
  
  comp_cntrs <- if (grepl("%",sel_var)) {
    c(names(l_groups$comp_groups),
        l_groups$comp_groups[[gsub("% of ","",sel_var)]],
        "Germany") # ,"World"
    } else {
      comp_cntrs <- c(names(l_groups$comp_groups),"Germany") # ,"World"
      }
  
  x_lab_txt <- if (grepl("%",sel_var)) {
    paste0("GDP per person employed as ",
      gsub("LAT_AM","Latin America",sel_var),
      "* (constant 2020 USD, PPP), change 1991 → 2024")
    } else {
        paste0("GDP per person employed",ifelse(grepl("log",type_scale),"",", thousand"),
        " (constant 2020 USD, PPP), change 1991 → 2024")
    }
  x_lab_txt <- paste0(ifelse(grepl("log",type_scale),"log of ",""),x_lab_txt)
  
  w_aver_string <- "weighted average of "
  comp_expl_caption <- if (grepl("%",sel_var)) { 
    paste0("\n*",str_wrap(case_when(
      grepl("W_EUR",sel_var) ~ paste0(w_aver_string,
                                  paste0(l_groups$comp_groups$W_EUR3,collapse=", ")),
      grepl("S_EUR",sel_var) ~ paste0(w_aver_string,
                                  paste0(l_groups$comp_groups$S_EUR4,collapse=", ")),
      grepl("LAT_AM",sel_var) ~ paste0(w_aver_string,
                                  paste0(l_groups$list_cntrs$`Latin America`,collapse=", ")),
      grepl("G7",sel_var) ~ paste0(w_aver_string,
                              paste0(l_groups$comp_groups$G7,collapse=", ")),
      grepl("DE",sel_var) ~ "Germany"),width=50) )
    } else {""}
  caption_txt <- paste0(
    "source: ourworldindata.org/grapher/gdp-per-person-employed-constant-ppp",
    comp_expl_caption)
  
df_summary <- left_join(df,
  l_pop$pop_sel_cnts %>% rename(pop=value) ) %>%
  filter(!is.na(value)) %>%
  filter(!country %in% comp_cntrs ) %>%
  group_by(country) %>%
  summarise(
    region=unique(region),
    start_yr=min(year,na.rm=T),
    end_yr=max(year,na.rm=T),
    start=(!!sym(sel_var))[year==start_yr],
    end=(!!sym(sel_var))[year==end_yr],
    pop_start=unique(pop[year==start_yr]),
    pop_end=unique(pop[year==end_yr]),
    .groups="drop") %>%
  filter(start_yr<=1995) %>%
  group_by(region) %>%
  mutate(
    mean_end=sum(end*pop_end/sum(pop_end)),
    mean_start=sum(start*pop_start/sum(pop_start))) %>%
  ungroup() %>%
  # calculate metric
  rowwise() %>%
  mutate(
    scaling=ifelse(grepl("%",sel_var),1,
      ifelse(grepl("log",type_scale),1,1e-3)),
    scaling=ifelse(grepl("%",sel_var) & grepl("log",type_scale),1/100,scaling),
    start=start*scaling,
    end=end*scaling,
    change=end-start,
    log_change=log(end/start),
    mean_lin_diff=(mean_end-mean_start)*scaling,
    mean_log_diff=log(mean_end/mean_start)) %>%
  # group_by(region) %>%
  arrange(desc(if (grepl("log", type_scale)) {log_change} else {change}),.by_group=T) %>%
  mutate(country=str_wrap(country,width=10),
    country=factor(country, levels=country)
      # str_wrap(factor(country, levels=country),width=10)
    ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(
    label_color=ifelse(change<0,"red","black"),
      label_txt_linear=ifelse(grepl("%",sel_var),
      		paste0(ifelse(change>0,"+",""),round(change),"%"),
      		paste0("$",round(change),"k")),
    label_txt_log=paste0(round(log_change,2),""),
    label_final=ifelse(grepl("log",type_scale),
              label_txt_log,label_txt_linear),
    x_text=ifelse(grepl("log",type_scale),
                (log(end)+log(start))/2,(start+end)/2), # 
    mean_start_end_lin=paste0(round(mean_start*scaling)," → ",
                        round(mean_end*scaling)),
    mean_start_end_log=paste0(round(log(mean_start*scaling),2)," → ",
                        round(log(mean_end*scaling),2)),
    mean_label_val=ifelse(grepl("log",type_scale),
              round(mean_log_diff,2),
              round(mean_lin_diff) ),
    mean_label_txt=paste0(ifelse(mean_label_val>0,"+",""),
      case_when(
            grepl("log", type_scale) ~ 
                      as.character(mean_label_val),
            grepl("lin", type_scale) & grepl("%", sel_var) ~ 
                    paste0(mean_label_val, "%"),
            grepl("lin", type_scale) & !grepl("%", sel_var) ~ 
                  paste0(mean_label_val, "k"))),
    mean_label_txt=ifelse(grepl("log",type_scale),
              paste0(mean_label_txt," (",mean_start_end_log,")"),
              paste0(mean_label_txt," (",mean_start_end_lin,")") ),
    region_lab=paste0(region,ifelse(grepl("log",type_scale),"\n","\n "),mean_label_txt),
    period_lab_T_F=!(start_yr==1991 & end_yr==2024),
    period_lab=ifelse(period_lab_T_F,paste0("(",start_yr,"-",end_yr,")"),"")
    ) %>% 
  mutate(
    x_start=if (grepl("log", type_scale)) {log(start)} else {start},
    x_end= if (grepl("log", type_scale)) {log(end)} else {end} )
  
# View(df_summary)

min_max_val_log_perc <- if (grepl(type_scale,"lin")) {
  list(min=ceiling(min(c(df_summary$start,df_summary$end))/0.5)*0.5,
       max=floor(max(c(df_summary$start,df_summary$end))/0.5)*0.5 ) 
} else {
    list(min=ceiling(min(log(c(df_summary$start,df_summary$end)))/1)*1,
       max=floor(max(log(c(df_summary$start,df_summary$end)))/1)*1 ) 
  }

# for csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_summary %>% mutate(type_scale=type_scale,sel_var=sel_var)

# View(df_summary)
# render plot
arrow_plot <- df_summary %>%
  ggplot(aes(x=x_start, xend=x_end, 
    y=country,yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",
                round(change,1),"%"))) +
  facet_wrap(~region_lab,scales="free_y") +
  geom_segment(arrow=arrow(length=unit(0.3,"cm"))) + # ,linewidth=1.5
  geom_text(aes(x=x_text,label=label_final),
    color=df_summary$label_color,size=4.5,vjust=-0.3) + 
  geom_text(data = . %>% filter(period_lab_T_F), 
          aes(x=x_text,label=period_lab),size=3,vjust=1.4) +
  labs(x=x_lab_txt,y=NULL,color="",caption=caption_txt) + # title=title_str
  scale_y_discrete(limits=rev,expand=expansion(0.01,3/5)) +
  theme_bw() + plot_settings +
  theme(axis.text.x=element_text(angle=0),legend.position="top")+ 
  make_x_scale_and_vlines(sel_var, type_scale, 
    log_perc_vline_incr=1, min_max_val_log_perc)

print(arrow_plot)

folder_name <- "output/lab_prod/gdp_per_pers_empl_change_level/"
if (save_plot_flag) {
  paste0(
    folder_name,
    ifelse(grepl("log",type_scale),"log_ratio/",""),
    gsub("% of ","",sel_var),".png") %>%
    ggsave(plot=arrow_plot, width=35,height=24,units="cm")
}

} # end of for loop for comp_group

} # end of forloop for scales
  
# SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
            
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# per hour worked

with(list(df=l_product$owid$`per hour of work`,
          all_vars=c("value",
                colnames(l_product$owid$`per person` %>% 
                ungroup() %>% select(contains("% of"))) ),
          save_plot_flag=T,
          save_table=T), {
  
  for (start_yr_val in c(1995,2005)) {
    l_print <- list(); k_cntr=0
  for (type_scale in c("linear","logratio")) {
  for (sel_var in all_vars) {
  
  comp_cntrs <- if (grepl("%",sel_var)) {
    c(names(l_groups$comp_groups),
        l_groups$comp_groups[[gsub("% of ","",sel_var)]],"Germany")
    } else {
      comp_cntrs <- c(names(l_groups$comp_groups),"Germany")
      }
  
  x_lab_txt <- if (grepl("%",sel_var)) {
    paste0("GDP per hour worked as ",
      gsub("LAT_AM","Latin America",sel_var),
      "* (constant 2020 USD, PPP), change ",start_yr_val, " → 2023")
    } else {
        paste0("GDP per hour worked",
        ", $ (constant 2020 USD, PPP), change ",start_yr_val, " → 2023")
    }
  x_lab_txt <- paste0(ifelse(grepl("log",type_scale),"log of ",""),x_lab_txt)
  
  w_aver_string <- "weighted average of "
  comp_expl_caption <- if (grepl("%",sel_var)) { 
    paste0("\n*", str_wrap(case_when(
      grepl("W_EUR",sel_var) ~ paste0(w_aver_string,
                                  paste0(l_groups$comp_groups$W_EUR3,collapse=", ")),
      grepl("S_EUR",sel_var) ~ paste0(w_aver_string,
                                  paste0(l_groups$comp_groups$S_EUR4,collapse=", ")),
      grepl("LAT_AM",sel_var) ~ paste0(w_aver_string,
                                      paste0(l_groups$list_cntrs$`Latin America`,collapse=", ")),
      grepl("G7",sel_var) ~ paste0(w_aver_string,
                              paste0(l_groups$comp_groups$G7,collapse=", ")),
      grepl("DE",sel_var) ~ "Germany"),width=50) ) 
    } else {""}
  caption_txt <- paste0(
    "source: ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable",
    comp_expl_caption)
  
df_summary <- left_join(df,
  l_pop$pop_sel_cnts %>% rename(pop=value) ) %>%
  filter(!is.na(value)) %>%
  filter(!country %in% comp_cntrs ) %>%
  group_by(country) %>%
  filter(min(year) <= start_yr_val) %>%
  summarise(
    region=unique(region),
    start_yr=min(year[year>=start_yr_val],na.rm=T),
    end_yr=max(year,na.rm=T),
    start=(!!sym(sel_var))[year==start_yr],
    end=(!!sym(sel_var))[year==end_yr],
    pop_start=unique(pop[year==start_yr]),
    pop_end=unique(pop[year==end_yr]),
    .groups="drop") %>%
  group_by(region) %>%
  mutate(
    mean_end=sum(end*pop_end/sum(pop_end)),
    mean_start=sum(start*pop_start/sum(pop_start))) %>%
  ungroup() %>%
  # calculate metric
  rowwise() %>%
  mutate(
    scale_flag=grepl("%",sel_var) & grepl("log",type_scale),
    scaling=ifelse(scale_flag,1/100,1),
    start=start*scaling,
    end=end*scaling,
    change=end-start,
    log_change=log(end/start),
    mean_lin_diff=(mean_end-mean_start)*scaling,
    mean_log_diff=log(mean_end/mean_start)) %>%
  arrange(desc(if (grepl("log", type_scale)) {log_change} else {change}),.by_group=T) %>%
  mutate(country=str_wrap(country,width=10),
    country=factor(country, levels=country)
      # str_wrap(factor(country, levels=country),width=10)
    ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(
    label_color=ifelse(change<0,"red","black"),
    label_txt_linear=ifelse(grepl("%",sel_var),
      paste0(ifelse(change>0,"+",""), round(change),"%"),
      paste0("$",round(change)) ),
    label_txt_log=paste0(round(log_change,2),""),
    label_final=ifelse(grepl("log",type_scale),
              label_txt_log,label_txt_linear),
    x_text=ifelse(grepl("log",type_scale),(log(end)+log(start))/2,(start+end)/2), # 
    mean_start_end_lin=paste0(round(mean_start*scaling)," → ",
                        round(mean_end*scaling)),
    mean_start_end_log=paste0(round(log(mean_start*scaling),2)," → ",
                        round(log(mean_end*scaling),2)),
    mean_label_val=ifelse(grepl("log",type_scale),
              round(mean_log_diff,2),
              round(mean_lin_diff) ),
    	mean_label_txt=paste0(ifelse(mean_label_val>0,"+",""),
      case_when(
            grepl("log", type_scale) ~ 
                      as.character(mean_label_val),
            grepl("lin", type_scale) & grepl("%", sel_var) ~ 
                    paste0(mean_label_val, "%"),
            grepl("lin", type_scale) & !grepl("%", sel_var) ~ 
                  paste0(mean_label_val))),
    mean_label_txt=ifelse(grepl("log",type_scale),
              paste0(mean_label_txt," (",mean_start_end_log,")"), # , " (log ratio)"
              paste0(mean_label_txt," (",mean_start_end_lin,")") ),
    region_lab=paste0(region,ifelse(grepl("log",type_scale),"\n","\n"),mean_label_txt),
    period_lab_T_F=!(start_yr==start_yr_val & end_yr==2023),
    period_lab=ifelse(period_lab_T_F,paste0("(",start_yr,"-",end_yr,")"),"")
    ) %>% 
  mutate(
    x_start=if (grepl("log", type_scale)) {log(start)} else {start},
    x_end= if (grepl("log", type_scale)) {log(end)} else {end} )
  
min_max_val_log_perc <- if (grepl(type_scale,"lin")) {
  list(min=ceiling(min(c(df_summary$start,df_summary$end))/0.5)*0.5,
       max=floor(max(c(df_summary$start,df_summary$end))/0.5)*0.5 ) 
} else {
    list(min=ceiling(min(log(c(df_summary$start,df_summary$end)))/1)*1,
       max=floor(max(log(c(df_summary$start,df_summary$end)))/1)*1 ) 
  }

# View(df_summary)

# for csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_summary %>% mutate(type_scale=type_scale,sel_var=sel_var)

# render plot
arrow_plot <- df_summary %>%
  ggplot(aes(x=x_start, xend=x_end, 
    y=country,yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",round(change,1),"%"))) +
  facet_wrap(~region_lab,scales="free_y") +
  geom_segment(arrow=arrow(length=unit(0.3,"cm"))) + # ,linewidth=1.5
  geom_text(aes(x=x_text,label=label_final),
    color=df_summary$label_color,size=4.5,vjust=-0.3) + 
  geom_text(data = . %>% filter(period_lab_T_F), 
          aes(x=x_text,label=period_lab),size=3,vjust=1.4) +
  labs(x=x_lab_txt,y=NULL,color="",caption=caption_txt) + # title=title_str
  scale_y_discrete(limits=rev,expand=expansion(0.01,3/5)) +
  theme_bw() + plot_settings +
  theme(axis.text.x = element_text(angle=0),legend.position="top")+ 
  make_x_scale_and_vlines(sel_var,type_scale,
        log_perc_vline_incr=1,min_max_val_log_perc=min_max_val_log_perc)

print(arrow_plot)

folder_name <- paste0(
  "output/lab_prod/gdp_per_hr_work_change_level/start_yr",
  start_yr_val,"/")
if (save_plot_flag) {
  paste0(
    folder_name,
    ifelse(grepl("log",type_scale),"log_ratio/",""),
    gsub("% of ","",sel_var),".png") %>%
    ggsave(plot=arrow_plot, width=35,height=24,units="cm")
}

} # end of for loop for comp_group

} # end of forloop for scales
  
    # SAVE table
if (save_table) {
  write_csv(bind_rows(l_print),
    file=paste0(folder_name,"data_table.csv"))
    }
    
} # end of forloop for start yr

})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# WAGES

# ANNUAL average wage
with(list(df_name="annual_aver_wage",
          save_plot_flag=T,
          save_table=T), {
  
  all_vars <- c("value",
                colnames(l_wages$oecd$sel_cntrs[[df_name]] %>% 
                ungroup() %>% select(contains("% of"))) )
  
  df <- l_wages$oecd$sel_cntrs[[df_name]]
  
  l_print <- list(); k_cntr=0
  
  for (type_scale in c("linear","logratio")) {
  for (sel_var in all_vars) {

  comp_cntrs <- if (grepl("%",sel_var)) {
    c(names(l_groups$comp_groups),
      l_groups$comp_groups[[gsub("% of ","",sel_var)]],"Germany") # 
    } else {
      comp_cntrs <- c(names(l_groups$comp_groups),"Germany") # ,"Germany"
      }
  
  x_lab_txt <- if (grepl("%",sel_var)) {
    paste0("average wage (annual) as ",
      gsub("LAT_AM","Latin America",sel_var),
      "* (2024 constant USD, PPP), change 1995 → 2024")
    
    } else {
        paste0("average wage (annual)",ifelse(grepl("log",type_scale),"",", thousand"),
        " (2024 constant USD, PPP), change 1995 → 2024")
    }
  if (grepl("log",type_scale)) {
  x_lab_txt <- gsub("%","proportion",paste0("log of ",x_lab_txt) )
  }
  
  w_aver_string <- "weighted average of "
  comp_expl_caption <- if (grepl("%",sel_var)) {
    
    avail_comp_cntrs <- unique((l_wages$oecd$all[[df_name]] %>% group_by(country) %>% 
        filter(min(year)<=1996))$country)
    
    paste0("\n*",case_when(
      grepl("W_EUR",sel_var) ~ paste0(w_aver_string,
                                  paste0(intersect(l_groups$comp_groups$W_EUR3,
                                    avail_comp_cntrs),
                                    collapse=", ")),
      grepl("S_EUR",sel_var) ~ paste0(w_aver_string,
                                  paste0(intersect(l_groups$comp_groups$S_EUR4,
                                    avail_comp_cntrs),
                                    collapse=", ")),
      grepl("LAT_AM",sel_var) ~ paste0(w_aver_string,
                                      paste0(intersect(avail_comp_cntrs,
                                        l_groups$list_cntrs$`Latin America`),
                                        collapse=", ")),
      grepl("G7",sel_var) ~ paste0(w_aver_string,
                              paste0(intersect(avail_comp_cntrs, 
                                l_groups$comp_groups$G7),
                                collapse=", ")),
      grepl("DE",sel_var) ~ "Germany")) 
  } else {""}
  
  caption_txt <- paste0(
    "source: https://data-explorer.oecd.org/s/1p0",
    comp_expl_caption)
  
xx <- left_join(df,
  l_pop$pop_sel_cnts %>% rename(pop=value) ) %>%
  filter(!is.na(value)) %>%
  filter(!country %in% comp_cntrs ) %>%
  group_by(country,year) %>%
  filter(!(is.na(value) | is.na(pop))) %>%
  group_by(country) %>%
  filter(min(year)<=1996) %>%
  summarise(
    region=unique(region),
    start_yr=min(year[year>=1995],na.rm=T),
    end_yr=max(year,na.rm=T),
    start=(!!sym(sel_var))[year==start_yr],
    end=(!!sym(sel_var))[year==end_yr],
    pop_start=unique(pop[year==start_yr]),
    pop_end=unique(pop[year==end_yr]),
    .groups="drop") 

# View(xx)

df_summary <- xx %>%
  # filter(start_yr<=1995) %>%
  group_by(region) %>%
  mutate(
    mean_end=sum(end*pop_end/sum(pop_end)),
    mean_start=sum(start*pop_start/sum(pop_start))) %>%
  ungroup() %>%
  # calculate metric
  rowwise() %>%
  mutate(
    scaling=ifelse(grepl("%",sel_var),1,
      ifelse(grepl("log",type_scale),1,1e-3)),
    scaling=ifelse(grepl("%",sel_var) & 
        grepl("log",type_scale),1/100,scaling),
    start=start*scaling,
    end=end*scaling,
    change=end-start,
    log_change=log(end/start),
    mean_lin_diff=(mean_end-mean_start)*scaling,
    mean_log_diff=log(mean_end/mean_start)
    ) %>%
  arrange(desc(if (grepl("log", type_scale)) {
    log_change } else { change }),.by_group=T) %>%
  mutate(country=str_wrap(country,width=10),
    country=factor(country, levels=country) ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(
    label_color=ifelse(change<0,"red","black"),
    label_txt_linear=ifelse(grepl("%",sel_var),
      paste0(ifelse(change>0,"+",""),round(change),"%"),
      paste0("$",round(change),"k")),
    label_txt_log=paste0(round(log_change,2),""),
    label_final=ifelse(grepl("log",type_scale),
              label_txt_log,label_txt_linear),
    x_text=ifelse(grepl("log",type_scale),
                (log(end)+log(start))/2,(start+end)/2),
    mean_start_end_lin=paste0(round(mean_start*scaling)," → ",
                        round(mean_end*scaling)),
    mean_start_end_log=paste0(round(log(mean_start*scaling),2)," → ",
                        round(log(mean_end*scaling),2)),
    mean_label_val=ifelse(grepl("log",type_scale),
              round(mean_log_diff,2),
              round(mean_lin_diff) ),
    mean_label_txt=paste0(ifelse(mean_label_val>0,"+",""),
      case_when(
            grepl("log",type_scale) ~ as.character(mean_label_val),
            grepl("lin", type_scale) & grepl("%", sel_var) ~ 
                    paste0(mean_label_val, "%"),
            grepl("lin", type_scale) & !grepl("%", sel_var) ~ 
                  paste0(mean_label_val, "k"))),
    mean_label_txt=ifelse(grepl("log",type_scale),
              paste0(mean_label_txt," (",mean_start_end_log,")"), # , " (log ratio)"
              paste0(mean_label_txt," (",mean_start_end_lin,")") ),
    region_lab=paste0(region,ifelse(grepl("log",type_scale),"\n","\n "),mean_label_txt),
    period_lab_T_F=!(start_yr==1995 & end_yr==2024),
    period_lab=ifelse(period_lab_T_F,paste0("(",start_yr,"-",end_yr,")"),"")
    ) %>% 
  mutate(
    x_start=if (grepl("log", type_scale)) {log(start)} else {start},
    x_end= if (grepl("log", type_scale)) {log(end)} else {end} )
  
# View(df_summary)

min_max_val_log_perc <- if (grepl(type_scale,"lin")) {
  list(min=ceiling(min(c(df_summary$start,df_summary$end))/0.5)*0.5,
       max=floor(max(c(df_summary$start,df_summary$end))/0.5)*0.5 ) 
} else {
    list(min=ceiling(min(log(c(df_summary$start,df_summary$end)))/1)*1,
       max=floor(max(log(c(df_summary$start,df_summary$end)))/1)*1 ) 
  }

# for csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_summary %>% mutate(type_scale=type_scale,sel_var=sel_var)

# View(df_summary)
# render plot
arrow_plot <- df_summary %>%
  ggplot(aes(x=x_start, xend=x_end, 
    y=country,yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",round(change,1),"%"))) +
  facet_wrap(~region_lab,scales="free_y") +
  geom_segment(arrow=arrow(length=unit(0.3,"cm"))) + # ,linewidth=1.5
  geom_text(aes(x=x_text,label=label_final),
    color=df_summary$label_color,size=4.5,vjust=-0.3) + 
  geom_text(data = . %>% filter(period_lab_T_F), 
          aes(x=x_text,label=period_lab),size=3,vjust=1.4) +
  labs(x=x_lab_txt,y=NULL,color="",caption=caption_txt) + # title=title_str
  scale_y_discrete(limits=rev,expand=expansion(0.01,3/5)) +
  theme_bw() + plot_settings +
  theme(axis.text.x = element_text(angle=0),legend.position="top")+ 
  make_x_scale_and_vlines(sel_var, type_scale, log_perc_vline_incr = 1,
    min_max_val_log_perc)
  
if (grepl("log",type_scale) ) {
  if (grepl("%",sel_var)) {
  arrow_plot <- arrow_plot + 
    scale_x_continuous(breaks=seq(-2,2,0.5)) + 
    geom_vline(xintercept=0,linewidth=1/2) 
  } else {
  arrow_plot <- arrow_plot + 
    scale_x_continuous(breaks=seq(7,12,0.5))
    }
}

if (grepl("lin",type_scale) & grepl("value",sel_var)) {
  arrow_plot <- arrow_plot + 
    scale_x_continuous(breaks=seq(5,100,5))
}

if (grepl("lin",type_scale) & grepl("LAT",sel_var)) {
  arrow_plot <- arrow_plot + 
    scale_x_continuous(breaks=seq(0,600,100)) +
    geom_vline(xintercept=1:5*100,linewidth=1/2,linetype="dashed")
}

print(arrow_plot)

scale_h <- ifelse(length(unique(df_summary$region_lab))<4,2,1)

folder_name <- "output/wages/annual_aver_wage/"
if (save_plot_flag) {
  paste0(
    folder_name,
    ifelse(grepl("log",type_scale),"log_ratio/",""),
    gsub("% of ","",sel_var),".png") %>%
    ggsave(plot=arrow_plot, width=35,height=24/scale_h,units="cm")
}

} # end of for loop for comp_group

} # end of forloop for scales
  
  # SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
  
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# ANNUAL MINIMUM WAGE

with(list(df_name="annual_min_wage",
          save_plot_flag=T,
          save_table=T), {
  
  l_print <- list(); k_cntr=0
            
  all_vars <- c("value",
                colnames(l_wages$oecd$sel_cntrs[[df_name]] %>% 
                ungroup() %>% select(contains("% of"))) )
  all_vars <- grep("% of DE",all_vars,invert=T,value=T)
  
  df <- l_wages$oecd$sel_cntrs[[df_name]]
  
  for (type_scale in c("linear","logratio") ) {
  for (sel_var in all_vars) {

  comp_cntrs <- if (grepl("%",sel_var)) {
    c(names(l_groups$comp_groups),
      l_groups$comp_groups[[gsub("% of ","",sel_var)]]) # ,"Germany"
    } else {
      comp_cntrs <- c(names(l_groups$comp_groups)) # ,"Germany"
      }
  
  x_lab_txt <- if (grepl("%",sel_var)) {
    paste0("minimum wage (annual) as ",
      gsub("LAT_AM","Latin America",sel_var),
      "* (2022 int. USD, PPP), change 1995 → 2024")
    } else {
        paste0("minimum wage (annual)",
          ifelse(grepl("log",type_scale),"",", thousand"),
          " (2022 int. USD, PPP), change 1995 → 2024")
    }
  # add 'log of' to x label
  if (grepl("log",type_scale)) {
      x_lab_txt <- gsub("%","proportion",paste0("log of ",x_lab_txt) )
  }
  
  w_aver_string <- "weighted average of "
  comp_expl_caption <- if (grepl("%",sel_var)) {
    
    avail_comp_cntrs <- unique((l_wages$oecd$all[[df_name]] %>% group_by(country) %>% 
        filter(min(year)<=1996))$country)
    
    paste0("\n*",case_when(
      grepl("W_EUR",sel_var) ~ paste0(w_aver_string,
                                  paste0(intersect(l_groups$comp_groups$W_EUR3,avail_comp_cntrs),
                                    collapse=", ")),
      grepl("S_EUR",sel_var) ~ paste0(w_aver_string,
                                  paste0(intersect(l_groups$comp_groups$S_EUR4,avail_comp_cntrs),
                                    collapse=", ")),
      grepl("LAT_AM",sel_var) ~ paste0(w_aver_string,
                                      paste0(intersect(avail_comp_cntrs,
                                        l_groups$list_cntrs$`Latin America`),
                                        collapse=", ")),
      grepl("G7",sel_var) ~ paste0(w_aver_string,
                              paste0(intersect(avail_comp_cntrs, l_groups$comp_groups$G7),
                                collapse=", ")),
      grepl("DE",sel_var) ~ "Germany")) 
  } else {""}
  
  caption_txt <- paste0(
    "source: https://data-explorer.oecd.org/s/1p0",
    comp_expl_caption)
  
xx <- left_join(df,
  l_pop$pop_sel_cnts %>% rename(pop=value) ) %>%
  filter(!is.na(value)) %>%
  filter(!country %in% comp_cntrs ) %>%
  group_by(country,year) %>%
  filter(!(is.na(value) | is.na(pop))) %>%
  group_by(country) %>%
  filter(min(year)<=1996) %>%
  summarise(
    region=unique(region),
    start_yr=min(year[year>=1995],na.rm=T),
    end_yr=max(year,na.rm=T),
    start=(!!sym(sel_var))[year==start_yr],
    end=(!!sym(sel_var))[year==end_yr],
    pop_start=unique(pop[year==start_yr]),
    pop_end=unique(pop[year==end_yr]),
    .groups="drop") 

# View(xx)

df_summary <- xx %>%
  # filter(start_yr<=1995) %>%
  group_by(region) %>%
  mutate(
    mean_end=sum(end*pop_end/sum(pop_end)),
    mean_start=sum(start*pop_start/sum(pop_start))) %>%
  ungroup() %>%
  # calculate metric
  rowwise() %>%
  mutate(
    scaling=ifelse(grepl("%",sel_var),1,
      ifelse(grepl("log",type_scale),1,1e-3)),
    scaling=ifelse(grepl("%",sel_var) & grepl("log",type_scale),1/100,scaling),
    start=start*scaling,
    end=end*scaling,
    change=end-start,
    log_change=log(end/start),
    mean_lin_diff=(mean_end-mean_start)*scaling,
    mean_log_diff=log(mean_end/mean_start)) %>%
  # group_by(region) %>%
  arrange(desc(if (grepl("log", type_scale)) {log_change} else {change}),.by_group=T) %>%
  mutate(country=str_wrap(country,width=10),
    country=factor(country, levels=country) ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(
    label_color=ifelse(change<0,"red","black"),
    label_txt_linear=ifelse(grepl("%",sel_var),
                paste0(ifelse(change>0,"+",""),round(change),"%"),
                paste0("$",round(change),"k")),
    label_txt_log=paste0(round(log_change,2),""),
    label_final=ifelse(grepl("log",type_scale),
              label_txt_log,label_txt_linear),
    x_text=ifelse(grepl("log",type_scale),
              (log(end)+log(start))/2,(start+end)/2), # 
    mean_start_end_lin=paste0(round(mean_start*scaling)," → ",
                        round(mean_end*scaling)),
    mean_start_end_log=paste0(round(log(mean_start*scaling),2)," → ",
                        round(log(mean_end*scaling),2)),
    mean_label_val=ifelse(grepl("log",type_scale),
              round(mean_log_diff,2),round(mean_lin_diff)),
    mean_label_txt=paste0(ifelse(mean_label_val>0,"+",""),
      case_when(
            grepl("log", type_scale) ~ 
                      paste0(mean_label_val, " (log ratio)"),
            grepl("lin", type_scale) & grepl("%", sel_var) ~ 
                    paste0(mean_label_val, "%"),
            grepl("lin", type_scale) & !grepl("%", sel_var) ~ 
                  paste0(mean_label_val, "k"))),
    mean_label_txt=ifelse(grepl("log",type_scale),
              paste0(mean_label_txt," (",mean_start_end_log,")"), # , " (log ratio)"
              paste0(mean_label_txt," (",mean_start_end_lin,")") ),
    region_lab=paste0(region,ifelse(grepl("log",type_scale),"\n","\n"),mean_label_txt),
    period_lab_T_F=!(start_yr==1995 & end_yr==2024),
    period_lab=ifelse(period_lab_T_F,paste0("(",start_yr,"-",end_yr,")"),"")
    ) %>% 
  mutate(
    x_start=if (grepl("log", type_scale)) {log(start)} else {start},
    x_end= if (grepl("log", type_scale)) {log(end)} else {end} )
  
# View(df_summary)

min_max_val_log_perc <- if (grepl(type_scale,"lin")) {
  list(min=ceiling(min(c(df_summary$start,df_summary$end))/0.5)*0.5,
       max=floor(max(c(df_summary$start,df_summary$end))/0.5)*0.5 ) 
} else {
    list(min=ceiling(min(log(c(df_summary$start,df_summary$end)))/1)*1,
       max=floor(max(log(c(df_summary$start,df_summary$end)))/1)*1 ) 
  }

# for csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_summary %>% mutate(type_scale=type_scale,sel_var=sel_var)

# View(df_summary)
# render plot
arrow_plot <- df_summary %>%
  ggplot(aes(x=x_start, xend=x_end, 
    y=country,yend=country,
    text=paste0(country," (",start_yr,"->",end_yr,"): ",round(change,1),"%"))) +
  facet_wrap(~region_lab,scales="free_y") +
  geom_segment(arrow=arrow(length=unit(0.3,"cm"))) + # ,linewidth=1.5
  geom_text(aes(x=x_text,label=label_final),
    color=df_summary$label_color,size=4.5,vjust=-0.3) + 
  geom_text(data = . %>% filter(period_lab_T_F), 
          aes(x=x_text,label=period_lab),size=3,vjust=1.4) +
  labs(x=x_lab_txt,y=NULL,color="",caption=caption_txt) + # title=title_str
  scale_y_discrete(limits=rev,expand=expansion(0.01,3/5)) +
  theme_bw() + plot_settings +
  theme(axis.text.x = element_text(angle=0),legend.position="top")+ 
  make_x_scale_and_vlines(sel_var, type_scale, log_perc_vline_incr = 1,
    min_max_val_log_perc)

if (grepl("log",type_scale) & grepl("%",sel_var)) {
  arrow_plot <- arrow_plot + 
    geom_vline(xintercept=0,linewidth=1/2) + 
    scale_x_continuous(breaks=seq(-2,2,0.5))
# if (grepl("%",sel_var)) {
#     arrow_plot <- arrow_plot + scale_x_continuous(breaks=seq(-2,2,0.5))
#   }
}

if (grepl("lin",type_scale) & grepl("value",sel_var)) {
  arrow_plot <- arrow_plot + 
    scale_x_continuous(breaks=seq(5,50,5))
}

if (grepl("lin",type_scale) & grepl("LAT",sel_var)) {
  arrow_plot <- arrow_plot + 
    scale_x_continuous(breaks=seq(0,600,100)) +
    geom_vline(xintercept=1:5*100,linewidth=1/2,linetype="dashed")
}

print(arrow_plot)

scale_h <- ifelse(length(unique(df_summary$region_lab))<4,1.5,1)

folder_name <- "output/wages/annual_min_wage/"
if (save_plot_flag) {
  paste0(
    folder_name,
    ifelse(grepl("log",type_scale),"log_ratio/",""),
    gsub("% of ","",sel_var),".png") %>%
    ggsave(plot=arrow_plot, width=35,
           height=24/scale_h,units="cm")
}

} # end of for loop for comp_group

} # end of forloop for scales

# SAVE table
if (save_table) {
  write_csv(bind_rows(l_print),
    file=paste0(folder_name,"data_table.csv")) }
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# REAL MEDIAN HOURLY EARNINGS (EUROSTAT)

with(list(all_vars=grep("%|value",
      colnames(l_wages$eurostat$real_median_hr_earning$sel_cntr),value=T),
          save_plot_flag=T,
          save_table=F), {
  
for (sel_var in all_vars) {

  x_txt <- if (grepl("value",sel_var)) {
  "Real median hourly earnings (Euros, PPS)" } else {
  paste0("Real median hourly earnings, ", sel_var,"*")
    }
  
df_plot  <- l_wages$eurostat$real_median_hr_earning$sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE ) %>%
  group_by(country) %>%
  mutate(year_end=lead(year),
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
  mutate(country_val_str=paste0(country," (", ifelse(diff_end_start>0,"+",""),
    signif(diff_end_start,2),
    ifelse(sel_var=="value","k PPS","%"),
    ")" ))
# View(df_plot)

# caption text
    caption_src <- "source: https://ec.europa.eu/eurostat/databrowser/view/earn_ses_pub2s/"
    caption_txt <- if (!grepl("World|usd|value",sel_var)) {
    paste0(ifelse(grepl("DE",sel_var),"*","*weighted average of "), 
      str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var])
round_val <- ifelse(grepl("%",sel_var),0,1)

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

p <- df_plot %>%
ggplot(aes(x=get(sel_var),xend=value_end,y=era,yend=era)) + # group = era
  facet_wrap(~country_val_str) +
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
  data = . %>% filter(year_end == 2022),
  aes(x=value_end,y=era,label=paste0(
      round(value_end, round_val),
      ifelse(grepl("%", sel_var), "%", "")    )  ),
  hjust = 0,          # left-justify text
  nudge_x = 1,     # move right
  size = 6)  +
  scale_x_continuous(limits=c(0,NA),
    expand=expansion(mult=c(0.02,0.15)),
    breaks=break_vals) +
  geom_vline(xintercept=if (sel_var == "value") {c(5,10,15)} else {
                  (1:ceiling(max_val/25))*25},
              linewidth=1/4,linetype="dashed") +
  labs(x=x_txt,y="",caption=caption_txt,title = title_str) +
  theme_bw() + plot_settings + theme(
    plot.title=element_text(size=22),
    axis.text.x=element_text(angle=0))

print(p)

# SAVE PLOT
folder_name <- "output/wages/real_median_hourly/"
file_name <- paste0(folder_name,gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}

# SAVE TABLE
if (save_table) {
  write_csv(df_plot,file=paste0(folder_name,"data_table.csv"))
    }

} # end of for loop
            
})


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# MEDIAN EQUIVALISED NET INCOME

with(list(all_vars=grep("%|value",
            colnames(l_wages$eurostat$median_equiv_net_income$sel_cntr),
            value=T),
          save_plot_flag=T,
          save_table=F), {
  
for (sel_var in all_vars) {

  y_txt <- if (grepl("value",sel_var)) {
  "Median equivalised net income (thousand PPS)" } else {
  paste0("Median equivalised net income, ", sel_var,"*")
    }
  
df_plot  <- l_wages$eurostat$median_equiv_net_income$sel_cntr %>%
    filter(country %in% l_groups$list_cntrs$CEE & year>=2005) %>%
  mutate(value=value/1e3)  %>%
  group_by(country) %>%
  mutate(start_val=(!!sym(sel_var))[year==min(year)],
         end_val=(!!sym(sel_var))[year==max(year)],
        diff_end_start=end_val-start_val ) %>%
  ungroup() %>%
  mutate(country_val_str=paste0(country," (", ifelse(diff_end_start>0,"+",""),
    signif(diff_end_start,2),
    ifelse(sel_var=="value","k PPS","%"),
    ")" ))
# View(df_plot)

# caption text
    caption_src <- "source: https://ec.europa.eu/eurostat/databrowser/view/ilc_di03/"
    caption_txt <- if (!grepl("World|usd|value",sel_var)) {
    paste0(ifelse(grepl("DE",sel_var),"*","*weighted average of "), 
      str_wrap(case_when(
    grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
    grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
    grepl("AT",sel_var) ~ "Austria",
    grepl("DE",sel_var) ~ "Germany"),
        width=55), "\n",caption_src)
  } else {
      caption_src
  }

max_val <- max(df_plot[,sel_var],na.rm = T)
round_val <- ifelse(grepl("%",sel_var),0,1)

df_labels <- df_plot %>% 
  group_by(country) %>% 
  filter(year %in% c(min(year),2010,2015,2020,max(year))) %>%
  mutate(dodge_y=year %in% 2010)
  
y_breaks <- if (sel_var == "value") {0:5*5} else {
                  (0:floor(max_val/20))*20 }
hline_vals <- if (sel_var == "value") {(1:floor(max_val/5))*5} else {
                  (1:floor(max_val/25))*25}

df_summ <- df_plot %>%
  group_by(country) %>%
  filter(year %in% c(min(year),max(year))) %>%
  mutate(year_fact=as.numeric(factor(year))) %>%
  group_by(year_fact) %>%
  summarise(
    value=sum(!!sym(sel_var)*pop/sum(pop)) # ,
    # n_yr=n(),
    # mean_start_yr=median(year[year_fact==1]),
    # mean_end_yr=median(year[year_fact==2])
    ) %>%
  distinct() %>%
  ungroup() %>%
  mutate(str_yr=ifelse(year_fact==2,
            paste0(signif(value,2), ifelse(sel_var=="value","k PPS","%")), 
            paste0(signif(value,2), ifelse(sel_var=="value","k","%"))  ))

# View(df_summ)

title_str <- paste0("weighted average: ",
  paste0(df_summ$str_yr,collapse = " → "))

p <- df_plot %>%
ggplot(aes(x=year,y=get(sel_var)) ) +
  facet_wrap(~country_val_str) +
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
    limits=c(0,NA),breaks=y_breaks) +
  labs(x="",y=y_txt,caption=caption_txt,title=title_str) +
  theme_bw() + plot_settings + theme(
    axis.text.x=element_text(angle=0),plot.title=element_text(size = 22))

print(p)

# SAVE PLOT
folder_name <- "output/wages/median_equiv_net_income/"
file_name <- paste0(folder_name,gsub("% of ","",sel_var),".png")
if (save_plot_flag) {
  file_name %>% ggsave(plot=p, width=42,height=28,units="cm")
}

# SAVE TABLE
if (save_table) {
        write_csv(df_plot,
              file=paste0(folder_name,"data_table.csv"))
}

} # end of for loop
            
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# life expectancy

# FACETED BY COUNTRY
with(list(
  df=l_life_exp$sel_cntrs,
  all_var_list=c("value","% of DE",
          paste0("% of ",names(l_groups$comp_groups)),
          "% of World"),
  save_plot_flag=F,
  save_table=T), {

l_print <- list(); k_cntr=0

for (sel_var in all_var_list) { # [3]
  
  x_lab_txt <- paste0("period life expectancy as ",
    gsub("LAT_AM","Latin America",sel_var),
    ifelse(grepl("World",sel_var),"","*") )
  x_lab_txt <- gsub(" as value","",x_lab_txt)
  
  caption_txt <- if (!grepl("World|DE",sel_var)) {
    str_wrap(paste0( "weighted average of ", case_when(
      grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
      grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
      grepl("LAT_AM",sel_var) ~ paste0(l_groups$list_cntrs$`Latin America`,collapse=", "),
      grepl("G7",sel_var) ~ paste0(l_groups$comp_groups$G7,collapse=", ") ) 
      ),width = 50)
  } else {
    ifelse(grepl("DE",sel_var),"*Germany","")
    }

  df_yrs <- df %>%
  filter(year>=1950 ) %>%
  filter(region %in% "CEE" | grepl("Russia|Serbia|Ukr|Belarus",country) ) %>% # 
  filter(!grepl(paste0(c("Germ","World","United S",
                  names(l_groups$comp_groups)),collapse="|"),country)) %>%
  mutate(cntr_group=case_when(
    grepl("Eston|Lith|Latv",country) ~ "Baltics",
    grepl("Croat|Sloven|Serb",country) ~ "Yugosl.",
    grepl("Russia|Ukra|Belar",country) ~ "USSR",
    .default="CEE") ) %>%
    relocate(c(cntr_group,region),.before=country) %>% 
    group_by(country) %>%
    mutate(min_yr=min(year),
          max_yr=max(year),
          trans_rec_end_yr=1995 ) %>%
    ungroup() %>%
    filter(year %in% c(1965,1989) | 
            year==min_yr | year==max_yr | 
            year==trans_rec_end_yr) %>%
    pivot_longer(cols=c("value",all_var_list),
      names_to="varname") %>%
  arrange(country,varname, year) %>%
  group_by(varname) %>%
  mutate(year_end=lead(year),
        value_end=lead(value)  ) %>%
  filter(!is.na(year_end)) %>%
  ungroup() %>%
  relocate(c(year,year_end,varname,value,value_end), .after=Code) %>%
  filter(year_end>=year) %>%
  filter(grepl(sel_var,varname)  ) %>%
  mutate(era=paste0(year,"-",year_end),
         era_col=case_when(
           year<1989 ~ "socialism",
           year==1989 ~ "transition",
           year>1989 ~ "capitalism")) %>%
    group_by(country) %>%
  mutate(era_num=as.numeric(factor(era)),
    era_low =era_num - 1/2,
    era_high=era_num + 1/2) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(cntr_region=paste0(cntr_group,": ",country),
         change_val=value_end-value,
         change_lab=paste0(ifelse(change_val<0,"","+"),
                round(change_val,1)),
         change_sign=ifelse(grepl("val",sel_var),
           case_when(round(change_val)<0 ~ "decrease",
           round(change_val)>0 ~  "increase",
           round(change_val)==0 ~  "no change"),
           # ifelse(round(change_val)<0,"divergence","catch-up") 
           case_when(round(change_val)<0 ~ "divergence",
           round(change_val)>0 ~  "convergence",
           round(change_val)==0 ~  "no change")
           ) 
    )

# View(df_yrs)

# for csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_yrs %>% mutate(sel_var=sel_var)

# render plot
p <- df_yrs %>%
  ggplot(aes(y=era,yend=era,
            x=value,xend=value_end,
            group=era)) + # color=era_col,
  facet_wrap(~cntr_region) + # ,scales="free_y"
  geom_segment(aes(color=change_sign), # alpha=0.6,
        arrow=arrow(length=unit(0.25,"cm")),linewidth=1) +
  geom_text(aes(x=(value+value_end)/2,label=change_lab),
              color="black",nudge_y=0.3) +
  geom_rect(aes(xmin=-Inf,xmax=Inf,ymin=era_low,ymax=era_high,
      fill=era_col), inherit.aes=F,alpha=0.2) +
  geom_vline(xintercept=c(100),linewidth=1/2,linetype="dashed") +
  labs(x=x_lab_txt,y="",caption = caption_txt,
       title="",color="",fill="") + 
  scale_fill_manual(values=c("capitalism"="darkgreen",
    "transition"="grey","socialism"="red")) +
  theme_bw() + plot_settings + theme(
    legend.position="top",
    axis.text.x=element_text(angle=0))

if (grepl("value",sel_var)) {
  p <- p + scale_color_manual(values=c("increase"="blue","decrease"="red",
    "no change"="black"))
} else {
  p <- p + scale_color_manual(values=c("convergence"="blue","divergence"="red",
        "no change"="black"))
}

# PNG
 print(p)
 
 folder_name <- "output/life_exp/by_cntr/"
if (save_plot_flag) {
  file_name <- paste0(
    folder_name,
    gsub("% of ","",sel_var),".png")
  file_name %>% ggsave(width=42,height=24,units="cm")
}

} # end of all_var loop

      # SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
      
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# LIFE EXPECTANCY FACETED BY COUNTRY GROUP

with(list(
  save_plot_flag=F,
  save_table=T,
  df=l_life_exp$sel_cntrs,
  all_var_list=c("value","% of DE",
    paste0("% of ",names(l_groups$comp_groups)),
    "% of World") ), {

      l_print <- list(); k_cntr=0
      
for (type_scale in c("linear","logratio") ) {
for (sel_var in all_var_list) {
  
  x_lab_txt <- if (grepl("%",sel_var)) {
    paste0("period life expectancy as ",
      gsub("LAT_AM","Latin America",sel_var))
    } else {
        "period life expectancy (years)" }
  if (grepl("log",type_scale)) {
  x_lab_txt <- gsub("%","proportion",paste0("log of ",x_lab_txt) )
  }
  
  caption_txt <- if (!grepl("World|DE|value",sel_var)) {
    str_wrap(paste0( "weighted average of ", case_when(
      grepl("W_EUR",sel_var) ~ paste0(l_groups$comp_groups$W_EUR3,collapse=", "),
      grepl("S_EUR",sel_var) ~ paste0(l_groups$comp_groups$S_EUR4,collapse=", "),
      grepl("LAT_AM",sel_var) ~ paste0(l_groups$list_cntrs$`Latin America`,collapse=", "),
      grepl("G7",sel_var) ~ paste0(l_groups$comp_groups$G7,collapse=", ") ) 
      ),width = 50)
  } else {
    if (grepl("DE",sel_var)) {"*Germany"} else {""}
    }

  l_sel_yrs <- list(start_soc=1950,early_soc_end=1965,
                    soc_end=1989,trans_rec_end=1995,end=2023)
  
  if (!grepl("value",sel_var)) {
  cntrs_to_rem <- paste0(c("Germ","World","United S",
                  names(l_groups$comp_groups) ),collapse="|") 
  } else {
    cntrs_to_rem <- "United S"
  }
  
  # View(df)
  # print(cntrs_to_rem)
  df_intermed <- df %>%
  filter(year>=1950 ) %>%
  filter(region %in% "CEE" | grepl("Russia|Serbia|Ukr|Belarus",country) | 
      country %in% names(l_groups$comp_groups) ) %>% # 
  filter(!grepl(cntrs_to_rem,country)) %>%
  mutate(cntr_group=case_when(
    (country %in% l_groups$list_cntrs$CEE &
        !grepl("Eston|Lith|Latv|Croat|Sloven|Serb",country) ) ~ "CEE",
        grepl("Eston|Lith|Latv",country) ~ "Baltics",
        grepl("Croat|Sloven|Serb",country) ~ "Yugosl.",
        grepl("Russia|Ukra|Belar",country) ~ "USSR",
        .default="world regions"),
      cntr_group=factor(cntr_group,
        levels=c("Baltics","CEE","USSR","Yugosl.","world regions"))) %>%
    relocate(c(cntr_group,region),.before=country) %>% 
    group_by(country) %>%
    mutate(min_yr=min(year),
          max_yr=max(year),
          trans_rec_end_yr=l_sel_yrs$trans_rec_end ) %>%
    ungroup() %>%
    filter(year %in% as.numeric(l_sel_yrs[c("early_soc_end","soc_end")]) | 
            year==min_yr | year==max_yr | 
            year==trans_rec_end_yr) %>%
    pivot_longer(cols=c("value",all_var_list),
      names_to="varname") 
  
  # View(df_intermed)
  
  ###
  # for comparison, on relative change plot, display abs changes in benchmark regions
  sel_comp <- ifelse(grepl("DE",sel_var),"Germany",gsub("% of ","",sel_var))
  df_comp <- (df %>% filter(country %in% sel_comp & 
                        year %in% as.numeric(l_sel_yrs) ))[,1:5]
  # View(df_comp)
  df_comp <-  df_comp %>%
    ungroup() %>%
    arrange(year) %>%
    mutate(next_year=lead(year),
      next_value = lead(value) ) %>%
    filter(!is.na(next_year)) %>%               # drop last (no endpoint)
    mutate(era=paste(year, next_year, sep = "-"),
        start_year=year,
        country=country,
        end_year=next_year,
        start_value = value,
        end_value=next_value,
        change_lab=paste0(country,":\n",
                round(start_value),"→",round(end_value),"y"),
        cntr_group="Baltics",.keep="none") %>%
    rowwise() %>%
    mutate(x_pos=80+ifelse(grepl("LAT",sel_var),
        ifelse(grepl("2023",era),30,7.5),0) )
  
  # main df for plot
  df_yrs <- df_intermed %>%
  arrange(country,varname, year) %>%
  group_by(varname) %>%
  mutate(year_end=lead(year),
        value_end=lead(value)  ) %>%
  filter(!is.na(year_end)) %>%
  ungroup() %>%
  relocate(c(year,year_end,varname,value,value_end), .after=Code) %>%
  filter(year_end>=year) %>%
  filter(grepl(sel_var,varname)  ) %>%
  mutate(era=paste0(year,"-",year_end),
         era_col=case_when(
           year<1989 ~ "socialism",
           year==1989 ~ "transition",
           year>1989 ~ "capitalism")) %>%
    group_by(country) %>%
  mutate(era_num=as.numeric(factor(era))) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(
    scaling=ifelse(grepl("log",type_scale) & !grepl("val",sel_var),1e-2,1),
    value=ifelse(grepl("log",type_scale),log(value*scaling),value),
    value_end=ifelse(grepl("log",type_scale),log(value_end*scaling),value_end),
    cntr_region=paste0(cntr_group,": ",country),
    change_val=value_end-value,
    change_val_lab=ifelse(!grepl("log",type_scale),
                      round(change_val),round(change_val,2)),
    change_lab=paste0(ifelse(change_val_lab<0,"","+"),
                      change_val_lab),
    change_sign=ifelse(grepl("val",sel_var),
                      case_when(change_val_lab<0 ~ "decrease",
                                  change_val_lab>0 ~  "increase",
                                  change_val_lab==0 ~  "no change"),
                      case_when(change_val_lab<0 ~ "divergence",
                              change_val_lab>0 ~  "convergence",
                              change_val_lab==0 ~  "no change")
           ),
    Code=ifelse(grepl("OWID_WRL|DEU",Code) | is.na(Code),country,Code ),
    Code=case_when(grepl("Ger",Code) ~ "DE",.default = Code  )
    ) %>%
    select(!c(min_yr,max_yr,year,year_end,
              trans_rec_end_yr,region)) %>%
    relocate(c(cntr_region,era),.after=Code) %>% 
    relocate(c(era_num,pop),.after=last_col())

  # View(df_yrs)
  
  val_range <- c(df_yrs$value,df_yrs$value_end)
  
  # for csv
k_cntr <- k_cntr+1
l_print[[k_cntr]] <- df_yrs %>% mutate(type_scale=type_scale,sel_var=sel_var)
  
# render plot
dodge_w <- 0.95
max_val <- max(c(df_yrs$value_end,df_yrs$value),na.rm = T)
x_dodge_cntr <- ifelse(grepl("val",sel_var),0.02,0.02)
# render plot
p <- df_yrs  %>%
  ggplot(aes(y=era, # ymin=era_col,ymax=era_col,
            xmin=value,xmax=value_end,
            group=country,
            text=paste0(round(value),"% -> ",round(value_end),"%")    )) + # color=era_col,
  facet_wrap(~cntr_group,1) + # ,scales="free_y"
  geom_linerange(aes(color=change_sign),
    position=position_dodge(width=dodge_w),linewidth=1.5,alpha=1/2) +
  geom_point(aes(x=value_end,color=change_sign),shape=5,
            position=position_dodge(width=dodge_w),size=2.5,
            show.legend=F) +
  # label of change
  geom_text(aes(x=(value+value_end)/2.05,y=era_num+0.075,
            label=paste0(Code,": ",change_lab),color=change_sign),size=4,
            position=position_dodge(width=dodge_w),
            show.legend=F  ) +
  geom_hline(yintercept=c(1.5,2.5,3.5)+0.025,linewidth=1) +
  labs(x=x_lab_txt,y="",title="", color="",
       caption=paste0("◇︎ symbol = value at end of period\n",caption_txt)) +
  scale_x_continuous(expand=expansion(0.08)) +
  scale_y_discrete(expand=expansion(0)) +
  theme_bw() + plot_settings + theme(
    legend.position="top",legend.box="vertical",
    axis.text.x=element_text(angle=0) )

if (!grepl("value",sel_var) & grepl("lin",type_scale)) {
  p <- p + geom_vline(xintercept = 100,linewidth=1/3)
} 

if (!grepl("value",sel_var) & grepl("log",type_scale)) {
  p <- p + geom_vline(xintercept = 0,linewidth=1/3)
} 

if (grepl("value",sel_var)) {
p <- p + scale_color_manual(values=c("increase"="blue","decrease"="red",
        "no change"="black"))
} else {
p <- p + scale_color_manual(values=c("convergence"="blue","divergence"="red",
        "no change"="black")) 
        }

# PNG
 print(p)
 
folder_name <- "output/life_exp/by_cntr_group/"
if (save_plot_flag) {
  file_name <- paste0(
    folder_name,
    ifelse(grepl("log",type_scale),"log/",""),
    gsub("% of ","",sel_var),".png")
  file_name %>% ggsave(width=42,height=24,units="cm")
}

} # end of all_var loop
} # type scale

      # SAVE table
    if (save_table) {
        write_csv(bind_rows(l_print),
              file=paste0(folder_name,"data_table.csv"))
    }
      
})

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# PLOT GDP/cap trends, post-1990

# with(list(), {
# 
#   save_plot_flag <- c(T,F)[2]
#   color_vals <- c("1"="red","2"="blue",
#     "3"="darkgreen","4"="darkgrey","5"="darkorange",
#     "6"="steelblue", "7"="violet","8"="green" )
#   
# # averages by region
# df_mean <- left_join(
#   l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr,
#   l_pop$pop_sel_cnts %>% select(!value) ) %>%
#   group_by(year,region) %>%
#   summarise(`mean value`=sum(`% of DE`*prop,na.rm=T) )
# # mean(`% of DE`,na.rm=T)
# 
# # legends
# legend_df <- l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>%
#   distinct(region, country, color_cntr) %>%
#   group_by(region) %>%
#   mutate(x=min(l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr$year,na.rm=T)+3, 
#          y=case_when(grepl("South",region) ~ 
#              seq(min(l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr$`% of DE`,na.rm=T),
#                by=7,length.out=n()),
#            .default=seq(max(l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr$`% of DE`,na.rm=T),
#              by=-7,length.out=n()) ) )
# 
# # plot
# p_gdp_cap_vs_DE <- l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr %>%
# ggplot(aes(x=year,y=`% of DE`,group=country,color=color_cntr,text=paste0(
#       "Country: ", country,"<br>Year: ",year,
#       "<br>% of DE: ", round(`% of DE`,2)) )) + 
#   facet_wrap(~region) + 
#   geom_line(alpha=1/2) + geom_point(alpha=1/4,size=1) +
#   geom_line(data = df_mean,inherit.aes=F,aes(x=year,y=`mean value`)) + # ,linewidth=1
#   geom_text(data=legend_df, aes(x=x, y=y, label=country, color=color_cntr),
#     inherit.aes=F, hjust=0) +
#   geom_hline(yintercept = 100,linetype="dashed",linewidth=1/2) +
#   xlab("") + ylab("GDP per cap (2021 USD PPP) as % of Germany ") + 
#   scale_color_manual(values=color_vals ) + 
#   scale_x_continuous(breaks=seq(1990,2026,4) ) +
#   scale_y_continuous(breaks=(0:10)*10) + # ,limits = c(NA,100)
#   labs(color="",caption="source: data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD") + 
#   theme_bw() + plot_settings + 
#   theme(legend.position="none",axis.text.x = element_text(angle=0))
# 
#   print(p_gdp_cap_vs_DE)
# 
# # PNG
#   if (save_plot_flag) {
#   "output/gdp_per_cap_vs_DE_trend.png" %>%
#     ggsave(width=30,height=24,units="cm")
# }
#   
# # as plotly
# if (save_plot_flag) {
#   saveWidget( ggplotly(p_gdp_cap_vs_DE,tooltip="text"),
#            "output/gdp_per_cap_vs_DE_trend.html")
# }
#   
# }
# )
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# plot the change only 

# with(list(df=l_GDP_percap$gdp_per_cap_2021usdppp_sel_cntr), {
#   
#   save_plot_flag <- c(T,F)[2]
#   title_str <- paste0("change in GDP/capita (USD 2021, PPP), 1990 → 2024 (◇),",
#                        "as a % of Germany's level")
#   
# df_summary <- df %>%
#   filter(!is.na(value)) %>%
#   group_by(country) %>%
#   summarise(
#     region=unique(region),
#     start_yr=min(year,na.rm=T),
#     end_yr=max(year,na.rm=T),
#     start=`% of DE`[year == start_yr],
#     end=`% of DE`[year == end_yr],
#     .groups="drop") %>%
#   filter(start_yr<1994) %>%
#   mutate(change=end-start) %>%
#   arrange(desc(change)) %>%
#   mutate(country=factor(country, levels=unique(country)),
#          label_color = ifelse(change < 0, "red", "black")  )
# # render plot
# arrow_plot <- df_summary %>% 
#   ggplot(aes(y=country, x=0, xend=change, yend=country,
#     text=paste0(country," (",start_yr,"->",end_yr,"): ",
#       round(start),"% → ",round(end),"%"))) + # ifelse(change>0,"+",""), 
#   geom_segment(aes(color=region),
#     arrow=arrow(length=unit(0.3, "cm")),linewidth=2) +
#   geom_text(aes(x=change, # y=as.numeric(rev(country))+1/3,
#     label=paste0(ifelse(change>0,"+",""),round(change),"%") ),
#     color=df_summary$label_color,size=5, nudge_x=ifelse(df_summary$change<0,-3,3) ) + 
#   labs(x="% of DE", y=NULL, color="",
#     title=title_str,
#     subtitle = "◇: most recent (2024) value",
#     caption="source: data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD") +
#   scale_x_continuous(breaks=(-5:10)*10) +
#   scale_y_discrete(limits=rev,expand=expansion(0.03)) +
#   theme_bw() + plot_settings +
#   theme(legend.position="top")
# print(arrow_plot)
# 
# if (save_plot_flag) {
#   "output/gdp_per_cap_vs_DE_change_only.png" %>%
#     ggsave(width=30,height=24,units="cm")
# }
# 
# arrow_plot <- arrow_plot + geom_point(
#   aes(x=change,color=region),shape=23,size=3,color="black")
# 
# if (save_plot_flag) {
#   saveWidget( ggplotly(arrow_plot,tooltip="text"),
#            "output/gdp_per_cap_vs_DE_change_only.html")
# }
# 
# })
