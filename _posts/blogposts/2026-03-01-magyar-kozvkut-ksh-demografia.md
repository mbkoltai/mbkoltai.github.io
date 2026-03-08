---
layout: post
title: Magyarországi politikai erőviszonyok demográfiája, 2025-2026
tags: hungary politics elections demographics data-visualisation magyar
excerpt: Nagyságrendek és trendek az utóbbi másfél évben 
secondary: blogposts
mathjax: true
hidden: true
---

<!-- ### ### ### ### ### ### ### ### ### STYLE ### ### ### ### ### ### ### ### ### -->


<style>

.textbox { 
    font-family: Calibri, Arial, sans-serif;
    font-size: 21px;
    border: 2px solid #ccc;
    padding: 15px;
    margin-bottom: 25px;
    background-color: #f9f9f9;
    border-radius: 6px;
}
.textbox pre {
    margin: 0;
    font-family: Consolas, "Courier New", monospace;
    font-size: 0.85em;   /* smaller than text */
    line-height: 1.3;
}

body { font-family: sans-serif; margin: 20px; }
        iframe { margin-bottom: 40px; }

.chart-group {
            display: none;
            margin-top: 20px;
        }

button {
    font-size: 20px;
    font-weight: 600;
    padding: 15px 30px;
    margin-right: 10px;
    cursor: pointer;
    border: 1px solid #ccc;
    background-color: #f0f0f0;
}

button.active {
    background-color: #333;
    color: white;
}

.btnExtLink {
    display: inline-block;
    background-color: #1a3e8c;  /* dark blue */
    color: white;               /* normal text color */
    padding: 10px 20px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: bold;
    font-family: Calibri, Arial, sans-serif;
    transition: color 0.2s, background-color 0.2s;
}

.btnExtLink:hover {
    color: red;                 /* text turns red on hover */
    background-color: #1a3e8c;  /* keep background dark blue */
}

</style>

<!-- JAVASCRIPT -->

<script>
function showCharts(type, btn) {

    document.getElementById("timeTrends").style.display = "none";
    document.getElementById("timeTrendsByParty").style.display = "none";
    // document.getElementById("barCharts").style.display = "none";

    document.getElementById(type).style.display = "block";

    document.querySelectorAll("button").forEach(b => b.classList.remove("active"));

    btn.classList.add("active");
}


window.onload = function() {
    document.getElementById("timeTrends").style.display = "block";
    document.getElementById("btnTime").classList.add("active");
};
</script>

<!-- 
<head>
    <meta charset="UTF-8">
    <title>magyar-partpreferencia-adatok</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

</head>
-->

<!-- ### ### ### ### ### ### ### ### ### STYLE ### ### ### ### ### ### ### ### ### -->

<body>

<!-- TEXT AT TOP -->

<!-- <h2> Magyarországi pártpreferencia-trendek demográfiai lebontásban, 2025-2026</h2> -->

<div class="textbox">

<h3> Bevezető </h3>

A lenti ábrák a 21Kutatóközpont és a Medián 2025-2026 évi méréseit integrálják a KSH demográfiai adataival. 
A cél az volt, hogy abszolút számokban is láthassuk ezeknek a közvéleménykutatásoknak a pártpreferencia-számait, különböző demográfiai dimenziókban: a teljes népességben, illetve nem, kor, végzettség és település-típus szerint lebontva.
Az ábrák mindegyike a <i>belföldi</i> szavazásra jogosult népesség egészére vonatkozik, tehát nem terjed ki a külföldön élő magyarokra.

