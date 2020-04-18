---
layout: post
title: Tracking the pandemic
tags: political-economy globalization epidemics complex-systems ecology covid19
excerpt: Graphs of the data and notes on the politics/economics of COVID19
secondary: ecopol
mathjax: true
---

This post includes graphs of the dynamics of the COVID19 pandemic, as well as notes that I am making on the economics and politics of the pandemic. Notes on mathematical modeling of the epidemic [are in the science section](https://mbkoltai.github.io/covid-modeling/). As of early April (9th of April) the notes are rather messy, I plan to clean them up with time.

I am mainly interested in structural analysis of how the pandemic will change society, especially on the medium/long-term.

## Table of contents

1. [Data visualization](#1-data-visualization)
1. [Economics and politics](#2-economics-and-politics)

## 1. Data visualization

The data source for all these plots is the central database by [Johns Hopkins University](https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series).

### Total number of cases by date (logarithmic y-axis)

This is showing the cumulative number of confirmed COVID19 cases in the major European countries, the US and some of the major Asian countries. The numbers are plotted by date.
The 5 biggest European countries by population (Germany, UK, France, Italy and Spain) have a combined population almost exactly equal to the US, so it is useful to plot them also as a group, this is shown by '*IT_ES_FR_DE_UK'*.
The insets show European countries plus the US and Asian countries, respectively.
The dashed blue lines on the left inset show the dates:
- 20/February: exponential increase of cases starts in Italy
- 26/February: exponential increase of cases starts in France
- 09/March: countrywide lockdown in Italy
- 16/March: countrywide lockdown in France (announced, effective from 17th noon)

![_config.yml]({{ site.baseurl }}/images/covid/west_vs_asia_w_china.png)

### Total number of cases, aligned (logarithmic y-axis)

Same as the previous plot, but countries are aligned to start from the same number of cases as Italy had on the 26th of February (or the day they had the closest value).

![_config.yml]({{ site.baseurl }}/images/covid/cases_cntrs_tracking_italy_log.png)

### Total number of deaths, aligned from same starting point (y logscale)

Same as the previous plot, but for cumulated number of fatalities.

![_config.yml]({{ site.baseurl }}/images/covid/deaths_cntrs_tracking_italy_log.png)

### Number of new cases in Europe, US and Asia (logarithmic y-axis)

Plotting the number of new cases by date, for the same Western (+Russia) and Asian countries.

![_config.yml]({{ site.baseurl }}/images/covid/newcases_west_vs_asia_w_china.png)

### Number of new cases in Europe and the US

Number of new confirmed cases by date for Western countries and Russia only. The dashed blue lines show the start of the lockdowns in Italy (02/March, 09/March) and France (16/March).

![_config.yml]({{ site.baseurl }}/images/covid/newcases_west.png)

### Number of daily deaths in Europe and the US

The dashed blue lines show the lockdowns of Italy (02/March, 09/March) and France (16/March).

![_config.yml]({{ site.baseurl }}/images/covid/newdeaths_west.png)

### Growth rate of cases on total number of cases

This plot shows the percentage (fractional) growth of the total number of cases, as a function of the total number, with time going from left to right. The growth rate is averaged over a sliding window of three days.

![_config.yml]({{ site.baseurl }}/images/covid/growth_rate_cases_china_korea_west_cutoff2000.png)

### Growth rate of deaths on the total number

As previous plot, but for the number of fatalities. The growth rate is averaged over a sliding window of three days.

![_config.yml]({{ site.baseurl }}/images/covid/growth_rate_deaths_china_korea_west_cutoff60.png)

#### Why Italy has a very high case fatality rate (CFR)?
[% of old people/all cases much higher](https://medium.com/@andreasbackhausab/coronavirus-why-its-so-deadly-in-italy-c4200a15a7bf)  
Reason for many older ppl infected: [20% of Italians 30-49 still live at home](https://twitter.com/kuhnmo/status/1238421146837684224)  
\+ testing policy was changed late March bc of capacity limits, and only testing severe cases, so the number of confirmed cases is smaller, so ratio of death/confirmed cases grows.

<div style="page-break-after: always;"></div>


## 2. Economics and politics

#### [James Meadway on Novara, 16/march](https://novaramedia.com/2020/03/16/coronavirus-will-require-us-to-completely-reshape-the-economy)  
2008: crisis of banking system. QE prevented a crash
COVID19 more fundamental as it threatens the basis of capitalism, the *labour market*. Division of labour has to change.
Already trillion USD intervention by Fed.
Epidemics becoming worse bc of climate change.
Sick leave, helicopter money, requisitioning.

#### [JP Morgan analysis on US small businesses](https://institute.jpmorganchase.com/content/dam/jpmc/jpmorgan-chase-and-co/institute/pdf/institute-growth-vitality-cash-flows.pdf)
Most US small businesses have less than 1 month financial reserves if no revenue.

#### [Syllabus of political-economic consequences of COVID19 (Evgeny Morozov)](https://the-politics-of-covid-19.com/search/?size=n_30_n)

Compilation of more in depth analysis of political and economic consequences of the pandemic.

#### [Effects on the global south](https://rpalat.wordpress.com/2020/03/27/coronavirus-and-the-world-economy-the-old-is-dead-the-new-cant-be-born/)

The lacking infrastructure of developing and poor countries to deal with a pandemic.

#### [Mike Davis: Who gets forgotten in an epidemic](https://www.thenation.com/article/politics/mike-davis-covid-19-essay/)

#### [Social contagion (Wuhan story)](http://chuangcn.org/2020/02/social-contagion/)

#### [Disease X WHO scenario 2018](https://edition.cnn.com/2018/03/12/health/disease-x-blueprint-who/index.html)

#### [M Roberts: War economy?](https://thenextrecession.wordpress.com/2020/03/30/a-war-economy)

![_config.yml](https://thenextrecession.files.wordpress.com/2020/03/war-4.jpg)

#### [Mike Davis: In a Plague Year (Jacobin 14/March)](https://jacobinmag.com/2020/03/mike-davis-coronavirus-outbreak-capitalism-left-international-solidarity)

Ebola: 1994, African bat cave  
SARS: 2003, Guangdong (manufact.)
1918 'Spanish flu' outbreak was H1N1, most fatalities young ppl, maybe older ppl had immunity from flus of 1890s.
#### [Monthly Review: COVID19 and circuits-of-capital](https://monthlyreview.org/2020/04/01/covid-19-and-circuits-of-capital/)

Trump dismantled his pandemic preparation team and left ~700 CDC positions unfilled.
At least 60 percent of novel human pathogens emerge by spilling over from wild animals to local human communities
[Big Farms Make Big Flu: Dispatches on Infectious Disease, Agribusiness, and the Nature of Science](https://monthlyreview.org/product/big_farms_make_big_flu/)
[Colgate/Johnson&Johnson heatmap](https://linkinghub.elsevier.com/retrieve/pii/S0140673612616845) of where next pandemics might emerge.
But they only talk abt the sources ('exotic' food), not demand driving it and networks.
Also growth of slums and incorporating rural communities into urban networks, so forest disease dynamics show up in cities v fast (cf. Mike Davis Planet of Slums). 'Post-agricultural' regions.  Deforestation + periurban lack of health infrastructure.
'Sylvatic pathogens' (wild animal pathogens) burned out in the forest before now entering susceptible human populations (no healthcare) ---> networks of travel/trade.
[Robert G. Wallace et al., Did Neoliberalizing West African Forests Produce a New Niche for Ebola? (2016)](https://doi.org/10.1177%2F0020731415611644)

'The lengthier the associated supply chains and the greater the extent of adjunct deforestation, the more diverse (and exotic) the zoonotic pathogens that enter the food chain.
Among recent emergent and reemergent farm and foodborne pathogens, originating from across the anthropogenic domain, are African swine fever, Campylobacter, Cryptosporidium, Cyclospora, Ebola Reston, E. coli O157:H7, foot-and-mouth disease, hepatitis E, Listeria, Nipah virus, Q fever, Salmonella, Vibrio, Yersinia, and a variety of novel inﬂuenza variants, including H1N1 (2009), H1N2v, H3N2v, H5N1, H5N2, H5Nx, H6N1, H7N1, H7N3, H7N7, H7N9, and H9N2.'

Growing genetic monocultures, overcrowding leading to immune suppression.

[The COVID-19 epidemic and China's wildlife business interest](https://theasiadialogue.com/2020/03/12/the-covid-19-epidemic-and-chinas-wildlife-business-interest/)

1989, the Wildlife Protection Law (WPL)
China’s wildlife farming has evolved into a gigantic business interest. In 2016, the industry produced 520.6 billion yuan (USD 81.3 billion) in revenue. The part of wildlife farming that supplied the exotic food market accounted for 24 per cent (125 billion yuan or USD 19.5 billion) of the total output.

#### [Reuters detailed account of UK gov response timeline](https://www.reuters.com/article/us-health-coronavirus-britain-path-speci-idUSKBN21P1VF)

#### [COVID-19 and the Coming Corporate Debt Catastrophe (13, March)](https://sbhager.com/covid-19-and-the-coming-corporate-debt-catastrophe/)

#### [Politico.eu: How Europe failed the coronavirus test](https://www.politico.eu/article/coronavirus-europe-failed-the-test/)
<!---![_config.yml]({{ site.baseurl }}/images/covid/reaction_eur_states_14978916_1586353616114.png)--->

This is a [useful table](https://images.jifo.co/14978916_1586353616114.png) on how many days it took European governments to apply restrictions after the 3rd death from COVID19.
Greece, Eastern European states did it before 3rd death, Spain 9-10 days after, UK, France 2 weeks after.

[Can you put a price on COVID-19 options? Experts weigh lives versus economics](https://www.sciencemag.org/news/2020/03/modelers-weigh-value-lives-and-lockdown-costs-put-price-covid-19)

Summary on modeling efforts to estimate costs of lockdowns vs letting the virus spread.
Early estimates suggested even a year-long lockdown more economically viable.
They made an estimate for economic loss due to deaths.
Important finding: usually fatality rates *fall* during economic crises (less accidents etc), even if suicides might increase.

[Data Gaps and the Policy Response to the Novel Coronavirus](https://drive.google.com/file/d/1Vu0wl-9K2dh8MpMqaO85MvE6UH7gcRLx/view)

Macroeconomic model to estimate economic effects of lockdowns vs. release.

[Martin S. Eichenbaum, Sergio Rebelo, Mathias Traband: The Macroeconomics of Epidemics (12 April)](https://www.kellogg.northwestern.edu/faculty/rebelo/htm/epidemics.pdf)

<!---!
<div class="infogram-embed" data-id="0991a8d7-ada2-4fc2-a351-f446081b8d95" data-type="interactive" data-title="3 — Comparing when coronavirus measures were implemented"></div><script>!function(e,i,n,s){var t="InfogramEmbeds",d=e.getElementsByTagName("script")[0];if(window[t]&&window[t].initialized)window[t].process&&window[t].process();else if(!e.getElementById(n)){var o=e.createElement("script");o.async=1,o.id=n,o.src="https://e.infogram.com/js/dist/embed-loader-min.js",d.parentNode.insertBefore(o,d)}}(document,0,"infogram-async");</script>
--->

[Capitalist agriculture and Covid-19: A deadly combination (11 March)](https://climateandcapitalism.com/2020/03/11/capitalist-agriculture-and-covid-19-a-deadly-combination/)
