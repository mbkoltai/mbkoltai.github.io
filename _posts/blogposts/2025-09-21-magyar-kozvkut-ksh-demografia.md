---
layout: post
title: Pártpreferencia felmérések abszolút számokban
tags: hungary politics elections demographics data-visualisation magyar
excerpt: Nem/kor/végzettség/településtípus szerinti KSH adatok alapján
secondary: blogposts
mathjax: true
---

A lenti ábrák a 21Kutatóközpont és a Medián 2025. évi méréseit integrálják a KSH demográfiai adataival. 
A célom az volt, hogy abszolút számokban is láthassuk ezeknek a közvéleménykutatásoknak a pártpreferencia-számait, különböző demográfiai dimenziókban: a teljes népességben, illetve nem, kor, végzettség és település-típus szerint lebontva.<br>

<b>Háttér</b>

Még ha a felmérések nagyon pontosak is (lennének), a hibahatár alkategóriákra lebontva szinte biztosan nagyobb, mint a teljes mintára nézve. 
Tehát az oszlopok fölötti számokat, amelyek tízezerre kerekítve lettek, nem helyes pontos becsléseknek venni. 
Viszont egyrészt megmutatják, hogy az egyes demográfiai csoportokban (pl. szakmunkás végzettségűek, 65 év felettiek stb.) összesen mennyien vannak.
Másrészt pedig azt, hogy az adott kategóriában hogyan oszlan(nán)ak el az emberek pártpreferencia szerint, <b>ha</b> a mérés tökéletesen pontos lenne. Még ha ez nincs is így, kaphatunk egy hozzávetőleges képet a relatív arányokról: egyrészt a demográfiai csoportok méretéről, másrészt az ezeken belüli hozzávetőleges politikai erőviszonyokról. <br>
Végül pedig, remélhetőleg ezek a demográfiailag lebontott kutatások folytatódni fognak a 2026-os választásokig, így  egy idősort fogunk kapni, amiből talán valamiféle trendek olvashatók majd ki. <br>
Ami a közvéleménykutatók választását illeti: a MEDIÁN 2002 óta készült választás előtti előrejelzéseit <a href='https://docs.google.com/spreadsheets/d/1NUEgN7eV7MoZqi8dd9-xAzWxY_u2u_HYImV6l_U5qDE/' target='_blank'>itt gyűjtöttem össze</a>, a tényleges eredményekkel összehasonlítva. Ezeken látható, hogy 2002 óta minden választáson helyesen jelezték előre a választás győztesét, illetve, hogy átlagosan 2-3%-ot tévedtek pártonként. <br>
A 21 Kutatóközpont nincsen ilyen hosszú távra visszamenő "recordja", mivel ez egy néhány éve megjelent cég, viszont a 2024-es <a href='https://mbkoltai.com/ep2024-hungary-datavis/' target='_blank'>EP-választások</a> előtti felmérésük <a href='https://24.hu/belfold/2024/06/09/ep-valasztas-2024-exit-poll-mandatumbecsles/' target='_blank'>gyakorlatilag tökéletesre sikerült</a>, illetve részletes, letölthető, viszonylag transzparens módszertanú kutatásokat közölnek, ezért használtam az ő méréseiket is. <br>
A többi közvéleménykutató demográfiai lebontást általában nem publikál, emellett a múltbeli teljesítményük (és kapcsolataik) annyira ellentmondásos(ak), hogy inkább nem használtam őket.
Az ábrákat tervezem update-elni, ha lesznek újabb demográfiailag lebontott mérések áprilisig.
<br>

<b>Értelmezés</b>

*Ha* a kutatások stimmelnek, akkor a a Fidesz bázisa 2025 szeptemberben így nézett ki:
- teljes tábor kb. 2-2.3 millió támogató (21Kutközpont 2 millióra, Medián inkább 2.3m-ra mérte augusztus végén)
- kb 2/3-uk 50 feletti: 650-700e 50-65 között, 800-850e 65 feletti
- 150-200 ezer körüli 30 év alatti támogatója van a Fidesznek, 200-250e 30-40 év közötti
- támogatók kb. 55-60%-a nem rendelkezik gimnáziumi érettségivel (kb 1.1-1.3 millió ember): kb. 600-800e 8 általánost végzett, kb. 600e szakmunkás
- egyharmaduknak van érettségije (~600e ember), kb 15%-uk diplomás (~250-350e)
- kb. egyharmaduk községekben (650-800e), további egyharmaduk kisebb/közepes (nem megyeszékhely) városban lakik
- 15-20%-uk lakik megyeszékhelyen (350-400e ember), és 10-15%-uk Budapesten (200-300e)

