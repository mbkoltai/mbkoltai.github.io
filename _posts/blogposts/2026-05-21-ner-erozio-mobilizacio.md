---
layout: post
title: "Lépésről lépésre: a NER-váltó választási blokk kialakulása"
tags: hungary politics elections demographics data-visualisation magyar
excerpt: Erózió, konszolidáció, mozgósítás
secondary: blogposts
mathjax: true
hidden: true
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


<style>
table td, table th {
  padding: 8px 16px;
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

A NER választási vereségének nagyságrendjét és területi mintázatait már több színvonalas elemzés is feltérképezte [1-7]. Közös következtetésük: az eltolódás a teljes magyar település-hierarchiát átfogta - a Tisza nemcsak a közép- és kisvárosokban, de a községek jelentős részében is "letarolta a vidéket" [1,4,7], miközben minden szinten megtizedelődött a Fidesz bázisa.

Ez a cikk az előbbi elemzésekhez három aspektusban szeretne hozzátenni: ez az eltolódás időben _mikor_ ment végbe a 2022-2026 ciklusban, _mekkora_ volt abszolút számokban kifejezve, illetve mik voltak a fő _mozgások_ az egyes választói blokkok között. 
Az elemzés alapja az utóbbi négy év három választási eredményeinek (OGY2022, EP2024, OGY2026), illetve a Medián közvéleménykutató teljes népességre vonatkozó, hosszú idősoros adatainak vizuális elemzése. 

Azt, hogy milyen választói mozgások eredményezték végül a Fidesz bukását jobban láthatjuk, ha a választások és a KVK (közvéleménykutató) adatok trendjeit elsősorban az _összes választó_ (vagy "teljes népesség" - ezt a két kifejezést felváltva fogom használni) arányában nézzük. 
A legtöbb elemzés a _leadott szavazatok_ arányában elemzi a változásokat, ami logikus, ha a mandátumokban kifejezett eredményeket nézzük, ugyanakkor így nézve a trendeket nem mindig látható tisztán, hogy mi okozta az elmozdulásokat: a Fidesz-bázis zsugorodása, a Tiszához való átállása, vagy a Tisza-bázis növekedése más forrásokból? Időben követve a pártpreferenciák arányát az _összes választó_ körében jobban beazonosítható, hogy mi is történt és milyen sorrendben.
A közvélemény-kutatások mellett fontos köztes adatpont az utóbbi négy évre nézve a 2024-es EP választás (EP2024). 
Általában véve az EP választások kevésbé használhatók a teljes választói csoportok méretének a megbecsülésére, mert annyira alacsony a részvétel. A 2024-es EP választás azonban kivétel volt, ugyanis a részvétel magas (60%) szintet ért el. Ezzel egyrészt validálta a teljes népességre vonatkozó KVK-okat (ld. később). Másrészt, mint idén áprilisban kiderült, az EP választáson "felvonult" Fidesz-bázis gyakorlatilag a teljes bázisnak felelt meg, a volt kormánypártnak további tartalékai már nem voltak. 
Így a 2024-es EP választási eredmények megmutatják, hogy addigra mennyiben történt meg a Fidesz-bázis eróziója, illetve az (egykori) ellenzéki bázis kibővülése, település-szintekre lebontva. 

Az elemzésben mindvégig [a hazai szavazatokról lesz szó](https://voxpopuli.444.hu/2026/04/22/meg-a-valasztasi-eredmenyrol-is-kodosit-a-propaganda-avagy-mit-kezdjunk-a-levelszavazatokkal). 
Egyrészt, mert a KVK adatok ezekre vonatkoznak, az erdélyi/vajdasági (és nyugati diaszpóra-beli) levélszavazatokra nem. 
Másrészt, mivel a mandátumokra az utóbbiaknak szinte semmi hatásuk nincsen (+1 Fidesz mandátum az OGY választásokon), így ez utóbbiak jórészt "holt" szavazatok. 
Végül, az erdélyi/vajdasági levélszavazatokat egy [súlyosan manipulált rendszerben](https://transtelex.ro/kozelet/2026/05/01/egyenlobb-erdelyert-mozgalom-jelentes-levelszavazas-kiss-tamas-toro-tibor-kiss-anna) születnek (illetve inkább: szedik őket össze), így a magyar választási rendszernek ez a része még formális-technikai értelemben sem nevezhető tisztának. 
Emellett, végig a listás szavazatokról fogok beszélni, mivel itt az országos trendek az érdekesek elsősorban - az egyéni eredmények egyébként szinte tökéletesen korreláltak a listásokkal (néhány kivételtől eltekintve), így a listás-egyéni megkülönböztetés eleve nem sok különséget jelent(ene).

Alapvető viszonyítási pontként érdemes összefoglalni a legutóbbi három választás eredményeit az összes választó arányában, illetve abszolút számokban kifejezve:

<div id="valasztas-wrap" style="font-family:sans-serif;max-width:900px;">

  <div style="display:flex;gap:6px;margin-bottom:12px;">
    <button onclick="valTab('m')" id="vbtn-m"
      style="padding:6px 14px;font-size:0.8rem;border:1px solid #aaa;border-radius:3px;background:#1a1a1a;color:#fff;cursor:pointer;">
      Millió fő
    </button>
    <button onclick="valTab('pct')" id="vbtn-pct"
      style="padding:6px 14px;font-size:0.8rem;border:1px solid #aaa;border-radius:3px;background:#f0f0f0;color:#333;cursor:pointer;">
      Összes választó %-a
    </button>
  </div>

  <!-- MILLIÓ FŐ -->
  <div id="vtbl-m" style="display:block;overflow-x:auto;">
    <table style="border-collapse:collapse;width:100%;font-size:0.85rem;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,0.08);">
      <thead>
        <tr style="background:#1a1a1a;color:#fff;">
          <th style="padding:0.6rem 0.9rem;text-align:left;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;"></th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #e06020;">Fidesz-KDNP</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #1a6e1a;">Mi Hazánk</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #2a3a7a;">Tisza</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #7a7a7a;">Óellenzék</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #4a9aba;">Vál. jogosult</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #4a9aba;">Szavazott</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #bbb;">Nem szavazott</th>
        </tr>
      </thead>
      <tbody>
        <tr style="border-bottom:1px solid #eee;">
          <td style="padding:0.6rem 0.9rem;font-weight:600;white-space:nowrap;">OGY 2022</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#fdf3ed;">2,81</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f0f7f0;">0,33</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef0f8;color:#aaa;">–</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f5f5f5;">2,12</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">7,76</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">5,45</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f9f9f9;">2,31</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
          <td style="padding:0.6rem 0.9rem;font-weight:600;white-space:nowrap;">EP 2024</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#fdf3ed;">1,99</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f0f7f0;">0,30</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef0f8;">1,34</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f5f5f5;">0,84</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">7,66</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">4,56</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f9f9f9;">3,09</td>
        </tr>
        <tr>
          <td style="padding:0.6rem 0.9rem;font-weight:600;white-space:nowrap;">OGY 2026</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#fdf3ed;">2,18</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f0f7f0;">0,35</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef0f8;">3,34</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f5f5f5;">0,12</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">7,62</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">6,07</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f9f9f9;">1,55</td>
        </tr>
      </tbody>
    </table>
  </div>

  <!-- ÖSSZES VÁLASZTÓ %-A -->
  <div id="vtbl-pct" style="display:none;overflow-x:auto;">
    <table style="border-collapse:collapse;width:100%;font-size:0.85rem;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,0.08);">
      <thead>
        <tr style="background:#1a1a1a;color:#fff;">
          <th style="padding:0.6rem 0.9rem;text-align:left;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;"></th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #e06020;">Fidesz-KDNP</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #1a6e1a;">Mi Hazánk</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #2a3a7a;">Tisza</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #7a7a7a;">Óellenzék</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #4a9aba;">Szavazott</th>
          <th style="padding:0.6rem 0.9rem;text-align:center;font-size:0.72rem;letter-spacing:0.05em;text-transform:uppercase;border-top:3px solid #bbb;">Nem szavazott</th>
        </tr>
      </thead>
      <tbody>
        <tr style="border-bottom:1px solid #eee;">
          <td style="padding:0.6rem 0.9rem;font-weight:600;white-space:nowrap;">OGY 2022</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#fdf3ed;">36,2%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f0f7f0;">4,2%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef0f8;color:#aaa;">–</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f5f5f5;">27,3%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">70,2%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f9f9f9;">29,8%</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
          <td style="padding:0.6rem 0.9rem;font-weight:600;white-space:nowrap;">EP 2024</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#fdf3ed;">26,0%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f0f7f0;">4,0%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef0f8;">17,5%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f5f5f5;">11,0%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">59,6%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f9f9f9;">40,4%</td>
        </tr>
        <tr>
          <td style="padding:0.6rem 0.9rem;font-weight:600;white-space:nowrap;">OGY 2026</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#fdf3ed;">28,6%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f0f7f0;">4,6%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef0f8;">43,8%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f5f5f5;">1,6%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#eef6fb;">79,7%</td>
          <td style="padding:0.6rem 0.9rem;text-align:center;background:#f9f9f9;">20,3%</td>
        </tr>
      </tbody>
    </table>
  </div>

  <p style="font-size:0.78rem;color:#555;margin-top:0.7rem;line-height:1.6;">
    <strong>A 2022, 2024, 2026 választások listás eredményei.</strong><br>
    Forrás: NVI
    <a href="https://vtr.valasztas.hu/ogy2022/orszagos-listak?tab=parties" style="color:#2a3a7a;">2022</a> ·
    <a href="https://vtr.valasztas.hu/ep2024" style="color:#2a3a7a;">2024</a> ·
    <a href="https://vtr.valasztas.hu/ogy2026/orszagos-listak" style="color:#2a3a7a;">2026</a><br>
    Óellenzék = DK, MSZP, LMP, PM, Momentum, Együtt, MKKP, Jobbik, 2RK, MMN.<br>
    Millió fő tízezerre, ill. az összes választó %-a egy tizedesjegyre kerekítve.
  </p>

</div>

<script>
function valTab(id) {
  ['m','pct'].forEach(function(t) {
    document.getElementById('vtbl-' + t).style.display = (t === id) ? 'block' : 'none';
    var btn = document.getElementById('vbtn-' + t);
    btn.style.background = (t === id) ? '#1a1a1a' : '#f0f0f0';
    btn.style.color      = (t === id) ? '#fff'    : '#333';
  });
}
</script>

<!--- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### --->
<!--- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### --->
<!--- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### --->

A NER-váltó választói blokk összeállása három lépésben valósult meg a 2022-es választásokat követően. Haladjunk időrendben.

**2022-2023: erózió**

A 2022-2026 ciklusra visszanézve leggyakrabban a pártválasztók közötti trendeket szokás bemutatni - amelyek 2020 után így néztek ki, a Medián méréseit használva (amelyeket mindhárom választás visszaigazolt):

<div class="table-toggle">
  <div class="controls">
    <button data-table="img-oe" class="active">Régi ellenzék egyben</button>
    <button data-table="img-orig">Pártonként (régi ellenzék külön)</button>
  </div>

  <div id="img-oe" class="table-view active">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/partvalasztok_pct_oell_2020_2026.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/partvalasztok_pct_oell_2020_2026.png" style="width: 1100px;"/>
      </a>
     <!---  
      <figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;">
        <strong>Trendek a pártválasztók között 2020-2026 — Óellenzék</strong>
      </figcaption>
      --->
    </figure>
  </div>

  <div id="img-orig" class="table-view">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/partvalasztok_pct_2020_2026.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/partvalasztok_pct_2020_2026.png" style="width: 1100px;"/>
      </a>
    <!--- 
      <figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;">
        <strong>Trendek a pártválasztók között 2020-2026</strong>
        A "választani tudók" és a "biztos pártválasztók" átlagát számolva.
    </figcaption>
      --->
    </figure>
  </div>

<figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;">
        <strong>Trendek a pártválasztók között 2020-2026 </strong>
        ("választani tudók" és a "biztos pártválasztók" kategóriák átlagával számolva)
</figcaption>
</div>

Ez alapján azt gondolhatnánk az események sorrendje a következő volt:
- a Fidesz támogatottsága kb. stabil volt 2024 közepéig
- a Tisza megjelenésével és az EP választásokat követően kezdett el süllyedni
- a Tisza térnyerése kb. megfelelt a régi ellenzék térvesztésének, elsősorban onnan táplálkozott, majd a választások előtti néhány hónapban bővült még tovább a korábban pártnélküliekből

Ez az értelmezés azonban részben téves lenne. 
Ennek oka, hogy ha csak a "pártválasztó" kategóriát nézzük, akkor összekeveredik pl. az hogy egy párt szavazóinak száma stabil, vagy hogy valójában zsugorodik, de egy általános de-mobilizáció mellett, így a pártválasztókon _belül_ stabilnak tűnik. 
Vagy megfordítva: egy párt támogatottsága süllyedhet azért mert valóban támogatókat veszt, de azért is, mert más pártoké nő, és így az összetétel-hatás miatt süllyed. 
Pontosan ez utóbbi két dolog történt az előző cikluban.

Erről tisztább képet kaphatunk, ha a _teljes népességben_ vett trendeket nézzük:

<div class="table-toggle">
  <div class="controls">
    <button data-table="img-oe" class="active">Összes választó %-a (régi ellenzék egyben)</button>
    <button data-table="img-orig">Összes választó %-a (régi ellenzék pártonként)</button>
    <button data-table="img-oe-absnum">Összes választó, millió ember (régi ellenzék egyben)</button>
    <button data-table="img-orig-absnum">Összes választó, millió ember (régi ellenzék pártonként)</button>
  </div>

<!--- összes vál %, óellenz egyben--->
  <div id="img-oe" class="table-view active">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/osszes_szav_szazalek_oell_2020_2026.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/osszes_szav_szazalek_oell_2020_2026.png" style="width: 1100px;"/>
      </a>
    </figure>
  </div>

<!--- összes vál %, óellenz külön--->
  <div id="img-orig" class="table-view">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/osszes_szav_szazalek_2020_2026.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/osszes_szav_szazalek_2020_2026.png" style="width: 1100px;"/>
      </a>
    </figure>
  </div>

<!--- összes vál ABSZ SZÁM, óellenz egyben--->
  <div id="img-oe-absnum" class="table-view">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/abszolut_szam_oell_2020_2026.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/abszolut_szam_oell_2020_2026.png" style="width: 1100px;"/>
      </a>
    </figure>
  </div>

<!--- összes vál %, óellenz külön--->
  <div id="img-orig-absnum" class="table-view">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
    <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/abszolut_szam_2020_2026.png">
    <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/abszolut_szam_2020_2026.png" style="width: 1100px;"/></a>
    </figure>
  </div>
<!--- CAPTION--->
<figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;">
2020-2026 közötti trendek a teljes (választásra jogosult) népességben a Medián mérései alapján (● és trendvonalak), illetve a választási eredmények (◆) szintén a teljes népesség arányában kifejezve
</figcaption>
</div>

A 2022-es választáson az összes választó kb. 36%-a szavazott a Fideszre (2,8 millió szavazó), míg a teljes népességben mért potenciális tábor kb. 40%, azaz 3 millió volt. Ez a bázis 2022 vége felé nagyot zuhant, majd 2023 végére kb. 30%-on, azaz 2,3-2,4 millió körül stabilizálódott. Tehát a 2022 nyara és 2023 ősze közötti időszakban a volt kormánypárt elvesztett 600-800 ezer támogatót, az összes támogatójának kb. egynegyedét. 
Ez még _azelőtt_ játszódott le, hogy a Tisza Párt egyáltalán megjelent volna. 
Ez a lassú, de összességében nagyon jelentős erózió ugyanakkor a pártválasztókra számított százalékokban kevésbé jelenik meg ebben az időszakban. Miért? Mert a pártnélküliek csoportja ugyanebben az időszakban szintén meredeken nőtt: a 2022-es választások környékén még csak 20% körül volt, 2023 végére kb. 35%-ra nőtt az arányuk. 
A teljes népességben mért párt-szimpatizáns csoportok majdnem mindig nagyobbak, mint a ténylegesen szavazók száma. 
Ökölszabályként alkalmazható, hogy 70-80% körüli részvétel mellett ennek a "potenciális szimpatizáns" körnek  kb. 80-90%-a megy el szavazni: a 2023 végére 2,4 millió körüli "tág" Fidesz bázis előrejelezte, hogy mennyi ennyi szavazója lehet a Fidesznek élesben, bár ezt akkor még nem lehetett biztosan tudni. 
A 2022-2023 során lemorzsolódó Fidesz-szavazók tehát ekkor elsősorban passzívvá váltak, nem pedig más pártokhoz mentek át. Eközben azonban az ellenzéki pártok támogatottsága is csökkent, innen a pártnélküliek csoportjának kb. 15%-os, azaz egymillió körüli felduzzadása 2022-2023-ban.

**2024: ellenzék-váltás és konszolidáció**

Ebben a helyzetben jelent meg 2024 tavaszán a Tisza Párt. 
Ekkor két tendencia megindulása figyelhető meg. Egyrészt a régi ellenzéki pártok összesített bázisa meredeken zuhanni kezdett. Az összes választó kb. egynegyedéről (kb. 2 millió szavazó) 2024 végére 5-10% közé, tehát kb. félmilliósra zsugorodott a régi ellenzéki pártok összesített bázisa. 
A Tisza Párt 2024-2025-ös támogatóinak jó része visszaemlékezésen alapuló felmérések szerint is [8,9] a 2022-es ellenzéki blokkból jött. Ugyanakkor már ebben az időszakban százezrek kezdtek el áramlani a pártnélküliek sorából a Tisza Párt felé, ahogyan azt a fenti ábrából is láthatjuk: a pártnélküliek száma a 2023 végi 2,5-2,7 millióról alig több, mint 1,5 millióra apadt 2024 végére. 
Tehát alapvetően két dolog történt 2024 során: egyrészt az újonnan megjelent Tisza Párthot áramlott át a szinte teljes '22-es ellenzéki blokk, illetve megindult egy mobilizáció amiből szintén kizárólag a Tisza profitált. 
A 21KK visszaemlékezéseken alapuló, 2025 közepén készült felmérése [8] szerint az akkori Tisza bázisban kb. 250 ezer korábbi Fidesz szavazó volt. Az alapján, hogy 2023-ban először a pártnélküliek tábora nőtt meg, ők minden valószínűség szerint azok voltak, akik először passzívvá váltak, majd 2024-25-ben a Tiszához mentek át.
Ezekről a trendekről egy nagyon érdekes "zuhanás közbeni" pillanatképet ad a 2024-es EP választás.

**EP2024: 2026 előképe a Fidesz, de nem az ellenzék számára**

A 2024-es EP választás (EP2024) összehasonlítása a 2023-24-es teljes népességre vonatkozó mérésekkel és a 2026-os választásokkal validálja ezeket a méréseket és lényegében bizonyítja azt, hogy a Fidesz-tábor eróziója ekkorra lényegében végbement és az ekkor látott erőviszonyok a _Fideszre nézve_ gyakorlatilag egészen 2026 áprilisáig konzerválódtak. 
Az EP2024-en az összes választó 26%-a szavazott a Fideszre (2 millió szavazó), míg 2026 áprilisában 28,6% (2,18 millió szavazó): szinte ugyanannyi, miközben a teljes részvétel húsz százalékponttal - 60-ról 80%-ra - nőtt. 
Tehát az EP2024 utáni trendek elsősorban a Tisza példátlan mértékű további erősödéséről szóltak, egy stagnáló, de _nem_ tovább zsugorodó Fidesz és egy gyakorlatilag nullára zsugorodó "óellenzék" mellett.

A településtípus szerinti lebontások tisztán megmutatják mindezt: 

<div class="table-toggle">
  <div class="controls">
    <button data-table="img-oe" class="active">Összes választó %-a</button>
    <button data-table="img-orig">Abszolút számok</button>
  </div>

  <div id="img-oe" class="table-view active">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/barplot/per_party/val_jog.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/barplot/per_party/val_jog.png" style="width: 1300px;"/>
      </a>

    </figure>
  </div>

  <div id="img-orig" class="table-view">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
<a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/barplot/per_party/abszolut_nemszav.png">
<img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/barplot/per_party/abszolut_nemszav.png" style="width: 1300px;"/>
      </a>

    </figure>
  </div>

<figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;">
        <strong>A 2024-es EP választások eredménye település-kategóriánként, az összes választó %-ában, illetve abszolút számban </strong>
</figcaption>
</div>

Látható, hogy az átrendeződés a Fidesznél és az ellenzéknél egymással pont ellentétes sorrendben történt.
A Fidesz teljes népességben számolt szavazataránya 2022-ről 2024-re _minden_ településszinten bezuhant. 
Ekkor, 2024-ben még lehetett azt gondolni, hogy ez csak az EP választások alacsonyabb részvétele miatt volt, és valójában még megvan a három milliót közelítő régi bázis, de valójában a Medián felméréseiből már lehetett látni, hogy ez nem így van: a teljes népességben mért bázis ekkorra már csak 2,4 milliós volt, amelynek kb. 85%-a részt vett az EP választásokon is.
Az egyes település-szinteken a visszaesés meglehetősen uniform volt, 6-12 százalékpont a teljes népesség arányában kifejezve (sorrendben az ábra településkategóriái szerint, falvaktól Budapestig: 6, 8, 10, 12, 12, 11, 11, 9 százalékpont visszaesés).
2026-ra ezek a 2024-re kialakult támogatottság-számok minimális mértékben mozdultak: hiába nőtt meg a teljes részvétel kb. 20 százalékponttal, a volt kormánypárt ebből a növekményből mindössze néhány százalékpontot tudott megszerezni, az összes település-szinten. 
Másképpen fogalmazva: bár 2026-ban másfél millióan többen szavaztak, mint az EP választáson, a volt kormánypárt szavazatszáma egyetlen település-kategóriában sem tudott néhány tízezezernél többel nőni, az utolsó kb. másfél évben megmozgatott gigantikus állami és félállami erőforrások ellenére. 
Igaz, a bázis nem is _csökkent_ egyetlen kategóriában sem, hanem gyakorlatilag ugyanakkora maradt, mindössze 180 ezerrel bővülve országos szinten.
Tehát a Fidesz-bázis zsugorodása 2024 nyarára már végbement, ezután már csak a szintentartás sikerült, habár ez a Medián és a 21KK kutatásai alapján nem egy teljesen statikus bázist jelentett, kb. 400 ezernyi szavazó "kicserélődött" a Fidesz-bázison belül (ld. lent).

Az ellenzék szempontjából a 2024-es EP választás egészen más fejlődési pontot jelentett. 
A 2022-es ellenzéki bázisnak (az MKKP-t is beleértve) ekkor még "csak" kb. 2/3-a vándorolt át a Tisza Párthoz, a régi ellenzéki pártok pedig még kb. 800 ezer szavazatot kaptak, tehát a bázis későbbi teljes abszorpciója a Tisza Pártba még csak nagyrészt ment végbe. 
A Tisza és az "óellenzék" ekkor még összeadva is hasonló eredményt ért el, mint a 2022-es ellenzéki összefogás (+MKKP): országosan 2,18 millió szavazatot szerezve a 2022-es 2,12 millióhoz képest. 
Nyilván ez nem jelenti azt, hogy a 2022-es és 2024-es csoport teljesen azonos lett volna, ugyanakkor a "konzerváció" mértéke felmérések [8] és modellezésre épülő elemzések [10] alapján nagyon nagy volt, közel 90%-os. 
A település-kategóriák szerinti eredményeket nézve is erősödhet ez a feltételezésünk, mivel a legtöbb település-kategóriában mindössze 1-2 százalékpontos különbség van a teljes ellenzék 2022-es és 2024-es szavazataránya között (teljes népesség). 
Ugyanakkor az ötezer főnél kisebb településeknél már ekkor volt egy 3-5%-os növekmény, ami összefügghetett a Tisza Párt sikeresen mobilizáló [11] első országjárásával. 
Összefoglalva: az EP választás egy pillanatképet adott egyrészt a Fidesz-bázis előző két évben megtörtént súlyos eróziójáról, és a már 2/3-ban végbement "ellenzékváltásról", amely során a régi ellenzék bázisa az új kihívó mögé sorakozott föl. 
Ugyanakkor ekkor még egy döntetlen közeli állapotról beszélhetünk ahol a kétmilliós Fidesz-táborral szemben egy alig nagyobb (2,2 milliós) és még nem egészen egységes ellenzéki blokk állt, ráadásul a Mi Hazánk kb. 300 ezres tábora is intakt maradt. Ez még [nem lett volna elég](https://mbklt.substack.com/p/erosion-of-the-fidesz-vote-share) a kormányváltáshoz sem, de a 2/3-hoz biztosan nem.
Hogyan lett ebből egy 3,34 milliós Tisza tábor, azaz kb. 1,2 millióval nagyobb választói blokk, mint a volt kormánypárté?

**2025-26: befagyott Fidesz-bázis, fokozódó mobilizáció**

2024 júniusa és a 2026. áprilisi választás között a Fidesz-bázis abszolút mérete a Medián-felmérései szerint gyakorlatilag nem változott: kb. 2,4 milliós maradt, amiből az EP-n 2 millióan az országgyűlési választáson pedig 2,2 millióan vettek részt.

A drámai változás a másik oldalon történt: az EP-választáson még kb. másfél milliós Tisza-bázis 2026 tavaszára kb. 3,6 milliósra nőtt a Medián szerint, amelynek több, mint 90%-a az urnákhoz is járult.
Honnan jött ez a kb. kétmilliós növekmény, kevesebb, mint kettő év alatt? 

A teljes népességben mért számokból nagyjából kiolvasható a válasz. 
Itt hozzá kell tegyük, hogy _elvileg_ az, hogy pl. a pártnélküliek száma valahány százezerrel csökken és egyidejűleg a Tisza párt támogatóinak száma ugyanennyivel nő még nem _bizonyítja_, hogy itt ugyanazokról az emberekről beszélünk, hiszen elvileg lehetséges, hogy az aggregált (nettó) számok változatlanok, miközben valamilyen mértékben kicserélődnek egyes csoportok. 
Ennek a realitása azonban nagyon kicsi, legalábbis rövidtávon. Mivel a Fidesz-tábor mérete mozdulatlan volt ebben az időszakban, a Tisza-bázis pedig gyakorlatilag azonos mértékben bővült a pártnélküliek és az "óellenzék" csoportok zsugorodásával, megkockáztathatjuk, hogy ezek a változások nagyrészt megfeleltethetők egymásnak. 
Az így produkált - erős, de nem 100%-os "konzervációt" feltételező - egyszerű aritmetikai becsléseket a Medián [12] és a 21KK [8,9] visszaemlékezésen alapuló felmérései, illetve [komplexebb modellezési megközelítések](https://exanumber.free.nf/szavazat/?i=2) is visszaigazolják, habár az is kiderül belőlük, hogy 3-4 év alatt azért volt egy kb. 10-15%-os kicserélődés a Fidesz-bázisnál.

A Tisza bázisának EP-választás utáni bővülése alapvetően két hullámban zajlott. 
Az EP idején mért - és a választási eredmény által visszaigazolt - kb. 1,5 milliós tábor (teljes népesség 19%-a) 2025 elejére 2,5 milliósra bővült (teljes népesség 33%), majd 2025 nyarára 2,9 milliósra (38%). 
Ezzel egyidőben a pártnélküliek száma kb. 500-600 ezerrel csökkent (29→22%) és a régi ellenzéki szavazóké is hasonló mértékben, miközben ekkor a Fidesznél is volt egy kb. hasonló mértékű erózió, tehát itt valamennyi kereszt-áramlás (Fidesz→Tisza) is lehetett, bár a 21KK ekkoriban publikált mérése szerint [8] kevésbé volt jelentős. Tehát a Tisza bővülése nagyrészt és hasonló mértékben jött a régi ellenzékből, illetve a pártnélküliek belépéséből. 

Ezután 2025 novemberig megtorpant a Tisza-bázis bővülése, és ezzel egyidőben pár százalékpontnyi (hibahatáron belüli) Fidesz-erősödést is mért a Medián, miközben tovább nőtt a politikai aktivitás, a pártnélküliek csoportja újabb 300-400 ezerrel süllyedt, ami valószínűleg korábban passzívvá vált Fidesz-szavazók visszatérését is jelezte. A régi ellenzék támogatottsága ebben az időszakban megint tovább süllyedt, újabb kb. háromszázezer szavazóval, és a teljes népességben 5% alá ment. 

Ezután, 2025 novembertől indult meg az utolsó nagy mobilizációs hullám. Ezekben az utolsó hónapokban a Tisza (potenciális) bázisa újabb kb. 700 ezerrel bővült és a Medián becslése szerint elérte a kb. 3,65 milliót, s ennek kb. 90%-a el is ment szavazni. 
A leadott szavazatok arányában a Medián végül 0,25%-os (!) pontossággal [jelezte](https://hvg.hu/360/20260412_a-tisza-tortenelmi-gyozelmet-vetiti-elore-a-median-merese-a-kampany-utolso-napjaibol) [előre](https://vtr.valasztas.hu/ogy2026/orszagos-listak?tab=partlistak&filter=orszagos-eredmenyek) a Tisza listás eredményét. 
Az utolsó mérésnél a pártnélküliek már nem is voltak elkülönítve a többi párttól, de hozzávetőleges becslés alapján számuk kb. 300-400 ezerrel csökkent 2025 novemberhez képest, míg a többi ellenzéki párt 200-300 ezer további szavazatot veszthetett, tehát a növekmény nagyobb része az új belépőkből jöhetett - eközben a Fidesz tábora még ekkor is nagyjából _stabil_ maradt.

Ezt a teljes népesség számok alapján számított hozzávetőleges rekonstrukciót összehasonlíthatjuk a Medián a választások előtt publikált felmérésével, ahol a 2022-es - emélkezetből felidézett - szavazat szerint is lebontották a pártpreferenciákat:

<div style="text-align: center;">
<figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
<a href="https://median.hu/wp-content/uploads/2026/04/ossz2-1024x710.png">
<img src="https://median.hu/wp-content/uploads/2026/04/ossz2-1024x710.png" alt="Medián – mozgó szavazók" style="width: 700px;"/>
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;">
<strong>Honnan jöttek a 2026-os választói blokkok?</strong><br>
Forrás: <a href="https://median.hu/2026/04/08/mozgo-szavazok-honnan-jottek-hova-mentek/">Medián, 2026. április 8.</a>
</figcaption>
</figure>
</div>

Ahhoz, hogy ezeket a százalékokat abszolút számokká kovertáljuk tekintetbe kell vennünk egyrészt a halálozásokat, másrészt a belépő új szavazókat.
A [2022-os](https://hvg.hu/360/20211229_Median_Az_emberek_ketharmada_Orban_maradasara_szamit) és a [2026-os választások](https://median.hu/2026/04/08/mozgo-szavazok-honnan-jottek-hova-mentek/) előtti hónapokban is jelentős mértékű Fidesz vezetés volt a 65+ csoportban, kb. a következő arányban: 50% Fidesz, 30% óellenzék/Tisza, 20% más/pártnélküli. 
Az újonnan belépő csoportokban ezzel szemben már 2022 elején kb. fordított, 50-20-30 ellenzék-Fidesz-más/pártnélküli arányok voltak, ami 2026-ra 75-10-15 Tisza-Fidesz-más aránnyá vált. 
Ezeknek a számoknak a középértékét használva kiszámolhatjuk a 2022-es választó blokkok demográfiai változását, tekintve hogy az azóta történt kb. 510 ezer [halálozás](https://www.ksh.hu/stadat_files/nep/hu/nep0065.html) szinte kizárólag a 65+ csoportban volt, miközben kb. [400 ezer új választó lépett be](https://www.ksh.hu/interaktiv/korfak/orszag.html) a 18-29 csoportba. 
A 2022-es választói blokkok (csak demográfiai szempontból) a halálozások miatt kb. így változtak 2026-ra:  
Fidesz: 2,81m <span style="color:red"> - 0.5\*0,51m</span> → 2,55m  
Ellenzéki összefogás: 1,94m <span style="color:red"> - 0.3\*0,51m</span> → 1.8m  
Más párt: 0.62m <span style="color:red"> - 0.1\*0,51m</span> → 0.57m  
Nem szavazott: 2,37m <span style="color:red"> - 0.1\*0.51</span> <span style="color:green">+0.4m</span> → 2,72m

A fenti demográfiailag korrigált blokkok összege 7,64m, ami csak 20 ezerrel tér el a 2026-ban ténylegesen a névjegyzéken lévőktől (7,62m), ami kisebb, mint 0,5%-nyi hiba, így elfogadhatónak mondható. 
Alkalmazva ezekre a blokkokra a Medián 2026/04 választás előtti "honnan hová" számait, kiszámíthatjuk, hogy a 2026-os blokkoknak mi volt az összetétele "eredet" szerint:  

<table style="border-collapse:collapse;width:100%;font-family:sans-serif;font-size:0.85rem;background:#fff;">
  <thead>
<tr style="background:#1a1a1a;color:#fff;">
      <th style="padding:0.6rem 0.8rem;text-align:left;font-size:0.75rem;letter-spacing:0.04em;text-transform:uppercase;">Honnan (2022)</th>
      <th style="padding:0.6rem 0.8rem;text-align:center;font-size:0.75rem;letter-spacing:0.04em;text-transform:uppercase;border-top:3px solid #2a3a7a;">Tisza (2026)</th>
      <th style="padding:0.6rem 0.8rem;text-align:center;font-size:0.75rem;letter-spacing:0.04em;text-transform:uppercase;border-top:3px solid #e06020;">Fidesz (2026)</th>
      <th style="padding:0.6rem 0.8rem;text-align:center;font-size:0.75rem;letter-spacing:0.04em;text-transform:uppercase;border-top:3px solid #999;">Meghalt (2022–26)</th>
      <th style="padding:0.6rem 0.8rem;text-align:center;font-size:0.75rem;letter-spacing:0.04em;text-transform:uppercase;border-top:3px solid #4a9aba;">Más / pártnélküli</th>
    </tr>
  </thead>
  <tbody>
    <tr style="border-bottom:1px solid #eee;">
  <td style="padding:0.6rem 0.8rem;"><strong>Fidesz-KDNP</strong><br><span style="font-size:0.72rem;color:#888;">2,81m → 2,55m élő</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#eef0f8;">0,31m<br><span style="font-size:0.72rem;color:#666;">9% (Tisza)</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#fdf3ed;">1,89m<br><span style="font-size:0.72rem;color:#666;">79% (Fidesz)</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#f5f5f5;">0,26m<br><span style="font-size:0.72rem;color:#666;">51%</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#eef6fb;">0,36m<br><span style="font-size:0.72rem;color:#666;">22% (más)</span></td>
</tr>
<tr style="border-bottom:1px solid #eee;">
  <td style="padding:0.6rem 0.8rem;"><strong>Ellenzéki összefogás</strong><br><span style="font-size:0.72rem;color:#888;">1,94m → 1,80m élő</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#eef0f8;">1,58m<br><span style="font-size:0.72rem;color:#666;">43% (Tisza)</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#fdf3ed;">0,02m<br><span style="font-size:0.72rem;color:#666;">1% (Fidesz)</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#f5f5f5;">0,15m<br><span style="font-size:0.72rem;color:#666;">29%</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#eef6fb;">0,20m<br><span style="font-size:0.72rem;color:#666;">13% (más)</span></td>
</tr>
<tr style="border-bottom:1px solid #eee;">
  <td style="padding:0.6rem 0.8rem;"><strong>Más párt</strong><br><span style="font-size:0.72rem;color:#888;">0,62m → 0,57m élő</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#eef0f8;">0,27m<br><span style="font-size:0.72rem;color:#666;">7% (Tisza)</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#fdf3ed;">0,04m<br><span style="font-size:0.72rem;color:#666;">2% (Fidesz)</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#f5f5f5;">0,05m<br><span style="font-size:0.72rem;color:#666;">10%</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#eef6fb;">0,26m<br><span style="font-size:0.72rem;color:#666;">16% (más)</span></td>
</tr>
<tr style="border-bottom:1px solid #eee;">
  <td style="padding:0.6rem 0.8rem;"><strong>Nem szavazott (+érvénytelen)</strong><br><span style="font-size:0.72rem;color:#888;">2,37m → 2,72m*</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#eef0f8;">1,50m<br><span style="font-size:0.72rem;color:#666;">41% (Tisza)</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#fdf3ed;">0,44m<br><span style="font-size:0.72rem;color:#666;">18% (Fidesz)</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#f5f5f5;">0,05m<br><span style="font-size:0.72rem;color:#666;">10%</span></td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#eef6fb;">0,79m<br><span style="font-size:0.72rem;color:#666;">49% (más)</span></td>
</tr>
<tr style="background:#f4f3ef;font-weight:600;border-top:2px solid #ccc;">
  <td style="padding:0.6rem 0.8rem;">Összesen (2026)</td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#d8ddf0;">3,66m</td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#faeae0;">2,39m</td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#efefef;">0,51m</td>
  <td style="padding:0.6rem 0.8rem;text-align:center;background:#e4f2f8;">1,61m</td>
</tr>
  </tbody>
</table>
<p style="font-size:0.9rem;margin-top:0.6rem;">* A „nem szavazott" sor tartalmaz ~0,4m új (2022 után nagykorúvá vált) szavazót is. A százalékok oszloponként értendők (az adott 2026-os párt táborából mekkora részt ad az adott sor).</p>

A fenti táblázat alapján összefoglalhatjuk a fő mozgásokat 2022 és 2026 között.  
A Fidesz 2,8-3 milliós 2022-es bázisából összesen kb. 900 ezren morzsolódtak le, ebből:
- kb. negyedmillióan meghaltak
- kb. háromszázezren a Tiszához mentek át
- kb. háromszáz-négyszáz ezren pártnélkülivé váltak (vagy - jóval kisebb részben - a MH-hoz vándoroltak)

Emellett kb. négyszázezer 2022-ben nem szavazó választó is csatlakozott a Fidesz-bázishoz. 
A 2022-es bázisnak összességében kb. 2/3-a maradt meg, a 2026-ban _még élő_ 2022-es bázisnak pedig háromnegyede, miközben a 2026-os bázis kb. egynegyede 2022-höz képest új volt. 

A Medián becslései és a demográfiai korrekció alapján alapján a Tisza 3,5 millió körüli választás előtti bázisából:
- kb. 45%-a (1,6 millió ember) a 2022-es ellenzéki összefogásból jött
- kb. 40%-a (1,5 millió ember) 2022-ben nem szavazott, ebből kb. 250-300 ezer lehetett új szavazó (400 ezer új belépő 60-70%-a)
- kb. 300 ezer volt Fidesz-szavazó
- kb. 250 ezer más pártok (döntően valószínűleg MKKP) 2022-es szavazói

Azaz a Tisza-bázis majdnem fele 2022-ben (és '24-ben) nem szavazó választó volt. 
A [21 Kutatóközpont](https://telex.hu/belfold/2026/04/18/21-kutatokozpont-valasztas-elotti-utolso-napok-varakozasok-gazdasag) választások előtti hasonló "honnan-hová" mérése nagyon hasonló számokat közölt. 
Egy jelentősebb eltérés, hogy a 2022-ben nem szavazott → Tisza/Fidesz mozgás ott jóval kisebb volt, emiatt 10-15%-kal kisebbre becsülve mindkét bázis abszolút méretét, minimálisan kisebbre, mint ami a választáson ténylegesen elért szavazatszám. 
Ebben az értelemben a Medián mérése reálisabbnak tűnik a teljes "potenciális" tábor méretére nézve, de összességében a Medián és a 21KK szavazatvándorlási becslése közötti különbség nem nagy, és valószínűleg jórészt módszertani (lekérdezési) különbségekből adódik. 
A fenti szavazatvándorlási becslések szintén konzisztensek komplexebb [modellezési megközelítések becsléseivel](https://exanumber.free.nf/szavazat/).

A választási eredmények település-kategória szerinti bontásában fent láthattuk, hogy ez milyen jelentős növekményt jelentett minden település-szinten a kormányváltó blokk számára: a 2024-es _kombinált_ (Tisza + óellenzék) ellenzéki bázis minden település-szinten minimum 10, de van ahol 15 százalékpontot emelkedett az _összes_ választó arányában. 

Emiatt a nagyon széles bázisú mobilizáció miatt az eredmények földrajzilag nézve (is) teljesen átbillentek 2022-höz képest, és már csak az 1000 főnél kisebb településeken volt Fidesz-előny, és még ott is csak néhány százaléknyi:

<div id="telep-tabs" style="font-family:sans-serif;max-width:1350px;">

  <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:12px;">
    <button onclick="showTab('t1')" id="btn-t1"
      style="padding:6px 13px;font-size:0.8rem;border:1px solid #aaa;border-radius:3px;background:#2a3a7a;color:#fff;cursor:pointer;">
      2026 – érvényes szav. %-a
    </button>
    <button onclick="showTab('t2')" id="btn-t2"
      style="padding:6px 13px;font-size:0.8rem;border:1px solid #aaa;border-radius:3px;background:#f0f0f0;color:#333;cursor:pointer;">
      2026 – összes választó %-a
    </button>
    <button onclick="showTab('t3')" id="btn-t3"
      style="padding:6px 13px;font-size:0.8rem;border:1px solid #aaa;border-radius:3px;background:#f0f0f0;color:#333;cursor:pointer;">
      Változások – érvényes szav. %-a
    </button>
    <button onclick="showTab('t4')" id="btn-t4"
      style="padding:6px 13px;font-size:0.8rem;border:1px solid #aaa;border-radius:3px;background:#f0f0f0;color:#333;cursor:pointer;">
      Változások – összes választó %-a
    </button>
    <button onclick="showTab('t5')" id="btn-t5"
      style="padding:6px 13px;font-size:0.8rem;border:1px solid #aaa;border-radius:3px;background:#f0f0f0;color:#333;cursor:pointer;">
      Kumulatív eloszlás 2026
    </button>
  </div>

  <div id="t1" style="display:block;">
    <figure style="margin:0;padding:8px;border:1px solid #bbb;border-radius:2px;background:#f8f8f8;display:inline-block;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/lineplot/per_year/2026_arany.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/lineplot/per_year/2026_arany.png" style="width:1300px;max-width:100%;"/>
      </a>
      <figcaption style="font-size:0.82rem;color:#444;margin-top:6px;max-width:1100px;">
        <strong>OGY 2026 – Szavazati arányok településméret szerint.</strong> Leadott érvényes szavazatok %-a. Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár.
      </figcaption>
    </figure>
  </div>

  <div id="t2" style="display:none;">
    <figure style="margin:0;padding:8px;border:1px solid #bbb;border-radius:2px;background:#f8f8f8;display:inline-block;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/lineplot/per_year/2026_val_jog.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/lineplot/per_year/2026_val_jog.png" style="width:1300px;max-width:100%;"/>
      </a>
      <figcaption style="font-size:0.82rem;color:#444;margin-top:6px;max-width:1100px;">
        <strong>OGY 2026 – Szavazati arányok településméret szerint.</strong> Szavazásra jogosultak %-a. Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár.
      </figcaption>
    </figure>
  </div>

  <div id="t3" style="display:none;">
    <figure style="margin:0;padding:8px;border:1px solid #bbb;border-radius:2px;background:#f8f8f8;display:inline-block;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/lineplot/per_party/arany.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/lineplot/per_party/arany.png" style="width:1300px;max-width:100%;"/>
      </a>
      <figcaption style="font-size:0.82rem;color:#444;margin-top:6px;max-width:1100px;">
        <strong>OGY 2022 / EP 2024 / OGY 2026 – Változások pártok szerint, településméret szerint.</strong> Leadott érvényes szavazatok %-a. Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár.
      </figcaption>
    </figure>
  </div>

  <div id="t4" style="display:none;">
    <figure style="margin:0;padding:8px;border:1px solid #bbb;border-radius:2px;background:#f8f8f8;display:inline-block;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/lineplot/per_party/val_jog.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/telep_kateg_aggreg/lineplot/per_party/val_jog.png" style="width:1300px;max-width:100%;"/>
      </a>
      <figcaption style="font-size:0.82rem;color:#444;margin-top:6px;max-width:1100px;">
        <strong>OGY 2022 / EP 2024 / OGY 2026 – Változások pártok szerint, településméret szerint.</strong> Szavazásra jogosultak %-a. Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár.
      </figcaption>
    </figure>
  </div>

  <div id="t5" style="display:none;">
    <figure style="margin:0;padding:8px;border:1px solid #bbb;border-radius:2px;background:#f8f8f8;display:inline-block;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/kumul_eloszlas/ogy2026_CDF_partonkent_telepmeret_szam.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/val_eredm/kumul_eloszlas/ogy2026_CDF_partonkent_telepmeret_szam.png" style="width:1300px;max-width:100%;"/>
      </a>
      <figcaption style="font-size:0.82rem;color:#444;margin-top:6px;max-width:1100px;">
        <strong>Pártok szavazatainak kumulatív eloszlása településméret szerint, OGY 2026.</strong> Forrás: NVI (100% feldolgozottság) + KSH Helységnévtár.
      </figcaption>
    </figure>
  </div>

</div>

<script>
function showTab(id) {
  ['t1','t2','t3','t4','t5'].forEach(function(t) {
    document.getElementById(t).style.display = (t === id) ? 'block' : 'none';
    var btn = document.getElementById('btn-' + t);
    btn.style.background = (t === id) ? '#2a3a7a' : '#f0f0f0';
    btn.style.color      = (t === id) ? '#fff'    : '#333';
  });
}
</script>

Ez egyben azt is jelentette, hogy a Medián felmérése szerint a Tisza bázisa demográfiailag relatíve kiegyensúlyozottá vált 2026 áprilisára:
- nem szerint: fele-fele férfi és nő
- település-szerkezet: 1/4 község, 1/3 kis-közepes (nem megyei jogú) város, 1/4 megyei jogú város, 1/5 Budapest
- életkor: 1/4 30 alatti, 1/6 65 fölötti, a köztes három csoport (30-40, 40-50, 50-65) mindegyike kb. 1/5 
- iskolázottság: 1/8 nyolc általános vagy kevesebb végzettség, 1/6 szakmunkás, 2/5 érettségizett, 1/3 diplomás

A legnagyobb aránytalanság a Tisza-bázisban a nyolc általánost végzettek, szakmunkások és a nyugdíjaskorúak (kb. 0,5-0,7x, tehát ennyiszer kisebb a teljes népességben való arányuknál) körüli alulreprezentáltsága, illetve a másik oldalon a diplomások, 40 alattiak és budapestiek 1,5-1,7x felülreprezentáltsága, ugyanakkor ezek sem olyan mérvűek mint a korábbi ellenzéki választói blokkoknál. 
Részletesebb [ábrák erről itt](https://mbkoltai.com/flourish_partok.html).  
A Fidesz választások előtti bázisának kb. 35%-a lakott községekben, 40%-a 65 évnél idősebb (további 30% 50-65 közötti), és 60%-nak nincsen érettségije, ami egy jóval aránytalanabb képet mutat.

<!--- 
https://hvg.hu/360/20260412_a-tisza-tortenelmi-gyozelmet-vetiti-elore-a-median-merese-a-kampany-utolso-napjaibol
0.12*2.81*0.92 + 0.88*1.94*0.95 + 2,31*0.55*0.95 + 0.47*0.45
2.81*0.9*0.09 + 1,94*0.95*0.91 + 2,31*0.97*0.62 + 0.45*0.4
--->

**A választások után: a Fidesz-bázis összeomlása**

A választások után több közvéleménykutatás is egyöntetűen azt jelezte 
([Medián](https://hvg.hu/360/20260506_median-felmeres-aprilis-vege-partpreferenciak-orban-viktor-felelossegrevonas-birosag-bizakodas), [21KK](https://24.hu/belfold/2026/05/15/21-kutatokozpont-2026-majus-tisza-fidesz/), [Publicus](https://nepszava.hu/3322698_tisza-part-fidesz-osszeomlas-felmeres-publicus-intezet-parlamenti-valasztas-2026)), 
hogy a Fidesz bázisa jelentős, kb. 600 ezres mértékben csökkent, 2,1-2,3 millióról kb. 1,5-1,6 millióra zsugorodva:

<iframe src="https://flo.uri.sh/visualisation/27917966/embed?auto=1"
  width="100%" height="800"
  frameborder="0" scrolling="no"
  style="border:none;">
</iframe>

Ezzel egyidejűleg hasonló mértékben tovább bővült a Tisza bázisa, már 4,5 milliót is meghaladva.  

Mivel demográfiai lebontások egyelőre nem jelentek meg, ezért nagy kérdés, hogy a Fidesz bázis "leszakadt" 1/3-a mely demográfiai csoportokból jött elsősorban: inkább a bázis többségét adó kistelepülési-idősebb-alacsony iskolázottságú csoportból, vagy a párt április elején még meglévő, de régóta fogyatkozó nagyvárosibb és érettségizett támogatói váltak le.
Ha ez utobbiról van szó, ez méginkább idősebbé és kistelepülésekre beszorulttá tenné a bázis összetételét, ami azt vetítené előre, hogy a még megmaradt kb. másfél milliós tábor csak demográfiai okokból - ha a várható politikai trajektóriát nem is nézzük - kb. évi 60-70 ezerrel zsugorodhat, ami most már a megmaradt támogatói tömeg évi 5%-át jelentené.

A politikai előrejelzés és a különböző politikai narratívák várható ellenállóképessége nem tárgya ennek az elemzésenek és túl is menne keretein. 
Azt megállapíthatjuk, hogy a Fidesz-bázis eróziója már 2022 óta tart, és 2024 után minden erőfeszítés ellenére sem sikerült megállítani a folyamatot: bár néhány százezer 2022-ben nem szavazó választót sikerült bevonni, ez nem tudta kompenzálni a veszteségeket a Tisza-párt illetve a politikai passzivitás irányában, miközben az elöregedés miatti demográfiai veszteség egyre erősebben hat. 
Ha ehhez hozzáadjuk, hogy a választások után a párt azonnal elvesztette támogatóinak közel egyharmadát, nehéz elképzelni, hogy egy ilyen hosszútávú leszállóágban lévő politikai erő - amelynek vezetői és támogatói is nagyrészt 60 év felettiek, és a megkérdőjelezhetetlen "vezér" visszatérését az összes választó kb. 2/3-a nemkívánatosnak és irreálisnak tartja - radikális profil-váltás nélkül meg tudná fordítani ezt a folyamatot. Ugyanakkor azt is nehéz elképzelni, hogy az utóbbira, ti. az alapvető változtatásra ez a politikai erő képes lenne, bár vezetésváltás esetén nem lehet kizárni. Ezen a ponton talán érdemes felidézni a Fidesz-bázis alakulását egészen 2010-től nézve:

<div class="table-toggle">
  <div class="controls">
    <button data-table="img-oe" class="active">Összes választó %-a (régi ellenzék egyben)</button>
    <button data-table="img-oe-absnum">Összes választó, millió ember (régi ellenzék egyben)</button>
    </div>

<!--- összes vál %, óellenz egyben--->
  <div id="img-oe" class="table-view active">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/osszes_szav_szazalek_oell_2009_2026.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/osszes_szav_szazalek_oell_2009_2026.png" style="width: 1100px;"/>
      </a>
    </figure>
  </div>


<!--- összes vál ABSZ SZÁM, óellenz egyben--->
  <div id="img-oe-absnum" class="table-view">
    <figure style="display: inline-block; border: 1px solid #888; padding: 8px; border-radius: 1px; text-align: center; background-color: #ddd;">
      <a href="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/abszolut_szam_oell_2009_2026.png">
        <img src="{{site.baseurl}}/images/2010-2026-Median-osszes/plots/kvk/abszolut_szam_oell_2009_2026.png" style="width: 1100px;"/>
      </a>
    </figure>
  </div>

<!--- CAPTION--->
<figcaption style="font-size: 20px; margin-top: 6px; width: 1100px;">
2009-2026 közötti trendek a teljes (választásra jogosult) népességben a Medián mérései alapján (● és trendvonalak), illetve a választási eredmények (◆) szintén a teljes népesség arányában kifejezve
</figcaption>
</div>

Alapvetően a következő periódusokat különböztethetjük meg, a fent elemzett időszak, tehát 2022 előtt:
- 2009-2011: a NER létrejötte, egy 3,5 millió potenciális bázis (ami azonban csak 80%-ban vett részt a választásokon), 1,5 milliósra zsugorodott liberális/baloldali ellenzék, erősödő, de még egymillió alatti Jobbik
- 2011-2012 közepe: kezdeti válság. A Fidesz-bázis összezuhan kb. kettő millióra, 2012-ben az "óellenzék" összesített támogatottságával összeér
- 2013-2022: "emelkedő NER" - nagyjából folyamatosan emelkedő Fidesz támogatottság, széteső "óellenzék", egymilliós Jobbik. 2015-től 2022-ig emelkedő politikai aktivitás. 2018-ra kialakul a bő hárommilliós Fidesz-bázis, ami egészen 2022 második feléig kitart

Azaz: bár volt egy-két rövid időszak, amikor a Fidesz bázis úgy tűnt, hogy megroppan (2011-2012, 2014-2015), az ellenzék sosem tudott _egy blokkban_ tartósan kettő millió támogató felé menni 2024-ig, így az egykori kormánypárt hegemóniája stabil volt. Ez esett szét 2022-től: lassú erózióval, majd a választásokat követően hirtelen zuhanással. És most, 2026. májusában, a Fidesz-bázis mérete kb. akkora, mint az egykori "balliberális" ellenzéké, de öregebb és más demográfiai dimenziókban méginkább egyoldalú.

A másik oldalon a Tisza-bázis felfutása nagyon gyors folyamat volt, és a választások előtti kb. 3,5 milliós bázisból kb. másfél millió szavazó a 2022-ben nem szavazók közül jött, illetve új szavazó volt. 
Könnyen elképzelhető, sőt valószínű, hogy a kormányzás nehézségeivel szembesülve a jelenleg már 4,5 milliósra mért bázis apadni fog, vissza a választás előtti 3-3,5 milliós sávba, vagy akár a 2025 eleji 2,5 millió körüli szintre. 
Ugyanakkor nehéz elképzelni, hogy a 2026-os "rendszerváltó" szavazóblokk valaha Orbánhoz fordulna, mint ahogy 2011-ben - az akkori kormánypárt kezdeti válságából - sem az egykori balliberális ellenzék profitált, amely soha nem tudott feltámadni, bár vegetálása még közel egy évtizedig tartott. 

Így ha megindulna a Tisza-bázis apadása, az könnyen lehet, hogy inkább a 2024 utáni nagyon magas politikai aktivitás süllyedését jelentené: ebben az esetben pedig akár egy 2,2-2,5 milliós bázis is elég lehet arra, hogy a Tisza Párt akár több cikluson keresztül is kormányozzon. Ezt tovább valószínűsíti, hogy a Tisza bázisa földrajzilag meglehetősen kiegyensúlyozott és széles bázisú, az átlagnál iskolázottabb és fiatalabb, és minden valószínűség szerint nagyon motivált, hogy ne történjen visszafordulás egy NER-típusú autokratikus rendszer és az európai szövetségi rendszerből való kisodródás felé. 
A jövő kiszámíthatatlan, és megjósolhatatlan, hogy hogyan fog kinézni a magyar politikai erőtér akár csak néhány év múlva - az azonban valószínű, hogy nem az utóbbi másfél évtized megismétlődése lesz.


**Hivatkozások**

[1] [Átlátszó: Fellázadó magyar vidék: hazai pályán verte meg a Tisza a Fideszt, a legfideszesebb kerületekben álltak át legtöbben](https://atlatszo.hu/adat/2026/04/15/fellazado-magyar-videk-hazai-palyan-verte-meg-a-tisza-a-fideszt-a-legfideszesebb-keruletekben-alltak-at-legtobben/)  
[2] [Telex: Bedöntötte a Tisza a Fidesz bástyáit, tarolt az egyéni választókerületekben](https://telex.hu/belfold/2026/04/13/bedontotte-a-tisza-a-fidesz-bastyait)  
[3] [Telex: Legaktívabbak, legkisebbek, legnagyobb győztesek és legszorosabb versenyek: a 2026-os választás legjei](https://telex.hu/belfold/2026/04/13/valasztas-2026-reszveteli-legek-legszorosabb-eredmenyek-legnagyobb-nyertesek)  
[4] [24.hu: Eltűnt a Fidesz a városokból, 13 ezer fős a legnagyobb település, amelyet Orbánék meg tudtak tartani](https://24.hu/belfold/2026/04/29/varos-eredmeny-2026-valasztas-tisza-fidesz/)  
[5] [444: Főleg apró falvakban bukott óriásit a Fidesz, de a felcsúti választókerület központjában is elvesztette szavazói 42 százalékát](https://444.hu/2026/04/14/fidesz-mi-hazank-telepulesi-valtoztas-valasztas-2026-partlista)  
[6] [Válasz Online: Öt ok, ami miatt a Fidesz elveszítette a magyar vidéket](https://www.valaszonline.hu/2026/04/20/valasztas-tisza-fidesz-magyarpeter-videk-orbanviktor-korhaz-demografia/)  
[7] [Választási Földrajz: A Tisza letarolta a vidéket, ezért lett meg a kétharmada](https://www.facebook.com/electoral.geography/posts/pfbid06H87858sEwBXaxtYd4aQJvy8SjRbmpqXrNck2NGKzu115c6iBGBbXkxHaSNPsBaHl)  
[8] [Honnan erősödik a Tisza, hova tűnnek a Fidesz szavazói?](https://21kutatokozpont.hu/szavazatvandorlas.html)  
[9] [Párhuzamos valóságok: kormánypártiak és ellenzékiek eltérő napirend érzékelése](https://21kutatokozpont.hu/parhuzamos_valosagok.html)  
[10] [Elite defection and opposition realignment in Hungary](https://www.tandfonline.com/doi/full/10.1080/21599165.2025.2468693)  
[11] [Ábrákon és térképeken mutatjuk, mennyire volt hatékony Magyar Péter országjárása](https://telex.hu/valasztasi-foldrajz/2024/07/11/magyar-peter-orszagjaras-ep-2024-valasztasi-eredmeny-terkep-foldrajz)  
[12] [Mozgó szavazók: Honnan jöttek, hova mentek?](https://median.hu/2026/04/08/mozgo-szavazok-honnan-jottek-hova-mentek/)