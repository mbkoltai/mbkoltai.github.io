## Kód és adatforrások a "[A NER-váltó választói blokk kialakulása számokban](https://mbklt.substack.com/p/a-ner-valto-valasztoi-blokk-kialakulasa)" című cikkhez

Ez a repo [ehhez a Substack-cikkhez](https://mbklt.substack.com/p/a-ner-valto-valasztoi-blokk-kialakulasa) felhasznált adatforrásokat és R kódot tartalmazza - az utóbbival reprodukálhatók a cikkben látható ábrák.
A cikk rövidített változata a [Telex-en is megjelent](https://telex.hu/belfold/2026/06/14/fidesz-tabor-osszeomlasa-tisza-tabor-felepulese-2022-2026).

### Guide a file-okhoz

At the top of the folder [inflow_progr_immigr/](https://github.com/mbkoltai/TB_det_mod_engl/blob/main/inflow_progr_immigr/) there are scripts to run and evaluate the model. 

- [2010-2026-Median-osszes.Rproj](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/2010-2026-Median-osszes.Rproj): R projekt file, ezt érdemes megnyitni először, mert betölti a helyes path-t stb.

- [main_plots.R](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/main_plots.R): a közvéleménykutatási eredményeket elemző ábrák kódja 

- [post_election.R](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/post_election.R): a 2026-os választások utáni első demográfiai lebontások összehasonlítása a választások előtti felmérésekkel 

- [2026-ogy/telep_plots.R](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/2026-ogy/telep_plots.R): választási eredményeket ábrázolásának a kódja

### Adatok

- [inputs/median_polls.csv](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/inputs/median_polls.csv): összes (általam megtalált) Medián felmérés 2009-2026

- [inputs/val_eredmenyek.csv](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/inputs/val_eredmenyek.csv): választási (országos listás) eredmények 2010-2026, a megjelentek és jogosultak számával

- [inputs/median_zavecz_21kk_osszehas/polling_combined_long.csv](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/inputs/median_zavecz_21kk_osszehas/polling_combined_long.csv): Medián, Závecz és 21KK felmérése 2022-26, a három KVK cég összehasonlítására

- [2026-ogy/adatok/Varmegye_List%C3%A1s_szavazokori_eredmenyek_2026/telepules/ogy2026_listas_telepulesenkent_long.csv](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/2026-ogy/adatok/Varmegye_List%C3%A1s_szavazokori_eredmenyek_2026/telepules/ogy2026_listas_telepulesenkent_long.csv): OGY2026 eredmények településenként. 

- [2026-ogy/adatok/valasztas_2022_telepules.csv](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/2026-ogy/adatok/valasztas_2022_telepules.csv): OGY2022 eredmények településenként

- [2026-ogy/adatok/ep_telepules_eredmenyek_2009_2014_2019_2024.csv](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/2010-2026-Median-osszes/2026-ogy/adatok/ep_telepules_eredmenyek_2009_2014_2019_2024.csv): 2009-2024 EP választási eredmények