# LOAD PACKAGES
source("functions.R")
### ### ### ### ### ### ### ### ### ### ### ### ### 

l_dem <- list()
l_part_data <- list()

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Partpreferencia

# 21kut, telj. nepesseg
l_part_data$`21_kut`$teljes_nepesseg <- read_csv(
            "input_files/kozvkut_adatok/21kut_teljes_nepesseg.csv") %>%
  filter(grepl("teljes",kateg)) %>%
  pivot_longer(!c(kateg,part),names_to = "datum") %>%
  mutate(value=value/100,
        datum=convert_hu_date(datum)  ) %>%
  rename(arány=value)

# 21KK, NEM szerint
# source: https://flo.uri.sh/visualisation/24922340/embed
l_part_data[["21_kut"]]$nem <- read_csv(
  "input_files/kozvkut_adatok/21kut_NEM.csv") %>%
  pivot_longer(!c(kateg,datum),names_to="part")  %>%
  mutate(arány=value/100,
         datum=convert_hu_date(datum)  ) %>% 
  select(!value) %>%
  mutate(part=ifelse(grepl("Kutya|DK|más párt",part),"más párt",part)) %>%
  group_by(kateg,datum,part) %>%
  summarise(arány=sum(arány))
  

# 21KK, ELETKOR szerint
l_part_data[["21_kut"]]$eletkor <- read_csv(
  "input_files/kozvkut_adatok/21kut_eletkor.csv") %>%
  pivot_longer(!c(kateg,datum),names_to="part")  %>%
  mutate(arány=value/100,
         datum=convert_hu_date(datum)  ) %>% 
  select(!value) %>%
  mutate(part=ifelse(grepl("Kutya|DK|más párt",part),"más párt",part)) %>%
  group_by(kateg,datum,part) %>%
  summarise(arány=sum(arány))

# 21KK, vegzettseg szerint
# source: https://flo.uri.sh/visualisation/24922340/embed
l_part_data[["21_kut"]]$vegzettseg <- read_csv(
  "input_files/kozvkut_adatok/21kut_vegzettseg.csv") %>%
  pivot_longer(!c(kateg,datum),names_to="part")  %>%
  mutate(arány=value/100,
         datum=convert_hu_date(datum)  ) %>% 
  select(!value) %>%
  mutate(part=ifelse(grepl("Kutya|DK|más párt",part),"más párt",part)) %>%
  group_by(kateg,datum,part) %>%
  summarise(arány=sum(arány))

# 21KK, telepulestipus
# source: https://flo.uri.sh/visualisation/23976053/embed
l_part_data$`21_kut`$telep_tipus <- read_csv(
  "input_files/kozvkut_adatok/21kut_telepulestipus.csv") %>%
  pivot_longer(!c(kateg,datum),names_to = "part") %>%
  rename(arány=value) %>% 
  mutate(arány=arány/100) %>%
  mutate(kateg_tipus="településtípus",
         datum=convert_hu_date(datum)  ) %>%
  rename(kateg_eredeti=kateg) %>%
  mutate(part=ifelse(grepl("Kutya|Mi Haz|DK|más párt",part),"más párt",part)) %>%
  group_by(kateg_eredeti,datum,part) %>%
  summarise(arány=sum(arány))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Median adatok betoltese 

median_periods <- c("2025_06", "2025_08", "2025_11", "2026_01", "2026_02")

for (p in median_periods) {
  # container
  l_part_data[["median"]][[p]] <- list()
  
  # demographic splits
  l_part_data[["median"]][[p]] <- load_median_demog(p)
  
  # teljes népesség
  l_part_data[["median"]][[p]]$telj_nepesseg_partok <- load_median_fullpop(p)
  
  # 2025_06-specific post-processing
  if (p == "2025_06") {
    # rename KORCSOPORT -> ÉLETKOR if present
    names(l_part_data$median$`2025_06`)[
      names(l_part_data$median$`2025_06`) %in% "KORCSOPORT"
    ] <- "ÉLETKOR"
    
    # TELEPÜLÉSTÍPUS -> TELEPÜLÉS
    l_part_data$median$`2025_06`$TELEPÜLÉS <- l_part_data$median$`2025_06`$TELEPÜLÉSTÍPUS
    l_part_data$median$`2025_06`$TELEPÜLÉSTÍPUS <- NULL
  }
}

