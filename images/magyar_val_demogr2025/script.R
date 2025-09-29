# LOAD PACKAGES
source("functions.R")
### ### ### ### ### ### ### ### ### ### ### ### ### 

l_dem <- list()
l_part_data <- list()

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# partpref

# 21kut aug, vegzettseg
# source: https://flo.uri.sh/visualisation/24922340/embed
l_part_data[["21_kut"]][["2025_08"]][["vegzettseg"]] <- read_csv(
  "input_files/21kut_2025_08_vegzettseg_szerint.csv") %>%
  pivot_longer(!vegzettseg,names_to="part")  %>%
  mutate(arány=value/100) %>% select(!value)

# 21kut, 2025/08, telj nepesseg
# source: https://flo.uri.sh/visualisation/24921118/embed
l_part_data$`21_kut`$`2025_08`$teljes_nepesseg <- read_csv(
            "input_files/21kut_2025_08_teljes_nepesseg.csv") %>%
  filter(grepl("teljes",kateg)) %>%
  pivot_longer(!c(kateg,part),names_to = "datum") %>%
  mutate(value=value/100,
        datum=case_when(
              grepl("prilis",datum) ~ "2025/04",
              grepl("nius",datum) ~ "2025/06",
              grepl("augus",datum) ~ "2025/08",
          )  ) %>%
  rename(arány=value)

# 21kut jun, telepules
# source: https://flo.uri.sh/visualisation/23976053/embed
l_part_data$`21_kut`$`2025_06`$telep_tipus <- read_delim(
  "input_files/21kut_2025_06_telepulestipus.csv",delim = ";") %>%
  pivot_longer(!telep_tipus,names_to = "part") %>%
  rename(arány=value) %>% mutate(arány=arány/100) %>%
  mutate(kateg_tipus="településtípus") %>%
  rename(kateg_eredeti=telep_tipus)
# unique(l_part_data$`21_kut`$`2025_06`$telep_tipus$telep_tipus)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# MEDIAN 2025/06, tobb demogr kateg

# MEDIAN 2025/06, tobb demogr kateg
# https://datawrapper.dwcdn.net/Ns8XR/10/
l_part_data[["median"]][["2025_06"]] = list()
l_part_data[["median"]][["2025_06"]] <- read_csv(
  "input_files/median_2025_06_nem_vegzettseg_telepules_vegzettseg.csv") %>%
  select(!url) %>%
  pivot_longer(!c(kateg_tipus,kateg,datum),names_to="part") %>%
  mutate(arány=value/100,
        part=gsub("\\*","",part),
        kateg=tolower(kateg),
        kateg=gsub("/vagy idősebb","\\+",gsub(" éves","",gsub(" végzettség","",gsub("\\, ","/",
                kateg))))  ) %>% 
  select(!value) %>%
  group_by(kateg_tipus) %>% { 
    set_names(group_split(.,.keep=F), group_keys(.)$kateg_tipus) } %>%
  as.list()

# l_part_data[["median"]][["2025_06"]]$KORCSOPORT
# l_part_data[["median"]][["2025_08"]]$ÉLETKOR
names(l_part_data[["median"]][["2025_06"]])[
  names(l_part_data[["median"]][["2025_06"]]) %in% "KORCSOPORT"] <- "ÉLETKOR"

# teljes nepesseg
# datawrapper.dwcdn.net/RLw52/2/
l_part_data[["median"]][["2025_06"]]$telj_nepesseg_partok <- read_csv(
  "input_files/median_2025_06_teljes_nepesseg.csv") %>% 
  rename(part=Párt) %>%
  select(part,`teljes népesség`) %>%
  pivot_longer(!part,names_to = "kateg") %>%
  mutate(arány=value/100,datum="2025/06") %>%
  select(!value)


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# MEDIAN 2025/08, tobb demogr kateg
# source: https://flo.uri.sh/visualisation/25049528/embed?auto=1

l_part_data[["median"]][["2025_08"]] <- list()
l_part_data[["median"]][["2025_08"]] <- read_csv(
  "input_files/median_2025_08_nem_vegzettseg_telepules_vegzettseg.csv") %>%
  rename(tipus=filter,kateg=preferencia) %>%
  pivot_longer(!c(tipus,kateg),names_to="part") %>%
  mutate(arány=value/100,
         kateg=tolower(kateg),
         datum="2025/08"  ) %>% 
  select(!value) %>%
  group_by(tipus) %>% { set_names(group_split(.,.keep=F), group_keys(.)$tipus) } %>%
  as.list()