<br>
<br>
A megadott százalékok és abszolút számok <i>nem</i> azonosak a választáson várhatóan résztvevők számával és így nem tekinthetők választási előrejelzésnek sem, <i>még akkor sem</i> ha a mérési hibáktól eltekintünk. 
Ennek oka, hogy ezek a "teljes népességre" (belföldi szavazásra jogosultak) vonatkozó számok azoknak az arányát jelölik, akik a közvéleménykutatásokban megneveztek egy pártot, amelyre potenciálisan szavaznának - közülük azonban sokan tipikusan végül nem mennek el szavazni, és a tényleges szavazók száma általában olyan 80-90%-a csak ezeknek a teljes népességben mért számoknak. 
<br>
Erre példa a Medián <a href="https://hvg.hu/360/20220330_Median_valasztas_2022_Fidesz_ellenzek_mandatumbecsles_kozvelemeny_kutatas">2022. március végi felmérése</a> - amely a belföldi relatív szavazatarányokat viszonylag jól, 2-4%-os hibával jelezte előre - 80%-ra mérte a pártpreferenciával rendelkezők arányát, de (belföldön) végül csak 70.2% szavazott.
A lenti becslések tehát inkább a teljes (belföldi) szavazókorú népességen belüli <i>potenciális</i> szimpatizáns-tábort adják meg, mintsem a várhatóan valóban szavazók számát. 
A teljes népességben mért pártpreferenciák jelentésében ugyanakkor mintha módszertani különbségek is lennének a közvéleménykutatók között. A 21Kutatóközpont az utóbbi két évben jóval kisebbre mérte a pártválasztók arányát a teljes népességben, mint a Medián, tehát az előbbi intézetnél a "pártpreferenciával rendelkező" mintha szűkebb kategória lenne.
<br>
<br>
Az egyes alcsoportoknál (pl. diplomások, 65 fölöttiek stb.) - mivel az alcsoportoknál a mintaméret értelemszerűen kisebb mint a teljes felmérésnél - az elméleti hibahatárok is nagyobbak, mint az egész halmazra (teljes népességre) vonatkozó becsléseknél. Ehhez még hozzájön az is, hogy egy 1000 fős teljes mintánál a mintavétel már eleve nem tökéletesen reprezentatív általában, amit súlyozással szoktak korrigálni, emiatt viszont számos alcsoportnál a mintaméret a népességarányosnál kisebb, ami tovább növeli a tényleges hibahatárt.
<br>
<br>
Mindezek miatt a lenti ábrákat inkább durva becsléseknek, a nagyságrendek érzékeltetéseként érdemes kezelni, mintsem pontos numerikus becsléseknek.  
<br> 
<br>
Az ábráknak két típusa van. 
A "Trendek demográfiai csoportok szerint" gombra katintva betöltő ábrák azt mutatják meg, hogy egy adott demográfiai csoportban mekkora a politikai blokkok  támogatói bázisa, a teljes csoport százalékában, illetve abszolút számban (tízezerre kerekítve).  
A "Trendek pártok szerint" ábrái pedig azt, hogy az egyes politikai blokkoknak milyen a demográfiai összetétele a különboző dimenziókban, tehát pl. településtípus vagy életkor szerint.
<br>
<br>
További információkért az adatokról ld. lent a <a href="#hatter">Háttér szekciót</a>, az ábrák alatt.

</div>

<!-- ### ### ### ### ### START OF CHARTS ### ### ### ### ###  -->

<button id="btnTime" onclick="showCharts('timeTrends', this)">Trendek demográfiai csoportok szerint</button>
<button id="btnTimeParty" onclick="showCharts('timeTrendsByParty', this)">Trendek pártok szerint</button>
<!--  <button id="btnBar" onclick="showCharts('barCharts', this)">Oszlopdiagramok (hónapok szerint)</button> -->


<!-- TIME TRENDS BY DEMOGR GROUP PLOTS-->
<div id="timeTrends" class="chart-group">

<!--  Teljes Nepesseg -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27917966"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27917966/thumbnail" width="100%" alt="visualization" /></noscript></div>

<div class="textbox">
komment
</div>

<!-- NEM -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27917953"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27917953/thumbnail" width="100%" alt="visualization" /></noscript></div>

<!-- KOR -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27917963"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27917963/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<!-- TELEP-TIPUS -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27916789"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27916789/thumbnail" width="100%" alt="visualization" /></noscript></div>