A június és szeptember közötti változások bőven hibahatáron belüliek, de mindkét intézet 1-2%-os (80-160 ezer ember) növekedést mért a Fidesz teljes népességen belüli támogatottságában. 
Ha szószerint vesszük az adatokat, akkor azt mutatják, hogy a következő csoportokban nőtt a Fidesz támogatottsága olyan mértékben, ami _talán_ több mint zaj (50e-nél nagyobb változásokat vettem):
- nők: +160e
- 40-50 év közöttiek: +130e
- 8 általános (+90e), szakmunkás (+70e) és érettségizettek (+110e)
- kis/közepes városok: +100e
Ezek a növekmények átfednek egymással, tehát nem összeadhatók. 

<b>Demográfiai adatokkal kapcsolatos megjegyzések</b>

A demográfiai adatokat a KSH összefoglaló tábláiból, illetve a [2022-es országgyűlési választás honlapjáról](https://www.valasztas.hu/ogy2022-letoltheto-es-tovabbfeldolgozhato-adatok) vettem. Az adatfile-ok letölthetők a <a href='https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025' target='_blank'>projekt Github mappájából</a>. 
A statikus grafikonokat generáló [R kódban](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025/script.R) a linkeket is megadtam, ahonnan az eredeti táblázatok letölthetők. 
A 74 éven felüliek végzettség szerinti eloszlására nem találtam adatot a KSH-nál, csak a 15-74 közötti népességre. 
Ezért itt (≥74) azt feltételeztem, hogy a végzettség szerinti megoszlás megfelel a legkorábbi adatpont (2009) <i>teljes</i> lakosságra vonatkozó adataival.
A választásra jogosult népesség méretére a [2025. októberi 12-i adatot](https://www.valasztas.hu/valasztopolgarok-szama-valasztastipusonkent) használtam, ami 7 635 775 (7.64 millió) fő volt. Ez csak a belföldi, magyarországi lakcímmel rendelkező szavazókat foglalja magában, tehát a levélszavazásra jogosultak (kb. 441 ezer fő 2025/10-ben) nincsenek benne, mint ahogy rájuk a magyarországi közvéleménykutatások sem terjednek ki általában.<br>



<a href="https://mbkoltai.shinyapps.io/magyar_val_demogr_2025/" class="button">ShinyApp interaktív grafikonokkal</a>

<style>
.button {
    display: inline-block;
    padding: 10px 20px;
    font-size: 22px;
    color: white;
    background-color: #0056b3; /* Button background color */
    border: 2px solid transparent; /* Transparent border by default */
    border-radius: 5px;
    text-align: center;
    text-decoration: none;
    transition: border-color 0.3s; /* Smooth transition for border color */
}
.button:hover {
    background-color: #0056b3; /* Darker shade on hover */
    border-color: red; /* Change border color to red on hover */
}
</style>

## Datawrapper

<iframe title="Pártprefenciák TELJES NÉPESSÉGBEN" aria-label="Split Bars" id="datawrapper-chart-cfTyu" src="https://datawrapper.dwcdn.net/cfTyu/1/" scrolling="no" frameborder="0" style="width: 0; min-width: 100% !important; border: none;" height="922" data-external="1"></iframe><script type="text/javascript">!function(){"use strict";window.addEventListener("message",function(a){if(void 0!==a.data["datawrapper-height"]){var e=document.querySelectorAll("iframe");for(var t in a.data["datawrapper-height"])for(var r,i=0;r=e[i];i++)if(r.contentWindow===a.source){var d=a.data["datawrapper-height"][t]+"px";r.style.height=d}}})}();
</script>

<br>
<br>

<iframe title="Pártprefenciák NEM szerint" aria-label="Split Bars" id="datawrapper-chart-us87e" src="https://datawrapper.dwcdn.net/us87e/1/" scrolling="no" frameborder="0" style="width: 0; min-width: 100% !important; border: none;" height="519" data-external="1"></iframe><script type="text/javascript">!function(){"use strict";window.addEventListener("message",function(a){if(void 0!==a.data["datawrapper-height"]){var e=document.querySelectorAll("iframe");for(var t in a.data["datawrapper-height"])for(var r,i=0;r=e[i];i++)if(r.contentWindow===a.source){var d=a.data["datawrapper-height"][t]+"px";r.style.height=d}}})}();
</script>

<br>
<br>

<iframe title="Pártprefenciák KOR szerint" aria-label="Split Bars" id="datawrapper-chart-4j1BB" src="https://datawrapper.dwcdn.net/4j1BB/1/" scrolling="no" frameborder="0" style="width: 0; min-width: 100% !important; border: none;" height="1077" data-external="1"></iframe><script type="text/javascript">!function(){"use strict";window.addEventListener("message",function(a){if(void 0!==a.data["datawrapper-height"]){var e=document.querySelectorAll("iframe");for(var t in a.data["datawrapper-height"])for(var r,i=0;r=e[i];i++)if(r.contentWindow===a.source){var d=a.data["datawrapper-height"][t]+"px";r.style.height=d}}})}();</script>

<br>
<br>

<iframe title="Pártprefenciák VÉGZETTSÉG szerint" aria-label="Split Bars" id="datawrapper-chart-wHysZ" src="https://datawrapper.dwcdn.net/wHysZ/1/" scrolling="no" frameborder="0" style="width: 0; min-width: 100% !important; border: none;" height="1431" data-external="1"></iframe><script type="text/javascript">!function(){"use strict";window.addEventListener("message",function(a){if(void 0!==a.data["datawrapper-height"]){var e=document.querySelectorAll("iframe");for(var t in a.data["datawrapper-height"])for(var r,i=0;r=e[i];i++)if(r.contentWindow===a.source){var d=a.data["datawrapper-height"][t]+"px";r.style.height=d}}})}();
</script>

<br>
<br>

<iframe title="Pártprefenciák TELEPÜLÉSTÍPUS szerint" aria-label="Split Bars" id="datawrapper-chart-QVOTR" src="https://datawrapper.dwcdn.net/QVOTR/4/" scrolling="no" frameborder="0" style="width: 0; min-width: 100% !important; border: none;" height="960" data-external="1"></iframe><script type="text/javascript">!function(){"use strict";window.addEventListener("message",function(a){if(void 0!==a.data["datawrapper-height"]){var e=document.querySelectorAll("iframe");for(var t in a.data["datawrapper-height"])for(var r,i=0;r=e[i];i++)if(r.contentWindow===a.source){var d=a.data["datawrapper-height"][t]+"px";r.style.height=d}}})}();
</script>


## Statikus grafikonok, ahol az oszlopok fölötti számok a szavazók számát mutatják ezerben megadva:

<div style="text-align: center;">
<figure style="display:inline-block;border:1px solid #888; padding:8px; border-radius:1px; text-align:center; background-color:#ddd;">
<a href="{{site.baseurl}}/images/magyar_val_demogr2025/plots/Median_2025_06_08_telj_vegz_teleptipus.png">
<img src="{{site.baseurl}}/images/magyar_val_demogr2025/plots/Median_2025_06_08_telj_vegz_teleptipus.png" alt="_config.yml" />
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 700px;"> <strong>MEDIÁN felmérés</strong> </figcaption>
</figure>
</div>

<br>
<br>
<br>


<div style="text-align: center;">
<figure style="display:inline-block;border:1px solid #888; padding:8px; border-radius:1px; text-align:center; background-color:#ddd;">
<a href="{{site.baseurl}}/images/magyar_val_demogr2025/plots/21kut_2025_04_06_08_telj_vegz_teleptipus.png">
<img src="{{site.baseurl}}/images/magyar_val_demogr2025/plots/21kut_2025_04_06_08_telj_vegz_teleptipus.png" alt="_config.yml" />
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 700px;">  <strong>21 kutatóközpont felmérés</strong> </figcaption>
</figure>
</div>

<!-- 
BOX FOR EQUATION
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \frac{d\vec{x}}{dt} = \vec{b} + (K_{\text{age}} - K_{\text{death}})\vec{x} \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (1) </div>
</div>
-->


### Kód és adatforrások

[GitHub mappa](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/magyar_val_demogr2025)