# teljes nepesseg partokra bontva
# https://flo.uri.sh/visualisation/25049245/embed?auto=1
l_part_data[["median"]][["2025_08"]]$telj_nepesseg_partok <- read_csv(
  "input_files/median_2025_08_teljes_nepesseg.csv") %>% 
  pivot_longer(!c(kateg,url,datum),names_to="part") %>%
  filter(grepl("Teljes",kateg)) %>%
  mutate(kateg=tolower(kateg),arány=value/100) %>%
  select(!c(value,url)) %>%
  relocate(c(datum),.after=last_col()) %>%
  bind_rows(data.frame(kateg="teljes népesség",part="Jobbik",datum="2025/08")) # arány=0,
  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# DEMOGRAFIA

# KORSZERKEZET
# source: https://www.ksh.hu/stadat_files/nep/en/nep0003.html
l_dem$stadat_nep0003 <- read_delim("input_files/stadat-nep0003-22.1.1.3-hu.csv",
            skip=1,locale=locale(encoding="CP1250"),delim = ";",trim_ws=T) %>%
  pivot_longer(
    cols = -Korév,
    names_to = "ev",
    values_to="value"  ) %>%
  mutate( nem = ifelse(Korév %in% c("Férfi", "Nő", "Összesen"), Korév, NA)  ) %>%
  fill(nem, .direction = "down") %>%
  filter(!(Korév %in% c("Férfi", "Nő", "Összesen"))) %>%
  rename(kor = Korév) %>%
  mutate(
    value = str_replace_all(value, " ", ""),  # remove thousand-sep spaces
    value = as.numeric(value),
    ev  = as.integer(ev),
    kor_num=as.numeric(kor),
    kor_num=ifelse(is.na(kor_num),90,kor_num)  ) 

# plot
if (F) {
l_dem$stadat_nep0003 %>%
  filter(grepl("esen",nem) & ev>2010) %>%
  group_by(ev,nem) %>%
  summarise(valasztok=sum(value[kor_num>=18])/1e3,
            kiskoruak=sum(value[kor_num<18])/1e3) %>%
  pivot_longer(!c(ev,nem)) %>%
ggplot(aes(x=ev,y=value)) + 
  facet_wrap(~name,scale="free_y") +
  geom_line() + geom_point() +
  xlab("") + ylab("ezer fo") + labs(color="") +
  scale_x_continuous(breaks = 2010:2025) +
  theme_bw() + l_plot$standard_theme
}

# Median felmeresnek megfelelo korcsoportok
# unique((l_part_data$median$`2025_08` %>% filter(tipus %in% "ÉLETKOR"))$kateg)
l_dem$korszerk_csop <- with(
  list(korcsop=unique((l_part_data$median$`2025_08`$ÉLETKOR)$kateg) ), {
      l_korcsop <- strsplit(x=korcsop,split = "-") 
l_dem$stadat_nep0003 %>% filter(ev==2025 & grepl("sszes",nem)) %>%
    mutate(age_group = case_when(
                kor_num >= as.numeric(l_korcsop[[1]][1]) & kor_num <= 
                        as.numeric(l_korcsop[[1]][2]) ~ korcsop[1],
                kor_num >= as.numeric(l_korcsop[[2]][1]) & kor_num <= 
                        as.numeric(l_korcsop[[2]][2]) ~ korcsop[2],
                kor_num >= as.numeric(l_korcsop[[3]][1]) & kor_num <= 
                        as.numeric(l_korcsop[[3]][2]) ~ korcsop[3],
                kor_num >= as.numeric(l_korcsop[[4]][1]) & kor_num <= 
                        as.numeric(l_korcsop[[4]][2]) ~ korcsop[4],
                kor_num >= as.numeric(gsub("\\+","",l_korcsop[[5]][1])) ~ korcsop[5] )  ) %>%
  filter(!is.na(age_group)) %>%
  group_by(age_group) %>%
  summarise(szam = sum(value), .groups = "drop") %>%
  arrange(age_group)  } ) %>%
  rename(kateg=age_group)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# teljes felnott nepesseg

