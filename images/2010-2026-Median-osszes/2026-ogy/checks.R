df_ogy2026 %>%
  filter(lako_nepesseg>=1e3 & lako_nepesseg<=2e3) %>%
  group_by(part) %>%
  summarise(szavazat=sum(szavazat),
            összes_vp=) %>%
  ungroup() %>%
  
df_ogy2026 %>% 
  select(telepules,lako_nepesseg,összes_vp,part,szavazat) %>%
  pivot_wider(values_from = szavazat,names_from = part)  %>% 
  # filter(lako_nepesseg>=2e4 & lako_nepesseg<=4e4 & !grepl("Budap",telepules)) %>%
  filter(lako_nepesseg>=4e4 & !grepl("Budap",telepules)) %>%
  summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)))