<!-- VEGZ -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27917957"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27917957/thumbnail" width="100%" alt="visualization" /></noscript></div>

</div> 

<!-- END OF TIME TREND, as % of demographic groups -->

<!-- ### ### ### ### ###  DEMOGRAPHIC MAKEUP OF PARTY BASES ### ### ### ### ###  -->

<div id="timeTrendsByParty" class="chart-group">
<!--  style="display:block;" -->

<!-- NEM -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27938529"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27938529/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<!-- KOR -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27937729"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27937729/thumbnail" width="100%" alt="visualization" /></noscript></div>

<!-- TELEP-TIPUS -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27938707"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27938707/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<!-- VEGZ -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27933940"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27933940/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

</div> <!-- END OF TIME TREND, as % of demographic groups -->

<hr style="border: none; border-top: 2px solid #333; margin: 20px 0;">

<h2 id="hatter">Háttér</h2>

<p class="textbox">
Még ha a felmérések nagyon pontosak is (lennének), a hibahatár alkategóriákra lebontva szinte biztosan nagyobb, mint a teljes mintára nézve. 
Tehát a grafikonokon feltüntetett (tízezerre kerekített) számokat nem érdemes és helyes pontos becsléseknek venni. 
Több szempontból mégis informatívak. 
Először is megmutatják, az egyes demográfiai csoportok (pl. szakmunkás végzettségűek, 65 év felettiek stb.) méretét a teljes szavazásra jogosult népességen belül.
Másrészt, a két nagy blokk (Tisza - Fidesz) demográfiai profilja olyannyira eltér, hogy még a hibahatárokat tekintetbe véve is jelentős és értelmezhető különbségek vannak.
Végül pedig, mivel az ábrázolt kutatások kb. 2024 tavasza óta relatíve rendszeresek és valamiféle trendek is kiolvashatók belőlük. Az, hogy a legtöbb trendvonal meglehetősen stabil, valamennyire növelheti a becslésekbe vetett bizalmat, habát szisztematikus torzító hatásokkal szemben ez sem véd meg, pl. ha a válaszadási készség és a politikai preferencia erősen korrelál. 
<br>
<br>
Ami a közvéleménykutatók választását illeti: a 2002 óta készült választás előtti előrejelzéseket <a href="https://voxpopuli.444.hu/2026/03/04/a-valasztasok-elotti-elorejelzesek-merlege-2002-tol-2024-ig" target="_blank">itt gyűjtöttem össze</a>, a tényleges eredményekkel összehasonlítva. A Medián 2002 óta minden választáson helyesen jelezte előre a választás győztesét, átlagosan 2-3%-ot tévedve pártonként, ami a legalacsonyabb hiba-szint a rendszeresen mérő cégek között.
<br>
A 21 Kutatóközpontnak - mivel egy néhány éve megjelent cég - nincsen ilyen hosszú távra visszamenő "recordja", 
viszont a 2024-es <a href="https://mbkoltai.com/ep2024-hungary-datavis/" target="_blank">EP-választások</a> 
<a href="https://24.hu/belfold/2024/06/09/ep-valasztas-2024-exit-poll-mandatumbecsles/" target="_blank">előtti felmérésük</a>
<a href="https://voxpopuli.444.hu/2026/03/04/a-valasztasok-elotti-elorejelzesek-merlege-2002-tol-2024-ig" target="_blank">az összes intézet közül a legjobb lett</a>, mindössze kb. 1%-os átlagos (pártonkénti) hibával, illetve részletes, letölthető, viszonylag transzparens módszertanú kutatásokat közölnek, ezért használtam az ő méréseiket is.
<br>
A többi közvéleménykutató demográfiai lebontást általában nem publikál és/vagy adataik nem letölthetőek, emellett a múltbeli teljesítményük (és kapcsolataik) annyira ellentmondásos(ak), hogy inkább nem használtam őket.
</p>