l_dem$teljes_felnott_nep_2025 <- as.numeric(
  l_dem$korszerk_csop %>% summarise(teljes_felnott_nepesseg=sum(szam)))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# NEMEK szerint
# l_part_data$median$`2025_08`$NEM
l_dem$NEM <- l_dem$stadat_nep0003 %>%
  filter(!grepl("sszes",nem) & ev==2025 & kor_num>=18) %>%
  group_by(nem) %>%
  summarise(value=sum(value)) %>%
  rename(kateg=nem) %>%
  mutate(kateg=tolower(kateg))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# TELEPULES MERET szerint

# Median kozos nevek 
unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg)

# osszes telep val.polg. szamaval
# osszesen 7.759m val.polgar jon ki a 2022-es valasztasi adatokbol, 
# vmivel (kb 100e) kevesebb mint a KSH 18+ lakossagmeret... nem vagyok benne biztos ennek mi az oka
l_dem$telep_lista_valpolg_tipus <- right_join(
  read_csv("input_files/Egyéni_szavazás_szkjkv.csv") %>% 
  # source: https://www.valasztas.hu/ogy2022-letoltheto-es-tovabbfeldolgozhato-adatok
  # Egyéni_szavazás_szkjkv.xls file-bol
  filter(!is.na(VÁLASZTÓPOLGÁR)) %>% 
  group_by(TELEPÜLÉS) %>% summarise(n_valpolg=sum(VÁLASZTÓPOLGÁR)) %>%
  mutate(telepules=ifelse(grepl("Budap",TELEPÜLÉS),"Budapest",TELEPÜLÉS)) %>%
  group_by(telepules) %>% summarise(n_valpolg=sum(n_valpolg)),
# telep jogallasa
  read_csv("input_files/l_telep_meret.csv") %>%
    # forras: https://www.ksh.hu/docs/helysegnevtar/hnt_letoltes_2024.xlsx
    select(c(`Helység megnevezése`,`Lakó-népesség`,`Helység jogállása` )) %>%
    mutate(telepules=ifelse(grepl("Budap",`Helység megnevezése`),"Budapest",`Helység megnevezése`)) %>%
    filter(!grepl("fővárosi kerület",`Helység jogállása`)) %>%
    group_by(telepules,`Helység jogállása`)
  )

