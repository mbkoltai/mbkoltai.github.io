---
layout: post
title: Hungary's convergence since 2010 within the CEE region
tags: hungary politics elections demographics data-visualisation magyar
excerpt: A story of failure, from EU accession to 16 years of Orbán
secondary: blogposts
mathjax: true
---


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- SETTINGS  -->
<!-- GLOBAL CSS/JAVA settings for tables -->

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


<!-- GLOBAL CSS/JAVA settings -->

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- Global CSS for images -->


<style>
.switchable {
  margin: 0.6rem 0 1rem 0;
  max-width: 90%;
  margin-left: auto;
  margin-right: auto;
  padding: 0.5rem;
  border: 2px solid #000;
  background: #e6e6e6;
}

.switchable.plot-frame {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.1rem;

  padding: 0.5rem;
  border: 2px solid #000;
  background: #e6e6e6;

  max-width: 90%;      /* respect page width */
  width: 100%;         /* take up available space inside max-width */
  box-sizing: border-box; /* include padding + border in width */
}

.switchable .controls {
  display: flex;
  gap: 0.15rem;
  flex-wrap: wrap;   /* ← absolutely required */
  margin: 0.25rem 0 0.4rem 0;
}

.switchable .controls .break {
  flex: 0 0 100%;
  width: 100%;
  height: 0;
  padding: 0;
  margin: 0;
}

.switchable .controls-label {
  padding: 0.5rem 0.5rem;
  margin-right: .5rem;      /* space to the next button */
  border: 1px solid #c00;     /* thin red frame */
  border-radius: 4px;
  font-size: 0.9rem;
  font-weight: 600;
  color: #c00;
  background: #fff;
  white-space: nowrap;       /* prevent wrapping */
  align-self: center;        /* vertical alignment */
}

.switchable button {
  padding: .4rem .9rem;
  border-radius: 6px;
  border: 1px solid #ccc;
  background: #fff;
  cursor: pointer;
  font-size: 0.95rem;
}

.switchable button.active {
  background: #0366d6;
  color: #fff;
  border-color: #0256b3;
}

.switchable .view {
  display: none;
}

.switchable .view.active {
  display: block;
}

#switchable .img-note {
  font-size: 1rem;   /* adjust size */
  margin-top: 0.1rem;  /* space above */
  text-align: center;  /* if you want it centered */
}

</style>
<!-- Global CSS for images -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- Global Java for images -->

<script>
document.addEventListener('DOMContentLoaded', function () {

  document.querySelectorAll('.switchable').forEach(wrapper => {

    wrapper.querySelectorAll('.controls button').forEach(button => {
      button.addEventListener('click', () => {

        // toggle buttons
        wrapper.querySelectorAll('.controls button')
          .forEach(b => b.classList.remove('active'));
        button.classList.add('active');

        // toggle views (tables OR images)
        const target = button.dataset.target;
        wrapper.querySelectorAll('.view')
          .forEach(v => v.classList.remove('active'));
        wrapper.querySelector('#' + target).classList.add('active');

      });
    });

  });

});
</script>

<!-- Global Java for images -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->

<div style="
  border-left: 4px solid #c0392b;
  background-color: #fff5f5;
  padding: 12px 16px;
  margin-bottom: 24px;
  font-size: 0.95em;
  color: #333;">
  <strong>Note:</strong>
This is an independent, long-form data analysis and visualisation project.
For best viewing, please use a monitor or tablet to see the charts clearly.
Sections are modular and may be adapted or republished with attribution. 
Feedback, discussion, or collaboration welcome.
</div>

<div style="background-color: #4a4a4a;
  color: #f2f2f2;
  padding: 1.2em 1.4em;
  margin: 1.5em 0;
  border-radius: 6px;
  font-size: 0.95em;
  line-height: 1.5;">
<strong>Summary</strong><br>
Hungary's economic convergence since 2004 and 2010 has been disappointing in a regional context. Although the country was one of the CEE region's forerunners at the time of its EU accession in 2004, its relative position has steadily declined, a trend that has largely continued under the current government's 16-year rule. Using ten high-level socio-economic indicators - covering output, productivity, wages, income, consumption and life expectancy - I compare Hungary's performance with the other ten Central and Eastern European countries. The analysis shows that Hungary's convergence has been among the weakest, whether measured from the 2004 or 2010 baseline.
</div>


