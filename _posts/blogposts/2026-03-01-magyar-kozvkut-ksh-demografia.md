---
layout: post
title: Becslések a magyar politikai erőviszonyok demográfiai trendjeiről, 2025-2026
tags: hungary politics elections demographics data-visualisation magyar
excerpt: Nagyságrendek és trendek az utóbbi másfél évben 
secondary: blogposts
mathjax: true
hidden: true
---

<!-- ### ### ### ### ### ### ### ### ### STYLE ### ### ### ### ### ### ### ### ### -->

<style>

.highlight {
    background-color: #939aa7;   /* light blue background */
    border: 1px solid #4a6fdc;   /* frame */
    padding: 0px 3px;
    border-radius: 4px;
}

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

<!-- ### ### ### ### ### ### ### ### ### STYLE END ### ### ### ### ### ### ### ### ### -->

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

<!-- ### ### ### ### ### ### ### ### ### STYLE ### ### ### ### ### ### ### ### ### -->

<body>

<!-- TEXT AT TOP -->


<p class="textbox">

Közismert, hogy a kormánypárt és a legfőbb ellenzéki erő társadalmi bázisának nagyon más az összetétele kor, végzettség vagy településtípus szerint. 
De mennyire vannak konkrét számaink arról, hogy ez mit jelent egyrészt adott társadalmi csoportokon belül, másrészt a két nagy politikai blokk összetételében, ezekben a különböző dimenziókban? 
Például: mekkora a Tisza támogatottsága a diplomások versus a szakmunkás végzettségűek körében? Mekkora a 40 év alattiak és a nyugdíjasok között? Néhány közvéleménykutató (főleg a Medián, kisebb mértékben a 21Kutatóközpont) időnként publikál társadalmi csoportok szerint lebontott százalékokat, ezekből azonban nem látszik, hogy egymáshoz képest mekkorák a különböző támogatói csoportok. 
Például, ha a 65 év felettiek között kb. 50% a Fidesz támogatottsága, ez több vagy kevesebb ember, mint a 30 vagy 40 alatti - nagy többségben lévő - Tisza-támogatók csoportja? 
És megfordítva, mit jelentenek ezek a számok egy-egy párt bázisának az összetételére nézve, pl. mekkora a diplomások, a 40 év alattiak, vagy a községben élők aránya az ellenzéki blokkban?

Ebben a posztban ezekre a kérdésekre próbáltam válaszolni interaktív grafikonokkal, kombinálva a 21Kutatóközpont és a Medián 2025-2026-os a teljes népességre vonatkozó, illetve demográfiailag részletezett pártpreferencia-méréseit a KSH demográfiai adataival. 
A lenti ábrák azt mutatják meg, hogy a mért pártpreferencia-százalékok abszolút számokban kb. mennyi szavazót jelentenek különböző demográfiai dimenziókban nézve: a teljes népességben, illetve nem, kor, végzettség és településtípus szerint. 
Megfordítva, az ábrák másik része pártonként csoportosítja az adatokat: ezek azt mutatják meg, hogy mi az összetétele a két nagy blokk, illetve a pártnélküliek csoportjának az egyes dimenziókban.
Az ábrák mindegyike a <i>belföldi</i> szavazásra jogosult népességre vonatkozik, tehát nem terjed ki a külföldön élő magyarokra.

