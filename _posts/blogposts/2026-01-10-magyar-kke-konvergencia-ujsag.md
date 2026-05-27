---
layout: post
title: Magyarország konvergencia-teljesítménye 2010 óta régiós összehasonlításban
tags: hungary politics elections demographics data-visualisation magyar
excerpt: Egy kudarc története
secondary: blogposts
mathjax: true
---



<style>
.table-toggle {
  display: inline-block;   /* shrink container to fit content */
  border: 1.5px solid #000;
  padding: 1rem;
  margin: 1.5rem 0;
  border-radius: 6px;
}

.table-caption {
  margin-top: 0.5rem;
  font-size: 0.95rem;
}

.table-toggle .controls {
  display: flex;
  gap: .5rem;
  margin: 0.25rem 0 0.4rem 0;
}

.table-toggle button {
  padding: .4rem .9rem;
  border-radius: 6px;
  border: 1px solid #ccc;
  background: #fff;
  cursor: pointer;
  font-size: 0.95rem;
}

.table-toggle button.active {
  background: #0366d6;
  color: #fff;
  border-color: #0256b3;
}

.table-toggle .table-view {
  display: none;
}

.table-toggle .table-view.active {
  display: block;
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.table-toggle').forEach(wrapper => {
    wrapper.querySelectorAll('.controls button').forEach(button => {
      button.addEventListener('click', () => {

        // toggle buttons
        wrapper.querySelectorAll('.controls button').forEach(b => b.classList.remove('active'));
        button.classList.add('active');

        // toggle tables
        const target = button.dataset.table;
        wrapper.querySelectorAll('.table-view').forEach(div => div.classList.remove('active'));
        wrapper.querySelector('#' + target).classList.add('active');

      });
    });
  });
});
</script>

<div style="
  border-left: 4px solid #c0392b;
  background-color: #fff5f5;
  padding: 12px 16px;
  margin-bottom: 24px;
  font-size: 0.95em;
  color: #333;">
  <strong>Megjegyzés:</strong>
Ez az írás egy független, hosszú formátumú adatelemző és -vizualizációs projekt.
Az ábrák jobb áttekintéséhez ajánlott monitoron vagy (nagyobb) tableten olvasni.
Visszajelzést, vitát, együttműködési javaslatokat örömmel veszek.
A cikk egy rövidített és átszerkesztett, részben átírt változata 
<a href="https://telex.hu/komplex/2026/04/09/kanyarban-akart-elozni-az-ut-szelen-maradt-orban-magyarorszaga">megjelent a Telex-en</a>
, a társszerző Csurgó Dénes volt.
</div>

<div style="background-color: #4a4a4a;
  color: #f2f2f2;
  padding: 1.2em 1.4em;
  margin: 1.5em 0;
  border-radius: 6px;
  font-size: 0.95em;
  line-height: 1.5;">
<strong>Összefoglaló</strong><br>
Magyarország gazdasági felzárkózása 2004 illetve 2010 óta régiós összehasonlításban kudarcosnak mondható. 
Bár az ország 2004-ben, az EU-csatlakozás idején, a legtöbb mutatóban a poszt-szocialista régió élmezőnyéhez tartozott, relatív pozíciója folyamatosan romlott, és ez a tendencia tovább folytatódott a jelenlegi kormány 16 éves uralma alatt. 
Tíz társadalmi-gazdasági mutató – amelyek lefedik a kibocsátás, termelékenység, keresetek, jövedelmek, fogyasztás és a várható élettartam fő trendjeit – segítségével hasonlítom össze Magyarország teljesítményét a többi tíz közép- és kelet-európai országgal (KKE). Az elemzés megmutatja, hogy Magyarország felzárkózása a leggyengébbek közé tartozott, akár a 2004-es, akár a 2010-es bázist használjuk.
</div>

