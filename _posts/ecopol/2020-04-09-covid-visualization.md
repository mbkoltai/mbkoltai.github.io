---
layout: post
title: Tracking the pandemic
tags: political-economy globalization epidemics complex-systems ecology covid19
excerpt: Graphs and notes on the science and economics of COVID19
secondary: ecopol
mathjax: true
---

This post includes graphs of the dynamics of the COVID19 pandemic, as well as notes that I am making on the science (mostly epidemiologic modeling), economics and politics of the pandemics. As of early April (9th of April) the notes are rather messy, I plan to clean them up with time.

There are two main interests that go through the notes. First, I am interested in mathematical modeling of how the epidemic is spreading and the efforts to slow it down or suppress it. Second, I am interested in structural analysis of how it might change society, especially on the medium/long-term.

## Table of contents

1. [Data visualization](#1-data-visualization)
1. [Science and modeling](#2-science-and-modeling)
1. [Economics and politics](#3-economics-and-politics)

## 1. Data visualization

The data source for all these plots is the central database by [Johns Hopkins University](https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series).

### Total number of cases by date (logarithmic y-axis)

This is showing the cumulative number of confirmed COVID19 cases in the major European countries, the US and some of the major Asian countries. The numbers are plotted by date.
The 5 biggest European countries by population (Germany, UK, France, Italy and Spain) have a combined population almost exactly equal to the US, so it is useful to plot them also as a group, this is shown by '*IT_ES_FR_DE_UK'*.

![_config.yml]({{ site.baseurl }}/images/covid/west_vs_asia_w_china.png)

### Total number of cases, aligned (logarithmic y-axis)

Same as the previous plot, but countries are aligned to start from the same number of cases as Italy had on the 26th of February (or the day they had the closest value).

![_config.yml]({{ site.baseurl }}/images/covid/cases_cntrs_tracking_italy_log.png)

### Total # deaths, aligned from same starting point (y logscale)

Same as the previous plot, but for cumulated number of fatalities.

![_config.yml]({{ site.baseurl }}/images/covid/deaths_cntrs_tracking_italy_log.png)

### Number of new cases in Europe, US and Asia (logarithmic y-axis)

Plotting the number of new cases by date, for the same Western (+Russia) and Asian countries.

![_config.yml]({{ site.baseurl }}/images/covid/newcases_west_vs_asia_w_china.png)

### Number of new cases in Europe, US and Asia, plotted by date

Number of new confirmed cases by date for Western countries and Russia only. The dashed blue lines show the imposition of the lockdowns in Italy (02/March, 09/March) and France (16/March).

![_config.yml]({{ site.baseurl }}/images/covid/newcases_west.png)

### Number of daily deaths in Europe and the US

The dashed blue lines show the imposition of the lockdowns in Italy (02/March, 09/March) and France (16/March).

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

## 2. Science and modeling

#### [School closures, event cancellations, and the mesoscopic localization of epidemics in networks with higher-order structure](https://arxiv.org/pdf/2003.05924.pdf)
higher-order struct leads to mesoscopic localization (concentration into substructures)
Individuals classified by # of contacts:  
$$S_k$$: % susceptible with k contacts  
$$I_k$$: % infected with k contacts  
Clique prevalence: average fraction of nodes within cliques of size *n*.

![_config.yml]({{ site.baseurl }}/images/covid/clique%20prevalence.PNG)

What does lower coupling mean?
There are two distributions that characterize the network:  
$$g_m$$: membership of nodes. $$S_m$$ is % of *S* with number *m* of memberships in higher order structures.  $$g_m \sim m^{-\gamma}$$  
p_n: distribution of clique size *n*. $$p_n \sim n^{-\gamma}$$  

If edges are removed, in the localized network there is a critical size n_c for cliques under which if enough edges are removed, then there are no infections anymore in these cliques.
Also, in localized networks global prevalence falls off much more sharply with stronger intervention, whereas effect is linear in 'delocalized' networks.

Variables are defined by master equations. This goes down after a week.
With active case finding the peak is lower and earlier.
With higher transmission rate this gets higher, converging to ~0.9.
But if structures are highly coupled (a), clique prevalence ~same for n [20,100].
With lower coupling (b) there is *mesoscopic localization*: global prevalence can be very low, but within cliques, much higher % of infection.  

#### Interactive modeling: https://alhill.shinyapps.io/COVID19seir/  
This is an ODE model assuming complete homogeneity. Three **I** populations with different rates of transmission.

#### [The Contribution of Pre-symptomatic Transmission to the COVID-19 Outbreak](https://cmmid.github.io/topics/covid19/control-measures/pre-symptomatic-transmission.html)  
Estimates that ~25% of transmission in Shenzhen was asymptomatic.

#### [Temporal variation in transmission during the COVID-19 outbreak in Italy](https://cmmid.github.io/topics/covid19/current-patterns-transmission/italy-time-varying-transmission.html)
Estimates on reproduction numbers in regions of Italy. Started from 3-4, falling towards 2.

#### Shiny app for contact tracing: https://bdi-pathogens.shinyapps.io/covid-19-transmission-routes

#### [Substantial undocumented infection facilitates the rapid dissemination of novel coronavirus (SARS-CoV2)](https://science.sciencemag.org/content/sci/early/2020/03/13/science.abb3221.full.pdf)

Estimates from a model + Bayesian inference.
Main findings (these are max probability estimates):
- 86% of infections were from undocumented cases in China *before travel ban of 23/january*.
- undocumented cases had 55% (mu*beta) transmission rate of documented ones (beta)
- undocumented cases were the source of 79% of documented cases

Model: dynamics of infections among 375 Chinese cities.
Spatial dynamics captured by # of passengers from city *i* to *j*.
Variables for each city: $$ S_i, E_i, I_i^r, I_i^u $$ (undocumented).
Simulations by 'iterated filter-ensemble adjustment Kalman filter (IF-EAKF) framework'.  
Inferred parameters:
- Z: average latent period
- D: average duration of infection
- $$\mu$$: transmission reduction factor for undocumented
- beta: transmission rate for documented
- alpha: fraction of documented infections
- theta: travel multiplicative factor

Reporting delay is included (from Gamma distribution).
Best-fitting parameter values identified by maximum likelihood.
They could distinguish between mu-alpha value pairs with different individual values but same product. They did simulations with all parameter value pairs (within certain range) and .
Delay of reporting crucial, this needs to be speeded up to stop the spread.

![_config.yml]({{ site.baseurl }}/images/covid/science_article_undocum_cases.PNG)

[SI](https://science.sciencemag.org/content/sci/suppl/2020/03/13/science.abb3221.DC1/abb3221_Li_SM.pdf) contains equations.
System of coupled ODEs: S_i is susceptibles in city *i*.
All terms normalised by total population (in that city).
D: <duration infection>  
Then effective reproduction number $$R_e=\alpha \beta D + (1-\alpha)\mu \beta\ D$$

System of ODEs are then solved stochastically: each RHS term is sampled from a Poisson distribution. So we take the current value of the variable and then sample from a Poisson distribution (the deterministic value is the lambda of the Poisson). This is for each RHS term!
Initial prior ranges for parameters are from Latin Hypercube Sampling.
Initial values for populations similarly sampled (eg. initial exposed).

Then the simulation results are mapped into reported cases by a separate delay model.
Delay is from a Gamma distribution approximated from data.
Movements between cities estimated from mobile apps: Tencent, Mobility Index from Baidu.
'Iterated' filtering to estimate model parameters.

#### [Wolfram Mathematica notebook on epidemic modeling](https://community.wolfram.com/groups/-/m/t/1896178)
https://www.twitch.tv/videos/569280246

#### [NECSI Slack channel for modeling](https://app.slack.com/client/T2DRR8UNB/CV19X1PKJ/thread/CUTSF2Q6R-1584495843.398200)

#### [Imperial: Impact of non-pharmaceutical interventions (NPIs) to reduce COVID19 mortality and healthcare demand](https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf)

2 strategies:
1) mitigation: can reduce peak healthcare demand by 2/3 and deaths by 50%. Still 100s of 1000s of deaths
2) Suppression: preferable for countries that can achieve. Means social distancing for *whole* of the population. Need to be maintained until vaccine found, as there is rebound if interventions are targeted.

Individual-based simulation model. Mixing in different environments. Schools double per capita rate of contacts. Incubation time 5 days. Infectiousness starts before symptoms. R0: between 2 and 2.6. Individual infectiousness varies (gamma distribution).
Symptomatic cases self-isolate w 1 day delay. 5 day delay to hospitalisation.

Results:
- no measures: peak after 3 months, 80% of US/UK population infected. 30-time more demand for critical care beds than available. 2.2M dead in US, 0.5M dead in UK.
- mitigation: for 7 different levels of mitigation they make estimates for the reduction in peak bed demand and total deaths. For two values of R0 (2.2, 2.4) and 4 values of 'triggers' (cumulative ICU cases). Trigger means when policies (home quarantine etc) are switched on/off.
- suppression: all measures combined can keep ICU bed demand below UK surge bed capacity (5K). Adaptive triggering of suppression: on-off with some thresholds for # of ICU cases.
Even with most comprehensive suppression strategy in 2 yrs abt 30K deaths in UK.
Higher ON trigger and/or lower OFF -> more deaths etc.

[Model used by Imperial from 2008](https://www.pnas.org/content/pnas/105/12/4639.full.pdf)

#### [NECSI response to Imperial paper (Ferguson et al) 'Impact of non-pharmarceutical...'](https://static1.squarespace.com/static/5b68a4e4a2772c2a206180a1/t/5e70eb32b16229792eb14836/1584458547530/ReviewOfFergusson.pdf)

They agree with Ferguson that suppression is needed to bring down R<sub>0</sub> below 1.
But they disagree w Ferguson claim that 2nd outbreak unavoidable. It's not because, during lockdown infectious ppl are identified and their contacts isolated.
Ferguson calculate new infections as fcn of infected % and immunity, but not the phase of trajectory (ergodicity).
Not true that resurgence starts from even 1 case, China data showed *only 5% of close contacts of infected tested positive*. Small outbreaks can be controlled by testing.
Ferguson ignores super-spreader events by ignoring 'fat tail distribution of contagion'.
But cutting off fat tail by banning events reduced R0.
Ferguson use SIR ODE-model, not appropriate bc they *ignore*:
- local dynamics
- non-normal distrib. of infection events per person (superspreaders)
- dynamic or stochastic values for parameters (social response)

But Imperial model has different environments and it is agent-based, so maybe this is not fair.
Debate: https://twitter.com/yaneerbaryam/status/1239936951823843328

#### [Beyond contact tracing: Community-based early detection for Ebola response, PLoS Currents Outbreaks (May 19, 2016)](https://necsi.edu/beyond-contact-tracing)

Stochastic model by NECSI.

#### [Community prevention](https://static1.squarespace.com/static/5b68a4e4a2772c2a206180a1/t/5e737b95403f772d8ce0e04a/1584626591711/CommunityPrevention.pdf)

NECSI model. R<sub>\*</sub>: community transmission rate.
i_0_c: stochastic factor of initial foothold the virus gains in a community
i_c(t): # active infections in community *c*  
If infection not contained, $$exp(r_c t)$$  
After $$T_c$$ community implements aggressive suppression policies.
Infections decay as $$exp(-t/\tau_c)$$  
After intervention # of infections is:  
$$i_c(t)=( i_c^0 exp(r_c T_c) ) exp(-(t-T_c)/\tau_c)$$  
Community transmission $$\sim i_c(t) p(travel)$$  
Poisson process, average number of infected communities can be estimated by integrating the two sub-processes (until and after $$T_c$$).  
Calculate expected number of other communities infected by community $$c$$.  
It's assumed growth within one community is exponential until $$T_c$$ (intervention), then exponential decay after $$T_c$$.

#### [Social Contacts and Mixing Patterns Relevant to the Spread of Infectious Diseases](https://journals.plos.org/plosmedicine/article?id=10.1371/journal.pmed.0050074)

Estimates for mixing patterns.

#### [The early phase of the COVID-19 outbreak in Lombardy, Italy](https://arxiv.org/abs/2003.09320)

#### [Secondary attack rate and superspreading events for SARS-CoV-2](https://www.thelancet.com/action/showPdf?pii=S0140-6736%2820%2930462-1)
Estimates for some 'super-spreader' events in table.

#### [Predicting collapse of adaptive networked systems without knowing the network](https://www.nature.com/articles/s41598-020-57751-y.pdf)
General on network collapse.

#### [Epidemiological data from the COVID-19 outbreak, real-time case information](https://www.nature.com/articles/s41597-020-0448-0.pdf)

#### [Fundamental principles of epidemic spread highlight the immediate need for large-scale serological surveys to assess the stage of the SARS-CoV-2 epidemic](https://www.medrxiv.org/content/10.1101/2020.03.24.20042291v1)

#### [Testing everyone instead of contact tracing](https://medium.com/@sten.linnarsson/to-stop-covid-19-test-everyone-373fd80eb03b)

if $$c\ p > (R_0-1)/(R_0-R_q)$$

Then exponential decay of outbreak. $$R_0$$ ~ 2.4, $$R_q$$ ~ 0.3 (Wuhan estimate).
c: compliance to self-quarantine after testing positive  
p: true positive rate

Fastest test currently: RT-LAMP technology, 10-30 mins, based on RNA detection. Polymerase with reverse transcriptase activity amplifies viral RNA ---> H+ release ---> pH sensitive dye.
But: it requires 65C incubation (tap water?).
Alternatives:
- rolling circle replication
- in vitro viral replication assays

Lockdown cost dwarfs testing cost.

#### [Imperial study on global effects](https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-Global-Impact-26-03-2020.pdf)

More detail on model. Distributions used for time of next infection.

#### [NN Taleb: Tail Risk of Contagious Diseases](https://www.researchers.one/media/documents/282-m-corona2.pdf)

#### [Why everyone should wear a mask](https://medium.com/@Cancerwarrior/covid-19-why-we-should-all-wear-masks-there-is-new-scientific-rationale-280e08ceee71)

#### [Estimates of the severity of coronavirus disease 2019: a model-based analysis](https://www.thelancet.com/journals/laninf/article/PIIS1473-3099(20)30243-7/fulltext)

#### [An investigation of transmission control measures during the first 50 days of the COVID-19 epidemic in China](https://science.sciencemag.org/content/early/2020/03/30/science.abb6105)

Effect of Wuhan travel ban.

#### [Predictions about peaks](http://www.healthdata.org/covid/updates)
Preds made 05 April. France: 15K deaths by August, UK 66K (!).

#### [Preparedness and vulnerability of African countries against importations of COVID-19: a modelling study](https://www.thelancet.com/action/showPdf?pii=S0140-6736%2820%2930411-6)

Importation risk from China vs health care system capacity

[Ron Milo: COVID by the numbers](https://elifesciences.org/articles/57309/)

estimates on size, mutation rate, genome of virus

[MERS basic reproduction number](https://biomedical-engineering-online.biomedcentral.com/track/pdf/10.1186/s12938-017-0370-7)

Authors fit SIR model to data, least-square fit, they find a $$R_0$$ around 8 (!).
How did they manage to suppress MERS?

[Uri Alon: Adaptive cyclic-exit-strategies-from-lockdown](https://medium.com/@urialonw/adaptive-cyclic-exit-strategies-from-lockdown-to-suppress-covid-19-and-allow-economic-activity-4900a86b37c7)

4 day work+10 day lockdown, antiphased for 2 groups of households.
Review of deterministic, stochastic and also *network* SEIR model, different cyclic lockdown strategies.

[SEIRSPLUS: Python package for stochastic and network based SEIR model](https://github.com/ryansmcgee/seirsplus)

<div style="page-break-after: always;"></div>

## 3. Economics and politics

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

#### [M Roberts: War economy?](https://thenextrecession.wordpress.com/2020/03/30/a-war-economy/)

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

#### [Politico.eu: How Europe failed the coronavirus test](https://www.politico.eu/article/coronavirus-europe-failed-the-test/)

<!---![_config.yml]({{ site.baseurl }}/images/covid/reaction_eur_states_14978916_1586353616114.png)--->
This is a [useful table](https://images.jifo.co/14978916_1586353616114.png) on how many days it took European governments to apply restrictions after the 3rd death from COVID19.
Greece, Eastern European states did it before 3rd death, Spain 9-10 days after, UK, France 2 weeks after.

<!---!
<div class="infogram-embed" data-id="0991a8d7-ada2-4fc2-a351-f446081b8d95" data-type="interactive" data-title="3 — Comparing when coronavirus measures were implemented"></div><script>!function(e,i,n,s){var t="InfogramEmbeds",d=e.getElementsByTagName("script")[0];if(window[t]&&window[t].initialized)window[t].process&&window[t].process();else if(!e.getElementById(n)){var o=e.createElement("script");o.async=1,o.id=n,o.src="https://e.infogram.com/js/dist/embed-loader-min.js",d.parentNode.insertBefore(o,d)}}(document,0,"infogram-async");</script>
--->