<br>
<br>
A megadott százalékok és abszolút számok <i>nem</i> azonosak a választáson várhatóan résztvevők számával és így nem tekinthetők választási előrejelzésnek sem, <i>még akkor sem</i> ha a mérési hibáktól eltekintünk. 
Ennek oka, hogy ezek a "teljes népességre" (belföldi szavazásra jogosultak) vonatkozó számok azoknak az arányát jelölik, akik a közvéleménykutatásokban megneveztek egy pártot, amelyre potenciálisan szavaznának - közülük azonban sokan tipikusan végül nem mennek el szavazni, és a tényleges szavazók száma általában olyan 80-90%-a csak ezeknek a teljes népességben mért számoknak. 
<br>
Egy példa erre a Medián 
<a href="https://hvg.hu/360/20220330_Median_valasztas_2022_Fidesz_ellenzek_mandatumbecsles_kozvelemeny_kutatas">2022. március végi felmérése</a> a választások előtt, 
amely a belföldi relatív szavazatarányokat viszonylag jól, 2-4%-os hibával jelezte előre, de 80%-ra mérte a pártpreferenciával rendelkezők arányát, míg a valóságban (belföldön) végül csak 70.2% szavazott.
A lenti becslések tehát inkább a szavazásra jogosult (belföldi) népességen belüli <i>potenciális</i> szimpatizáns-tábort adják meg, mintsem a várhatóan valóban szavazók számát. 
A teljes népességben mért pártpreferenciák jelentésében ugyanakkor mintha módszertani különbségek is lennének a közvéleménykutatók között: a 21Kutatóközpont (21KK) az utóbbi két évben jóval kisebbre mérte a pártválasztók arányát a teljes népességben, mint a Medián, tehát az előbbi intézetnél a "pártpreferenciával rendelkező" mintha egy szűkebb kategória lenne.
<br>
<br>
Az egyes alcsoportoknál (pl. diplomások, 65 fölöttiek stb.) - mivel itt a mintaméret értelemszerűen kisebb mint a teljes minta - az elméleti hibahatárok is nagyobbak, mint az egész halmazra (teljes népességre) vonatkozó becsléseknél. 
Ehhez még hozzájön az is, hogy egy 1000 fős teljes mintánál a mintavétel általában eleve nem tökéletesen reprezentatív, amit súlyozással szoktak korrigálni, emiatt viszont számos alcsoportnál a mintaméret a népességarányosnál is kisebb, ami tovább növeli a tényleges hibahatárt.
<br>
<br>
Mindezek miatt <b>a lenti ábrákat inkább durva becsléseknek, a nagyságrendek érzékeltetéseként érdemes kezelni, mintsem pontos numerikus becsléseknek</b>.
<br> 
<br>
Az első, legfelső ábra a teljes népességben mutatja meg az egyes pártok illetve bizonytalanok/pártnélküliek számát és arányát. 
Az ezután következő ábráknál két ábrázolásmód közül lehet választani. 
A 
<span class="highlight">Trendek demográfia szerint csoportosítva</span>
gombra katintva betöltő ábrák azt mutatják meg, hogy egy adott demográfiai csoportban mekkora a politikai blokkok támogatói bázisa, a teljes csoport százalékában, illetve abszolút számban (tízezerre kerekítve).  
A
<span class="highlight">Trendek pártok szerint csoportosítva</span> 
gombra kattintva betöltő ábrák pedig azt, hogy az egyes politikai blokkoknak milyen a demográfiai összetétele a különboző dimenziókban, tehát pl. településtípus vagy életkor szerint.
Mindegyik ábra alatt egy rövid szöveges összefoglalóval elemeztem az arányokat és trendeket. 

<br>
<br>
Fontos hangsúlyozni, hogy <b>az összes lenti számhoz (és értelmezésükhöz) hozzá lehet tenni ezeket az óvatosságra intő megjegyzéseket</b>: 1) ha a mérések rosszak, akkor nyilván az értelmezések is elesnek 2) még ha szisztematikus torzítások nincsenek is a számokban, a hibahatárok a demográfiailag lebontott alcsoportoknál a kis mintaméretek miatt rendkívül nagyok 3) <a href="https://www.facebook.com/valasztasi.kalauz/posts/pfbid02eCqrvoDkCrQPD5FVQ1j2AFmMAAhHfr89ASLr6FqsaQYNr5diws6CRBjKED4kKdHjl">több</a> <a href="https://alexanderbor.github.io/idokozik/">arra utaló</a> dolog van, hogy a Fidesz támogatottságát a Medián és a 21KK recens mérései alulbecsülik; ha ez valóban így van, ez a lenti számokat is értelemszerűen módosítaná, de nagyon nehéz megbecsülni, hogy mennyivel. 
<br>
<br>
További információkért az adatokról ld. lent, az ábrák alatt, a <a href="#hatter">"Háttér"</a> szekciót.


</p>

<!-- ### ### ### ### ### START OF CHARTS ### ### ### ### ###  -->


<!--  Teljes Nepesseg -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27917966"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27917966/thumbnail" width="100%" alt="visualization" /></noscript></div>