rm(p,median_periods)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# DEMOGRAFIA

# KORSZERKEZET
# source: https://www.ksh.hu/stadat_files/nep/en/nep0003.html
l_dem$stadat_nep0003 <- read_delim(
  "input_files/stadat-nep0003-22.1.1.3-hu.csv",
      skip=1,locale=locale(encoding="CP1250"),
      delim=";",trim_ws=T) %>%
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

# DE!!! ez a teljes Magyaro-i lakossag, nem a valasztasra jogosultak szama
# ez utobbi itt erheto el: https://www.valasztas.hu/valasztopolgarok-szama-valasztastipusonkent
# 2025/10/12: 7635775
# csinalunk egy korrekciot, hogy a 18>= lakossagot felszorozzuk a ketto aranyaval...
# mivel a csak valasztojoguakra nincsenek reszletes adatok
l_dem$stadat_nep0003 <- with(list(valjog_belfold=7635775,
  teljes_nep=sum((l_dem$stadat_nep0003 %>% 
      filter(ev %in% 2025 & nem %in% "Összesen" & kor_num>=18))$value)),
l_dem$stadat_nep0003 %>%
  mutate(value_valjog=ifelse(ev==2025 & kor_num>=18,
    value*valjog_belfold/teljes_nep,NA)) %>%
  rename(value_telj_nep=value) %>% rename(value=value_valjog)
)

# plot
# if (F) {
#   # ez a teljes >=18 lakossag
# l_dem$stadat_nep0003 %>%
#   filter(grepl("esen",nem) & ev>2010) %>%
#   group_by(ev,nem) %>%
#   summarise(valasztok=sum(value[kor_num>=18])/1e3,
#             kiskoruak=sum(value[kor_num<18])/1e3) %>%
#   pivot_longer(!c(ev,nem)) %>%
# ggplot(aes(x=ev,y=value)) + 
#   facet_wrap(~name,scale="free_y") +
#   geom_line() + geom_point() +
#   xlab("") + ylab("ezer fo") + labs(color="") +
#   scale_x_continuous(breaks = 2010:2025) +
#   theme_bw() + l_plot$standard_theme
# }

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

l_dem$val_jog_nep_2025 <- as.numeric(
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
# vmivel TOBB mint a 2025 val.jogosultak 
# (https://www.valasztas.hu/valasztopolgarok-szama-valasztastipusonkent)
# , vszleg demografiai fogyas miatt
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
    mutate(telepules=ifelse(grepl("Budap",`Helység megnevezése`),
            "Budapest",`Helység megnevezése`)) %>%
    filter(!grepl("fővárosi kerület",`Helység jogállása`)) %>%
    group_by(telepules,`Helység jogállása`)
  )

# telep tipus, teljes lakossag
l_dem$telep_tipus <- l_dem$telep_lista_valpolg_tipus %>% 
  rename(kateg_ksh=`Helység jogállása`) %>%
  group_by(kateg_ksh) %>% 
  summarise(kateg_tipus="településtípus",
            n_valpolg2022=sum(n_valpolg),
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

# scale this by 2025 data on all eligible to vote
l_dem$telep_tipus$n_valpolg <- with(l_dem$telep_tipus,
  n_valpolg2022*l_dem$val_jog_nep_2025/sum(n_valpolg2022))

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# 21 kut kategoriak osszehangolasa Median-nal

l_part_data$`21_kut`$telep_tipus <- l_part_data$`21_kut`$telep_tipus %>%
  mutate(kateg=case_when(
                grepl("község|Község",kateg_eredeti,ignore.case=T) ~ grep("község",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                grepl("megyei|Megyei",kateg_eredeti,ignore.case=T) ~ grep("megyei",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                grepl("Egyéb|egyéb",kateg_eredeti,ignore.case=T) ~ grep("egyéb város",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                grepl("Főváros",kateg_eredeti,ignore.case=T) ~ grep("főváros",
                            unique(l_part_data$median$`2025_08`$TELEPÜLÉS$kateg),value=T),
                .default=kateg_eredeti) )


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# VEGZETTSEG szerint

# demografia: 15-74 eves korosztaly
l_dem$vegzettseg[["15_74_props"]] <- read_csv(
  "input_files/stadat-okt0001-23_osszes.csv") %>%
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
      grepl("általános iskol",vegzettseg,ignore.case=T) ~ 
              grep("általános",kozos_vegzettseg_kateg,value=T),
      grepl("érettségi nélkül, szakmai",vegzettseg) ~ 
              grep("szakmunkás",kozos_vegzettseg_kateg,value=T),
      grepl("érettségivel",vegzettseg) ~ 
              grep("érettségi",kozos_vegzettseg_kateg,value=T),
      grepl("felsőfokú",vegzettseg,ignore.case=T) ~ 
              grep("felsőfokú",kozos_vegzettseg_kateg,value=T)
    ))                    
})