# telep tipus, teljes lakossag
l_dem$telep_tipus <- l_dem$telep_lista_valpolg_tipus %>% 
  rename(kateg_ksh=`Helység jogállása`) %>%
  group_by(kateg_ksh) %>% 
  summarise(kateg_tipus="településtípus",
            n_valpolg=sum(n_valpolg),
            n_lako=sum(`Lakó-népesség`)) %>%
  mutate(kateg=case_when(
                grepl("község",kateg_ksh,ignore.case=T) ~ grep("község",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                grepl("megyei",kateg_ksh,ignore.case=T) ~ grep("megyei",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                grepl("főváros",kateg_ksh,ignore.case=T) ~ grep("főváros",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                kateg_ksh %in% "város" ~ grep("egyéb város",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                .default=kateg_ksh)   )

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# 21 kut kategoriak osszehangolasa a mediannal
l_part_data$`21_kut`$`2025_06`$telep_tipus <- l_part_data$`21_kut`$`2025_06`$telep_tipus %>%
  mutate(kateg=case_when(
                grepl("község",kateg_eredeti,ignore.case=T) ~ grep("község",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                grepl("megyei",kateg_eredeti,ignore.case=T) ~ grep("megyei",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                grepl("Egyéb város",kateg_eredeti,ignore.case=T) ~ grep("egyéb város",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                grepl("Főváros",kateg_eredeti,ignore.case=T) ~ grep("főváros",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                .default=kateg_eredeti),
        datum="2025/06"  )


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# VEGZETTSEG szerint

# demografia: 15-74 eves korosztaly
l_dem$vegzettseg[["15_74_props"]] <- read_csv("input_files/stadat-okt0001-23_osszes.csv") %>%
  # source: https://www.ksh.hu/stadat_files/mun/hu/mun0006.html
  pivot_longer(!Év,names_to="vegzettseg") %>%
  group_by(Év) %>%
  mutate(prop=value/sum(value[!grepl("Összesen",vegzettseg)]))
# shld be the same as:
# l_dem$stadat_nep0003 %>% filter(grepl("esen",nem) & kor_num>=15 & 
#   kor_num<74 & ev==2024) %>% summarise(sum(value))/1e3

# ebben nincs benne a 74+ lakossag...
# vegyuk a 2009-es adatokat, mert ezek az aranyok vszleg inkabb megfelelnek
# a 2024-es 74+ lakossagnak, mint a 2024-es %-ok...
# -> Ezeket a 2009-es %-okat szoroztam meg a 74+ csoport teljes meretevel

l_dem$vegzettseg$teljes <- with(list(x_val_74plus=as.numeric(l_dem$stadat_nep0003 %>% 
            filter(grepl("esen",nem) & kor_num>74 & ev==2025) %>% 
            summarise(sum(value)) ),
      x_val_18_74=as.numeric(l_dem$stadat_nep0003 %>% 
            filter(grepl("esen",nem) & kor_num>=18 & kor_num<=74 & ev==2025) %>% 
            summarise(sum(value))) ),
# 74+
  bind_rows(
  l_dem$vegzettseg[["15_74_props"]] %>% filter(Év==2009) %>%
    mutate(szam=x_val_74plus*prop,korcsoport="74+"),
# 18-74
  l_dem$vegzettseg[["15_74_props"]] %>% filter(Év==2024) %>%
    mutate(szam=x_val_18_74*prop,korcsoport="18-74")      ) %>%
    group_by(vegzettseg) %>%
    summarise(szam=sum(szam)) %>%
    mutate(prop=szam/sum(szam[!grepl("Összesen",vegzettseg)])) %>%
    filter(!vegzettseg %in% "Összesen")
)

l_dem$vegzettseg$kozos_vegzettseg_kateg=c("≤8 általános","középfokú-szakmunkás",
                        "középfokú-érettségi","felsőfokú")

# kozos kategoriak letrehozasa
l_dem$vegzettseg$teljes <- with(l_dem$vegzettseg, {
l_dem$vegzettseg$teljes %>%
  mutate(vegzettseg_kozos=case_when(
      grepl("általános iskol",vegzettseg,ignore.case=T) ~ grep("általános",kozos_vegzettseg_kateg,value=T),
      grepl("érettségi nélkül, szakmai",vegzettseg) ~ grep("szakmunkás",kozos_vegzettseg_kateg,value=T),
      grepl("érettségivel",vegzettseg) ~ grep("érettségi",kozos_vegzettseg_kateg,value=T),
      grepl("felsőfokú",vegzettseg,ignore.case=T) ~ grep("felsőfokú",kozos_vegzettseg_kateg,value=T)
    ))                    
})

# Median/21kut kategoriak
# unique((l_part_data$median$`2025_08` %>% filter(tipus %in% "VÉGZETTSÉG"))$kateg)
for (k_name in names(l_part_data$median) ) {
l_part_data$median[[k_name]]$VÉGZETTSÉG <- l_part_data$median[[k_name]]$VÉGZETTSÉG %>%
  mutate(vegzettseg_kozos=case_when(
      grepl("általános",kateg) ~ grep("általános",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("szakmunkás",kateg,ignore.case=T) ~ grep("szakmunkás",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("érettségi",kateg,ignore.case=T) ~ grep("érettségi",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("felsőfokú",kateg,ignore.case=T) ~ grep("felsőfokú",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
        .default=kateg)) %>%
  rename(kateg_eredeti=kateg,kateg=vegzettseg_kozos)
}
rm(k_name)
# "Legfeljebb 8 általános", "Szakmunkásképző", "Érettségi/szakérettségi", "Felsőfokú"

# 21kut
# unique(l_part_data$`21_kut`$`2025_08`$vegzettseg$vegzettseg)
# "8 általános" , "szakmunkásképző, szakiskola" , "érettségi", "felsőfokú végzettség" 
l_part_data$`21_kut`$`2025_08`$vegzettseg <- l_part_data$`21_kut`$`2025_08`$vegzettseg %>%
  mutate(vegzettseg_kozos=case_when(
      grepl("általános",vegzettseg) ~ grep("általános",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("szakmunkás",vegzettseg,ignore.case=T) ~ grep("szakmunkás",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("érettségi",vegzettseg,ignore.case=T) ~ grep("érettségi",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("felsőfokú",vegzettseg,ignore.case=T) ~ grep("felsőfokú",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
        .default=vegzettseg))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# JOINT PLOTS

# 21 kut
l_plot$`21_kut` <- bind_rows(
# vegzettseg szerint
left_join(
l_part_data$`21_kut`$`2025_08`$vegzettseg,
l_dem$vegzettseg$teljes %>%
  select(vegzettseg_kozos,szam) %>% 
  rename(kateg_telj_nep=szam) %>%
  group_by(vegzettseg_kozos) %>%
  summarise(kateg_telj_nep=sum(kateg_telj_nep)) ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="végzettség",
         datum="2025/08" ) %>%
  rename(kateg=vegzettseg_kozos) %>%
  select(!vegzettseg) %>%
  relocate(arány,.after=kateg_telj_nep) %>%
  relocate(kateg_tipus,.before=part),
# teljes nepesseg
 l_part_data$`21_kut`$`2025_08`$teljes_nepesseg %>%
  mutate(kateg_tipus="teljes népesség", 
        kateg_telj_nep=l_dem$teljes_felnott_nep_2025,
        valasztok_szama=arány*kateg_telj_nep,
        kateg="teljes népesség" ),
 # telepules-tipus
 left_join(l_part_data$`21_kut`$`2025_06`$telep_tipus, 
          l_dem$telep_tipus %>% group_by(kateg) %>% 
            summarise(kateg_telj_nep=sum(n_valpolg)) ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep) %>%
  arrange(desc(row_number()))
  ) %>%
  mutate(partnev_kozos=case_when(
                    grepl("Fidesz",part) ~ "Fidesz",
                    grepl("egyéb|más párt",part,ignore.case=T) ~ "más\npárt", 
                    grepl("Kutya",part,ignore.case=T) ~ "MKKP",
                    grepl("TISZA",part,ignore.case=T) ~ "TISZA", 
                    grepl("Pártnélküli|bizonytalan",part,ignore.case=T) ~ "pártnélk/\nbizonyt.",
                    .default=part      ) ,
    partnev_kozos=factor(partnev_kozos, # gsub("Mi Hazánk","MiHaz",partnev_kozos),
            levels=c("TISZA","Fidesz","Mi Hazánk","DK","MKKP","más\npárt","pártnélk/\nbizonyt.")) ) %>%
  group_by(kateg,datum) %>%
  mutate(kateg=factor(gsub("középfokú-","",kateg),
            levels=c("teljes népesség",
                    gsub("középfokú-","",l_dem$vegzettseg$kozos_vegzettseg_kateg),
                    rev(unique(l_part_data$`21_kut`$`2025_06`$telep_tipus$kateg))    ) ),
         kateg_nev_meret_str=paste0(kateg," (",round(sum(valasztok_szama,na.rm=T)/1e6,2),"m)" ),
         kateg_nev_arany_str=paste0(kateg," (",arány*100,"%)" ),
         partnev_kozos_aggr=partnev_kozos
    ) # close mutate
# reorder factors
l_plot$`21_kut`$kateg_nev_meret_str <- factor(l_plot$`21_kut`$kateg_nev_meret_str,
                levels=unlist(lapply(c(F,T), \(x) 
                  grep("teljes",unique(l_plot$`21_kut`$kateg_nev_meret_str),value=T,invert=x)))  )

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# render
l_plot$`21_kut` %>%
ggplot(aes(x=partnev_kozos,y=valasztok_szama/1e3,fill=datum)) +
  # facet_wrap(~kateg_nev_meret_str,scales="free",drop=T) +            # facet by kateg
  facet_manual(vars(kateg_nev_meret_str),scales="free",design="AA##\nBCDE\nFGHI") + # 
  geom_col(position=position_dodge2(),alpha=0.5,color="black",linewidth=1/3) + 
  # position=position_dodge2(width=0.9,preserve="single")
  labs(x="",y="szavazók száma (ezer)", fill="") +
  geom_text(aes(label=round(valasztok_szama/1e4)*10), 
    position=position_dodge2(width=0.9,preserve="single"),vjust= -0.3,size=3) +
  scale_y_continuous(expand=expansion(mult=c(0.005,0.09)),
              limits=function(x) c(0,max(max(x),1.05e3)) ) +
  ggtitle("21 KUTATÓKÖZPONT: nem, végzettség és településtípus szerint lebontott pártpreferenciák a teljes népességben") +
  theme_bw() + l_plot$standard_theme +
  theme(axis.text.x=element_text(vjust=0.5,hjust=1),
        strip.text=element_text(size=18)) # ,legend.position="top"
# save
if (F) {
  ggsave(filename="plots/21kut_2025_04_06_08_telj_vegz_teleptipus.png",
          device="png",width=48,height=28,units="cm")
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Median plot

# kozos dataframe letrehozasa
l_plot$median <- bind_rows(
# teljes nepesseg
  bind_rows(l_part_data[["median"]]$`2025_06`$telj_nepesseg_partok,
            l_part_data[["median"]]$`2025_08`$telj_nepesseg_partok ) %>%
  mutate(kateg_tipus="teljes népesség", 
        kateg_telj_nep=l_dem$teljes_felnott_nep_2025,
        valasztok_szama=arány*kateg_telj_nep) %>%
    relocate(c(kateg_tipus,kateg_telj_nep),.before=kateg),
# NEM
left_join(
  bind_rows(
    l_part_data$median$`2025_06`$NEM,
    l_part_data$median$`2025_08`$NEM), 
  l_dem$NEM %>% rename(kateg_telj_nep=value) ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="nem"),
# ELETKOR
  left_join(
  bind_rows(l_part_data$median$`2025_06`$ÉLETKOR,
    l_part_data$median$`2025_08`$ÉLETKOR), 
  l_dem$korszerk_csop %>% rename(kateg_telj_nep=szam) ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="ELETKOR" ),
# VÉGZETTSÉG  
left_join(
  bind_rows(l_part_data$median$`2025_06`$VÉGZETTSÉG,
  l_part_data$median$`2025_08`$VÉGZETTSÉG),
  l_dem$vegzettseg$teljes %>%
      select(vegzettseg_kozos,szam) %>% 
      rename(kateg_telj_nep=szam) %>%
  group_by(vegzettseg_kozos) %>%
  summarise(kateg_telj_nep=sum(kateg_telj_nep)) %>%
  rename(kateg=vegzettseg_kozos)   
  ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="végzettség") %>%
  relocate(arány,.after=kateg_telj_nep) %>%
  relocate(kateg_tipus,.before=part),
 # telepules-tipus
 left_join(
   bind_rows(l_part_data$median$`2025_06`$TELEPÜLÉSTÍPUS,
     l_part_data$median$`2025_08`$TELEPÜLÉS),
   l_dem$telep_tipus %>% group_by(kateg) %>% 
            summarise(kateg_telj_nep=sum(n_valpolg)) ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="településtípus") %>%
  arrange(desc(row_number()))
  ) %>%
  mutate(part=gsub("\\*","",part),
    partnev_kozos=case_when(
                    grepl("TISZA|Tisza",part,ignore.case=T) ~ "TISZA",
                    grepl("Fidesz",part) ~ "Fidesz",
                    grepl("más pártok és pártnélküliek",part,ignore.case=T) ~ "más párt/\npártnélk.",
                    grepl("^Pártnélküli$|^pártnélküli$", part) ~ "pártnélk.",
                    grepl("Egyéb|egyéb", part) ~ "más\npárt",
                    grepl("más párt", part) ~ "más\npárt",
                    grepl("Kutya",part,ignore.case=T) ~ "MKKP",
                    .default=part ),
  partnev_kozos_aggr=case_when(
                grepl("más\npárt|pártnélk.", partnev_kozos) ~ "más párt/\npártnélk.",
                    .default=partnev_kozos)        ) %>%
  ungroup() %>%
  mutate(pattern_var=ifelse(partnev_kozos != partnev_kozos_aggr & 
            grepl("más\npárt", partnev_kozos),0.79,0.8)) %>%
  group_by(kateg,datum) %>%
  mutate(kateg=gsub("középfokú-","",kateg),
         kateg_nev_meret_str=paste0(kateg," (",round(sum(valasztok_szama,na.rm=T)/1e6,2),"m)"),
         kateg_nev_arany_str=paste0(kateg," (",arány*100,"%)" )    ) 

# factor levels
l_plot$median$kateg <- factor(l_plot$median$kateg,levels=unique(l_plot$median$kateg))
l_plot$median$kateg_nev_meret_str <- factor(l_plot$median$kateg_nev_meret_str,
                levels=unlist(lapply(c(F,T), \(x) 
                  grep("teljes",unique(l_plot$median$kateg_nev_meret_str),value=T,invert=x)))  )
# partnev_kozos
l_plot$median$partnev_kozos <- factor(l_plot$median$partnev_kozos,
  levels=unlist(lapply(c(T,F), \(x) grep("pártnélk|más",
        unique(l_plot$median$partnev_kozos),value=T,invert=x))) )
# partnev_kozos_aggr
l_plot$median$partnev_kozos_aggr <- factor(l_plot$median$partnev_kozos_aggr,
  levels=unlist(lapply(c(T,F), \(x) grep("pártnélk|más",
        unique(l_plot$median$partnev_kozos_aggr),value=T,invert=x))) )

### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# render

l_plot$median %>%
  arrange(pattern_var) %>%
ggplot(aes(x=partnev_kozos_aggr,y=valasztok_szama/1e3,
  fill=datum, group=datum )) + # pattern = partnev_kozos,
  facet_manual(vars(kateg_nev_meret_str),scales="free",
    design="AAAA# \n BC### \n DEFGH \n IJKL# \n MNOOP") + # 
  geom_col(aes(alpha=pattern_var),position=position_dodge2(), # preserve="single"
          color="black",linewidth=1/3) + 
  guides(alpha="none") +
  labs(x="",y="szavazók száma (ezer)", fill="",
    caption="2025/06: halványabb színű oszlopok=más párt, kevésbé halvány=pártnélküli.
              2025/08-tól ez a két csoport egy közös \"más párt/pártnélküli\" kategóriában van") +
  geom_text(aes(label=round(valasztok_szama/1e4)*10), 
    position=position_dodge2(width=0.9),vjust= -0.3,size=4) + # ,preserve="single"
  scale_y_continuous(expand=expansion(mult=c(0.005,0.118)) ) + 
  expand_limits(y=c(0,1100)) +
  ggtitle("MEDIÁN: nem, végzettség és településtípus szerint lebontott pártpreferenciák a teljes népességben") +
  theme_bw() + l_plot$standard_theme + # 
  theme(axis.text.x=element_text(angle=0),
        plot.caption=element_text(size=10), # ,vjust=0.5,hjust=1
        strip.text=element_text(size=18),legend.position="top")
# save
if (F) {
  ggsave(filename="plots/Median_2025_06_08_telj_vegz_teleptipus.png",
    device="png",width=48,height=35,units="cm")
}

### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# segment into sep datafrs for datawrapper

if (F) {
lapply(unique(l_plot$median$kateg_tipus), \(x_nev)
bind_rows(
  l_plot$`21_kut` %>% mutate(cég="21kut"), 
  l_plot$median %>% mutate(cég="MEDIÁN")) %>%
  mutate(valasztok_szama=round(valasztok_szama),
          partnev_kozos=ifelse(grepl("más|egyéb|pártnélk|bizonyt",partnev_kozos),
            "más párt/bizonytalan/pártnélküli",as.character(partnev_kozos) )) %>% # datum=ym(datum)
  filter(kateg_tipus %in% x_nev) %>%
  group_by(kateg,partnev_kozos,datum,cég) %>%
  summarise(valasztok_szama=sum(valasztok_szama)) %>%
  select(c(kateg,partnev_kozos,datum,cég,valasztok_szama)) %>%
  mutate(valasztok_szama=round(valasztok_szama/1e4)*1e4) %>%
  pivot_wider(names_from=c(cég),values_from=valasztok_szama) %>%
  write_csv(file = paste0("l_plot_",gsub(" ","",x_nev),".csv")) )
}