<div class="textbox">
A teljes népességre vonatkozó számoknál a legfeltűnőbb a számok stabilitása 2025 tavasza óta. 
A 21KK számainál az egyetlen jelentősebb - a hibahatár szintet elérő - mozgás a Fidesz tábor zsugorodása (-200e) 2025 tavaszán, illetve a Tisza bázis bővülése (+300e) 2025 novemberétől. A két nagy blokk náluk kb. 2.4-2.7 milliós (Tisza), illetve 1.9-2.2 milliós; az MH 300-400 ezres, a másik két kispárt 100-200 ezres sávban van stabilan.<br>
A Medián a két nagy blokkot ennél nagyobbra méri: 2.9-3.2 (Tisza) illetve 2.1-2.5 milliósra, miközben a kispártok bázisát ugyanakkorára. Emiatt a Mediánnál pártnélküliek csak olyan másfél millióian vannak már csak (21KK: 2 millió). 
A számok a Mediánnál is stabilak, bár a Tisza bázisnál mértek egy fokozatos, összesen kb. 300 ezres bővülést 2025 őszétől.
</div>
<!-- ### ### ### ### ### ### ### -->


<button id="btnTime" onclick="showCharts('timeTrends', this)">Trendek demográfia szerint csoportosítva</button>
<button id="btnTimeParty" onclick="showCharts('timeTrendsByParty', this)">Trendek pártok szerint csoportosítva</button>
<!--  <button id="btnBar" onclick="showCharts('barCharts', this)">Oszlopdiagramok (hónapok szerint)</button> -->


<!-- TIME TRENDS BY DEMOGR GROUP PLOTS-->
<div id="timeTrends" class="chart-group">


<!-- NEM -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27917953"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27917953/thumbnail" width="100%" alt="visualization" /></noscript></div>

<div class="textbox">
A Medián becslései szerint a férfiak között stabilan kb. 400-500 ezerrel nagyobb a Tisza bázisa, mint a kormánypárté. 
A nők között 2025 nyara óta folyamatosan süllyed a pártnélküliek (+ két nagyon kívüli pártot támogatók) aránya, és mostanra már nem magasabb, mint a férfiak között. 
Ebből 2025 őszén a Fidesz profitált (+350 ezer szavazó), 2025 novembere óta viszont a Tisza (+240 ezer), így a legutóbbi felméréskor a nők között kb. 350 ezerrel több támogatója volt. 
</div>

<!-- ### ### ### ### ### ### ### -->
<!-- KOR -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27917963"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27917963/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<div class="textbox">
Az életkor az egyik olyan dimenzió - a végzettség és a településtípus mellett - ami nagyon erősen korrelál azzal, hogy a két nagy párt közül melyiket támogatja valaki. 
A felmérések szerint 18-29 éves kohortban a legutóbbi (2026/02) felméréskor már kb. nyolcszor annyi támogatója volt a Tiszának, mint az állampártnak (800 vs 100 ezer - de ne felejtsük el fejben hozzáadni/kivonni a hibahatárokat). 
A spektrum másik végén, a 65 év felettieknél a Fidesz támogatók vannak kb. kétszer annyian, mint az ellenzék támogatói, ami kb. 450 ezres előnyt jelent: a 65 felettiek csoportja kb. másfélszer nagyobb, mint a 30 alatti (1.9 vs 1.2 millió). 
A támogatói bázisok egyfajta "besűrűsödése" is mintha történt volna 2025 óta: a fiatalok között a Tisza, az idősek között a Fidesz támogatók száma nőtt méginkább. 
A 30-39 kohortban kb. háromszoros Tisza-vezetés tapasztalható stabilan (700 vs 250 ezer), míg a 40-49 és az 50-64 csoportban kb. ugyanakkora a két párt bázisa.
</div>

<!-- ### ### ### ### ### ### ### -->
<!-- TELEP-TIPUS -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27916789"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27916789/thumbnail" width="100%" alt="visualization" /></noscript></div>

<div class="textbox">
A településtípus szintén erősen előre tudja jelezni a pártpreferenciát. 
Ez valójában inkább egy összetétel-hatás: a községekben és kisvárosokban alacsonyabb a fiatalok, magasabb végzettségűek és magasabb jövedelműek aránya, ezért <i>átlagban</i> kevesebb az ellenzéki (és több a Fidesz-) szavazó; tehát ha kontrollálnánk végzettségi és jövedelmi helyzetre is, akkor <i>önmagában</i> a településtípus nem erős prediktor. A választási földrajz szempontjából ugyanakkor ez szinte mindegy. 
A községekben 1-6% (max. 150 ezres) között ingadozó Fidesz-fölényt mutatnak a felmérések. 
A kisebb (nem megyei jogú, ezek kb. a 10-40 ezres települések) kiegyenlítettek az erőviszonyok, általában inkább pár százalékos Tisza-fölénnyel. 
A megyei jogú városokban kb. másfélszer akkora az ellenzéket támogatók aránya (45 vs 30%, kb. 250 ezres különbség). 
A fővárosban jelenleg majdnem háromszor akkora az ellenzéki párt támogatóinak aránya, mint a kormánypárté (58% vs 21%, kb. 450 ezres különbség). 
Ez a különség korábban csak másfél-kétszeres volt, de a más pártot támogatók/pártnélküliek számának apadásával november óta jelentősen nyílott az olló, tehát úgy tűnik ez a mozgás szinte teljesen a Tisza bázist bővítette.  
</div>

