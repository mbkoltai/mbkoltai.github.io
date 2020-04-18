---
layout: post
title: Notes on modeling the COVID19 pandemic
tags: epidemics complex-systems covid19
excerpt: Math modeling the pandemic
mathjax: true
---

These are notes on the science (mostly epidemiological modeling) of the COVID19 pandemic. As of early April (9th of April) the notes are rather messy, I plan to clean them up with time.


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

#### [The hammer and the dance](https://medium.com/@tomaspueyo/coronavirus-the-hammer-and-the-dance-be9337092b56)

Uses simple SIR model to argue why suppression is needed, as mitigation leads to enormous death toll (some estimates on side-effects).
Suppression buys time for producing equipment, maybe drugs.

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

#### [Ron Milo: COVID by the numbers](https://elifesciences.org/articles/57309/)

Estimates on size, mutation rate, genome of virus.
Nucleotide identity with other coronaviruses:
- bat CoV: 96%
- pangolin CoV: 91%
- SARS-CoV-1: 80%
- MERS: 55%
- common cold CoV: 50%

[MERS basic reproduction number](https://biomedical-engineering-online.biomedcentral.com/track/pdf/10.1186/s12938-017-0370-7)

Authors fit SIR model to data, least-square fit, they find a $$R_0$$ around 8 (!).
How did they manage to suppress MERS?

[Uri Alon: Adaptive cyclic-exit-strategies-from-lockdown](https://medium.com/@urialonw/adaptive-cyclic-exit-strategies-from-lockdown-to-suppress-covid-19-and-allow-economic-activity-4900a86b37c7)

4 day work+10 day lockdown, antiphased for 2 groups of households.
Review of deterministic, stochastic and also *network* SEIR model, different cyclic lockdown strategies.

Antiphasing (staggering) uses the timeline of the disease and infectiousness:
![_config.yml](https://miro.medium.com/max/770/0*MWxESwBV56QMF9rc)

[SEIRSPLUS: Python package for stochastic and network based SEIR model](https://github.com/ryansmcgee/seirsplus)

Python package to set up epidemiologic models easily, used in Uri Alon study.
