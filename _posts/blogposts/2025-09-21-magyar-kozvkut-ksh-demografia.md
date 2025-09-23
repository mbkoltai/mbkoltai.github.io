---
layout: post
title: Pártpreferencia felmérések abszolút számokban
tags: hungary politics elections demographics data-visualisation magyar
excerpt: Nem/kor/végzettség/településtípus szerinti KSH adatok alapján
secondary: blogposts
mathjax: true
---

Az ábrák a 21Kutatóközpont és a Medián 2025 nyári méréseit integrálják a KSH demográfiai adataival. 
Minden demográfiai adat a választásra jogosult, tehát 18 éves vagy idősebb, népességre vonatkozik, ami a KSH 2025 évi becslése szerint kb. 7.88 millió ember. A függőleges tengelyen a választók száma ezerben van megadva. <br>

<b>Értelmezés</b>: Még ha a felmérések nagyon pontosak is (lennének), a hibahatár így, alkategóriákra lebontva, szinte biztosan nagyobb, mint a teljes mintára nézve. <br>
Tehát az oszlopok fölötti számokat, amelyek tízezerre kerekítve lettek, nem helyes pontos becsléseknek venni. Ehelyett csak azt mutatják meg, hogy hány (százalék) szavazó lenne az adott kategóriában, <b>ha</b> a mérés tökéletesen pontos lenne - ami szinte biztosan nem igaz. <br>
Ugyanakkor azt megmutatják, hogy az egyes demográfiai csoportokban (pl. szakmunkás végzettségűek, 65 év felettiek stb.) összesen mennyien vannak, illetve <i>ha</i> a mérések hozzávetőlegesen pontosak, akkor azt is, hogy körülbelül hogyan oszlik el a népesség pártszimpátia szerint az adott demográfiai kategóriában. 
<br>

<b>Adatokkal kapcsolatos megjegyzések</b>: 
A demográfiai adatokat a KSH összefoglaló tábláiból, illetve a [2022-es országgyűlési választás honlapjáról](https://www.valasztas.hu/ogy2022-letoltheto-es-tovabbfeldolgozhato-adatok) vettem. Az adatfile-ok letölthetők a <a href='https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025' 
target='_blank'> projekt Github mappájából</a>. 
A statikus grafikonokat generáló [R kódban](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025/script.R) a linkeket is megadtam, ahonnan az eredeti táblázatok letölthetők. 
A 74 éven felüliek végzettség szerinti eloszlására nem találtam adatot a KSH-nál, csak a 15-74 közötti népességre. 
Ezért itt (≥74) azt feltételeztem, hogy a végzettség szerinti megoszlás megfelel a legkorábbi adatpont (2009) <i>teljes</i> lakosságra vonatkozó adataival.
Emellett, a KSH 2025-ös felnőtt népesség méret-adata kb. 120 ezerrel nagyobb, mint ami a 2022-es települési választási adatokból kivonható. 
Ennek nem tudom, hogy mi az oka, talán a nem bejelentett külföldön élők. Ez a két demográfiai pontatlanság nem változtat sokat (valószínűleg kb. néhány tízezret) a végzettség és településtípus szerinti demográfiai csoportok méretén. <br>

A MEDIÁN 2002 óta készült választás előtti - az eredményekkel összehasonlított - előrejelzéseit <a href='https://docs.google.com/spreadsheets/d/1NUEgN7eV7MoZqi8dd9-xAzWxY_u2u_HYImV6l_U5qDE/' target='_blank'>itt gyűjtöttem össze</a>. <br>
A 21Kutközpont 2024-es <a href='https://mbkoltai.com/ep2024-hungary-datavis/' target='_blank'>EP-választások</a> előtti (gyakorlatilag tökéletesre sikerült) <a href='https://24.hu/belfold/2024/06/09/ep-valasztas-2024-exit-poll-mandatumbecsles/' target='_blank'> előrejelzése itt</a>. <br>
A többi közvéleménykutató demográfiai lebontást általában nem publikál, illetve a <i> record</i>-juk annyira ellentmodásos, hogy inkább nem használtam őket.
 
A grafikonokat a választásokig megjelenő újabb Medián és 21Kutközponz mérésekkel frissíteni tervezem, így remélhetőleg egy hozzávetőleges idősort kaphatunk majd.


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