## Table of contents
1. [Introduction](#introduction)
2. [Methods](#methods)  
    2.1 [CEE and Western Europe](#cee-and-western-europe)  
    2.2 [Indicators and metrics](#selected-indicators-and-metrics)  
3. [Results](#results)  
    3.1 [GDP and GNI per capita](#gdp-and-gni-per-capita)  
    3.2 [Labour productivity](#labour-productivity)  
    3.3 [Wages, earnings and income](#wages-earnings-and-income)  
    3.4 [Actual individual consumption](#actual-individual-consumption)  
    3.5 [Employment ratio](#employment-ratio)  
    3.6 [Life expectancy](#life-expectancy)
4. [Discussion](#discussion)
5. [Conclusion](#conclusion)

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->

# Introduction

Hungary joined the European Union in 2004, together with several other former socialist countries from Central and Eastern Europe (CEE). Since the early 1990s, this group has achieved substantial economic convergence toward Western Europe. As shown in a [previous analysis](https://mbkoltai.com/cee-convergence/), on average CEE countries moved from roughly 30-40% of the Western European core's level to about 60-75% across key indicators of output and income - such as GDP (or GNI) per capita, labour productivity, median wages, and household income. Outside of some East Asia economies, no other region has shown this pace of catch-up over the same period.

There are however large differences within the CEE region itself. In the 1990s and early 2000s, Hungary was often seen as one of the standout performers of post-socialist transition. Since then, its relative position has increasingly been weakened, with its convergence momentum increasingly falling behind relative to peers.

This longread examines Hungary's economic performance since EU accession, and especially since 2010, in comparison with the rest of the CEE region. Hungary has had the same political leadership since 2010, marking 16 years of uninterrupted rule under Viktor Orbán. This period is long enough to be treated as a distinct economic era and allows us to assess whether Hungary's idiosyncratic policy path has produced faster or slower convergence than its regional peers.

# Methods

## CEE and Western Europe

Hungary's economic performance since EU accession cannot be viewed in isolation. To place it in context, we compare it to the convergence performance of similar economies in the region. Specifically, we compare Hungary's performance since 2004 to the other 10 countries that joined the EU from 2004 onward, ranked by population (EU accession year, million population in the most recent available year):

- Poland (2004, 36.5m)
- Romania (2007, 19.0m)
- Czech Republic (2004, 10.9m)
- Hungary (2004, 9.5m)
- Bulgaria (2007, 6.4m)
- Slovakia (2004, 5.4m)
- Croatia (2013, 3.9m)
- Lithuania (2004, 2.9m)
- Slovenia (2004, 2.1m)
- Latvia (2004, 1.9m)
- Estonia (2004, 1.4m)

To assess convergence, we also need a benchmark. The widely held aspiration in the region, and the goal of EU cohesion policy, is for the CEE countries to reach Western European income levels. The composite benchmark we use is therefore the population-weighted average of the eight wealthiest Western European countries, excluding Ireland and Luxembourg:

- Germany (83.4m)
- France (68.4m)
- Denmark (6.0m)
- Netherlands (17.9m)
- Austria (9.2m)
- Sweden (10.6m)
- Belgium (11.8m)
- Finland (5.6m)

Ireland and Luxembourg are excluded because their small size and tax-haven status distort macroeconomic indicators, making them unsuitable as benchmarks.

## Indicators and metrics

We look at a broad set of indicators to assess convergence in output per capita, productivity, median wages and household income, as well as consumption. 
While GDP per capita - the metric most often used to gauge convergence - shows convergence of output, it can be misleading if workers' wages and household incomes do not rise at a similar rate. 
This may occur, for example, when there is a large gap between GDP and GNI due to profit outflows from foreign investment - a real issue in [some](https://data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD?locations=HU-SK) [CEE countries](https://data.worldbank.org/indicator/NY.GNP.PCAP.PP.KD?locations=HU-SK&start=1994) - leaving less of the value produced within a country available for domestic incomes. 
Similarly, if the labour share is low or declining, wages may stay low or grow more slowly even if output is rising. Therefore, besides GDP per capita, we will look at GNI per capita and output per hour worked, but also annual average wages, median hourly earnings and median household incomes.

We also examine minimum wages, which are an important indicator for low-wage workers. The employment-to-population ratio is another key metric, as it highlights potential underemployment, a notable issue in the CEE region following the transition years, and shows how tight labour markets are. Finally, trends in life expectancy show whether economic growth is translating into longer life spans, arguably the most important vital statistic.

There is no single, definitive set of indicators for assessing economic convergence. 
The indicators used below are widely employed in the literature and together provide a coherent and reasonably comprehensive picture, capturing the main trends in output, income, consumption, labour market conditions, and longevity.

For each variable, I examine growth trends in three ways.

The **first metric** looks at a variable's change over time **in absolute terms**. For output and income variables, this means monetary values (USD or euros). 
To enable international comparisons, I always use purchasing power parities/standards (PPP/PPS) to adjust for price differences between countries. To remove the effect of inflation, wherever it's available, I rely on *constant* USD measures, anchored to a given year.

For median earnings and household income, as well as consumption, I use Eurostat's PPS (purchasing power standards) metric, which adjusts for price differences across countries, with 1 PPS purchasing the same basket of goods throughout the EU. 
However, unlike the other output and income measures, PPS units are *not constant* over time, that is, they are *not* inflation adjusted. Instead, they are anchored to the EU-wide price level rather than to prices in individual countries.

As a result, for these three metrics (earnings, household income, actual individual consumption), trends in absolute terms still include inflation, but *not* inflation in the individual country. 
Rather, they reflect *EU-wide* inflation, which was typically lower than inflation in the CEE countries. As an illustration, median household incomes in Romania increased by approximately 4.6-fold between 2005 and 2024. This increase is not in real terms, but it is also not purely nominal, as it is anchored to EU-wide rather than Romanian inflation. 
EU-wide cumulative inflation over this period was roughly 60–70%, implying that the increase of household income in real terms would be, very roughly, about 2.8-fold (4.65/1.65).

For the employment-to-population ratio, the unit is the percentage of the population aged 15+ that is in employment, while for life expectancy the unit is years.

The **second metric** is **relative change from the baseline**, obtained by normalising absolute values to the first year of the analysis window. I examine trends starting either from 2004 (the year of EU accession for most of CEE), or from 2010, when the current Hungarian government entered office. Relative change from a given starting year will typically be larger for countries with a lower initial level, as they tend to experience higher growth rates that gradually slow over time.

The **third metric** expresses indicators **as a percentage of the EU8 group's average**. In my view this is the most meaningful measure of convergence, as it shows not only trends within the convergence countries themselves, but also whether they are catching up with the Western European core. 
In this case, variables are still expressed in the same units as above (purchasing power parities for monetary variables), but are then divided by the EU8 average and reported as a percentage of that benchmark.

For each indicator, I present time trends in the plots using these three metrics, which the reader can switch between, shown either from 2004 (or the earliest available post-2004 year) or from 2010. 
After each plot, I summarise the *cumulative* changes in tables, ranking countries by their convergence to the EU8 group, that is, by their cumulative increase as a percentage of the EU8 average.

For the employment ratio, countries are ranked by the increase in the percentage of the 15+ population in employment, since this is already a relative measure with a ceiling and is therefore more informative than re-normalising by EU8 values. 
Similarly, for life expectancy, countries are ranked by the more meaningful absolute increase, as values expressed as a percentage of the EU8 average are very similar, given that all CEE countries already exceed 90% of the EU8 benchmark.

All code and data used in the post and its plots can be downloaded from the project's [Github repo](https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence).

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->

# Results

## GDP and GNI per capita

### GDP per capita

For the entire CEE region, GDP per capita has almost doubled (+93%) since 2004, and has grown 55% since 2010. Poland, Romania, and Lithuania have been the top three performers across all metrics.

As with several other indicators, Czechia (CZ) and Slovenia (SI) were well above the regional average in 2004 - by almost 50% ($33–34k, compared to $23k for the regional average). Given this higher starting point, their subsequent growth rates have understandably been slower.

As a result, cumulative gains in both relative and absolute terms have been smaller for CZ and SI. Even so, by 2024 they still remained - narrowly - at the top of the region, at around 80% of the EU8 level, while the CEE average continued to catch up. By 2024, Lithuania and Poland had effectively reached the same level as Czechia and Slovenia in GDP per capita.


<!-- GDP per capita plots -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2004</div>
    <button class="active" data-target="GDPpercap-abs-val-2004">2021 USD (PPP)</button>
    <button data-target="GDPpercap-rel-to-start-2004">Relative-to-2004</button>
    <button data-target="GDPpercap-eu8-2004">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="GDPpercap-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view active" id="GDPpercap-abs-val-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/GDP_per_cap/2004/value.png" alt="2021 USD (PPP)" style="max-width:100%;">
</div>

<div class="view" id="GDPpercap-rel-to-start-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/GDP_per_cap/2004/rel_val.png" alt="Relative-to-2004" style="max-width:100%;">
</div>

<div class="view" id="GDPpercap-eu8-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/GDP_per_cap/2004/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="GDPpercap-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/GDP_per_cap/2010/rel_val.png"
alt="Relative-to-2010" style="max-width:100%;">
</div>

<p class="img-note">
<b>Figure 1</b> GDP per capita since 2004, measured in constant 2021 international dollars (PPP).
The chart shows levels (const. USD PPP), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2024. 
<br>
<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/GDP_per_cap/full_table.csv" 
target="_blank" rel="noopener">[download data]</a>
<a href="https://ourworldindata.org/grapher/gdp-per-capita-worldbank" target="_blank" rel="noopener">[source]</a>
</p>

</div>

Ranking countries by cumulative convergence places **Hungary** in the lower half of the regional ranking, whether calculated from 2004 or 2010. 
Czechia and Slovenia registered even smaller gains, but this reflects their higher starting (and finishing) levels. Apart from these two countries, only Estonia - and, using the 2010 baseline, Slovakia - experienced smaller convergence to the EU8 average. Consequently, while Hungary ranked 4th in 2004 and 6th in 2010, it slipped to 8th position by 2024.

However, this ranking understates just how weak Hungary's convergence has been by regional standards, since GDP per capita is an area where its relative performance was actually stronger than in most other metrics, moving from 52 to 67% of the EU8 average from 2004 to 2024. It should be noted too that in the 2004-2010 period Hungary showed slight *de*convergence, falling 1% behind the EU8 benchmark, so all its increase occurred in the 2013 to 2022 period.

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- GDP per capita table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="GDP-2004">2004–2024</button>
    <button class="active" data-table="GDP-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="GDP-2004" class="table-view">
      {% include images/hu-cee-convergence/output/GDP_per_cap/table_2004_2024.html %}
    </div>
    <div id="GDP-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/GDP_per_cap/table_2010_2024.html %}
    </div>
</div>

<br>
<b>Table 1:</b> Cumulative change in GDP per capita from 2004 or 2010 to 2024, shown as a percentage of the EU8 weighted average, relative to the initial year, and in absolute terms (constant 2021 international dollars (PPP)). Countries are ranked by the EU8-relative measure.

</div>


### GNI per capita

We saw [in a previous analysis](https://mbkoltai.com/cee-convergence/) that GNI per capita is a better metric of domestsic income growth than GDP per capita, as several countries in CEE (such as Slovakia, Hungary, Bulgaria or Latvia) GDP growth has outstripped gross national *income* growth due to a large negative primary income balance.

GNI per capita trends tell a similar story regarding which countries have shown stronger or weaker convergence. Poland, Romania, and the Baltic countries moved 23-29% closer to the EU8 average. At the bottom of the table, we again find Czechia, Slovenia, Slovakia and **Hungary**. However, CZ and SI were again already at a higher level relative to the EU8 in 2003 than Hungary was even in 2024, so their smaller convergence is arguably less concerning.

<!-- GNI per capita plots -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2004</div>
    <button class="active" data-target="GNIpercap-abs-val-2004">2021 USD (PPP)</button>
    <button data-target="GNIpercap-rel-to-start-2004">Relative-to-2004</button>
    <button data-target="GNIpercap-eu8-2004">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="GNIpercap-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view active" id="GNIpercap-abs-val-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/GNI_per_cap/2004/value.png" alt="2021 USD (PPP)" style="max-width:100%;">
</div>

<div class="view" id="GNIpercap-rel-to-start-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/GNI_per_cap/2004/rel_val.png" alt="Relative-to-2004" style="max-width:100%;">
</div>

<div class="view" id="GNIpercap-eu8-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/GNI_per_cap/2004/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="GNIpercap-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/GNI_per_cap/2010/rel_val.png" 
alt="Relative-to-2010" style="max-width:100%;">
</div>

<p class="img-note">
<b>Figure 2</b> GNI per capita since 2004, measured in constant 2021 international dollars (PPP).
The chart shows levels (const. USD PPP), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2023. <br>

<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/GNI_per_cap/full_table.csv" 
target="_blank" rel="noopener">[download data]</a>
<a href="https://ourworldindata.org/grapher/gross-national-income-per-capita-undp" target="_blank" rel="noopener">[source]</a>
</p>

</div>


**Hungary**'s +10% convergence in GNI per capita to the EU8 benchmark over two decades - compared with +23% for the CEE region as a whole - represents a remarkably poor performance. The only comparably weak convergence story is Slovakia's, which has shown almost no progress since 2010. Considering relative change since 2010 alone, Slovakia ranks worst, while Hungary is the second worst, excluding Czechia and Slovenia, which started (and finished) from levels 30-40% higher than HU. 

As can be seen from Figure 2, **Hungary** saw two prolonged periods of stagnation, from 2005 to 2012 and from 2022 to today. While the Baltics have also suffered in the last three years, they had stronger growth in the previous periods, so their cumulative performance has been better. It is only Slovakia where the growth model seems to be similarly stuck as in HU.

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- GNI per capita table  -->

<div class="table-toggle">
  <div class="controls">
    <button data-table="gni-2004">2004–2023</button>
    <button class="active" data-table="gni-2010">2010–2023</button>
  </div>

<div class="table-container">
    <div id="gni-2004" class="table-view">
      {% include images/hu-cee-convergence/output/GNI_per_cap/table_2004_2023.html %}
    </div>
    <div id="gni-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/GNI_per_cap/table_2010_2023.html %}
    </div>
</div>

<br>
<b>Table 2:</b> Cumulative change in GNI per capita from 2004 to 2024 or from 2010 to 2023, shown as a percentage of the EU8 weighted average, relative to the initial year, and in absolute terms (constant 2021 international dollars (PPP)). Countries are ranked by the EU8-relative measure.

</div>



<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->

## Labour productivity

Ultimately, growth in output and income [has to](https://mbkoltai.com/cee-convergence/#labour-productivity-trends-since-1990) [come from](https://mbkoltai.com/decomposing-gdp-growth/) productivity growth. If a national economy suffers from chronic underemployment, increasing the employment ratio can temporarily boost output, but this effect is naturally limited by demographics. 
Similarly, in high-income countries, annual working hours tend to be stable - or even decline slowly - and extending hours is neither politically feasible nor socially desirable.

The convergence of the CEE region's labour productivity to the EU8 average illustrates this dynamic. 
Productivity convergence has been somewhat weaker than convergence of GDP or GNI per capita, going from 40 to 57% of the EU8 benchmark in the 2004-2024 period. 
Some of CEE's *per capita* convergence in output was due to a substantial increase in the employment ratio from the mid-2000s onward, reflecting recovery from the post-transition recession and the resulting structural underemployment. 
However, this source of growth has largely run its course, leaving labour productivity as the main plausible driver of further growth.

We again see a similar picture for the relative performance of countries as for the previous indicators. Romania, Poland and the Baltics have seen the strongest convergence in output per hour worked, with Romania tripling and the Baltics roughly doubling their level. 

What is potentially worrisome for the convergence prospects of the whole region is that the two most advanced regional countries (CZ and SI) have only managed to move 6-10% closer to the EU8 average in 20 years, a yearly rate of less than 0.5%. 

<!-- Output per hour worked plots -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2004</div>
    <button class="active" data-target="outputperhr-abs-val-2004">2021 USD (PPP)</button>
    <button data-target="outputperhr-rel-to-start-2004">Relative-to-2004</button>
    <button data-target="outputperhr-eu8-2004">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="outputperhr-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view active" id="outputperhr-abs-val-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/productivity/per_hr_work/2004/value.png" alt="2021 USD (PPP)" style="max-width:100%;">
</div>

<div class="view" id="outputperhr-rel-to-start-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/productivity/per_hr_work/2004/rel_val.png" alt="Relative-to-2004" style="max-width:100%;">
</div>

<div class="view" id="outputperhr-eu8-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/productivity/per_hr_work/2004/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### plot for 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="outputperhr-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/productivity/per_hr_work/2010/rel_val.png" alt="Relative-to-2010" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### LEGEND ### ### ### ### ### ### ### ### ### ### -->
<p class="img-note">
<b>Figure 3</b> Labour productivity (output per hour worked) since 2004, measured in constant 2021 international dollars (PPP).
The chart shows levels (const. USD PPP), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2024. 

<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/productivity/per_hr_work/data_table.csv" target="_blank" rel="noopener">[download data]</a>
<a href="https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable" target="_blank" rel="noopener">[source]</a>
</p>

</div>

Measured from the 2004 baseline, Hungary ranks last in labour productivity convergence, both in absolute terms (constant USD PPP) and when expressed as a percentage of the EU-8 average. When measured from 2010 it ranks second from the bottom. 
Remarkably, by 2024, Hungary's labour productivity was at a lower percentage of the EU8 average than in 2010. Only Hungary and Slovakia experienced a relative decline in labour productivity compared to Western Europe over this period. Croatia also experienced very weak convergence.
Looking at the dynamics, there may be some signs of improvement though for HU: labour productivity began to increase from 2016 onward, although still at a slower pace than in most of the region.


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- OUTPUT per hr worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="GDPperhr-2004">2004–2023</button>
    <button class="active" data-table="GDPperhr-2010">2010–2023</button>
  </div>

<div class="table-container">
    <div id="GDPperhr-2004" class="table-view">
      {% include images/hu-cee-convergence/output/productivity/per_hr_work/table_2004_2023.html %}
    </div>
    <div id="GDPperhr-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/productivity/per_hr_work/table_2010_2023.html %}
    </div>
</div>
<br>
<b>Table 3:</b> Cumulative change in labour productivity (per hour worked) from 2004 or 2010 to 2024, shown as a percentage of the EU8 weighted average, relative to the initial year, and in absolute terms (constant 2021 international dollars (PPP)). Countries are ranked by the EU8-relative measure.

</div>

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->

## Wages, earnings and income

Growth in output and productivity is one thing - but what about the incomes of workers and households? Has Hungary fallen behind its regional peers here as well? We now turn to wage and income indicators to answer these questions.

### Annual average wages

We use the OECD database on annual average wages, expressed in purchasing power parities and constant 2021 US dollars. Since 2004, average annual wages in the CEE region have increased by 55% on average, with most of this growth occurring after 2010. 
Measured relative to the EU8 average, this meant that the CEE region moved from 46% to 63% of the Western European benchmark.

Romania, Croatia and Bulgaria are not included in this dataset, as they are not yet OECD members. Among the remaining eight countries, the strongest convergence is again observed in the Baltic states and Poland, and in this case also in Slovenia, which almost reached the EU8 average (92%) by 2024.

<!-- Annual average wage plots -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2004</div>
    <button class="active" data-target="annualwages-abs-val-2004">2021 USD (PPP)</button>
    <button data-target="annualwages-rel-to-start-2004">Relative-to-2004</button>
    <button data-target="annualwages-eu8-2004">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="annualwages-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view active" id="annualwages-abs-val-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/annual_aver_wage/2004/value.png" alt="2021 USD (PPP)" style="max-width:100%;">
</div>

<div class="view" id="annualwages-rel-to-start-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/annual_aver_wage/2004/rel_val.png" alt="Relative-to-2004" style="max-width:100%;">
</div>

<div class="view" id="annualwages-eu8-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/annual_aver_wage/2004/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### plot for 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="annualwages-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/annual_aver_wage/2010/rel_val.png" alt="Relative-to-2010" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### LEGEND ### ### ### ### ### ### ### ### ### ### -->
<p class="img-note">
<b>Figure 4</b> Average annual wages since 2004, measured in constant 2024 international dollars (PPP).
The chart shows levels (const. USD PPP), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2024. 

<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/wages/annual_aver_wage/data_table.csv" target="_blank" rel="noopener">[download data]</a>
<a href="https://www.oecd.org/en/data/indicators/average-annual-wages.html" target="_blank" rel="noopener">[source]</a>
</p>

</div>

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- ANNUAL AVERAGE WAGE per hr worked table  -->

Measured from the 2004 baseline, **Hungary** has experienced the slowest convergence in average wage levels. When calculated from the 2010 baseline, its convergence was second slowest, as again Slovakia's convergence performance has been even weaker. 
Czechia also shows less convergence from 2010 onward, but this partly reflects its higher starting level, as it both began and ended the period at a higher wage level than Hungary.


<div class="table-toggle">

  <div class="controls">
    <button data-table="annaverwage-2004">2004–2024</button>
    <button class="active" data-table="annaverwage-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="annaverwage-2004" class="table-view">
      {% include images/hu-cee-convergence/output/wages/annual_aver_wage/table_2004_2024.html %}
    </div>
    <div id="annaverwage-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/wages/annual_aver_wage/table_2010_2024.html %}
    </div>
</div>
<br>
<b>Table 4:</b> Cumulative change in average annual wages from 2004 or 2010 to 2024, shown as a percentage of the EU8 weighted average, relative to the initial year, and in absolute terms (constant 2024 international dollars (PPP)). 
Countries are ranked by the EU8-relative measure.
</div>

However, this dataset is about *average* wages, which can be skewed by high wages and not necessarily reflecting the median worker's wage situation. 

### Median hourly earnings

Eurostat provides data on median hourly earnings in the private sector, reported both in nominal euros and in purchasing power standards (PPS), where nominal values are converted into EU-wide purchasing power units. 
We focus on median earnings expressed in PPS (see Methods). For CEE countries, this series begins in 2006, so the baseline years used here are 2006 and 2010. This dataset is collected every four years and currently its last entry is from 2022, therefore the effects of the inflationary spike on real wages in 2023 are not yet included.

Since 2006, average median hourly earnings in the region have increased from 34% to 61% of the EU8 level. The Baltic countries, Romania and Poland again rank at the top of the region in terms of cumulative convergence to the EU8 benchmark.

<!-- Real median earnings plots -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2006</div>
    <button data-target="realmedianhrearnings-abs-val-2006">PPS</button>
    <button data-target="realmedianhrearnings-rel-to-start-2006">Relative-to-2006</button>
    <button class="active" data-target="realmedianhrearnings-eu8-2006">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="realmedianhrearnings-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view" id="realmedianhrearnings-abs-val-2006">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/real_median_hourly/2006/value.png" alt="PPS" style="max-width:100%;">
</div>

<div class="view" id="realmedianhrearnings-rel-to-start-2006">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/real_median_hourly/2006/rel_val.png" alt="Relative-to-2006" style="max-width:100%;">
</div>

<div class="view active" id="realmedianhrearnings-eu8-2006">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/real_median_hourly/2006/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### plot for 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="realmedianhrearnings-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/real_median_hourly/2010/rel_val.png" alt="Relative-to-2010" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### LEGEND ### ### ### ### ### ### ### ### ### ### -->
<p class="img-note">
<b>Figure 5</b> Median hourly earnings since 2006, measured in PPS (purchasing power standards; anchored to EU-wide price changes).
The chart shows levels (PPS), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2022. 

<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/wages/real_median_hourly/data_table.csv" target="_blank" rel="noopener">[download data]</a>
<a href="https://ec.europa.eu/eurostat/databrowser/view/earn_ses_pub2s/default/table?lang=en" target="_blank" rel="noopener">[source]</a>
</p>

</div>

**Hungary** once more appears towards the bottom of the regional ranking. Measured from the 2006 baseline and expressed as a percentage of the EU8 average, only Czechia and Slovenia recorded smaller convergence, but both started from, and remained at, a level 10–20% higher by the end of the period. When calculated from the 2010 baseline, Hungary still shows the third lowest convergence performance in the region; Croatia's earnings convergence was even poorer.

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Real median earnings per hr worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="real_median_hourly-2006">2006–2022</button>
    <button class="active" data-table="GDPperhr-2010">2010–2022</button>
  </div>

<div class="table-container">
    <div id="real_median_hourly-2006" class="table-view">
      {% include images/hu-cee-convergence/output/wages/real_median_hourly/table_2006_2022.html %}
    </div>
    <div id="real_median_hourly-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/wages/real_median_hourly/table_2010_2022.html %}
    </div>
</div>
<br>
<b>Table 5:</b> Cumulative change in median hourly earnings from 2006 or 2010 to 2022, shown as a percentage of the EU8 weighted average, relative to the initial year, and in absolute terms (purchasing power standards, PPS). Countries are ranked by the EU8-relative measure.
</div>

### Minimum wage

Minimum wages set an important floor under pay levels, especially for low-wage workers. The OECD provides an international minimum wage database in constant 2021 USD (PPP), which allows for cross-country comparisons in real (inflation-adjusted) terms. 
Several EU8 countries do not have a statutory national minimum wage, relying instead on sectoral bargaining. As a result, the Western European benchmark used here is the population-weighted average of three countries (EU3: Belgium, France and the Netherlands).

Expressed as a share of the EU3 benchmark, the average minimum wage across the CEE region more than doubled, rising from 28% to 63%. Romania, Poland, Bulgaria and the Baltic countries again lead the region in terms of convergence. In Romania, the minimum wage quadrupled relative to the EU3 level, while it nearly tripled in Bulgaria and more than doubled in Poland and Lithuania.


<!-- Minimum wage plots -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2004</div>
    <button data-target="minimwage-abs-val-2004">constant USD PPP 2024</button>
    <button data-target="minimwage-rel-to-start-2004">Relative-to-2004</button>
    <button class="active" data-target="minimwage-eu8-2004">% of EU3</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="minimwage-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view" id="minimwage-abs-val-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/min_wage/2004/value.png" alt="constant USD PPP 2024" style="max-width:100%;">
</div>

<div class="view" id="minimwage-rel-to-start-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/min_wage/2004/rel_val.png" alt="Relative-to-2004" style="max-width:100%;">
</div>

<div class="view active" id="minimwage-eu8-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/min_wage/2004/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### plot for 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="minimwage-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/min_wage/2010/rel_val.png" alt="Relative-to-2010" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### LEGEND ### ### ### ### ### ### ### ### ### ### -->
<p class="img-note">
<b>Figure 6</b> Minimum wages since 2004, measured in constant 2024 international dollars (PPP).
The chart shows levels (const. USD PPP), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2024. 
<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/wages/min_wage/data_table.csv" target="_blank" rel="noopener">[download data]</a>
<a href="https://data-explorer.oecd.org/vis?lc=en&df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_EARNINGS%40RMW&df[ag]=OECD.ELS.SAE&df[vs]=1.0" target="_blank" rel="noopener">[source]</a>
</p>

</div>

Calculated from the 2004 baseline, **Hungary** ranks third from the bottom (+22% expressed as a share of the EU3 benchmark), with only Slovakia and Czechia showing weaker convergence. 
However, minimum wage increases accelerated in Hungary after 2010, and measured from this baseline its convergence is in the middle of the pack.

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Minimum wage table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="min_wage-2004">2004–2024</button>
    <button class="active" data-table="min_wage-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="min_wage-2004" class="table-view">
      {% include images/hu-cee-convergence/output/wages/min_wage/table_2004_2024.html %}
    </div>
    <div id="min_wage-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/wages/min_wage/table_2010_2024.html %}
    </div>
</div>
<br>
<b>Table 6:</b> Cumulative change in minimum wages from 2004 or 2010 to 2024, shown as a percentage of the EU8 weighted average, relative to the initial year, and in absolute terms (constant 2024 international dollars (PPP)). Countries are ranked by the EU8-relative measure.
</div>


### Median equivalised net income

Wages are not the only source of income for individuals and households, and some households rely partly or entirely on other income streams, such as pensions or social benefits. 
Eurostat provides a series on median equivalised net income, a broader measure than median earnings that covers the entire population and includes all sources of household disposable income after taxes and transfers. 
The indicator is expressed on a per-person basis and adjusted for household size and composition.

Over the 2005-2024 period, the CEE region as a whole has seen substantial convergence, with median equivalised net income rising from 31 to 62% of the EU8 average. 
Poland, Romania and the Baltic countries recorded the largest gains, with Poland reaching 73% of the Western European benchmark. Slovenia, the most advanced country in the region, reached 87% of the EU8 level in 2024, coming close to Western European household income levels in purchasing power terms.

<!-- Median equivalised net income plots -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2005</div>
    <button data-target="median_equiv_net_income-abs-val-2005">PPS</button>
    <button data-target="median_equiv_net_income-rel-to-start-2005">Relative-to-2005</button>
    <button class="active" data-target="median_equiv_net_income-eu8-2005">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="median_equiv_net_income-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view" id="median_equiv_net_income-abs-val-2005">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/median_equiv_net_income/2005/value.png" alt="PPS" style="max-width:100%;">
</div>

<div class="view" id="median_equiv_net_income-rel-to-start-2005">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/median_equiv_net_income/2005/rel_val.png" alt="Relative-to-2005" style="max-width:100%;">
</div>

<div class="view active" id="median_equiv_net_income-eu8-2005">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/median_equiv_net_income/2005/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### plot for 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="median_equiv_net_income-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/wages/median_equiv_net_income/2010/rel_val.png" alt="Relative-to-2010" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### LEGEND ### ### ### ### ### ### ### ### ### ### -->
<p class="img-note">
<b>Figure 7</b> Median equivalised net income since 2005, measured in PPS (purchasing power standards anchored to EU-wide price changes).
The chart shows levels (PPS), indexed values relative to 2005 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2024. 
<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/wages/median_equiv_net_income/data_table.csv" target="_blank" rel="noopener">[download data]</a>
<a href="https://ec.europa.eu/eurostat/databrowser/view/ilc_di03/default/table?lang=en" target="_blank" rel="noopener">[source]</a>
</p>

</div>

**Hungary** has seen the weakest convergence from the 2005 baseline, with household income rising by only 9 percentage points relative to the EU8 average over two decades. 
This is the poorest performance in the region and has resulted in Hungary also having the lowest *level* of household income in 2024. Measured from the 2010 baseline, Slovakia's convergence has been even weaker. 
As a result, household income levels in the two countries are now roughly identical and below two-thirds of Poland's level, although Hungary started from a higher level than Poland in 2005.


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Median equivalised net income worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="median_equiv_net_income-2005">2007–2024</button>
    <button class="active" data-table="median_equiv_net_income-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="median_equiv_net_income-2005" class="table-view">
      {% include images/hu-cee-convergence/output/wages/median_equiv_net_income/table_2007_2024.html %}
    </div>
    <div id="median_equiv_net_income-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/wages/median_equiv_net_income/table_2010_2024.html %}
    </div>
</div>
<br>
<b>Table 7:</b> Cumulative change in median equivalised net income from 2005 or 2010 to 2024, shown as a percentage of the EU8 weighted average, relative to the initial year, and in absolute terms (purchasing power standards,PPP). Countries are ranked by the EU8-relative measure.
</div>

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->

## Actual individual consumption

Median net household income provides a broad picture of household finances, but it does not fully capture living standards, since consumption patterns can differ across countries. Savings rates also vary - for example, due to differences in pension systems - which affects how much income is available for current consumption.

To address these differences, Eurostat uses a per capita consumption measure known as **actual individual consumption (AIC)**. 
AIC reflects total household consumption per person, regardless of who pays for it. 
AIC includes goods and services consumed by households but paid for by governments or non-profit institutions, even when households do not incur these costs directly. The indicator is expressed in purchasing power standards (PPS; see the Methods section for details).

Figure 8 shows that the convergence in consumption level to the EU8 average has been similar to that of household income, with a 27% rise from 2004 to 2024. Romania, Bulgaria, Poland and the Baltic states again recorded the largest gains. 

<!-- Actual individual consumption plots -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2004</div>
    <button data-target="actual_indiv_cons-abs-val-2004">PPS</button>
    <button data-target="actual_indiv_cons-rel-to-start-2004">Relative-to-2004</button>
    <button class="active" data-target="actual_indiv_cons-eu8-2004">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="actual_indiv_cons-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view" id="actual_indiv_cons-abs-val-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/actual_indiv_consump/2004/value.png" alt="PPS" style="max-width:100%;">
</div>

<div class="view" id="actual_indiv_cons-rel-to-start-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/actual_indiv_consump/2004/rel_val.png" alt="Relative-to-2004" style="max-width:100%;">
</div>

<div class="view active" id="actual_indiv_cons-eu8-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/actual_indiv_consump/2004/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### plot for 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="actual_indiv_cons-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/actual_indiv_consump/2010/rel_val.png" alt="Relative-to-2010" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### LEGEND ### ### ### ### ### ### ### ### ### ### -->
<p class="img-note">
<b>Figure 8</b> Actual individual consumption since 2004, measured in PPS (purchasing power standards anchored to EU-wide price changes).
The chart shows levels (PPS), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2024. 
<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/actual_indiv_consump/data_table.csv" target="_blank" rel="noopener">[download data]</a>
<a href="https://ec.europa.eu/eurostat/databrowser/view/prc_ppp_ind/" target="_blank" rel="noopener">[source]</a>
</p>
</div>

**Hungary** has experienced the second-weakest convergence in consumption levels since 2004, with AIC rising by only 9% relative to the EU-8 average over two decades. In 2024, Hungary had the lowest level of AIC in the region, at 64% of the EU-8 average. The only country with weaker convergence is Slovenia, which started from a higher baseline (67% of the EU8 average) - a level Hungary had still not reached by 2024.

In a familiar pattern, measured from a 2010 baseline, Slovakia's convergence appears even weaker. Even from this later starting point, Hungary's gains lagged behind all other countries except Slovakia and the two higher-baseline cases, Czechia and Slovenia.


<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Actual individual consumption worked table  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="actual_indiv_cons-2004">2004–2024</button>
    <button class="active" data-table="actual_indiv_cons-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="actual_indiv_cons-2004" class="table-view">
      {% include images/hu-cee-convergence/output/actual_indiv_consump/table_2004_2024.html %}
    </div>
    <div id="actual_indiv_cons-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/actual_indiv_consump/table_2010_2024.html %}
    </div>
</div>
<br>
<b>Table 8:</b> Cumulative change in actual individual consumption from 2004 or 2010 to 2024, shown as a percentage of the EU8 weighted average, relative to the initial year, and in absolute terms (purchasing power standards,PPP). Countries are ranked by the EU8-relative measure.
</div>

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->
<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###  -->

## Employment ratio

The employment-to-population ratio measures the share of the population aged 15 and over that is in employment. Among countries with broadly similar age structures, as is the case in the CEE region, a low employment ratio can be a sign of structural unemployment (or underemployment) that is not fully captured by official unemployment statistics. 
It should also be noted that in countries with high emigration rates there is considerable uncertainty about the number of workers actually residing in the country, and therefore about both the numerator and denominator of the employment ratio. For this reason, these figures should not be interpreted as exact.

In the mid-2000s, many CEE countries had a relatively [low employment ratio](https://data.worldbank.org/indicator/SL.EMP.TOTL.SP.ZS?locations=PL-B8-DE) compared with Western Europe, in particular with the most advanced EU8 countries such as Germany, Austria and the Nordic states. 
This was likely a legacy of the transition crisis of the 1990s, which led to the closure of uncompetitive industries and the permanent exit of large segments of the labour force from employment. Many of these workers did not appear in unemployment statistics, for example because they entered early retirement schemes, or other forms of labour market exit (which probably included informal employment too) as a way of coping with long-term joblessness.

In 2004, the average employment ratio across the CEE region was around 45%, compared with roughly 55-60% in the EU8. As Figure 8 shows, this gap was closed over the following decade and a half. By the late 2010s, most CEE countries had reached employment ratios comparable to the EU8 average, with the exceptions of Croatia and Romania. Overall, employment ratios in the region rose into the 55-60% range of the 15+ population, broadly in line with Western European levels.

<!-- Employment ratio (15+) -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2004</div>
    <button class="active" data-target="employment-abs-val-2004">% of 15+ population</button>
    <button data-target="employment-rel-to-start-2004">Relative-to-2004</button>
    <button data-target="employment-eu8-2004">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="employment-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view active" id="employment-abs-val-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/employment/2004/value.png" alt="% of 15+ population" style="max-width:100%;">
</div>

<div class="view" id="employment-rel-to-start-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/employment/2004/rel_val.png" alt="Relative-to-2004" style="max-width:100%;">
</div>

<div class="view" id="employment-eu8-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/employment/2004/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### plot for 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="employment-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/employment/2010/rel_val.png" alt="Relative-to-2010" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### LEGEND ### ### ### ### ### ### ### ### ### ### -->
<p class="img-note">
<b>Figure 9</b> Employment ratio (% of 15+ population) since 2004.
The chart shows levels (% of 15+ population), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2024. 
<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/employment/data_table.csv" target="_blank" rel="noopener">[download data]</a>
<a href="https://data.worldbank.org/indicator/SL.EMP.TOTL.SP.ZS?locations=HU-B8" target="_blank" rel="noopener">[source]</a>
</p>

</div>

In this indicator, **Hungary** is in line with the region and even slightly stands out positively. Measured from 2004, its increase in the employment ratio is the third largest; from 2010, it is - tied with Lithuania - the largest. 
This partly reflects a baseline effect: the employment ratio in both countries actually fell between 2004 and 2010, which was rather the exception in the region. The subsequent rise in Hungary's employment ratio aligns with broader regional trends and neither the cumulative increase, nor the level achieved by 2024 are outliers. The unusual feature is how low the ratio was in 2010.

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- Employment ratio (15+ population) TABLE  -->

<div class="table-toggle">

  <div class="controls">
    <button data-table="employment-2004">2004–2024</button>
    <button class="active" data-table="employment-2010">2010–2024</button>
  </div>

<div class="table-container">
    <div id="employment-2004" class="table-view">
      {% include images/hu-cee-convergence/output/employment/table_2004_2024.html %}
    </div>
    <div id="employment-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/employment/table_2010_2024.html %}
    </div>
</div>
<br>
<b>Table 9:</b> Cumulative change in employment ratio (% of 15+ population) from 2004 or 2010 to 2024, shown as a percentage of the EU8 weighted average, relative to the initial year, and as a % of 15+ population. Countries are ranked by the EU8-relative measure.
</div>


## Life expectancy

Period life expectancy represents the expected length of life based on current age-specific mortality rates. In the CEE region, this metric had already showed significant increases from the early 1990s to 2004, following roughly 25 years of stagnation prior to 1990.

From 2004 to 2024 convergence continued, but at a slower pace, as life expectancy across the CEE region rose by about 4 years, reaching an average of 78 years, or roughly 95% of the EU8 average. Slovenia reached full parity with Western Europe, while Romania, Bulgaria, and Lithuania remain at the lower end, around 92% of the EU level.

<!-- Life expectancy -->
<div class="switchable">

  <div class="controls">
    <div class="controls-label">2004</div>
    <button class="active" data-target="life_exp-abs-val-2004">Years</button>
    <button data-target="life_exp-rel-to-start-2004">Relative-to-2004</button>
    <button data-target="life_exp-eu8-2004">% of EU8</button>
    <!--BREAK-->
    <div class="break"></div>
    <div class="controls-label">2010</div>
    <button data-target="life_exp-rel-to-start-2010">Relative-to-2010</button>
  </div>

<div class="view active" id="life_exp-abs-val-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/life_exp/2004/value.png" alt="Years" style="max-width:100%;">
</div>

<div class="view" id="life_exp-rel-to-start-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/life_exp/2004/rel_val.png" alt="Relative-to-2004" style="max-width:100%;">
</div>

<div class="view" id="life_exp-eu8-2004">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/life_exp/2004/EU8.png" 
alt="Relative-to-EU8" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### plot for 2010 ### ### ### ### ### ### ### ### ### ### -->

<div class="view" id="life_exp-rel-to-start-2010">
<img src="{{site.baseurl}}/images/hu-cee-convergence/output/life_exp/2010/rel_val.png" alt="Relative-to-2010" style="max-width:100%;">
</div>

<!-- ### ### ### ### ### ### ### LEGEND ### ### ### ### ### ### ### ### ### ### -->
<p class="img-note">
<b>Figure 10</b> Life expectancy (years) since 2004. The chart shows levels (years), indexed values relative to 2004 and 2010, and percentages of the EU8 weighted average. Countries are ranked by cumulative growth from the selected base year through 2024. 
<a href="https://github.com/mbkoltai/mbkoltai.github.io/tree/source/images/hu-cee-convergence/output/life_exp/data_table.csv" target="_blank" rel="noopener">[download data]</a>
<a href="https://ourworldindata.org/grapher/life-expectancy" target="_blank" rel="noopener">[source]</a>
</p>

</div>

Life expectancy in **Hungary** has increased roughly in line with the CEE regional average, whether measured from 2004 or 2010. By 2022, it reached 77 years, just below the region's weighted average.

<!-- ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### -->
<!-- life_exp TABLE -->

<div class="table-toggle">
  <div class="controls">
    <button data-table="life_exp-2004">2004–2023</button>
    <button class="active" data-table="life_exp-2010">2010–2023</button>
  </div>

<div class="table-container">
    <div id="life_exp-2004" class="table-view">
      {% include images/hu-cee-convergence/output/life_exp/table_2004_2023.html %}
    </div>
    <div id="life_exp-2010" class="table-view active">
      {% include images/hu-cee-convergence/output/life_exp/table_2010_2023.html %}
    </div>
</div>
<br>
<b>Table 10:</b> Cumulative change in life expectancy from 2004 or 2010 to 2024. 
Expressed in years, as % of the EU8 (weighted average), or relative to the initial value. Countries are ranked by the change in years.
</div>


# Discussion


To provide an overview of the results, the table below summarises all indicators analysed.

Table 11 presents the findings in three complementary ways. First, it shows country rankings, calculated in two variants: one excluding Czechia and Slovenia - often outliers across multiple indicators - and one including all 11 CEE countries. 
Countries are ranked by their levels in 2004 (where available), 2010, and 2024, as well as by cumulative changes from 2004 or 2010 to 2024.

By clicking the “Values” button, rankings are replaced by the underlying indicator values (mostly expressed as percentages of the EU-8 average) for Hungary and the CEE regional average.


<div class="table-toggle">
  <div class="controls">
    <button class="active" data-table="df_hu_rank_no_CZ_SI">Ranking (no CZ/SI)</button>
    <button data-table="df_hu_rank_all">Ranking (all countries)</button>
    <button data-table="df_hu_value">Values</button>
  </div>

<div class="table-container">
    <div id="df_hu_rank_no_CZ_SI" class="table-view active">
      {% include images/hu-cee-convergence/output/df_hu_rank_no_CZ_SI.html %}
    </div>
    <div id="df_hu_rank_all" class="table-view">
      {% include images/hu-cee-convergence/output/df_hu_rank_all.html %}
    </div>
    <div id="df_hu_value" class="table-view">
      {% include images/hu-cee-convergence/output/df_hu_value_all.html %}
    </div>

</div>
<br>
<b>Table 11:</b> Summary of indicators for Hungary and the CEE average. Rankings are shown for a nine-country group excluding CZ and SI and for all eleven CEE countries. Values report the underlying indicators (mostly as % of the EU-8 average).
</div>

It is clear that in most indicators Hungary saw a relative decline within the region, going from the top two to four countries in the CEE9 group to the bottom 2 or 3 by 2024, with a few exceptions (employment, minimum wage and life expectancy).

To make the conclusions more straightforward, I calculate the median and mean rankings across all indicators in Table 12.

<div class="table-container">
    <div id="rank_mean_median" class="table-view">
      {% include images/hu-cee-convergence/output/rank_mean_median.html %}
    </div>

<b>Table 12:</b> Median and mean rankings of Hungary across all metrics. This summary ranking is calculated for the levels of the indicators in 2004, 2010 and 2024, as well as for cumulative increases. The level in 2010 and the cumulative change from 2010 to 2024 are highlighted in red.
</div>

I would argue that the most informative summary measure is the median ranking within the CEE9, which excludes Czechia and Slovenia - countries that were already substantially more developed in 2004 (and even in 1990). 
Their smaller cumulative gains relative to the EU8 group average reflect an expected slowdown associated with higher initial income levels rather than a clear policy failure. 
At the same time, this pattern raises the question how realistic full convergence to the Western European core is for the CEE region as a whole.

<!-- Even so, Czechia and Slovenia have already reached at least 75% of the EU8 level in most indicators - roughly comparable to Spain - with some measures, such as life expectancy and the employment ratio, effectively at parity with the EU8 average. 
In this sense, their convergence can be considered largely complete, although not yet at the level of Europe's wealthiest economies. -->

For **Hungary**, Table 12 paints a clear and deeply negative picture of the past two decades. In 2004, Hungary still ranked fourth by the median of the indicators within the full 11-country CEE group. Excluding Czechia and Slovenia, it stood second in the narrower CEE9 group. The exact mean or median ranking is not the main point, since it depends on which variables are included. While the ten variables selected here are the most comprehensive economic indicators I could identify, the list could be expanded or narrowed, producing slightly different results. What is clear, however, is that across the broadest measures of convergence, Hungary’s performance over the past two decades ranks among the worst - whether it was the absolute worst, second, or third depends on the choice of indicators.

Using the 10 indicators discussed, by 2010 Hungary had already fallen three places in its median ranking (5/9 in the CEE9 group or 7/11 in CEE11). Between 2010 and 2024, it slipped a further two positions, ending up seventh out of nine in the CEE9 — or eighth to ninth in the full CEE11. 

As a result, Hungary's convergence performance ranks among the weakest in the region, whether measured from a 2004 or a 2010 baseline.From the 2004 baseline, Hungary has the worst median ranking in cumulative convergence within the CEE9. 
From the 2010 baseline, it ranks between the second- and third-worst (median ranking of 7.5/9), alongside Slovakia and Croatia, whose convergence has also been weak. 
Hungary avoids placing last since 2010 as well only because of the sharp rise in its employment ratio after 2010 and Slovakia's similarly poor performance across most other indicators.

While the increase in Hungary's employment ratio after 2010 was a welcome development, it was not unique. 
Similar gains occurred across nearly all CEE countries as part of a broader regional trend. Indeed, Hungary's increase in employment since 2004 exactly matches the CEE average. This makes the argument that weak productivity and income growth reflect the absorption of previously underemployed workers and *therefore* weak or no productivity growth was unavoidable unconvincing. Several other countries managed to raise both employment *and* productivity over the same period.

In short, Hungary's relative downward slide already started around 2004 and continued after 2010, under the Orban government.
If we look at the curves above, we can also visually locate the two sub-periods when Hungary was more or less completely stagnant, while most of the region - with the exception of post-2010 Slovakia - continued to climb upwards.
Hungary was stagnant in the main output variables in the 2006-2012 period and again from 2022 until today, although it seems for different reasons.
While in 2006-2010 the employment ratio fell in absolute terms, output per hour of work was still on the way up until 2011.
Since 2021 the employment ratio plataeud - which is expected as it already reached a high level - but labour productivity has been essentially stagnant too. 

Since 2022 this led to stagnating GDP and GNI per capita, ie. total output, while - somewhat surprisingly - wages, incomes and consumption still kept slowly increasing, with minimum wages hiked. However, within the context of a stagnating national economy, these wage increases are unlikely to be sustainable.

# Conclusion

This survey of macro-trends does not, in itself, provide a causal analysis.
It does, however, allow us to assess the record of the past 16 years - an uninterrupted period of Orbán's rule.

Across the economic indicators examined, the only area of clear success over this period was the rise in the employment ratio. This increase followed a broader regional trend and, by the end of the 2010s, reached Western European levels.

That achievement, however, was accompanied by an absolute decline in average labour productivity until 2016, followed by only weak productivity growth thereafter. Improvements in living standards were similarly limited: median wages, household incomes, and per-capita consumption showed the weakest convergence in the CEE region, with the sole exception of Slovakia, which underperformed even Hungary. While minimum wage increases in Hungary were around the regional average, rather than below average, this did not lead to a comparable convergence of actual wages, income or consumption.

This trajectory left Hungary as the second- or third-worst performer in the CEE region by 2024, despite entering the EU as one of the region's frontrunners.

This does not mean Hungary stagnated *in absolute terms* over the past two decades - it did not. Rather, it is its convergence toward Western European levels of output and income that has been notably weak, compared with most of the CEE region.

The contrast is stark in the headline indicator of GNI per capita. Since 2004, Poland, Romania, and Latvia have roughly doubled their real GNI per capita, and since 2010 have increased it by around 60%. In Hungary, by comparison, real GNI per capita rose by only 40% since 2004 and 35% since 2010. Similar relative gaps are visible in wage, income, and consumption trends when Hungary is compared with the best-performing CEE economies.

While the reasons for this relative decline are complex, the fact that Hungary has been governed by the same administration for 16 years makes it reasonable to conclude that the current regime's economic record has been a failure in comparative, regional terms.

The combination of near-stagnant output since 2022 *and* below average productivity, income and consumption growth throughout the 2010s is distinctive to Hungary (and to Slovakia) and increasingly divergent from broader regional trends. The post-2021 stagnation also does not appear to be explicable by the Ukraine war. It is only Estonia (and perhaps Czechia) that seems to have suffered a similar shock to output growth, while other countries in a similar geographic and geo-economic situation as Hungary - the other Visegrad countries, Romania, Croatia, Slovenia - has not experienced stagnation in the last four years.

It is important to note that the 2004-2010 period in Hungary was also unsuccessful, by several metrics even more so than 2010-2024, and contributed to this divergence. However, the 16 years since 2010 constitute a sufficiently long horizon for a government to identify structural problems in its macroeconomic strategy and to propose - if not fully implement - a change in direction.

Whatever the underlying causes of Hungary's relative stagnation, the current government has consistently refused to acknowledge any shortcomings in its policy mix. Instead, it has doubled down on a strategy characterised by extreme centralisation, disproportionately large government subsidies to foreign (primarily manufacturing) investment, and an almost exclusive focus on physical infrastructure, especially motorways. This inability - and indeed aggressive rejection - of any admission of error, let alone correction, is perhaps the most troubling feature of the past 16 years.

Whatever the precise causal mechanisms, this policy mix has not delivered strong economic outcomes. On the contrary, it has resulted in the second or third worst economic performance in the entire region. 
The continued refusal to reconsider any element of this strategy, combined with explicit commitments to pursue it further, suggests that Hungary's relative marginalisation within its historical region and the EU is likely to persist - at least in the absence of a change in political leadership.