# Median/21kut kategoriak
# unique((l_part_data$median$`2025_08` %>% filter(tipus %in% "VÉGZETTSÉG"))$kateg)
for (k_name in names(l_part_data$median) ) {
  if (!is.null(l_part_data$median[[k_name]]$VÉGZETTSÉG)) {
l_part_data$median[[k_name]]$VÉGZETTSÉG <- l_part_data$median[[k_name]]$VÉGZETTSÉG %>%
  mutate(vegzettseg_kozos=case_when(
      grepl("általános",kateg) ~ 
              grep("általános",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("szakmunkás",kateg,ignore.case=T) ~ 
              grep("szakmunkás",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("érettségi",kateg,ignore.case=T) ~ 
              grep("érettségi",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("felsőfokú",kateg,ignore.case=T) ~ 
              grep("felsőfokú",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
        .default=kateg)) %>%
  select(!c(kateg)) %>% # kateg_eredeti,
  rename(kateg=vegzettseg_kozos) # kateg_eredeti=kateg,
  }
  }
rm(k_name)
# "Legfeljebb 8 általános", "Szakmunkásképző", "Érettségi/szakérettségi", "Felsőfokú"

# 21kut
# unique(l_part_data$`21_kut`$`2025_08`$vegzettseg$vegzettseg)
# "8 általános" , "szakmunkásképző, szakiskola" , "érettségi", "felsőfokú végzettség" 
l_part_data$`21_kut`$vegzettseg <- l_part_data$`21_kut`$vegzettseg %>%
  mutate(kateg=case_when(
      grepl("általános",kateg) ~ 
            grep("általános",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("szakmunkás",kateg,ignore.case=T) ~ 
            grep("szakmunkás",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("érettségi",kateg,ignore.case=T) ~ 
              grep("érettségi",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
      grepl("felsőfokú",kateg,ignore.case=T) ~ 
              grep("felsőfokú",l_dem$vegzettseg$kozos_vegzettseg_kateg,value=T),
        .default=kateg))

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# JOINT PLOTS

# 21 kut
l_plot$`21_kut` <- bind_rows(
# teljes nepesseg
 l_part_data$`21_kut`$teljes_nepesseg %>%
  mutate(kateg_tipus="teljes népesség", 
        kateg_telj_nep=l_dem$val_jog_nep_2025,
        valasztok_szama=arány*kateg_telj_nep,
        kateg="teljes népesség"),
### ### ### ### ### ### ### ### ### ### ### 
# vegzettseg szerint
left_join(
  # párt adatok
l_part_data$`21_kut`$vegzettseg,
  # %>% filter(!datum %in% "2026/03"),
  # demogr adatok
with(list(l_dem_vegz=l_dem$vegzettseg$teljes %>%
  select(vegzettseg_kozos,szam) %>% 
  rename(kateg_telj_nep=szam) %>%
  group_by(vegzettseg_kozos) %>%
  summarise(kateg_telj_nep=sum(kateg_telj_nep)) ),
    bind_rows(
      l_dem_vegz,
      l_dem_vegz %>%
        mutate(vegzettseg_kozos_aggreg=ifelse(
          grepl("középfokú",vegzettseg_kozos),"középfokú",vegzettseg_kozos)) %>%
      group_by(vegzettseg_kozos_aggreg) %>%
      summarise(kateg_telj_nep=sum(kateg_telj_nep)) %>%
      filter(grepl("középfokú",vegzettseg_kozos_aggreg)) %>%
      rename(vegzettseg_kozos=vegzettseg_kozos_aggreg) ) %>%
    rename(kateg=vegzettseg_kozos))
  ) %>%
  mutate(kateg=gsub("középfokú-","",kateg),
    valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="végzettség" ) %>%
  # select(!vegzettseg) %>%
  relocate(arány,.after=kateg_telj_nep) %>%
  relocate(kateg_tipus,.before=part),
### ### ### ### ### ### ### ### ### ### ### 
 # telepules-tipus
 left_join(
   # párt adatok
   l_part_data$`21_kut`$telep_tipus, 
   # demogr adatok
   l_dem$telep_tipus %>% 
            group_by(kateg) %>% 
            summarise(kateg_telj_nep=sum(n_valpolg))
   ) %>%
  mutate(kateg_tipus="településtípus",
    valasztok_szama=arány*kateg_telj_nep) %>%
  arrange(desc(row_number())),
  ### ### ### ### ### ### ### ### ### ### ### 
  # eletkor
  left_join(
    # bind_rows(lapply(l_part_data$median, `[[`, "ÉLETKOR")), 
    l_part_data$`21_kut`$eletkor,
    l_dem$korszerk_csop %>% rename(kateg_telj_nep=szam) ) %>%
      mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="ELETKOR" ),
  ### ### ### ### ### ### ### ### ### ### ### 
  # NEM
  left_join(
  l_part_data$`21_kut`$nem,
  l_dem$NEM %>% rename(kateg_telj_nep=value) ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="nem")
  )

# clean party names
l_plot$`21_kut` <- l_plot$`21_kut` %>% # bind_rows close
  mutate(partnev_kozos=case_when(
                    grepl("Fidesz",part) ~ "Fidesz",
                    grepl("egyéb|más párt",part,ignore.case=T) ~ "más\npárt", 
                    grepl("Kutya",part,ignore.case=T) ~ "MKKP",
                    grepl("TISZA",part,ignore.case=T) ~ "TISZA", 
                    grepl("Pártnélküli|pártnélk|bizonytalan",
                          part,ignore.case=T) ~ "pártnélk./\nbizonyt.",
                    .default=part      ) ,
    partnev_kozos=factor(partnev_kozos, # gsub("Mi Hazánk","MiHaz",partnev_kozos),
            levels=c("TISZA","Fidesz","Mi Hazánk","DK","MKKP",
                      "más\npárt","pártnélk./\nbizonyt.")) ) 
### ### ### ### ### ### ### ### 
# factors for categs
l_plot$`21_kut` <- l_plot$`21_kut` %>%
  group_by(kateg,datum) %>%
  mutate(kateg=factor(kateg, # gsub("középfokú-","",kateg),
            levels=unique(l_plot$`21_kut`$kateg)),
         kateg_nev_meret_str=paste0(kateg," (",round(unique(kateg_telj_nep)/1e6,2),"m)" ),
         # kateg_nev_arany_str=paste0(kateg," (",arány*100,"%)" ),
         partnev_kozos_aggr=partnev_kozos
    ) # close mutate

# reorder factors
l_plot$`21_kut`$kateg_nev_meret_str <- factor(l_plot$`21_kut`$kateg_nev_meret_str,
                levels=unlist(lapply(c(F,T), \(x) 
                  grep("teljes",unique(l_plot$`21_kut`$kateg_nev_meret_str),
                    value=T,invert=x)))  )
l_plot$`21_kut`$datum <- factor(l_plot$`21_kut`$datum,
  levels=sort(unique(l_plot$`21_kut`$datum)))


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Median plot

# kozos dataframe letrehozasa
l_plot$median <- bind_rows(
# teljes nepesseg
  bind_rows(
  lapply(l_part_data[["median"]], `[[`, "telj_nepesseg_partok") ) %>%
  mutate(kateg_tipus="teljes népesség", 
        kateg_telj_nep=l_dem$val_jog_nep_2025,
        valasztok_szama=arány*kateg_telj_nep) %>%
    relocate(c(kateg_tipus,kateg_telj_nep),.before=kateg),
# NEM
left_join(
  bind_rows(
  lapply(l_part_data$median, `[[`, "NEM")), 
  l_dem$NEM %>% rename(kateg_telj_nep=value) ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="nem"),
# ELETKOR
  left_join(
    bind_rows(
      lapply(l_part_data$median, `[[`, "ÉLETKOR")), 
  l_dem$korszerk_csop %>% rename(kateg_telj_nep=szam) 
    ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="ELETKOR" ),
# VÉGZETTSÉG  
left_join(
  bind_rows(
      lapply(l_part_data$median, `[[`, "VÉGZETTSÉG")),
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
  ### ### ### ### ### ### ### ### ### ### ### ### ### 
 # telepules-tipus
 left_join(
   bind_rows(
  lapply(l_part_data$median, `[[`, "TELEPÜLÉS")),
   l_dem$telep_tipus %>% group_by(kateg) %>% 
            summarise(kateg_telj_nep=sum(n_valpolg)) ) %>%
  mutate(valasztok_szama=arány*kateg_telj_nep,
         kateg_tipus="településtípus") %>%
  arrange(desc(row_number()))
  ) %>%
  # END OF bind_rows
  mutate(part=gsub("\\*","",part),
    partnev_kozos=case_when(
                    grepl("TISZA|Tisza",part,ignore.case=T) ~ "TISZA",
                    grepl("Fidesz",part) ~ "Fidesz",
                    grepl("más pártok és pártnélküliek",part,ignore.case=T) ~ 
                            "más párt/\npártnélk.",
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
         kateg_nev_meret_str=paste0(kateg,
           " (",round(kateg_telj_nep/1e6,2),"m)"),
      #   kateg_nev_arany_str=paste0(kateg," (",arány*100,"%)" )
    ) 

# factor levels
l_plot$median$kateg <- factor(l_plot$median$kateg,levels=unique(l_plot$median$kateg))
l_plot$median$kateg_nev_meret_str <- factor(
          l_plot$median$kateg_nev_meret_str,
                levels=unlist(lapply(c(F,T), \(x) 
                  grep("teljes",unique(l_plot$median$kateg_nev_meret_str),
                    value=T,invert=x)))  )
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
# SAVE IN wide format (FLOURISH)

lapply(unique(l_plot$median$kateg_tipus),
  function(x_kat) {

xx <- bind_rows(
  l_plot$median %>% mutate(cég="MEDIÁN"),
  l_plot$`21_kut` %>% mutate(cég="21KK") 
  ) %>% 
  filter(!grepl("Jobbik",part)) %>% 
  group_by(datum,kateg_tipus,kateg_nev_meret_str,
          kateg_telj_nep,partnev_kozos_aggr,cég) %>%
  summarise(valasztok_szama=round(sum(valasztok_szama)),
            szazalek=round(sum(arány)*100)) %>% 
  mutate(valasztok_szama_10e=round(valasztok_szama/1e4)*1e4) %>%
  # select(!c(pattern_var,valasztok_szama,arány,
  #           partnev_kozos,part,kateg_nev_arany_str,kateg_eredeti)) %>%
  filter(kateg_tipus %in% x_kat) 

  if ( any(grepl("21", unique(xx$cég)))  ) {
  xx <- xx %>%
  pivot_wider(names_from=cég,values_from=szazalek,
            names_glue="{cég} (%)") %>%
  rowwise() %>%
  mutate(
    `21KK (ezer választó)`=ifelse(is.na(`21KK (%)`),
          NA,valasztok_szama_10e/1e3),
    `MEDIÁN (ezer választó)`=ifelse(is.na(`MEDIÁN (%)`),
           NA,valasztok_szama_10e/1e3) ) %>%
  select(!valasztok_szama_10e) 
  } else {
      xx <- xx %>%
      mutate(`MEDIÁN (ezer választó)`=valasztok_szama_10e/1e3,
             `MEDIÁN (%)`=szazalek ) %>% 
      select(!c(valasztok_szama_10e,szazalek)) 
      }
    
  # FORMAT and SAVE
    df_wide <- xx %>%
      ungroup() %>%
      select(!c(kateg_telj_nep)) %>%
    mutate( # kateg_telj_nep=round(kateg_telj_nep),
           partnev_kozos_aggr={
      cleaned <- partnev_kozos_aggr %>%
        gsub("/\n", "/", .) %>%
        gsub("\n", " ", .)
      factor(cleaned, levels = unique(cleaned))    } ) %>% 
  pivot_longer(matches("MED|21")) %>% 
  filter(!is.na(value)) %>%
  pivot_wider(names_from = name,values_from = value) 
    
    # SAVE wide format (bar chart)
    df_wide %>% 
      select(!valasztok_szama) %>%
  write_csv(file=paste0("output/wide_format_bar_charts/l_plot_",
    gsub(" ","",x_kat),".csv"))
    
    # wide format, panels by demogr categ (for trend lines)
    df_wide %>% 
        select(!valasztok_szama) %>%
        ungroup() %>%
        pivot_longer(cols = matches("21|Med"),names_to = "pollster") %>% 
        filter(!is.na(value)) %>%
        pivot_wider(names_from = partnev_kozos_aggr,values_from=value) %>%
        arrange(desc(pollster)) %>%
    write_csv(file=paste0("output/wide_format_trend_charts/l_plot_",
          gsub(" ","",x_kat),".csv"))
    
    ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
    ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
    # panels by party
    if (!grepl("teljes",x_kat)) {
  df_by_party <- df_wide %>%
      select(!contains("%")) %>%
      pivot_longer(matches("MED|21"),names_to = "pollster") %>% 
      filter(!is.na(value)) %>%
      group_by(datum,partnev_kozos_aggr,pollster) %>%
      mutate(total_by_party=sum(valasztok_szama),
              perc_of_party=round(100*valasztok_szama/total_by_party,1)) %>%
      select(!valasztok_szama) %>%
      pivot_longer(cols = c(value,perc_of_party),names_to="num_type") %>%
      rowwise() %>%
      mutate(pollster_type=ifelse(!grepl("perc",num_type),
              paste0(ifelse(grepl("MED",pollster),"MEDIÁN","21KK"),
                      " (ezer választó)"),
              paste0(ifelse(grepl("MED",pollster),"MEDIÁN","21KK"),
                      " (%)")  )) %>%
      ungroup() %>%
      select(!c(pollster,num_type)) %>%
      pivot_wider(names_from=kateg_nev_meret_str,values_from=value) %>%
      arrange(desc(pollster_type)) 
  if (grepl("végz",x_kat)){
  df_by_party <- df_by_party %>%
      filter(!(grepl("21",pollster_type) & datum %in% "2026/03"))
    }
  # SAVE
  write_csv(x = df_by_party, file=paste0("output/wide_format_panel_by_party/l_plot_",
          gsub(" ","",x_kat),".csv"))
      }
    
  }
)

### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# segment into sep datafrs for datawrapper

# abszolut szamok
# if (F) {
#   
# lapply(unique(l_plot$median$kateg_tipus), \(x_nev)
# bind_rows(
#   l_plot$`21_kut` %>% mutate(cég="21kut"), 
#   l_plot$median %>% mutate(cég="MEDIÁN")) %>%
#   mutate(valasztok_szama=round(valasztok_szama),
#           partnev_kozos=ifelse(grepl("más|egyéb|pártnélk|bizonyt",partnev_kozos),
#             "más párt/bizonytalan/pártnélküli",as.character(partnev_kozos) )) %>%
#   filter(kateg_tipus %in% x_nev) %>%
#   group_by(kateg,kateg_nev_meret_str,partnev_kozos,datum,cég) %>%
#   summarise(valasztok_szama=sum(valasztok_szama)) %>%
#   select(c(kateg,kateg_nev_meret_str,partnev_kozos,datum,cég,valasztok_szama)) %>%
#   mutate(valasztok_szama=round(valasztok_szama/1e4)*1e4) %>%
#   pivot_wider(names_from=c(cég),values_from=valasztok_szama) %>%
#   filter(!if_all(any_of(c("21kut", "MEDIÁN")), ~ is.na(.x))) %>%
#   write_csv(file=paste0("output/l_plot_",gsub(" ","",x_nev),".csv")) )
# }
# 
# # szazalekok
# if (F) {
# lapply(unique(l_plot$median$kateg_tipus), \(x_nev)
# bind_rows(
#   l_plot$`21_kut` %>% mutate(cég="21kut"), 
#   l_plot$median %>% mutate(cég="MEDIÁN")) %>%
#   mutate(valasztok_szama=round(valasztok_szama),
#           partnev_kozos=ifelse(
#             grepl("más|egyéb|pártnélk|bizonyt",partnev_kozos),
#             "más párt/bizonytalan/pártnélküli",
#             as.character(partnev_kozos) )) %>%
#   filter(kateg_tipus %in% x_nev) %>%
#   group_by(kateg,kateg_nev_meret_str,partnev_kozos,datum,cég) %>%
#   summarise(szazalek=sum(arány)*100) %>%
#   select(c(kateg,kateg_nev_meret_str,
#           partnev_kozos,datum,cég,szazalek)) %>%
#   pivot_wider(names_from=c(cég),values_from=szazalek) %>%
#   filter(!if_all(any_of(c("21kut", "MEDIÁN")), ~ is.na(.x))) %>%
#   write_csv(file=paste0("output/szazalekok/l_plot_",gsub(" ","",x_nev),".csv")) )
# }
### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Median ABRA

# if (F) {
# with(list(), ({
# title_str <- paste0("MEDIÁN: nem, végzettség és településtípus szerint lebontott",
#                     " pártpreferenciák a teljes népességben")
# l_plot$median %>%
#   arrange(pattern_var) %>%
# ggplot(aes(x=partnev_kozos_aggr,y=valasztok_szama/1e3,
#   fill=datum, group=datum )) + # pattern = partnev_kozos,
#   facet_manual(vars(kateg_nev_meret_str),scales="free",
#     design="AAAA# \n BC### \n DEFGH \n IJKL# \n MNOOP") + # 
#   geom_col(aes(alpha=pattern_var),position=position_dodge2(), # preserve="single"
#           color="black",linewidth=1/3) + 
#   guides(alpha="none") +
#   labs(x="",y="szavazók száma (ezer)", fill="",
#     caption=paste0(
#       "2025/06: halványabb színű oszlopok=más párt, kevésbé halvány=pártnélküli.","\n",
#       "2025/08-tól ez a két csoport egy közös \"más párt/pártnélküli\" kategóriában van")) +
#   geom_text(aes(label=round(valasztok_szama/1e4)*10), 
#     position=position_dodge2(width=0.9),vjust= -0.3,size=4) + # ,preserve="single"
#   scale_y_continuous(expand=expansion(mult=c(0.005,0.118)) ) + 
#   expand_limits(y=c(0,1100)) +
#   ggtitle(title_str) +
#   theme_bw() + l_plot$standard_theme + # 
#   theme(axis.text.x=element_text(angle=0),
#         plot.caption=element_text(size=10), # ,vjust=0.5,hjust=1
#         strip.text=element_text(size=18),legend.position="top")
# }) )
# # save
# if (F) {
#   ggsave(filename="plots/Median_2025_06_08_telj_vegz_teleptipus.png",
#     device="png",width=48,height=35,units="cm")
# }
# }

### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# save for shiny app
# saveRDS(l_plot,file = "shiny/l_plot_21kut_median.RDS")

# bind_rows(
#   l_plot$`21_kut` %>% mutate(cég="21kut"), 
#   l_plot$median %>% mutate(cég="MEDIÁN")) %>% 
#   mutate(valasztok_szama=round(valasztok_szama/1e4)*1e4,
#         szazalek=arány*100  ) %>%
#   select(!c(pattern_var,kateg_eredeti,szazalek)) %>% 
#   write_csv(file = "l_plot.csv")


### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# 21 kut eredmenyek abra

# if (F) {
# with(list(), ({
#   title_str <- paste0("21 KUTATÓKÖZPONT: ",
#     "nem, végzettség és településtípus szerint",
#     " lebontott pártpreferenciák a teljes népességben")
# l_plot$`21_kut` %>%
# ggplot(aes(x=partnev_kozos,y=valasztok_szama/1e3,fill=datum)) +
#   # facet_wrap(~kateg_nev_meret_str,scales="free",drop=T) +            # facet by kateg
#   facet_manual(vars(kateg_nev_meret_str),scales="free",design="AA##\nBCDE\nFGHI") + # 
#   geom_col(position=position_dodge2(),alpha=0.5,color="black",linewidth=1/3) + 
#   # position=position_dodge2(width=0.9,preserve="single")
#   labs(x="",y="szavazók száma (ezer)", fill="") +
#   geom_text(aes(label=round(valasztok_szama/1e4)*10), 
#     position=position_dodge2(width=0.9,preserve="single"),vjust= -0.3,size=3) +
#   scale_y_continuous(expand=expansion(mult=c(0.005,0.09)),
#               limits=function(x) c(0,max(max(x),1.05e3)) ) +
#   ggtitle(title_str) +  theme_bw() + l_plot$standard_theme +
#   theme(axis.text.x=element_text(vjust=0.5,hjust=1),
#         strip.text=element_text(size=18)) # ,legend.position="top"
# }) )
# # save
# if (F) {
#   ggsave(filename="plots/21kut_2025_04_06_08_telj_vegz_teleptipus.png",
#           device="png",width=48,height=28,units="cm")
# }
# 
# }  