## Tartalom
1. [Mi történt velünk?](#mi-történt-velünk)  
2. [Mihez képest? KKE és Nyugat-Európa](#mihez-képest-kke-és-nyugat-európa)  
3. [Mit nézzünk? A felzárkózás mérőszámai](#mit-nézzünk-a-felzárkózás-mérőszámai)  
4. [Egy főre jutó GDP és GNI](#egy-főre-jutó-gdp-és-gni)  
5. [Termelékenység](#termelékenység)  
6. [Keresetek és jövedelem](#keresetek-és-jövedelem)  
7. [Fogyasztás](#fogyasztás)  
8. [Foglalkoztatás](#foglalkoztatás)  
9. [Várható élettartam](#várható-élettartam)  
10. [Összkép](#összkép)  
11. [Végszó](#végszó)
12. [Függelék](#függelék)
13. [Források](#források)

# Mi történt velünk?

Több mint másfél évtized telt el 2010 óta Orbán Viktor megszakítás nélküli országlása alatt, akinek elképzelései a gazdaságpolitika jellegét is - minden jel szerint - alapvetően meghatározták. 
Ez már elég hosszú idő ahhoz, hogy értékeljük ennek az időszaknak az eredményeit, különösen mivel az országot vezető gazdaságpolitikai rezsim elképzelései és gyakorlata markánsan eltér mind a tágabb európai, mind a szűkebb térségbeli gyakorlatoktól, így racionális azt várni, hogy a pozitív vagy negatív hatások mára felhalmozódtak annyira, hogy beazonosíthatók legyenek.
A lenti elemzésben tíz - elsősorban makrogazdasági jellegű - mutató alapján értékeljük az utóbbi 16 év gazdaságpolitikájának mérlegét. 

# Mihez képest? KKE és Nyugat-Európa

Ahhoz, hogy értelmesen tudjunk beszélni a magyar nemzetgazdaság teljesítményéről, nem nézhetjük az ország makrogazdasági mutatóit önmagukban. Ehelyett egy kontrollált összehasonlításra van szükség: a magyarországi trendeket egyrészt a térségbeli országokkal, másrészt az EU legfejlettebb tagállamaival érdemes összehasonlítani. 
Az előbbi összehasonlítás azt mutatja meg, Magyarország mennyire tér el a régiós trendektől. 
A nyugat-európai referenciaszinthez való közeledés (vagy annak hiánya) pedig azt, milyen mértékben teljesült a "fejlett Nyugathoz" való felzárkózás - ami gyakorlatilag minden térségbeli politikai vezetés célja, illetve a lakosság többségének az elvárása (vagy vágyálma) is. 
Régiós összehasonlításunk így arra a további tíz közép- és kelet-európai (KKE) poszt-szocialista országra terjed ki, amelyek 2004-et követően az EU tagállamaivá váltak. 
Ezek - zárójelben az EU-csatlakozás évét illetve a jelenlegi lakosságméretet jelölve - a következők: Lengyelország (2004, 36,5 millió), Románia (2007, 19 millió), Csehország (2004, 10,9 millió), Bulgária (2007, 6,4 millió), Szlovákia (2004, 5,4 millió), Horvátország (2013, 3,9 millió), Litvánia (2004, 2,9 millió), Szlovénia (2004, 2,1 millió), Lettország (2004, 1,9 millió), Észtország (2004, 1,4 millió).

A nyugat-európai referenciaszintet a nyolc legmagasabb GDP/fő értékkel rendelkező EU-tagállam - lakosságarányosan súlyozott - átlagaként definiáltuk. 
Írországot és Luxemburgot eltávolítottuk az összehasonlításból mivel ezek kis népességű országok speciális adottságokkal, ahol ráadásul a makrogazdasági adatokat adózási-könyvelési anomáliák torzítják. 
Szintén nem vesszük bele az összehasonlításba a dél-európai országokat, mivel ezek az országok gyakran súlyos gazdaségi nehézségekkel küzdöttek az utóbbi tizenöt évben, így nem jelentenének egy értelmes referenciaszintet.
Így az EU8 referencia-csoport országai (lakosság): Németország (83,4 millió), Franciaország (68,4 millió), Dánia (6,0 millió), Hollandia (17,9 millió), Ausztria (9,2 millió), Svédország (10,6 millió), Belgium (11,8 millió), Finnország (5,6 millió).

# Mit nézzünk? A felzárkózás mérőszámai

A gazdasági felzárkózást az egy főre jutó bruttó nemzeti össztermék (GDP) és jövedelem (GNI), a termelékenység, a bérek, a háztartási jövedelmek, a tényleges fogyasztás, a foglalkoztatottsági szint és a várható élettartam mutatói alapján vizsgáljuk. 
Nyilván nincsen egyetlen, "tökéletes" indikátor-halmaz a gazdasági felzárkózás értékelésére, de a választott mutatók adnak egy átfogó képet a kibocsátás, a jövedelmek, a fogyasztás, a munkaerőpiac és a hosszú távú életkilátások alakulásáról.
Egyik mutatónál sem használunk önkényesen definiált küszöbértékeket, amelyek az adatokkal való "trükközés" eszközei lehetnek, hanem egyszerűen az egy főre eső nyers átlag- vagy mediánérték időbeli változását tekintjük. 

Túlságosan kevés makro-mutató használata problémás lehet: pl. a GDP egy főre jutó értéke valószínűleg a leggyakrabban használt mérőszám, de önmagában ugyanakkor félrevezető lehet a lakossági jövedelmekre nézve, például ha a külföldi tőkebefektetések nyereségkiáramlása miatt jelentős rés keletkezik a GDP és a GNI között – ami több KKE-országban, pl. Magyarországon is valós jelenség –, vagy ha a munkajövedelmek részesedése alacsony vagy csökken. Ezért az alábbiakban a GDP egy főre jutó értéke mellett a GNI egy főre jutó mutatóját, valamint több, az átlagos vagy medián lakossági keresetet illetve jövedelmet leíró változót is használunk. 
Szintén elemezzük a minimálbér-szintet, amely különösen az alacsony bérű munkavállalók számára fontos, valamint a foglalkoztatási rátát, amely megmutat(hat)ja a munkaerőpiac feszességét. A várható élettartam trendjei azt mutatják meg, hogy a gazdasági növekedés hosszabb életéveket jelent-e.

Fontos kérdés, hogy hogyan mérjük a felzárkózás mértékét, és ez a gazdasági mutatóknál egyáltalán nem egyértelmű. 

<div style="border: 4px solid red; padding: 24px 16px 16px 16px; border-radius: 5px; position: relative;">

<span style="
  position: absolute;
  top: -10px;
  left: 12px;
  background: #bc8581;
  color: black;
  padding: 2px 8px;
  font-size: 16px;
  border-radius: 4px;
">
MÓDSZERTANI JEGYZET
</span>

A konvergencia mérésének megfelelő mérőszámairól bonyolult módszertani viták folynak, magyar nyelven is, ld. pl. ezeket a tanulmányokat:
<a href="https://www.portfolio.hu/gazdasag/20230907/mire-jo-a-vasarloero-paritas-es-mire-nem-637557">Obláth 2023</a>
és <a href="https://kulgazdasag.eu/api/uploads/Kuelg_7_8_2_Oblath_df9f0c279f.pdf">Obláth 2021</a>.

A cikk végén egy külön függelékben foglalkozunk azzal, hogy mennyiben (nem) függenek az eredmények a választott mérőszámtól. Itt röviden összefoglaljuk a lényeget, összehasonlítva a három lehetséges mérőszámot. 
<br>
A vásárlóerő-paritás (PPP illetve PPS) mérőszámok az országok közötti árkülönbségekre próbálnak úgy korrigálni, hogy a nominális pénzbeli értékeket az egyes valutákban normalizálják egy reprezentatív(nak szánt) vásárló kosár adott országbeli árával, tehát tekintetbe veszik a relatív árszint-különbségeket. <br>

<button style="font-size:0.7em;padding:1px 6px;border:1px solid #6f7a86;border-radius:6px;background:#f6f8fa;color:#0969da;cursor:pointer;">1</button> 
A <b> <a href="https://data.worldbank.org/indicator/NY.GDP.PCAP.PP.CD?locations=HU-PL">folyóáras PPP</a> 
/
PPS mérőszámok </b>  
alkalmasak arra, hogy egy adott időpontban reálértéken hasonlítsuk össze különböző országok jövedelem/kibocsátás/fogyasztás szintjét. A probléma itt az <i>időbeli</i> változások összehasonlításával van, mert a PPP/PPS-ben megadott mutatók időbeli változása egyszerre tükrözi a reálértéken vett (inflációra szűrt) volumen-változásokat, az országokon <i>belüli</i> relatív árváltozásokat (bizonyos áruk másokhoz képest megdrágulnak), illetve az általános árszínvonal emelkedést és az árfolyamhatást. 
Így időben összehasonlítani különböző országok folyóáras PPP mutatóit annyiban problematikus, hogy több tényezőt von össze, amiből az inflációtól megtisztított (reál) volumen-növekedés csak az egyik. <br>

<button style="font-size:0.7em;padding:1px 6px;border:1px solid #6f7a86;border-radius:6px;background:#f6f8fa;color:#0969da;cursor:pointer;">2</button>  
A PPP/PPS alapú összehasonlítás alternatívája, ha csak <b>volumenindexeket</b> hasonlítunk össze. Ez azt jelenti, hogy az egyes országok nominális, saját pénznemükben vett idősorait defláljuk az adott ország releváns árindexével (GDP deflátor, vagy fogyasztói árindex-szel), majd a különböző országok adatait egy fixált árfolyamon egy közös és konstans egységre váltjuk át. 
Ilyen pl. a Világbank 
<a href="https://data.worldbank.org/indicator/NY.GNP.PCAP.KD?locations=HU-B8">constant 2015 USD</a> 
mutatója. 
Ekkor megkapjuk az inflációtól megtisztított volumen-változásokat, amely alkalmas arra, hogy az időbeli relatív növekedést hasonlítsuk össze országok között. Azonban, ha egy referencia-országhoz képest számított <i>relatív szint</i> érdekel minket, erre ez a mutató kevésbé alkalmas, mert az országok közötti árszint-különbségeket egyáltalán nem veszi figyelembe, így az alacsonyabb jövedelemszinten lévő országokat alacsonyabb szintre fogja tenni a gazdagabbakhoz képest, mint a tényleges jövedelmi vagy fogyasztás-szintbeli különbség. 
Ugyanakkor, ha csak a relatív felzárkózási teljesítményt nézzük, pl. hogy adott KKE országok GNI/fő szintje az EU8 átlag hány százaléka volt 2010-ben és ez hogyan változott 2024-re, akkor a volumenindex egy alkalmas konvergencia-indikátor, viszont egy <i>adott</i> év GNI/fő szintjének az EU8 országokkal való összehasonlítására kevésbé megfelelő.
<br>

<button style="font-size:0.7em;padding:1px 6px;border:1px solid #6f7a86;border-radius:6px;background:#f6f8fa;color:#0969da;cursor:pointer;">3</button> 
Az időbeli és térbeli összehasonlíthatóságot egyszerre próbálja megoldani a <b>konstans PPP</b> mutató. Ezek a mutatók valójában szintén volumen-indexek, tehát az inflációra korrigált reál-növekedést hasonlítják össze, azonban az így kapott értékeket egy <i>adott év</i> relatív árszint különbségeivel korrigálják. Tehát, pl. ha a PPP által használt fogyasztói kosár 2021-ben (az adott év árfolyamát használva) egy adott országban csak 70%-a volt a referenciaszintnek (ami a PPS-nél az egész EU-ra vett átlagos ár), akkor ezen ország mutatóit arányosan felszorozza 100%-ra, hogy eltávolítsa az árkülönbségek hatását.
Mivel ez a mutató csak egy konstanssal szorozza meg a volumenváltozások trendjét, ezért ha relatív változásokat nézünk, akkor a konstans PPP és a konstans áras (de nem PPP-alapú) volumenindex ugyanazt fogja mutatni. Ezért ezt a két mutatót nem szükséges egyszerre vizualizálni. A konstans PPP-nél viszont azt fontos látni, hogy a konkrét értékek erősen függeni fognak attól, hogy melyik évhez rögzítjük az adatsort, mivel az országok közötti relatív árszinteket több tényező is mozgatja. 

Mivel a lenti elemzésben elsősorban az EU centrumországaihoz viszonyított relatív változást elemezzük, 
ezért a legtöbb esetben a <i>konstans PPP</i> mutatót használtuk, ami egyrészt megadja a volumen-változást, másrészt az EU8-hoz képest számolt <i>szintet</i> is, habár az utóbbi számoknál fontos észben tartani, hogy függenek a referenciaévtől. Mivel azonban minden KKE országra ugyanazt a referenciaévet alkalmaztuk, ezért az eredmények nem függenek erősen ettől.

A cikk végén lévő 
<a href="https://mbkoltai.com/magyar-kke-konvergencia-ujsag/#f%C3%BCggel%C3%A9k">Függelékben</a> 
részletesen megvizsgáljuk, hogy mennyiben függenek az eredmények a választott mértékegységtől.
</div>

Az alábbiakban a mutatók időbeli változását mindig háromféleképpen számoljuk ki. Az első egyszerűen az abszolút változás időben. A pénzbeli mutatókat vásárlóerő-paritáson (PPP/PPS) fejeztük ki a nemzetközi összehasonlíthatóság érdekében, és ahol lehetséges, állandó USD-ben, az inflációt kiszűrve. 
A medián kereseteket, a háztartási jövedelmeket és a fogyasztást az Eurostat vásárlőerő-szabványában (PPS) megadva elemezzük. Ez kiszűri az országok közötti árszintkülönbségeket, viszont időben *nem* infláció-korrigált (ellentétben a konstans USD mutatókkal), hanem az EU egészének árszintjéhez kötött - így ezek az idősorok lényegében az EU-szintű fogyasztói inflációt tükrözik. A mértékegységekkel kapcsolatban az alábbi piros szövegdobozban teszünk egy rövid kitérőt. 


A második számításmód a bázisévhez viszonyított relatív változás, ahol az értékeket 2004-hez (EU-csatlakozás) vagy 2010-hez normalizáljuk (kiindulási év=100). Az alacsonyabb kezdeti szintről induló országoknál jellemzően nagyobb a relatív növekedés. 

A harmadik számításmód az indikátorokat az EU8 országcsoport átlagának százalékában fejezi ki: ez a nyugat-európához való felzárkózás mércéje.

A lenti ábrák az egyes indikátorok időbeli alakulását mindhárom számításmód szerint megmutatják, míg a kumulatív változásokat táblázatokban foglaljuk össze. Az országokat az EU8-hoz való felzárkózás mértéke szerint rangsoroljuk - ez alól kivétel a foglalkoztatási ráta, ahol az abszolút százalékpontos növekedés a rangsorolás alapja, illetve a várható élettartam, ahol az abszolút (években mért) emelkedés alapján rangsoroljuk. Ennél a két változónál az abszolút számok informatívabbak, mivel az EU8 százalékában nézve mindkét mutató közel jár a 100%-hoz. És most nézzük az eredményeket.

# Egy főre jutó GDP és GNI

### GDP/fő

A [KKE régió egészét nézve](https://mbklt.substack.com/p/the-long-road-to-convergence-central) az egy főre eső - reálértéken vett, inflációra korrigált - bruttó nemzeti össztermék (GDP) 2004 óta csaknem megduplázódott (+93%), 2010 óta pedig másfélszeresére (+55%) nőtt. 
Bármelyik számításmódot is használjuk - abszolút, az EU8 %-ában kifejezett vagy relatív növekmény - Lengyelország, Románia és Litvánia teljesítettek a legjobban a régióban.

Több más indikátorhoz hasonlóan Csehország (CZ) és Szlovénia (SI) GDP/fő szintje már 2004-ben is jelentősen - közel 50%-kal - a régiós átlag felett volt. E két ország későbbi növekedési üteme lassabb volt, feltehetően a magasabb kezdeti szint miatt (is), így Csehország és Szlovénia kumulatív növekedése mind relatív, mind abszolút értelemben kisebb volt. 
Ennek ellenére 2024-ben CZ és SI továbbra is a régió élén maradtak, az EU8 szintjének nagyjából 80%-án, de 2024-re Litvánia és Lengyelország gyakorlatilag szintén elérték ugyanezt az egy főre jutó GDP-szintet.


<div class="flourish-embed flourish-chart" data-src="visualisation/27400942"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27400942/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<div class="table-toggle">

  <div class="controls">
    <button data-table="GDP-2004">2004–2024</button>
    <button class="active" data-table="GDP-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="GDP-2004" class="table-view">
      {% include images/hu-cee-convergence/output/HU/GDP_per_cap/table_2004_2024.html %}
    </div>
    <div id="GDP-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/GDP_per_cap/table_2010_2024.html %}
    </div>
</div>

<br>
<b>1. táblázat:</b> A GDP/fő változása 2004-től illetve 2010-től 2024-ig, az EU8 átlagának százalékában, a kiinduló évhez viszonyítva, valamint abszolút értékben (2021-es konstans nemzetközi dollár, PPP). Zárójelben a teljes időszak alatt történt változás. Az országok az EU8-hoz viszonyított mutató szerint vannak rangsorolva.
</div>

A tizenegy KKE ország kumulatív felzárkózás szerinti rangsorában Magyarország 2004-től számítva a 8., 2010-től a 7. helyen van. 
Csehország és Szlovénia még kisebb felzárkózást mutatott, de egy jóval magasabb kiindulási szintről. 
E két országon kívül csak Észtország - illetve a 2010-es bázist használva Szlovákia - mutatott kisebb mértékű felzárkózást az EU8 átlagához. 2004-2012 között Magyarország GDP/fő-ben *leszakadást* mutatott az EU8 átlaghoz képest, 2022-től pedig stagnálást, azaz a teljes felzárkózás - már amennyi volt - a 2013 és 2022 közötti időszakban történt.

A továbbiakban látni fogjuk, hogy a GDP/fő rangsor valójában *túl pozitív* képet fest Magyarország felzárkózásáról, ugyanis a termelékenység és a lakossági jövedelmek tekintetében a helyzet ennél jóval rosszabb. 

### GNI/fő

A bruttó nemzeti jövedelem (GNI) szűkebb és az ország jövedelmi viszonyaira nézve gyakran informatívabb kategória mint a GDP. 
A GNI megkapható a GDP-ből, ha az utóbbihoz hozzáadjuk az adott ország nettó elsődleges jövedelem-mérlegét: ez az ország lakosainak külföldön szerzett (akár tőke- akár munkajellegű) jövedelmeinek illetve a külföldieknek az országban szerzett jövedelmeinek különbsége. Ez a jövedelem-mérleg gyakran negatív olyan országokban, ahol a külföldi befektetések jelentősek és ezt nem kompenzálják az ország állampolgárainak külföldi befektései. Ez a legtöbb KKE országban így van, azaz a nemzeti jövedelem (GNI) kisebb, mint a nemzeti össztermék (GDP), Magyarországon kb. 5%-kal, ami a belföldi jövedelmeknek is egyfajta felső határt szab. 
Több KKE országban (Magyarországon kívül pl. Szlovákiában, Bulgáriában vagy Lettországban) a GDP növekedése meghaladta a GNI bővülését a jelentős negatív elsődleges jövedelemegyenleg miatt és a GNI/fő jobb előrejelzője a lakossági jövedelmek növekedésének, mint a GDP/fő.

Az egy főre jutó GNI *trendjei* ugyanakkor hasonló képet mutatnak arról, hogy mely országok közeledtek jobban az EU8 átlagához: Lengyelország, Románia és a balti államok kb 25-30%-kal kerültek közelebb az EU8 átlagához 2004 óta. 
A felzárkózás mértékét rangsorolva a lista alján ismét Csehországot, Szlovéniát, Szlovákiát és Magyarországot találjuk. 
Mivel Csehország és Szlovénia már 2003-ban is magasabb szinten voltak az EU8-hoz viszonyítva, mint ahol Magyarország és Szlovákia akár 2024-ben volt, kisebb mértékű felzárkózásuk kevésbé tekinthető aggasztónak.

<div class="flourish-embed flourish-chart" data-src="visualisation/27360441"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27360441/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<!--- TÁBLÁZAT --->

<div class="table-toggle">
  <div class="controls">
    <button data-table="gni-2004">2004–2023</button>
    <button class="active" data-table="gni-2010">2010–2023</button>
  </div>

<div class="table-container">
    <div id="gni-2004" class="table-view">
      {% include images/hu-cee-convergence/output/HU/GNI_per_cap/table_2004_2023.html %}
    </div>
    <div id="gni-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/GNI_per_cap/table_2010_2023.html %}
    </div>
</div>

<br>
<b>2. táblázat:</b> A GNI/fő kumulatív változása 2004-től illetve 2010-től 2023-ig; az EU8 átlagának százalékában, a kiinduló évhez viszonyítva, valamint abszolút értékben (2021-es konstans nemzetközi dollár, PPP). Az országok az EU8-hoz viszonyított mutató szerint vannak rangsorolva.
</div>

Miközben a KKE régió egésze 23 százalékpontnyi felzárkózást mutatott az EU8 átlaghoz (43→66%) GNI/fő tekintetében, Magyarország két évtized alatt mindössze 10%-kal közeledett hozzá. 
Hasonlóan gyenge konvergenciapályát gyakorlatilag csak Szlovákia mutatott, ahol 2010 óta szinte egyáltalán nem tapasztalható konvergencia. 
Ha nem számítjuk a magasabb jövedelem-szinten lévő Csehországot és Szlovéniát, a 2010 óta bekövetkezett relatív változást nézve Szlovákia áll a rangsor legvégén, Magyarország pedig a második legrosszabb helyen.

Magyarország gyenge konvergencia-teljesítménye kettő elhúzódó stagnálási időszakból adódik: 2005 és 2012 között, valamint 2022-től napjainkig semmilyen felzárkózásra nem volt képes az ország. 
Bár a balti államok az elmúlt három évben szintén stagnáltak GNI/fő tekintetében, mivel a korábbi időszakokban erőteljesebb növekedést értek el, így kumulatív teljesítményük jobb. 
Magyarországhoz hasonlóan "beragadt" GNI-növekedési pálya csak Szlovákiában figyelhető meg.

# Termelékenység

A kibocsátás és a jövedelmek emelkedését hosszabb távon csak a termelékenység javulása tarthatja fönt (eltekintve a fizikai környezet kapacitásairól, amit itt most nem elemzünk, bár nyilván fontos - talán a legfontosabb - kérdés). 
Ha egy nemzetgazdaság tartós alulfoglalkoztatottsággal küzd, a foglalkoztatási ráta emelése átmenetileg növelheti a kibocsátást, de a foglalkoztatottsági arány egyszerűen demográfiai okokból egy adott szint fölé nem növelhető. 
A munkaórák mennyisége szintén egy "kemény plafonnal" rendelkező változó, hiszen magas jövedelmű országokban az éves ledolgozott munkaórák jellemzően stabilak - sőt, általában lassan csökkennek - és a munkaidő meghosszabbítása se nem reális, se nem kívánatos.

A KKE-régió munkatermelékenységének felzárkózása az EU8 átlagához jól szemlélteti ezt a dinamikát. 
Összességében a KKE régió termelékenységi konvergenciája gyengébb volt, mint az egy főre jutó GDP vagy GNI felzárkózása: 2004 és 2024 között az EU8 szintjének 40%-áról 57%-ára emelkedett. 
Ennek oka, hogy az egy *főre* jutó kibocsátás felzárkózásának egy része a 2000-es évek közepétől bekövetkezett foglalkoztatás-bővülésből adódott, ami vélhetően a rendszerváltás utáni recesszió során kialakult strukturális alulfoglalkoztatottság csökkenéséből jött a 2010-es évek fellendülése során. 
Ez a növekedési forrás azonban mára nagyrészt kimerült, így további növekedés már csak a munkatermelékenység javulásától várható.

A munkatermelékenységben az egyes országok relatív teljesítménye hasonló mintázatot mutat, mint a korábbi mutatóknál. 
Románia, Lengyelország és a balti államok érték el a legerősebb felzárkózást az egy ledolgozott órára jutó kibocsátásban: Románia szintje megháromszorozódott, a balti országoké pedig nagyjából megduplázódott.

A régió egészének felzárkózási kilátásai szempontjából aggodalomra adhat okot, hogy a két legfejlettebb régiós ország (Csehország és Szlovénia) húsz év alatt mindössze 6-10%-kal tudott feljebb kapaszkodni az EU8 átlagának százalékában kifejezve, és még mindig csak az EU8 szintjének 62-63%-án vannak.

<div class="flourish-embed flourish-chart" data-src="visualisation/27401752"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27401752/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- OUTPUT per hr worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="GDPperhr-2004">2004–2023</button>
    <button class="active" data-table="GDPperhr-2010">2010–2023</button>
  </div>

<div class="table-container">
    <div id="GDPperhr-2004" class="table-view">
      {% include images/hu-cee-convergence/output/HU/productivity/per_hr_work/table_2004_2023.html %}
    </div>
    <div id="GDPperhr-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/productivity/per_hr_work/table_2010_2023.html %}
    </div>
</div>
<br>
<b>3. táblázat:</b> A GDP/ledolgozott óra kumulatív változása 2004-től illetve 2010-től 2024-ig; az EU8 átlagának százalékában, a kiinduló évhez viszonyítva, valamint abszolút értékben (2021-es konstans nemzetközi dollár, PPP). Az országok az EU8-hoz viszonyított mutató szerint vannak rangsorolva.

</div>

Magyarország a 2004-es bázishoz viszonyítva a munkatermelékenység felzárkózásában az *utolsó* helyen áll, mind abszolút értelemben, mind az EU8 átlagának százalékában mérve. 
A 2010-es bázist használva sem sokkal jobb a helyzet: Magyarország itt hátulról a második helyen van. 
Figyelemre méltó, hogy 2024-re Magyarország munkatermelékenysége az EU8 átlagához képest *alacsonyabb szinten volt, mint 2010-ben*. 
Ez azt jelenti, hogy a termelékenység nem csak a régiós versenytársaknál nőtt kevésbé, de még a - sokkal magasabb produktivitás-szinten lévő - centrumállamoknál is.
Ebben az időszakban csak Magyarország és Szlovákia mutatott relatív visszaesést a nyugat-európai szinthez képest. 
Magyarország esetében *talán* láthatók javulásra utaló jelek az utóbbi években, mivel a munkatermelékenység 2016-tól emelkedésnek indult, bár továbbra is lassabb ütemben, mint a régió legtöbb országában.

# Keresetek és jövedelem

A kibocsátás és a termelékenység növekedése egy dolog - de mi a helyzet a munkavállalók és a háztartások jövedelmeivel? 
Ezen a téren is lemaradt Magyarország a régiós versenytársaihoz képest? 
Ezekre a kérdésekre a bérekre és jövedelmekre vonatkozó mutatók segítségével keressük a választ.

## Éves átlagkereset

Az éves átlagkeresetekre (annual average wages) az OECD adatbázisát használjuk, ami vásárlóerő-paritáson és 2021-es állandó amerikai dollárban adja meg ezeket. 
2004 óta a KKE-régióban az átlagkeresetek átlagosan 55%-kal emelkedtek, aminek nagy része 2010 után következett be. 
Az EU8 átlagához viszonyítva ez azt jelenti, hogy a régió a nyugat-európai referenciaérték 46%-áról 63%-ára zárkózott fel.
Románia, Horvátország és Bulgária nem szerepelnek ebben az adatbázisban, mivel még nem tagjai az OECD-nek. 
A fennmaradó nyolc ország közül ismét a balti államokban és Lengyelországban figyelhető meg a legerősebb felzárkózás, és ebben az esetben Szlovéniában is, amely 2024-re csaknem elérte az EU8 csoport átlagát (92%).

<div class="flourish-embed flourish-chart" data-src="visualisation/27401033"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27401033/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- ANNUAL AVERAGE WAGE per hr worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="annaverwage-2004">2004–2024</button>
    <button class="active" data-table="annaverwage-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="annaverwage-2004" class="table-view">
      {% include images/hu-cee-convergence/output/HU/wages/annual_aver_wage/table_2004_2024.html %}
    </div>
    <div id="annaverwage-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/wages/annual_aver_wage/table_2010_2024.html %}
    </div>
</div>
<br>
<b>4. táblázat:</b> Az átlagos éves kereset kumulatív változása 2004-től illetve 2010-től 2024-ig; az EU8 átlagának százalékában, a kiinduló évhez viszonyítva, valamint abszolút értékben (2024-es konstans nemzetközi dollár, PPP). Az országok az EU8-hoz viszonyított mutató szerint vannak rangsorolva.
</div>


A 2004-es bázishoz viszonyítva Magyarország mutatta a *legkisebb* mértékű felzárkózást az átlagkeresetet tekintve. 
2010-es bázist használva a felzárkózás a *második* leglassabb volt, Csehországot leszámítva - Szlovákia konvergenciája még ennél is gyengébb volt.
Ugyanakkor ez az adatbázis az *átlag*keresetekről szól, amit eltorzíthatnak a magas keresek, és nem feltétlenül tükrözik a tipikus munkavállaló helyzetét.

## Medián órabér

Az Eurostat négy évente közöl becsléseket a medián órabérekre; mi itt a vásárlóerő-szabványban (PPS) kifejezett medián bérekre fókuszálunk (ld Módszerek). Jelenleg az utolsó adat 2022-ből származik, így a 2023-as inflációs hullám reálbérekre gyakorolt hatásai még nem tükröződnek az adatokban. A KKE-országok esetében az idősor 2006-ban kezdődik, ezért kiindulási bázisévként használjuk. 

2006 óta a régió medián órabére átlagban az EU8 szintjének 34%-áról 61%-ára nőtt. A kumulatív felzárkózást nézve - az EU8 referenciaérték százalékában - a régió élmezőnyében ismét a balti államok, Románia és Lengyelország állnak.

<div class="flourish-embed flourish-chart" data-src="visualisation/27401652"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27401652/thumbnail" width="100%" alt="chart visualization" /></noscript></div>


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Real median earnings per hr worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="real_median_hourly-2006">2006–2022</button>
    <button class="active" data-table="GDPperhr-2010">2010–2022</button>
  </div>

<div class="table-container">
    <div id="real_median_hourly-2006" class="table-view">
      {% include images/hu-cee-convergence/output/HU/wages/real_median_hourly/table_2006_2022.html %}
    </div>
    <div id="real_median_hourly-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/wages/real_median_hourly/table_2010_2022.html %}
    </div>
</div>
<br>
<b>5. táblázat:</b> A medián órabér kumulatív változása 2006-tól illetve 2010-től 2022-ig; az EU8 átlagának százalékában, a kiinduló évhez viszonyítva, valamint abszolút értékben (vásárlóerő-paritás, PPS). Az országok az EU8-hoz viszonyított mutató szerint vannak rangsorolva.
</div>

Magyarország a medián órabér felzárkózásában is a régiós rangsor alsó részén helyezkedik el. 
A 2006-os bázishoz viszonyítva csak Csehország és Szlovénia mutatott kisebb mértékű felzárkózást, de - mint gyakorlatilag minden indikátornál - mindkettő jelentősen magasabb szintről indult, mint Magyarország. 
A 2010-es bázishoz képest Magyarország a régió harmadik legalacsonyabb felzárkózási teljesítményét mutatja; Csehországtól és Szlovéniától eltekintve egyedül Horvátország bérfelzárkózása volt ennél is gyengébb.

## Minimálbér

A törvényben meghatározott minimálbér különösen az alacsony bérű munkavállalók számára fontos, de az egész kereslet-eloszlásra is jelentős hatása lehet. 
Itt az OECD nemzetközi minimálbér-adatbázisát használjuk, amely megint csak konstans 2021-es USD-ben és vásárlóerőparitáson (PPP) adja meg a minimálbért az OECD országokban. 
Több EU8 országban nincsen országosan előírt minimálbér (vagy korábban nem volt), helyette ágazati kollektív megállapodásokra támaszkodnak, így itt a nyugat-európai referenciaérték csak az OECD adatbázisban szereplő három EU8 ország - Belgium, Franciaország és Hollandia - súlyozott átlagát jelenti.

Az EU3 referenciaértékhez viszonyítva a KKE-régió (átlagos) minimálbér-szintje 2004 óta több mint megduplázódott, az előbbi 28%-áról 63%-ára nőve. 
A felzárkózás szempontjából a régió élén ismét Románia, Lengyelország, Bulgária és a balti államok állnak. 
Romániában a minimálbér 2004-hez viszonyítva négyszeresére nőtt (az EU3 átlagszint százalékában kifejezve), míg Bulgáriában majdnem háromszoros, Lengyelországban és Litvániában pedig több, mint kétszeres emelkedés történt.

<div class="flourish-embed flourish-chart" data-src="visualisation/27401120"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27401120/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Minimum wage table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="min_wage-2004">2004–2024</button>
    <button class="active" data-table="min_wage-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="min_wage-2004" class="table-view">
      {% include images/hu-cee-convergence/output/HU/wages/min_wage/table_2004_2024.html %}
    </div>
    <div id="min_wage-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/wages/min_wage/table_2010_2024.html %}
    </div>
</div>
<br>
<b>6. táblázat:</b> A minimálbér kumulatív változása 2004-től illetve 2010-től 2024-ig: az EU3 átlagának százalékában, a kiinduló évhez viszonyítva, valamint abszolút értékben (2024-es konstans nemzetközi dollár, PPP). Az országok az EU3 szint arányában kifejezett változás szerint vannak rangsorolva.

</div>

A 2004-es bázishoz viszonyítva Magyarország a harmadik legrosszabb helyen áll (+22% az EU3 referenciaértékének arányában), csak Szlovákia és Csehország mutatott gyengébb felzárkózást. 
Ugyanakkor 2010 után Magyarországon felgyorsultak a minimálbér emelések, és 2010-től mérve a felzárkózási teljesítmény - az EU3 átlag 29%-áról 52%-ára emelkedve - a mezőny közepére (5/11) esik.

## Medián nettó háztartási jövedelem

A munkabérek nem az egyetlen lakossági jövedelemforrást jelentik - sok háztartás más bevételi forrásokra, például nyugdíjakra vagy szociális juttatásokra, is támaszkodik. 
A háztartási jövedelem középértékét adja meg az Eurostat *medián ekvivalens nettó jövedelem* idősora, amely a keresetnél tágabb mutató: egyrészt a teljes népességre (nem csak a munkavállalókra) kiterjed, másrészt magában foglalja a háztartások minden rendelkezésre álló jövedelmét, adók és transzferek után, egy főre vetítve és tekintetbe véve a háztartások méret- és összetétel-különbségeit is.

2005 és 2024 között a KKE régió jelentős felzárkózást mutatott ebben a mutatóban: a régió átlagát nézve a medián ekvivalens nettó jövedelem az EU8 átlagának 31%-áról 62%-ára emelkedett. A legnagyobb növekedést Lengyelország, Románia és a balti államok érték el. Lengyelország elérte a nyugat-európai referenciaérték 73%-át, míg a régió legfejlettebb országa, Szlovénia, 2024-re az EU8 szintjének 87%-ára kúszott föl (vásárlóerő-paritáson mérve), megközelítve a nyugat-európai háztartási jövedelmek szintjét.

<div class="flourish-embed flourish-chart" data-src="visualisation/27401327"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27401327/thumbnail" width="100%" alt="chart visualization" /></noscript></div>


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Median equivalised net income worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="median_equiv_net_income-2005">2007–2024</button>
    <button class="active" data-table="median_equiv_net_income-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="median_equiv_net_income-2005" class="table-view">
      {% include images/hu-cee-convergence/output/HU/wages/median_equiv_net_income/table_2007_2024.html %}
    </div>
    <div id="median_equiv_net_income-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/wages/median_equiv_net_income/table_2010_2024.html %}
    </div>
</div>
<br>
<b>7. táblázat:</b> A medián ekvivalens nettó jövedelem kumulatív változása 2005-től illetve 2010-től 2024-ig; az EU8 átlagának százalékában, a kiinduló évhez viszonyítva, valamint abszolút értékben (vásárlóerő-szabvány, PPS). Az országok az EU8-hoz viszonyított mutató szerint vannak rangsorolva.

</div>

Magyarország a 2005-ös bázishoz viszonyítva a *leggyengébb* felzárkózást mutatta: a háztartási jövedelmek két évtized alatt mindössze 9 százalékponttal emelkedtek az EU8-átlag arányában kifejezve. Ez a régió legrosszabb teljesítménye, amelynek következtében 2024-ben Magyarországon volt a *legalacsonyabb* a nettó medián háztartási jövedelem. 
A 2010-es bázistól mérve sem jobb a helyzet: Magyarország hátulról a második - ebben a periódusban Szlovákia felzárkózása még ennél is gyengébb volt. 
Ennek eredményeként e két ország háztartási jövedelmi szintje mára nagyjából azonos - és kevesebb mint kétharmada a lengyel szintnek, annak ellenére, hogy Magyarország 2005-ben magasabb szintről indult, mint Lengyelország.

# Fogyasztás

A medián nettó háztartási jövedelem nem adja meg feltétlenül a fogyasztási színvonalat is, mivel országonként eltérhet, hogy a jövedelem mekkora részét fordítják a háztartások tényleges fogyasztásra, illetve, hogy mennyire léteznek ingyenes állami (vagy más szervezetek által nyújtott) szolgáltaltások.

A háztartási fogyasztási szint követésére használja az Eurostat az ún. tényleges egyéni fogyasztás (actual individual consumption, AIC) mutatót. Az AIC az egy főre jutó teljes háztartási fogyasztást tükrözi, függetlenül attól, hogy ki finanszírozza azt, így tartalmazza azokat a javakat és szolgáltatásokat is, amelyeket a háztartások fogyasztanak, de az állam vagy nonprofit intézmények fizetik meg. 
Ez a mutató is vásárlóerő-standardban (PPS) van kifejezve (ld. a Módszerek részben).

A lenti ábra megmutatja, hogy a fogyasztási szint EU8 átlagához való felzárkózása hasonló volt a jövedelmekéhez: 2004 és 2024 között átlagosan 27%-os növekedés következett be az egész KKE régióban, az EU8-átlag százalékában kifejezve. 
A legnagyobb előrelépést ismét Románia, Bulgária, Lengyelország és a balti államok érték el.

<div class="flourish-embed flourish-chart" data-src="visualisation/27401717"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27401717/thumbnail" width="100%" alt="chart visualization" /></noscript></div>

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Actual individual consumption worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="actual_indiv_cons-2004">2004–2024</button>
    <button class="active" data-table="actual_indiv_cons-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="actual_indiv_cons-2004" class="table-view">
      {% include images/hu-cee-convergence/output/HU/actual_indiv_consump/table_2004_2024.html %}
    </div>
    <div id="actual_indiv_cons-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/actual_indiv_consump/table_2010_2024.html %}
    </div>
</div>
<br>
<b>8. táblázat:</b> A tényleges egyéni fogyasztás kumulatív változása 2004-től illetve 2010-től 2024-ig; az EU8 átlagának százalékában, a kiinduló évhez viszonyítva, valamint abszolút értékben (vásárlóerő-paritás, PPS). Az országok az EU8-hoz viszonyított mutató szerint vannak rangsorolva.

</div>

Magyarország 2004 óta a *második leggyengébb* felzárkózást mutatta a fogyasztási szintben (is): a tényleges egyéni fogyasztás két évtized alatt mindössze 9%-kal emelkedett az EU8 átlagának arányában kifejezve, így 2024-ben Magyarországon volt a régió legalacsonyabb AIC-szintje, az EU8 átlagának 64%-a. 
Az egyetlen ország, amely ennél is gyengébb felzárkózást mutatott, Szlovénia, ám Szlovénia már 2004-ben az EU8 átlagának 67%-án volt, amit Magyarország még 2024-re sem ért el.

A már ismert mintázatot ismételve a 2010-es bázishoz viszonyítva Szlovákia felzárkózása még Magyarországénál is gyengébb volt. 
Magyarország előrelépése a 2010-es bázisról számítva is elmaradt az összes többi országétól, Szlovákiát és a magasabb bázisról induló Csehországot és Szlovéniát leszámítva.

# Foglalkoztatás

A foglalkoztatási rátának itt használt verziója a teljes 15 év feletti népességre vonatkozik. 
Hasonló korstruktúrájú országok esetében - mint amilyenek a KKE-régió országai - az alacsonyabb foglalkoztatási ráta strukturális alulfoglalkoztatottságra utalhat, amit a munkanélküliségi statisztika nem feltétlenül mutat meg. A KKE régió magas kivándorlási rátával rendelkező országaiban jelentős bizonytalanság van a ténylegesen az országban élő munkavállalók számában, így a foglalkoztatási ráta számlálója és nevezője egyaránt bizonytalan lehet. Emiatt az alábbi adatokat valószínűleg nem helyes pontos értékekként értelmezni, de a trendekről valamit mégis elmondanak.

A 2000-es évek közepén számos KKE országban a foglalkoztatási ráta viszonylag [alacsony](https://data.worldbank.org/indicator/SL.EMP.TOTL.SP.ZS?locations=PL-B8-DE) volt Nyugat-Európához, különösen az EU8 legfejlettebb országaihoz – például Németországhoz, Ausztriához és a skandináv államokhoz – képest: 2004-ben a KKE-régió átlagos foglalkoztatási rátája körülbelül 45% volt, szemben az EU8 55-60%-os szintjével. 
Ez alighanem a 1990-es évek tranzíciós válságának egyfajta öröksége volt, amelynek során a gazdaságtalan iparágak bezárása a munkaerő jelentős részének tartós kiszorulásához vezetett a foglalkoztatásból. Sok érintett nem jelent meg a munkanélküliségi statisztikákban, például mert korai nyugdíjazási programokba lépett be, vagy más módon (pl. informális foglalkoztatás) hagyta el a munkaerőpiacot.

Amint a lenti ábra mutatja, ez a különbség a 2004 utáni másfél évtizedben gyakorlatilag eltűnt. 
A 2010-es évek végére a legtöbb KKE-ország elérte az EU8 átlagához hasonló foglalkoztatási rátát, Horvátország és Románia kivételével. Összességében a régióban a foglalkoztatási ráta a 15 év feletti népesség körében az 55–60%-os tartományba emelkedett, nagyjából elérve a nyugat-európai szintet.

<div class="flourish-embed flourish-chart" data-src="visualisation/27401826"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27401826/thumbnail" width="100%" alt="chart visualization" /></noscript></div>


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Employment ratio (15+ population) TABLE  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="employment-2004">2004–2024</button>
    <button class="active" data-table="employment-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="employment-2004" class="table-view">
      {% include images/hu-cee-convergence/output/HU/employment/table_2004_2024.html %}
    </div>
    <div id="employment-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/employment/table_2010_2024.html %}
    </div>
</div>
<br>
<b>9. táblázat:</b> A foglalkoztatási ráta (% a 15+ éves népességből) kumulatív változása 2004-től illetve 2010-től 2024-ig; az EU8 átlagának százalékában, a kiinduló évhez viszonyítva, valamint a 15+ éves népesség százalékában. Az országok az abszolút változás (15+ éves népesség százaléka) mértéke szerint vannak rangsorolva.

</div>

Ez az egyetlen mutató, amiben Magyarország felzárkózása valamivel meghaladta a régiós átlagot. 
A 2004-es bázishoz viszonyítva a foglalkoztatási ráta növekedése a harmadik legnagyobb, a 2010-es bázistól mérve pedig – Litvániával holtversenyben – a legnagyobb. Tegyük hozzá, hogy ez a 2010-hez viszonyított kiemelkedő teljesítmény részben bázishatást tükröz: 2004 és 2010 között e két utóbbi országban a foglalkoztatási ráta (enyhén) csökkent, ami inkább kivételnek számított a régióban, emiatt a 2010-es érték különösen alacsony volt. 
Az ezt követő emelkedés Magyarországon beleilleszkedik a régiós trendbe, és a kumulatív növekedés illetve a 2024-re elért szint nem kiugró, bár marginálisan átlag feletti; a szokatlan inkább az volt, hogy 2010-ben mennyire alacsony volt a foglalkoztatási ráta.

# Várható élettartam

A várható élettartam (period life expectancy) az adott pillanatban mért kor-specifikus halálozási ráták alapján becsült élettartamot jelenti. A KKE-régióban ez a mutató már az 1990-es évek elejétől jelentősen emelkedett, nagyjából 25 évnyi stagnálást követően, amely 1990 előtt [jellemezte a térséget](https://mbkoltai.com/cee-convergence/).

2004 és 2024 között ez a felzárkózás folytatódott, de lassabb ütemben: a várható élettartam a KKE-régió egészében mintegy 4 évvel nőtt, átlagosan 78 évre emelkedve, ami az EU8 átlagának körülbelül 95%-a. 
Szlovénia elérte az EU8 átlag-szintet, míg Románia, Bulgária és Litvánia továbbra is csak az EU8-átlagszint mintegy 92%-án vannak.

<div class="flourish-embed flourish-chart" data-src="visualisation/27401876"><script src="https://public.flourish.studio/resources/embed.js"></script><noscript><img src="https://public.flourish.studio/visualisation/27401876/thumbnail" width="100%" alt="chart visualization" /></noscript></div>


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- life_exp TABLE -->

<div class="table-toggle">
  <div class="controls">
    <button data-table="life_exp-2004">2004–2023</button>
    <button class="active" data-table="life_exp-2010">2010–2023</button>
  </div>

<div class="table-container">
    <div id="life_exp-2004" class="table-view">
      {% include images/hu-cee-convergence/output/HU/life_exp/table_2004_2023.html %}
    </div>
    <div id="life_exp-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/life_exp/table_2010_2023.html %}
    </div>
</div>
<br>
<b>10. táblázat:</b> A várható élettartam kumulatív változása 2004-től illetve 2010-től 2024-ig. Értékei években, az EU8 átlagának százalékában (súlyozott átlag), vagy a kiinduló értékhez viszonyítva. Az országok a változás évei szerint vannak rangsorolva
</div>

Magyarországon a várható élettartam növekedése nagyjából összhangban volt a KKE-régió átlagos trendvonalával, akár 2004-től, akár 2010-től mérjük. 2022-re a várható élettartam elérte a 77 évet, ami minimálisan a régió súlyozott átlaga alatt maradt.

# Összkép

Az alábbi táblázatban összefoglaltuk hogyan változott az összes vizsgált indikátor Magyarországon a régióhoz képest.

A táblázat három egymást kiegészítő módon mutatja be az eredményeket. 
Először is Magyarország helyezését adja meg a régióban, kétféleképpen. 
Az egyik rangsorolásnál ("Rangsor CZ/SI nélkül") kizártuk Csehországot és Szlovéniát, mivel ezek a legtöbb mutatónál jóval magasabb szintről indultak, míg a másikban ("Rangsor (összes ország)") mind a 11 KKE-országot néztük. 
Az országok rangsorolása egyrészt a kezdeti (általában 2004), a 2010-es illetve a 2024-es *szint*, másrészt a 2004–2024 vagy 2010–2024 közötti kumulatív *változás* - tehát a felzárkózási teljesítmény - alapján van kiszámítva.

Az "Értékek" gombra kattintva az indikátorok *értékeit* láthatjuk Magyarországra (HU) illetve a KKE-régió átlagára (KKE) kiszámítva.


<div class="table-toggle">
  <div class="controls">
    <button class="active" data-table="df_hu_rank_no_CZ_SI">Rangsor (CZ/SI nélkül)</button>
    <button data-table="df_hu_rank_all">Rangsor (összes ország)</button>
    <button data-table="df_hu_value">Értékek</button>
  </div>

<div class="table-container">
    <div id="df_hu_rank_no_CZ_SI" class="table-view active">
      {% include images/hu-cee-convergence/output/HU/df_hu_rank_no_CZ_SI.html %}
    </div>
    <div id="df_hu_rank_all" class="table-view">
      {% include images/hu-cee-convergence/output/HU/df_hu_rank_all.html %}
    </div>
    <div id="df_hu_value" class="table-view">
      {% include images/hu-cee-convergence/output/HU/df_hu_value_all.html %}
    </div>

</div>
<br>
<b>11. táblázat:</b> Magyarország összes indikátorának rangsorolása a KKE régión belül. Az egyik rangsorolásban (CZ és SI nélkül) Csehország és Szlovénia el lett távolítva, míg a másiknál mind a 11 ország adatait használtuk. Az "értékek" fül az indikátorok szintjének illetve változásának mértékét mutatja meg a rangsorolás helyett.
</div>

A legtöbb mutató esetében Magyarország meredek visszaesést mutat a régión belül: a KKE9 csoport élmezőnyéből 2024-re a rangsor legaljára, az utolsó 2-3 helyre csúszott minden indikátorban, néhány kivételtől eltekintve (foglalkoztatás, minimálbér és várható élettartam).

Az eredmények további egyszerűsítése érdekében a következő táblázatban kiszámítottunk egy összesített rangsort, ami az összes mutató helyezésének a mediánját illetve átlagértékét adja meg.

<div class="table-container">
    <div id="rank_mean_median" class="table-view">
      {% include images/hu-cee-convergence/output/HU/rank_mean_median.html %}
    </div>

<b>12. táblázat:</b> Magyarország medián és átlagos helyezése a régióban az összes mutató átlagolása alapján. 
Az összesített rangsor egyrészt a mutatók szintjeire vonatkozik 2004-ben, 2010-ben és 2024-ben, másrészt kumulatív változásukra. 
A 2024-es érték és a 2010–2024 közötti kumulatív változás pirossal kiemelve. 
</div>

Az összefoglaló rangsor egyrészt a mutatók 2004-es, 2010-es és 2024-es *szintjére*, másrészt kumulatív növekedésükre vonatkozik. A leginformatívabb összefoglaló mutató alighanem a KKE9 országcsoporton belüli medián helyezés, amely egyrészt kizárja Csehországot és Szlovéniát - melyek már 2004-ben, sőt 1990-ben is, lényegesen fejlettebbek voltak -, illetve azt mutatja meg mi volt a *tipikus* régiós helyezése az országnak. 

A fenti összefoglaló táblázat elég egyértelmű és meglehetősen negatív képet fest Magyarország elmúlt két évtizedéről és ezen belül a 2010 óta tartó időszakról. 
2004-ben Magyarország még a teljes, 11 országot tartalmazó KKE-csoport medián rangsorában a negyedik helyen állt, ha pedig kivesszük Csehországot és Szlovéniát, a szűkebb KKE9 csoportban a második helyen. 
Nyilván nem a helyezések pontos átlag- vagy medián értéke a legfontosabb, hiszen ez - valamennyire - függ attól, milyen változókat veszünk figyelembe. Bár azt hiszem a tíz kiválasztott változó a lehető legátfogóbb gazdasági-szociális mutatók közé tartozik, a lista nyilván bővíthető vagy szűkíthető lenne, ami kissé eltérő eredményekhez vezetne. 
Az összesített helyezések numerikus értékétől eltekintve is egyértelműnek tűnik, hogy a használt - meglehetősen konszenzusos és átfogó jellegű - felzárkózási mutatók alapján Magyarország konvergencia-teljesítménye az elmúlt tizetnöt-húsz évben a leggyengébbek közé tartozik a régióban. Hogy abszolút értelemben a legrosszabb, vagy a hátulról második vagy harmadik, az már a választott indikátoroktól függ, de a konklúzió, hogy a legrosszabbak között van, robusztusnak tűnik.

A tíz vizsgált indikátor alapján Magyarország már 2004 és 2010 között három helyet csúszott vissza a medián helyezési rangsorban (5/9 a KKE9 csoportban, illetve 7/11 a teljes KKE11-ben), majd 2010 és 2024 között további két hellyel csúszott még lejjebb, így a KKE9 csoportban a hetedik helyen végzett, a teljes KKE11-ben pedig a nyolcadik–kilencedik helyre esett vissza.

Így elmondhatjuk, hogy Magyarország felzárkózási teljesítménye a régió leggyengébbjei közé tartozik, *akár* a 2004-es, akár a 2010-es bázist használjuk. 
A 2004-es bázishoz viszonyítva Magyarország medián helyezése a kumulatív felzárkózás tekintetében *legutolsó* a KKE9 csoportban. 
A 2010-es bázisról kiindulva az ország helyezése a második vagy harmadik *leggyengébb* (medián helyezés: 7,5/9), Szlovákiával és Horvátországgal (amely azonban csak 2014-ben lett EU tag) együtt, amelyek felzárkózása szintén gyenge volt. 
A 2010-es bázist használva Magyarország csak azért kerüli el a legutolsó helyet, mert a foglalkoztatási ráta 2010 után jelentősen emelkedett, illetve mert Szlovákia hasonlóan gyenge teljesítményt mutatott a többi indikátorban.

Bár a foglalkoztatási ráta emelkedése 2010 után üdvözlendő fejlemény, ez nem volt egyedi jelenség a régióban: kb. ugyanekkora növekedés történt a legtöbb KKE-országban, egy szélesebb régiós trendbe illeszkedve, és Magyarország 2004 óta mért foglalkoztatás-növekedése egész pontosan megegyezik a KKE régió átlagával. 
Ez cáfolja azt az elképzelést, hogy a gyenge termelékenység- és jövedelem-növekedés csak vagy elsősorban a korábban alulfoglalkoztatott munkavállalók reintegrációjának következménye volt, és ezért a gyenge - vagy egyenesen zérus - termelékenységnövekedés elkerülhetetlen volt. 
A valóság ezzel szemben az, hogy számos KKE ország képes volt ugyanezen időszakban *egyszerre* növelni a egyrészt a foglalkoztatást, másrészt a termelékenységet és a lakossági jövedelmeket illetve fogyasztást is.

Összefoglalva elmondhatjuk, hogy Magyarország relatív visszaesése már 2004 körül elkezdődött, és 2010 után, az Orbán-kormányok alatt folytatódott. 
Ha megnézzük a fenti görbéket, vizuálisan is azonosítható az a két alperiódus, amikor Magyarország többé-kevésbé teljesen stagnált, miközben a régió nagy része – a 2010 utáni Szlovákia kivételével – tovább emelkedett: Magyarország először 2006-2012 között mutatott stagnálást a fő kibocsátási változókban, majd újra 2022-től napjainkig. 
Míg 2006–2010 között a foglalkoztatási ráta abszolút értelemben csökkent, a munkatermelékenység 2011-ig még emelkedett, míg a 2013-2020 időszakban ennek fordítottja történt. 
2021 óta viszont a foglalkoztatási ráta nem tudott tovább emelkedni – ami várható volt, mivel már magas szintet ért el –, de a munkaerő-termelékenység is lényegében tovább stagnált.

A 2022 óta megtorpanó foglalkoztatás *és* termelékenység az egy főre jutó GDP és GNI stagnálásához vezetett, vagyis a teljes kibocsátás nem nőtt, miközben – némileg meglepő módon – a bérek, jövedelmek és a fogyasztás lassan emelkedett, a minimálbér emelésével együtt. Egy stagnáló nemzetgazdaság kontextusában ez az államilag erőltetett kereset- és fogyasztásemelkedés azonban nem tűnik fenntarthatónak.

# Végszó

Ez a makrogazdasági trendeket áttekintő elemzés önmagában nem ad ok-okozati magyarázatot arra, hogy *miért* történt ami történt, azt viszont lehetővé teszi, hogy értékeljük az elmúlt 16 év teljesítményét, azaz az Orbán-kormányok megszakítás nélküli, lassan két évtizedes korszakát.

A vizsgált gazdasági mutatók közül az egyetlen egyértelmű siker ebben az időszakban a foglalkoztatási ráta növekedése volt. Ez az emelkedés egy szélesebb régiós trendet követett, amely eredményeképpen a foglalkoztatás a 2010-es évek végére lényegében elérte a nyugat-európai szintet, csakúgy mint a legtöbb régiós országban.

Ezt a foglalkoztatás-bővülést a munkaerő-termelékenység abszolút csökkenése kísérte 2011-2016 között, és ezt követően is csak gyenge termelékenység-növekedés volt tapasztalható, egészen máig. 
Az életszínvonal emelkedése - ettől valószínűleg nem függetlenül - szintén korlátozott volt: a medián bérek, a háztartási jövedelmek és az egy főre jutó fogyasztás a KKE-régió leggyengébb felzárkózását mutatták, egyedül Szlovákia volt az, amely 2010 után még Magyarországnál is gyengébben teljesített. 
Bár a minimálbér emelésében Magyarországon nagyjából a régiós átlag körül mozgott, ez nem vezetett az átlagos/medián bérek, jövedelmek és fogyasztás a régióban tipikus mértékű felzárkózásához, hanem alulmúlta azt.

Ez *nem* jelenti azt, hogy Magyarország az elmúlt két évtizedben *abszolút* értelemben stagnált volna. Azt viszont elmondhatjuk, hogy az ország felzárkózása a nyugat-európai kibocsátási és jövedelmi szinthez gyenge volt - az egész poszt-szocialista KKE régióban az egyik leggyengébb.

Míg 2004 óta Lengyelország, Románia vagy Lettország nagyjából megduplázta - reálértéken - az egy főre eső nemzeti _jövedelem_ (GNI) szintjét, és 2010 óta körülbelül 60%-kal növelte azt, Magyarországon 2004 óta csak 40%-kal, 2010 óta pedig 35%-kal nőtt ugyanez a mutató. 
Nem meglepő módon - hiszen lakossági jövedelmek a nemzeti jövedelem részei, fogyasztás pedig csak jövedemből történhet - hasonló lemaradás figyelhető meg a bérek, a jövedelmek és a fogyasztás trendjeiben is.

Bár a relatív visszaesés okai összetettek, mivel Magyarországot ugyanaz a kormányzat vezeti immár 16 éve, elkerülhetetlennek tűnik a következtetés, hogy a jelenlegi rezsim gazdasági teljesítménye régiós összehasonlításban nyilvánvalóan kudarcot vallott.

A 2022 óta gyakorlatilag stagnáló kibocsátás és a 2010-es évek átlag alatti termelékenység-, jövedelem- és fogyasztásnövekedése egy olyan kudarcos kombináció, ami a régióban csak Magyarországra és Szlovákiára jellemző, és egyre inkább elszakad a szélesebb régiós trendektől. 
A 2021 utáni stagnáció magyarázatául pedig nem tűnik elégségesnek az ukrajnai háború: csak Észtország (és talán Csehország) látszik hasonló mértékben stagnálni, miközben több földrajzilag és gazdaságilag hasonló helyzetben lévő ország - Lengyelország, Románia, Horvátország, Szlovénia - az elmúlt négy évben emelkedő pályán volt.

Fontos megjegyezni, hogy Magyarország konvergenciája már a 2006-2010 közötti időszakban sem volt sikeres, sőt, több mutatóban még a 2010-2024-es időszaknál is gyengébb volt, ami hozzájárult a mára kialakult leszakadáshoz. 
Ugyanakkor a 2010 utáni 16 év elegendő időt adhatott (volna) ahhoz, hogy az ország vezetése azonosítsa a makrogazdaság strukturális problémáit, és javaslatot tegyen a korrekcióra, még ha ennek végrehajtása esetleg esetleg ennél is több időt igényel (vagy igényelt volna).

A hosszú ideje regnáló magyar kormány ehelyett következetesen megtagadta, hogy beismerje gazdaságpolitikai stratégiájának bármilyen hiányosságát. Ehelyett egy olyan stratégia mellett kötelezte el magát egyre inkább, amelyet a szélsőséges centralizáció, a külföldi - elsősorban feldolgozóipari - beruházások közvetlen és aránytalan állami támogatása, az önkényesen változó "különadók", valamint az állami fejlesztéspolitika fizikai infrastruktúra-fejlesztésre (autópályák és stadionok...) való szinte kizárólagos leszűkítése jellemez. 
A hibák elismerésére való képtelenség, illetve bármiféle korrekció kategorikus elutasítása talán az elmúlt 16 év legaggasztóbb jellemzője: nem is annyira az a probléma, ha egy vezetés hibákat követ el, hiszen ez elkerülhetetlen - hanem az, ha teljesen hiányzik bármilyen mechanizmus a korrekcióra.

Vannak plauzibilis és közismert "jelöltek" Magyarország relatív lecsúszásának kauzális magyarázatára: a humántőke-befektetés elhanyagolása, a rendszerszintű kleptokrácia és ebből adódó versenyhiány, az ország nyugati kapcsolatainak megrendülése, és a mindezekből fakadó fokozódó jogi és gazdasági bizonytalanság és kiszámíthatatlanság. 
Bármi volt is a pontos oksági mechanizmus, egy dolog világosnak tűnik mostanra: az alkalmazott stratégia nem eredményezett sikeres, vagy akár csak a régióban átlagosnak mondható, felzárkózási teljesítményt. 
Ellenkezőleg, úgy tűnik, hogy a teljes KKE régióban a második vagy harmadik legrosszabb gazdasági teljesítményt eredményezte az utóbbi másfél évtizedben. 

A stratégia bármely elemének felülvizsgálatától való teljes elzárkózás, valamint az explicit elköteleződés további folytatására, sőt fokozására, azt teszi valószínűve, hogy Magyarország relatív lecsúszása mind saját történelmi régióján, mind az egész EU-n belül tovább fog folytatódni. Legalábbis addig, amíg nem történik politikai és ezen belül gazdaságpolitikai változás.

---

# Függelék

Az alábbi néhány ábrán azt foglaljuk össze, hogy a fenti eredmények mennyiben függnek attól, hogy melyik mérőszámot használjuk az egyes mutatók időbeli és térbeli összehasonlítására: 
- folyóáras PPP/PPS
- volumenindex (konstans áras mutatók, vásárlóerő-paritás nélkül)
- konstans PPP

Az első ábrán a konstans áron megadott volumenindexek illetve a folyóáras PPP-ben számolt adatok relatív változásának hasonlóságát ábrázoltuk. A konstans PPP mérőszámokat nem mutatjuk külön, mivel ezek _relatív_ változása azonos a volumenindexek relatív változásával.

<div style="text-align: center;">
<figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
<a href="{{site.baseurl}}/images/hu-cee-convergence/output/compare_units/summary/HU_plots/incl2021/scatter_arany_osszehasonlitas_log.png">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/compare_units/summary/HU_plots/incl2021/scatter_arany_osszehasonlitas_log.png" alt="_config.yml" style="width: 1100px;"/>
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;"> <strong>Függelék 1. ábra</strong>
A volumenindexek (konstans ár, vásárlóerő-paritás nélkül) és a folyóáras PPP/PPS-ben számolt relatív növekedési mutatók összefüggése hat vizsgált mutatóra. 
</figcaption>
</figure>
</div>

A Világbank illetve az OECD által publikált mutatók eleve elérhetők konstans árú idősorban, itt ezeket használtuk. 
Az Eurostat nominális mérőszámait minden esetben az adott ország HICP fogyasztói árindexével defláltuk, majd egy fixált év árfolyamán váltottuk euróra. 
Mivel csak a relatív változást ábrázoltuk, ezért az átváltási árfolyam nem változtat az eredményeken, az arányszámokból az átváltási árfolyam kiesik.
Az arányszámok azt mutatják meg, hogy az adott mutató hányszorosára nőtt a választott bázisévtől (ami 2004 [néhány kivétellel, ld. az ábrát], 2010 és 2021) 2024-ig.
Látható, hogy a korreláció igen erős (R^2 0.8 és 0.95 között) a volumenindexek és a folyóáras PPP/PPS mérőszámok között, bár van néhány ország ami messze esik az átlótól (ahol a két érték azonos). Különösen Romániánál a folyóáras PPP-ben megadott GDP számok növekedése [meghaladja](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/compare_units/gdp_per_cap/gdp_per_cap_pct_change_from_baselines_CEE9.png) a konstans áras (volumenindex) mérőszámét, ami feltehetőleg azért van mert itt a belföldi teljes infláció jelentősen meghaladta a PPP kosárban lévő (nagyrészt _tradeable_) áruk inflációját. 
Mivel a fenti elemzésben a konstans áras mutatókat használtuk, ez Románia konvergencia-teljesítményét inkább konzervatívan becsüli meg. 

A következő ábrán egyesével áttekintjük, hogy az egyes mutatókra hogyan alakult a folyóáras PPP-ben, illetve volumenindexben számolt relatív változás, egyrészt Magyarországon, másrészt a másik nyolc összehasonlítható KKE ország (KKE9: a kilenc EU-tag ex-szocialista ország, Csehország és Szlovénia nélkül) Magyarország nélküli átlagát nézve.

<div style="text-align: center;">
<figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
<a href="{{site.baseurl}}/images/hu-cee-convergence/output/compare_units/summary/HU_plots/incl2021/change/valtozas_foldchange_kke9_wtd-changes.png">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/compare_units/summary/HU_plots/incl2021/change/valtozas_foldchange_kke9_wtd-changes.png" alt="_config.yml" style="width: 1100px;"/>
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;"> <strong>Függelék 2. ábra</strong>
A volumenindexek (konstans ár, vásárlóerő-paritás nélkül) és a folyóáras PPP/PPS-ben számolt relatív növekedési mutatók hat vizsgált mutatóra. A karikák a magyar, a négyzetek a KKE9 mérőszámok relatív növekedését mutatják, három különböző bázisévtől nézve. Piros=volumenindex, kék=folyóáras PPP/PPS. KKE9 csoportnál az országonként számolt relatív változások súlyozott átlagát ábrázoljuk.
</figcaption>
</figure>
</div>

Ahogy a korrelációkat mutató ábra alapján várható volt, a relatív növekedési számok alapvetően hasonlóak, akár konstans áron, akár folyóáras PPP/PPS-ben számolunk. 
Két mutató van, ahol a konstans áras (volumenindex) mutatóban Magyarország nincs annyira elmaradva a 2010-2024 időszak konvergencia-teljesítményében, mint a folyóáras mutatóban: ezek a tényleges egyéni fogyasztás és a medián órabér. 
Ennél a két mutatónál Magyarország volumen-indexben számolt relatív növekedése kb. megfelelt a KKE9 átlagnak a 2010-2024 időszakban, és volumenindexben mért (saját) növekedése nagyobb mértékű, mint a PPS-ben számított.
Ennek pontos oka további elemzést igényelne, de a forint leértékelődése valószínűleg fontos szerepet játszik ebben: a lértékelődés miatt a PPS kosár forintban kifejezett ára még erősebben nőtt, mint a fogyasztói árindex, így a PPS-kosárral elosztott nominális értékek relatív növekedése kisebb volt, mint a fogyasztói árindex deflátorával számolt volumenindex-növekedés.
Mivel azonban itt életszínvonalbeli változókról van szó, a folyóáras PPS ebben az esetben alighanem mégis informatívabb, még ha a [máshol tárgyalt okokból](https://www.portfolio.hu/gazdasag/20230907/mire-jo-a-vasarloero-paritas-es-mire-nem-637557) a folyóáras PPS idősorokat nem teljesen helyes időbeli görbéknek kezelni - habár ez utóbbiban sincs teljes egyetértés, és vannak tanulmányok, [amelyek megteszik ezt](https://www.bruegel.org/analysis/twenty-years-european-east-west-household-income-convergence).

Az összes számítás kódja megtalálható [ebben a folderben](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/compare_units_scripts), illetve az összehasonlító ábrák az összes változóra, országra lebontva [ebben a folderben](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/compare_units_scripts). 
Itt látható az is, hogy a konstans PPP és a konstans áras volumenindex mérőszámok relatív változása [mindig](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/compare_units/gdp_per_hr_worked/gdp_per_hr_worked_pct_change_from_baselines_CEE9.png) [azonos](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/compare_units/gdp_per_hr_worked/gdp_per_hr_worked_pct_change_from_baselines_CEE9.png).
Az is látható, hogy a 2021 utáni időszakban az eloszlás összeszűkült, és itt már Magyarország az átlagtól való lemaradása több mutatóban kisebb. Tekintetbe kell azonban venni, hogy egyrészt itt csak három évnyi időszakról beszélünk, tehát eleve a különbségek törvényszerűen kisebbek. Másrészt, az adatokban nincsen benne a 2025-ös év, amikor is a magyar gazdaság újra stagnált - ha a hamarosan elérhetővé váló 2010-2025 periódusra újraszámolnánk az adatokat, akkor szinte biztosan újra megnőne Magyarország relatív lemaradása.

Végül megvizsgáltuk mennyire hat a rangsorolásra az, hogy melyik mérőszámot használjuk.

<div style="text-align: center;">
<figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
<a href="{{site.baseurl}}/images/hu-cee-convergence/output/compare_units/summary/HU_plots/incl2021/rank/helyezes_foldchange_kke9.png">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/compare_units/summary/HU_plots/incl2021/rank/helyezes_foldchange_kke9.png" alt="_config.yml" style="width: 1100px;"/>
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;"> <strong>Függelék 3. ábra</strong>
Országok rangsorolása volumenindexben (konstans ár, vásárlóerő-paritás nélkül) és folyóáras PPP/PPS-ben számolt relatív növekedési mutatók alapján, három különböző bázisévtől nézve. 
Piros=volumenindex, kék=folyóáras PPP/PPS. A KKE9 csoportnál az országonként számolt relatív változások súlyozott átlagát ábrázoljuk.
</figcaption>
</figure>
</div>

A különbségek jelentéktelennek mondhatók. Volumenindexben nézve Magyarország a tényleges fogyasztásra és a medián órabérre vonatkozó helyezése kevésbé rossz a 2010-2024 időszakra nézve, de ennél a két változónál kérdéses, hogy ez jobb mérőszám-e, mint a folyóáras PPS. 
A medián órabért tekintve 2022-be (utolsó adat ennél a mutatónál) Magyarország hátulról a [második helyen állt](https://ec.europa.eu/eurostat/databrowser/view/earn_ses_pub2s/default/table?lang=en) az EU-ban, míg a tényleges fogyasztásban 2024-ben [a legutolsón](https://ec.europa.eu/eurostat/databrowser/view/prc_ppp_ind_1__custom_20761075/default/table). 
Ha a folyóáras PPS-t idősorként kezelni nem is egészen helyes módszertanilag, a végső állapot összehasonlítása viszont az, és világos képet mutat.

---

# Források

A cikkben szereplő ábrákhoz használt adatok, illetve az ábrákat generáló kód megtalalálható a projekt [Github repójában](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence).
<!--- A módszerek részletesebb kifejtéséért lásd a szerző [Substack-jén](https://mbklt.substack.com/p/hungarys-convergence-since-eu-accession). --->