<!-- ### ### ### ### ### ### ### -->
<!-- VÉGZETTSÉG -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27917957"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27917957/thumbnail" width="100%" alt="visualization" /></noscript></div>

<div class="textbox">
A végzettségi szint az életkorhoz hasonlóan erős előrejelzője annak, hogy valaki a kormánypártot vagy a Tiszát támogatja.
A maximum nyolc általánost végzett szavazóknál (kb. másfél millió ember) a Fidesz támogatók a legutóbbi mérésnél már abszolút többséget alkottak (+6% növedekedés 2025 nyara óta), míg a Tisza támogatottsága stabilan 20% körül van csak. 
A szakmunkás végzettségűeknél (1.7 millió szavazó) stabilan kb. 10%-os Fidesz előny tapasztalható az utóbbi fél évben. 
Az érettségivel rendelkezőknél - ez a legnagyobb csoport, kb. 2.5 millió ember - már jelentős, kb 20%-os ellenzéki fölényt mutatnak a felmérések.
A felsőfokú végzettségűeknél eleve magas volt a Tiszát támogatók aránya (kb. 50 vs 20%), de 2025 nyara óta folyamatosan nő, a legutóbbi mérésnél már majdnem ötszöröse volt a kormány támogatóinak. 
A fiatal választókhoz és a budapestiekhez hasonlóan - e két kategóriával a diplomások nyilván átfednek, tehát ezek nem független változók - itt is egyfajta "besűrüsödés" figyelhető meg, hogy az eleve ellenzéki csoportokban még tovább erősödött ez a tendencia. Felmerül ugyanakkor, itt nem lehet-e egy olyan torzító hatás, hogy az ellenzéki választók ezekben a csoportokban sokkal könnyebben válaszolnak a közvéleménykutatóknak, mint a kormánypártiak, felerősítve az arányukat. 
</div>

</div> 

<!-- END OF TIME TREND, as % of demographic groups -->

<!-- ### ### ### ### ###  DEMOGRAPHIC MAKEUP OF PARTY BASES ### ### ### ### ###  -->

<div id="timeTrendsByParty" class="chart-group">
<!--  style="display:block;" -->

<!-- NEM -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27938529"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27938529/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<div class="textbox">
A politikai blokkok nem szerinti összetétele azt mutatja, hogy a Tisza támogatói kb. fele-fele arányban férfiak illetve nők. 
Ez igaz a a pártnélküliek/más pártot választókra is.
A Fidesz támogatóinak átlagosan kb. 55%-át adják a nők a Medián becsléseiben; ez nyilván összefügg az idősek  felül-reprezentáltságával a Fidesz-táborban, ui. a 65 feletti korcsoportban több a nő.
</div>

<!-- ### ### ### ### ### ### ### -->

<!-- KOR -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27937729"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27937729/thumbnail" width="100%" alt="visualization" /></noscript></div>

<div class="textbox">
Korcsoport szerint az ellenzéki blokk összetétele viszonylag kiegyensúlyozottnak mondható, amennyiben az öt korcsoport (18-29, 30-39, 40-49, 50-64, 65+) mindegyike 16-25%-át adja a teljes bázisnak. Ez azt is jelenti, hogy a 18-30 korosztály 1.6x-os mértékben, a 30-39 korosztály 1.4x felülreprezentált a teljes népességbeli arányukhoz képest, az idősebbek pedig hasonló relatív mértékben alulreprezentáltak.
A Fidesz-bázis jóval inkább kiegyensúlyozatlan, a 65 éven felüliek 40%-át adják, az 50-65 évesek pedig további 28%-át, miközben a 40 alattiak <i>összesen</i> kevesebb mint 15%-át. 
A pártnélküliek és más pártokat támogatók kor-összetétele kb. megfelel a teljes választókorú lakosság összetételének.
</div>