<h2>Demográfiai adatok</h2>

<div class="textbox">

<p>
A demográfiai adatokat a KSH összefoglaló tábláiból, illetve a <a href="https://www.valasztas.hu/ogy2022-letoltheto-es-tovabbfeldolgozhato-adatok" target="_blank">2022-es országgyűlési választás honlapjáról</a> vettem. Az adatfile-ok letölthetők a <a href="https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025" target="_blank">projekt Github mappájából</a> (<it>input_files</it> folder). 
A grafikonokat utolsó lépésben a flourish honlapján manuális beállításokkal generáltam, de minden ehhez szükséges táblázat megtalálható az <a href="https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025/output" target="_blank">output_folder</a>-ben, illetve a táblázatokat generáló    <a href="https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025/script_magyar_val_demogr.R" target="_blank">R kód itt</a>. Ez utóbbi forráskód file-ban a linkeket is megadtam, ahonnan az eredeti táblázatok letölthetők. 

<br>
Az adatokban volt néhány hiányosság, amelyek miatt feltételezésekkel kellett élni.
A 74 éven felüliek végzettség szerinti eloszlására nem találtam adatot a KSH-nál, csak a 15-74 közötti népességre.
<br>

Ezért itt (≥74) azt feltételeztem, hogy a végzettség szerinti megoszlás megfelel a legkorábbi adatpont (2009) <i>teljes</i> lakosságra vonatkozó adataival. Ez egy további bizonytalansági tényező a végzettségi szerinti népességeloszlásban, bár nem nagyon nagy, mert az egész 74+ csoport csak kb. 822 ezer ember volt. Konkrétan így lett szétosztva ez a 822 ezer választó végzettség szerint, a 2009-es végzettségi adatokat használva, illetve ha a 2024-eseket használtuk volna:
</p>

<div class="textbox">
<pre><code>vegz_kateg   perc_2009 perc_2024 szam_2009 szam_2024
  &lt;chr&gt;            &lt;dbl&gt;     &lt;dbl&gt;     &lt;dbl&gt;     &lt;dbl&gt;
1 8alt              29.5      17.9    242000    147000
2 szakmunkas        23.5      22.2    193000    183000
3 erettsegi         30.8      33.9    253000    279000
4 felsooktatas      16.3      26      134000    214000
</code></pre>
</div>

<p>
Tehát kb. egy 50-100 ezres bizonytalanságról beszélünk emiatt a <i>teljes</i> (végzettség szerinti) csoportok méretében, ti. ebben a sávban van a különbség kategóriánként ha a 2009-es vagy 2024-es végzettség-adatokat alkalmazzuk a 74+ csoport megoszlására. Ez pártonként nézve maximum olyan 50 ezres (ha azt mondjuk a tévedés 100 ezer fő, ennél valószínűleg kisebb) további bizonytalanságot jelenthet az abszolút számokban, mivel egyik párt sincs 50% fölött egyik kategóriában sem.
<br>
<br>
A választásra jogosult népesség méretére a <a href="https://www.valasztas.hu/valasztopolgarok-szama-valasztastipusonkent" target="_blank">2025. októberi 12-i adatot</a> használtam, ami 7 635 775 (7.64 millió) fő volt. 
Ez a szám havi pár ezerrel csökken, mert a halálozások száma meghaladja a 18 éve korba belépők számát.
Ez a 7.64 millió választó csak a belföldi, magyarországi lakcímmel rendelkező szavazókat foglalja magában, tehát a levélszavazásra jogosultak (kb. 441 ezer fő 2025/10-ben) nincsenek benne, mint ahogy rájuk a magyarországi közvéleménykutatások sem terjednek ki általában. 
</p>
</div>

<h2>Kód és adatforrások</h2>

<div style="margin: 20px 0;">
    <a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/magyar_val_demogr2025" target="_blank" class="btnExtLink">GitHub</a>
</div>

<!-- END OF HTML BODY -->
</body>
<!-- </html> -->
