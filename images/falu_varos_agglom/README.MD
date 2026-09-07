## Kód és adatforrások

Ez a repo [a "Falu, város, vidék, Budapest" c. Substack-cikkhez](https://mbklt.substack.com/p/falu-varos-videk-budapest) használt adatforrásokat és R kódot tartalmazza - az utóbbival reprodukálhatók a cikkben látható ábrák.

### Útmutató a file-okhoz

- [2010-2026-Median-osszes.Rproj](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/falu_varos_agglom/falu_varos_agglom.Rproj): R projekt file, ezt érdemes megnyitni először, mert betölti a helyes path-t stb.

- [calc_plot.R](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/falu_varos_agglom/calc_plot.R): a 2012-2025 időszakot elemző ábrák kódja

- [hist_comp.R](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/falu_varos_agglom/hist_comp.R): az 1920-2025 közötti történelmi trendeket elemző ábrák kódja

### Adatok

- [adatok folder](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/falu_varos_agglom/adatok): adatfile-ok. Az utóbbi 14 évre vonatkozó településméret adatok a [hu_hnt_lakonepesseg_2012_2025.csv](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/falu_varos_agglom/adatok/hu_hnt_lakonepesseg_2012_2025.csv "hu_hnt_lakonepesseg_2012_2025.csv") file-ban vannak, az agglomerációs zónák településeinek listája a [hu_agglomeracio_telepulesek_2024.csv](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/falu_varos_agglom/adatok/hu_agglomeracio_telepulesek_2024.csv "hu_agglomeracio_telepulesek_2024.csv") file-ban. A történeti adatok a *mek\_[\*].csv* file-okban
- [plots](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/falu_varos_agglom/plots "plots"): ábrák. A történeti ábrák a [hist](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/falu_varos_agglom/plots/hist "hist") subfolder-ben vannak. A tables/ subfolder táblázatos formában összegzi az eredményeket. 