<!-- ### ### ### ### ### ### ### -->

<!-- TELEP-TÍPUS -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27938707"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27938707/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<div class="textbox">
A Tisza bázisban erősen felülreprezentáltak a budapestiek (1.4x a teljes népességbeli arányukhoz képest), és alulreprezentáltak a községekben élők (0.78x); a megyei jogú illetve kisebb városok súlya szinte pont lakosságarányos. 
A párt bázisa így kb. egyenlően oszlik el e négy település-típus között. 
A Fidesz bázisban felülreprezentáltak (1.25x) a községekben élők, és masszívan alulreprezentáltak a fővárosiak (0.67x). 
A bázis közel 70%-a községben vagy kisebb városban él.
A pártnélküliek/más pártot választók összetétele inkább a Fidesz-bázisra hasonlít: felülreprezentáltak a községek és alulreprezentáltak a fővárosiak. 
Kérdés ez így lesz-e a választáson is, vagy itt lehet még egy mobilizációs potenciál a kormánypártnak.
A trendek összességében rendkívül stabilak, az összetétel alig változott valamit 2025 óta.
</div>

<!-- ### ### ### ### ### ### ### -->

<!-- VEGZ -->
<div class="flourish-embed flourish-chart" data-src="visualisation/27933940"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27933940/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<div class="textbox">
Az iskolai végzettség dimenziója mentén a Tisza bázisa erősen a magasabban képzettek felé hajlik. 
A felsőfokú végzettségűek erősen felül- (1.5x), míg a legfeljebb 8 osztályt végzettek erősen alulreprezentáltak (0.5x), és a szakmunkás végzettségűek is a népességbeli arányuk alatt jelennek meg (0.7x). 
Az érettségizettek súlya nagyjából lakosságarányos.
A Fidesz bázis a kevésbé képzettek felé torzít: nagyon erősen felülreprezentáltak a legfeljebb 8 osztályt végzettek (1.7x), és kisebb mértékben a szakmunkások is (1.2x), míg a felsőfokú végzettségűek nagyon erősen alulreprezentáltak (0.45x).
A pártnélküliek vagy más pártot választók összetétele közelebb áll a teljes népesség összetételéhez, bár a szakmunkások kissé felülreprezentáltak, a felsőfokú végzettségűek pedig valamelyest alulreprezentáltak.
</div>

</div> <!-- END OF TIME TREND, as % of demographic groups -->

<hr style="border: none; border-top: 2px solid #333; margin: 20px 0;">

<h2 id="hatter">Háttér</h2>

<div class="textbox">

Még ha a felmérések nagyon pontosak is (lennének), a hibahatár alkategóriákra lebontva szinte biztosan nagyobb, mint a teljes mintára nézve. 
Tehát a grafikonokon feltüntetett, tízezerre kerekített számokat nem érdemes és helyes pontos becsléseknek venni. 
Több szempontból mégis informatívak. 
Először is megmutatják, az egyes demográfiai csoportok (pl. szakmunkás végzettségűek, 65 év felettiek stb.) méretét a teljes szavazásra jogosult népességen belül.
Másrészt, a két nagy blokk (Tisza - Fidesz) demográfiai profilja annyira eltér, hogy még a hibahatárokat tekintetbe véve is jelentős és értelmezhető különbségek vannak.
Végül pedig, mivel az ábrázolt kutatások kb. 2025 tavasza óta relatíve rendszeresek, ezért trendek is kiolvashatók belőlük, habár a mozgások nagy része hibahatáron belüli. 
Az, hogy a legtöbb trendvonal meglehetősen stabil, valamennyire növelheti a becslésekbe vetett bizalmat, habár szisztematikus torzító hatásokkal szemben ez sem véd meg, pl. ha a válaszadási hajlandóság és a politikai preferencia erősen korrelál. 
<br>
<br>

A pártpreferencia számokhoz a Medián és a 21Kutatóközpont felméréseit használtam. A többi közvéleménykutató demográfiai lebontást általában nem publikál vagy az adataik nem letölthetőek. 
Emellett a többi intézetnek a múltbeli teljesítménye (illetve kapcsolataik) is ellentmondásos(ak).
A 2002 óta készült választás előtti előrejelzéseket 
egy 
<a href="https://voxpopuli.444.hu/2026/03/04/a-valasztasok-elotti-elorejelzesek-merlege-2002-tol-2024-ig" target="_blank">korábbi cikkben</a> 
gyűjtöttem össze
gyűjtöttem össze (<a href="https://docs.google.com/spreadsheets/d/1An-qWlh0ZpSAihY024BYd2QczFoa-AjSwPS1yAEK6-g/" target="_blank">adatok itt</a>). A Medián 2002 óta minden választáson helyesen jelezte előre a választás győztesét, átlagosan 2-3%-ot tévedve pártonként, ami a legalacsonyabb hiba-szint a rendszeresen mérő cégek között.
<br>
A 21 Kutatóközpontnak - mivel egy néhány éve megjelent cég - nincsen ilyen hosszú távra visszamenő "recordja", 
viszont a 2024-es 
<a href="https://mbkoltai.com/ep2024-hungary-datavis/" target="_blank">EP-választások</a> 
<a href="https://24.hu/belfold/2024/06/09/ep-valasztas-2024-exit-poll-mandatumbecsles/" target="_blank">előtti felmérésük</a>
<a href="https://voxpopuli.444.hu/2026/03/04/a-valasztasok-elotti-elorejelzesek-merlege-2002-tol-2024-ig" target="_blank">az összes intézet közül a legjobb lett</a>, 
mindössze kb. 1%-os átlagos (pártonkénti) hibával. Emellett, a 21KK részletes, letölthető, viszonylag transzparens módszertanú kutatásokat közöl, ezért használtam az ő méréseiket is.
A demográfiaialag részletezett felmérések nagy része ugyanakkor a Mediántól van, a 21KK csak néhányszor közölt ilyet, viszont a teljes népességre vonatkozó méréseik egy vagy két havonta folytonosan megjelennek 2025 tavasza óta.

</div>

<h2>Demográfiai adatok</h2>

<div class="textbox">

<p>

A demográfiai adatokat a KSH összefoglaló tábláiból, illetve a <a href="https://www.valasztas.hu/ogy2022-letoltheto-es-tovabbfeldolgozhato-adatok" target="_blank">2022-es országgyűlési választás honlapjáról</a> vettem. Az adatfile-ok letölthetők a <a href="https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025" target="_blank">projekt Github mappájából</a> (<i>input_files/</i>). 
A grafikonokat utolsó lépésben a flourish honlapján manuális beállításokkal generáltam, de minden ehhez szükséges táblázat megtalálható az <a href="https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025/output" target="_blank">output_folder</a>-ben, illetve a táblázatokat generáló 
<a href="https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr2025/script_magyar_val_demogr.R" target="_blank">R kód itt</a>. Ez utóbbi file-ban megadtam a linkeket, ahonnan az eredeti táblázatok letölthetők. 

<br>
Az adatokban volt néhány hiányosság, amelyek miatt feltételezésekkel kellett élni.
A 74 éven felüliek végzettség szerinti eloszlására nem találtam adatot a KSH-nál, csak a 15-74 közötti népességre.
<br>

Ezért itt (≥74 év) azt feltételeztem, hogy a végzettség szerinti megoszlás megfelel a legkorábbi adatpont (2009) <i>teljes</i> lakosságra vonatkozó adataival. Ez a feltételezés egy további bizonytalansági tényező a végzettségi szerinti népességeloszlásban, bár nem túl nagy. 
Az egész 74+ csoport kb. 822 választó, akik így oszlanak el végzettség szerint, ha a 2009-es illetve ha a 2024-eseket használjuk (a '<i>perc_...</i>' oszlopok százalékot, a '<i>szam_...</i>' oszlopok abszolút számot jelölnek):
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
Tehát kb. 50-100 ezer fős bizonytalanságot okoz ez a végzettség szerinti csoportokban, azaz kb. ekkora a különbség kategóriánként, ha a 2009-es illetve 2024-es végzettség-adatokat alkalmazzuk a 74+ csoport megoszlására, ami pártonként nézve maximum kb. 50 ezres bizonytalanságot jelenthet az abszolút számokban.
<br>
<br>
A választásra jogosult népesség méretére a <a href="https://www.valasztas.hu/valasztopolgarok-szama-valasztastipusonkent" target="_blank">2025. októberi 12-i adatot</a> használtam, ami 7 635 775 (7.64 millió) fő volt. 
Ez a szám havi pár ezerrel csökken, mivel a halálozások száma meghaladja a 18 éves korba belépők számát.
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