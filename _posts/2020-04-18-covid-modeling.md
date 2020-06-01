---
layout: post
title: Notes, thoughts, graphs on the COVID19 pandemic
tags: epidemics complex-systems covid19
excerpt: General properties, not predictions
mathjax: true
---

These are some notes on the COVID19 pandemic.
They include data visualization on the pandemic, comparing its evolution in different world regions, as well as exploring some general properties of compartmental dynamic transmission (SIR-type) models.  
The models below make no specific predictions, instead I am only looking at their general mathematical properties.  
Finally, I have been making notes of scientific papers and preprints that caught my attention.

## Table of contents

1. [Own stuff](#1-own-stuff)
      1. [Data visualization](#data-visualization)
      1. [SIR models](#sir-models)
1. [Notes on the literature](#2-notes-on-the-literature)
      1. [Dynamical models](#dynamical-models)
      1. [Data and reports](#data-and-reports)
      1. [Tools](#tools)

## <ins>1. Own stuff</ins>

### <ins>Data visualization</ins>

On the plots below the x-axis shows the number of cumulative reported COVID19 cases and fatalities relative to a country's population (cases/deaths per million inhabitants).  
The y-axis shows the 3-day average of the number of new cases or fatalities per one million inhabitants.
Time is implicit on these graphs, moving from left to right, and each data point is one day.  
This way one can see how much of the population is known to have contracted the virus and what is the current rate of growth per one million people. This makes the situation in different countries visually comparable.  
All data downloaded from the [Johns Hopkins University database](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series) and the graphs were made in a [Jupyter notebook](https://github.com/mbkoltai/mbkoltai.github.io/blob/master/images/covid/covid_data.ipynb).
For higher resolution see the <ins>[pdf](https://github.com/mbkoltai/mbkoltai.github.io/blob/master/images/covid/multiplot_growth_rate_deaths_popul_cutoff100_loglog.pdf)</ins> <ins>[files](https://github.com/mbkoltai/mbkoltai.github.io/blob/master/images/covid/multiplot_growth_rate_cases_popul_cutoff100_loglog.pdf)</ins>.  
I also regularly update <ins>[two](https://github.com/mbkoltai/mbkoltai.github.io/blob/master/images/covid/merged_cases_daily_incr.pdf)</ins> <ins>[plots](https://github.com/mbkoltai/mbkoltai.github.io/blob/master/images/covid/merged_deaths_daily_incr.pdf)</ins> where the daily increase in cases and fatalities are separately shown for each country in the same six world regions.


<ins>Dynamics of the number of reported cases</ins>

![_config.yml]({{ site.baseurl }}/images/covid/multiplot_growth_rate_cases_popul_cutoff100_loglog.png)

<ins>Dynamics of the number of reported fatalities</ins>

![_config.yml]({{ site.baseurl }}/images/covid/multiplot_growth_rate_deaths_popul_cutoff100_loglog.png)

It is also interesting to plot the time evolution of the (population normalized) number of fatalities and cases against each other and visualize the distance of the trajectory from the estimated case fatality ratio (I use 1%).
This suggests the scale of underestimation of case numbers, although the relationship is not straightforward as the demographics of infections, timing and quality of health care also affect the CFR; I track this <ins>[on these plots](https://github.com/mbkoltai/mbkoltai.github.io/blob/master/images/covid/merged_cases_deaths.pdf)</ins>.
With more testing the CFR could be converging the (forming) consensus estimate, I am plotting this process <ins>[here](https://github.com/mbkoltai/mbkoltai.github.io/blob/master/images/covid/merged_tests_cfr.pdf)</ins>.
Looking at the [cases/million-deaths/million scatterplot](https://github.com/mbkoltai/mbkoltai.github.io/blob/master/images/covid/cases_deaths_permillion_last_date.pdf) of countries at the most recent date we can see what countries seem to be outliers.

### <ins>SIR models</ins>


Let us start with the simplest epidemic model, ie. the SIR compartmental model, where we have:  
$$ \frac{dS(t)}{dt}{=}{-}\alpha S(t) I(t) \\
\frac{dI(t)}{dt}{=}\alpha S(t) I(t)-\beta I(t) \\
\frac{dR(t)}{dt}{=}\beta I(t)
\tag{1}\label{SIR_odes}
$$

It is more convenient and meaningful to work with fractions of a population (and not absolute numbers), so that we have the conservation $$S(t){+}I(t){+}R(t){=}1$$. Clearly, $$I(\infty){=}0$$, since this variable has first-order (linear) decay, so any nonzero value in this compartment eventually 'leaks out' into $$R$$.
Therefore the equilibrium of the system is $$(\overline{S},0,\overline{R})$$ and due to the conservation $$\overline{R}{=}1{-}\overline{S}$$. So to characterize the stationary behavior of the system all we need to calculate is
$$\overline{S}$$.

Of course this can be done by numerically integrating the ODEs in \ref{SIR_odes} and indeed half the internet is full of SIR-models now. But how about an [exact solution](http://http://mbkoltai.github.io/exastolog/)?  
In this very clear [paper in Nature Medicine](https://www.nature.com/articles/s41591-020-0883-7) (and probably others before) the authors explicitly derive the stationary solution for a more complicated model of 8 variables they abbreviate as the 'SIDARTHE' model.
Despite the apparent complexity this model is basically identical to the simple SIR model. The only difference is that 1) the $$I$$ variable is split into several sub-variables (**I**: infected, a-/presymptomatic, undetected, **D**: diagnosed (asymptomatic infected, detected); __A__: ailing (symptomatic infected, undetected); __R__: recognized (symptomatic infected, detected); __T__: threatened (infected with life-threatening symptoms, detected)) 2) the sink variable __R__ of the SIR model is split into two sinks (__H__: healed (recovered); __E__: extinct (dead)). However the $$IDART$$ 'module' (the five state variables representing different stages of infection) has the same basic property as __I__, namely that in $$t{\rightarrow}\infty$$ they decay to 0, and only __S__, __H__, __E__ can have nonzero values.

For the simple SIR model defined of \ref{SIR_odes} the solution for the stationary value of $$\overline{S}$$ is less complicated than in the latter model, ie. it is given by the implicit expression:  
$$
\frac{\alpha}{\beta} \overline{S} - log\overline{S} = \frac{\alpha}{\beta} - logS(0)
\tag{2}\label{SIR_S_stationary}
$$

This can be solved by an efficient algebraic solver such as $$fsolve$$ in MATLAB.
Let us do a parameter sweep in the $$\frac{\alpha}{\beta}$$ ratio and the initial value of $$S(0)$$, and look at the stationary solution of __R__, ie. the fraction of the population that went through infection (ie. is now immune, if there is long-term immunity). Let us also check if the algebraic formula is the same as integrating the ODEs of \ref{SIR_odes} for a long time span:
![_config.yml]({{ site.baseurl }}/images/covid/SIR_immune_pop_algebr_ode_sol.png)
*Figure 1: Stationary solutions of SIR model calculated by simulations (left) and exact calculations (right)*

Fortunately the analytical solutions from \ref{SIR_S_stationary} are identical with the numerical solutions of the ODEs, so we didn't make a mistake in \ref{SIR_S_stationary}.  
What do we see from this plot? The $$\frac{\alpha}{\beta}$$ ratio is the famous $$R_0$$, the basic reproduction parameter, and logically, the larger this ratio is, the more of the population will go through infection (again, in the framework of this extremely simplified model not meant to be realistic).
It is also intuitive that if $$S(t{=}0)$$ is smaller because of a larger initial infected population $$I(0)$$, then $$\overline{H}{+}\overline{E}$$ will be larger.

Now, let us make the model one step more refined, and split __R__ into two variables, __H__(ealed) and __E__(xtinct , ie. deceased), as:

![_config.yml]({{ site.baseurl }}/images/covid/SIHE_cropped_resiz.png)
*Figure 2: 'SIHE' version of the SIR model where __R__(recovered) is split into __H__ and __E__*

The __I__(nfected) variable now has two outcomes. It is clear intuitively that this will not change how the stationary solution of $$\overline{S}$$ is calculated, as the sink nodes do not interact with __S__, except that now __I__ has two outgoing flows, so it is the ratio $$\frac{\alpha}{\lambda{+}\tau}$$ that will define $$\overline{S}$$ as:
$$
\frac{\alpha}{\lambda{+}\tau} \overline{S} - log\overline{S} = \frac{\alpha}{\lambda{+}\tau} - logS(0)
\tag{3}\label{SIHE_statsol_S}
$$

Moreover we can give the formulas for $$\overline{H}, \overline{E}$$ as a function of $$\overline{S}$$ and the initial infected population $$I(0)$$.
It is reasonable to assume $$H(0), E(0)$$ are 0.
Downstream of __I__ the dynamics is completely linear: what flows out from __S__ into __I__ (ie. $$\Delta{S}{=}S(0){-}\overline{S}$$), as well as the initial concentration of $$I(0)$$ will be partitioned into the sink variables proportionally to the rate constants $$\lambda$$ and $$\tau$$. Specifically, we'll have:  
$$
\overline{H} = [(S(0)-\overline{S}) + I(0)] \frac{\lambda}{\lambda{+}\tau}\\
\overline{E} = [(S(0)-\overline{S}) + I(0)] \frac{\tau}{\lambda{+}\tau}  
\tag{4}\label{SIHE_statsol_H_E}
$$   

The ratio $$\frac{\tau}{\lambda{+}\tau}$$ is the infection fatality (IFR) rate.
It is clear from \ref{SIHE_statsol_S} that the IFR does not affect $$\overline{S}$$ if the sum $$\lambda{+}\tau$$ is kept constant, it is instead the ratio of $$\alpha$$ (rate constant of new infections) to these two parameters that determine at what level of total infections the epidemic stops.
To check if the formulas are correct, let us again compare the exact solution to the numerical solution of the ODEs, and plot the stationary solutions of $$\overline{S}, $$ at different IFR values:
![_config.yml]({{ site.baseurl }}/images/covid/SIHE_algebr_ode_IFRscan.png)
*Figure 3: stationary solutions of SIHE model at S(0)=0.99 and four different values of the IFR*

Circles show the results from numerical integration of the ODEs, confirming they are identical with the analytical solutions (lines). The fraction of the population that has not been infected throughout the epidemic ($$\overline{S}$$) goes down with $$\frac{\alpha}{\lambda{+}\tau}$$, but is independent of the IFR as the sum $${\lambda{+}\tau}$$ was kept constant here. The ratio $$\frac{\alpha}{\lambda{+}\tau}$$ expresses how fast subjects exit the infectious state relative to the rate constant of generating new infections. A higher ratio means more of the population is infected, which is $$\overline{H}+\overline{E}=(S(0){-}\overline{S}){+}I(0)$$.
In contrast, if both $$\alpha$$ and $$\lambda{+}\tau$$ are equally scaled then this quantity does not change.  
How the infected fraction of the population is partitioned between the two sink states ($$\overline{H}, \overline{E}$$) obviously depends on the IFR (note the logarithmic scale), as stated in \ref{SIHE_statsol_S}.
Note that while the IFR is 'hard-wired' in the parameter ratio $$\frac{\tau}{\tau+\lambda}$$, how much of the population gets infected and dies depends on $$\overline{S}$$ and therefore $$\alpha$$, the rate constant for transmission. This is where physical distancing measures would intervene to choke off the flow $${S}\rightarrow{I}$$.  

Let us go now one step further and allow for a pre-symptomatic state, defining __I__ as a variable of the infectious but pre-symptomatic state and adding a variable __A__(iling) that is the infectious and symptomatic state. Now the compartments of this '_SIAHE_' model and the flows between them are:

![_config.yml]({{ site.baseurl }}/images/covid/SIAHE_res.jpeg)
*Figure 4: 'SIAHE' SIR model with presymptomatic (__I__) and symptomatic (__A__) infectious state and two outcomes*

By highlighting the $${S}\rightarrow{I}$$ flow in red I want to indicate that this is the (only) nonlinear term, and now this flow has two parameters as the ODE for __S__ is:  
$$
\frac{dS(t)}{dt} = -S(t)(\alpha I(t) + \gamma A(t))
$$

These two bilinear terms are positive feedbacks on the otherwise linear system. If it wasn't for these terms the system would have an equilibrium where only the [terminal vertices](http://vcp.med.harvard.edu/papers/jg-lap-dyn.pdf) ($$H, E$$) of its graph can have nonzero value, just like with the equilibrium we have for the [state transition graph of a stochastic Boolean model](https://mbkoltai.github.io/exastolog).
Because of this nonlinear feedback however __S__ can (and usually does) also have a nonzero value in steady state, so the equilibrium of SIAHE is $$(\overline{S},0,0,\overline{H},\overline{E})$$.

Let us again get the formula for $$\overline{S}$$. Ff we have this, the rest of the system has linear kinetics, so the stationary values of __H__ and __E__ will follow easily from the kinetic matrix of the IAHE variables. I follow here the derivation from the Nature Medicine article, except that it is for a simpler (5 variables) model.

We need to introduce some notation:  
$$
x(t){=}\begin{bmatrix} I(t) \\ A(t) \end{bmatrix},
c{=}\begin{bmatrix} \alpha \\ \gamma \\ \end{bmatrix},
b{=}\begin{bmatrix} 1 \\ 0 \end{bmatrix},
F{=}\begin{bmatrix} -(\lambda{+}\zeta)&{0}\\{\zeta}& -(\kappa{+}\tau) \end{bmatrix}
$$

Then the ODE for $$I(t)$$ and $$A(t)$$ is:  
$$
\dot{x(t)}{=}F x(t) + b c^T x(t) S(t)
$$

Since $$\dot{S}(t){=}-c^T x(t) S(t)$$ we can substitute this in and get:    
$$
\dot{x(t)}{=}F x(t) - b  \dot{S}(t)
$$

Then integrating (and changing $$t$$ to $$\phi$$), for the left side:  
$$
\int_0^\infty \dot{x}(\phi) d\phi = x(\infty){-}x(0){=}-x(0)
$$

...and on the right hand side we have:  
$$
F\int_0^\infty x(\phi) d\phi - b \int_0^\infty \dot{S}(\phi) =
F\int_0^\infty x(\phi) d\phi - b(\overline{S}-S(0))
$$

so then we have:  
$$
-x(0){=}F\int_0^\infty x(\phi) d\phi - b(\overline{S}-S(0))
$$

Now if we pre-multiply by $$c^T F^{-1}$$ (a [1x2] vector) to get rid of F and to turn both sides into scalars we get:  
$$
-c^T F^{-1} x(0) =\int_0^\infty c^T x(\phi) d\phi - c^T F^{-1} b(\overline{S}-S(0))
$$

From the ODE of $$\dot{S}$$ we can substitute $$\frac{\dot{S(t)}}{S(t)}$$ into $$c^T x(t)$$:  
$$
-c^T F^{-1} x(0){=} - \int_0^\infty \frac{\dot{S}(\phi)}{S(\phi)} d\phi - c^T F^{-1} b(\overline{S}-S(0)) = log \frac{S(0)}{\overline{S}} - c^T F^{-1} b(\overline{S}-S(0))
$$

Then after a rearrangement we have the solution for $$\overline{S}$$ in the same form as for the '_SIHE_' model in \ref{SIHE_statsol_S}:  
$$
-c^T F^{-1}b \overline{S} - log \overline{S} = -c^T F^{-1}b S(0) - log S(0) + c^T F^{-1} x(0)
$$

$$-c^T F^{-1} b$$ is the $$R_0$$ of this version of the model, so rewriting with $$R_0$$:  
$$
R_0 \overline{S}- log \overline{S} = R_0 S(0) - log S(0) + c^T F^{-1} x(0)
\tag{5}
\label{SIAHE_S_statsol_R0}
$$

Explicitly, $$R_0$$ is:  
$$
R_0{=}\frac{\alpha}{\lambda+\zeta}{+}\frac{\zeta \gamma}{(\kappa+\tau)(\lambda+\zeta)}
$$

$$R_0$$ is linearly increasing in the contagion rates $$\alpha$$ and $$\gamma$$, while decreasing in the rate constants of the outgoing flows of __I__ and __A__, ie. $$\kappa, \tau, \lambda$$.
$$\zeta$$ has a more complicated effect as it decreases the first term, but increases the second. This makes sense too, since this is the rate constant _between_ the two contagious states __I__ and __A__.    

(to be continued...in progress)

## <ins>2. Notes on the literature</ins>

### <ins>Dynamical models</ins>

#### [School closures, event cancellations, and the mesoscopic localization of epidemics in networks with higher-order structure](https://arxiv.org/pdf/2003.05924.pdf)
Higher-order struct leads to mesoscopic localization (concentration into substructures).  
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

#### [The Contribution of Pre-symptomatic Transmission to the COVID-19 Outbreak](https://cmmid.github.io/topics/covid19/control-measures/pre-symptomatic-transmission.html)  
Estimates that ~25% of transmission in Shenzhen was asymptomatic.

#### [Temporal variation in transmission during the COVID-19 outbreak in Italy](https://cmmid.github.io/topics/covid19/current-patterns-transmission/italy-time-varying-transmission.html)
Estimates on reproduction numbers in regions of Italy. Started from 3-4, falling towards 2.

#### [Substantial undocumented infection facilitates the rapid dissemination of novel coronavirus (SCIENCE, 16 March)](https://science.sciencemag.org/content/sci/early/2020/03/13/science.abb3221.full.pdf)

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

<!---
#### [Wolfram Mathematica notebook on epidemic modeling](https://community.wolfram.com/groups/-/m/t/1896178)
https://www.twitch.tv/videos/569280246

#### [NECSI Slack channel for modeling](https://app.slack.com/client/T2DRR8UNB/CV19X1PKJ/thread/CUTSF2Q6R-1584495843.398200)
--->

#### [Imperial: Impact of non-pharmaceutical interventions (NPIs) to reduce COVID19 mortality and healthcare demand (16 March)](https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf)

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
They disagree w Ferguson claim that 2nd outbreak unavoidable, because (according to NECSI) during lockdown infectious ppl can be identified and their contacts isolated.
Ferguson calculate new infections as fcn of infected % and immunity, but not the phase of trajectory (ergodicity).
Not true that resurgence starts from even 1 case, China data showed *only 5% of close contacts of infected tested positive*. Small outbreaks can be controlled by testing.
Ferguson ignores super-spreader events by ignoring 'fat tail distribution of contagion'.
But cutting off fat tail by banning events reduced $$R_0$$.
Ferguson use SIR ODE-model, not appropriate bc it ignores:
- local dynamics
- non-normal distrib. of infection events per person (superspreaders)
- dynamic or stochastic values for parameters (social response)

But Imperial model has different environments and it is agent-based, so maybe this is not fair.
Debate on this on [Twitter](https://twitter.com/yaneerbaryam/status/1239936951823843328).

#### [Beyond contact tracing: Community-based early detection for Ebola response, PLoS Currents Outbreaks (2016)](https://necsi.edu/beyond-contact-tracing)

Stochastic model by NECSI.

#### [NECSI Working Paper: Eliminating COVID-19. A Community-based Analysis (19 March)](https://static1.squarespace.com/static/5b68a4e4a2772c2a206180a1/t/5e737b95403f772d8ce0e04a/1584626591711/CommunityPrevention.pdf)

NECSI probabilistic model. $$R_*$$: community transmission rate.
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

#### [Social Contacts and Mixing Patterns Relevant to the Spread of Infectious Diseases (PLoS Medicine, 2008)](https://journals.plos.org/plosmedicine/article?id=10.1371/journal.pmed.0050074)

Estimates for mixing patterns.

#### [An investigation of transmission control measures during the first 50 days of the COVID-19 epidemic in China (Science, 31 Mar)](https://science.sciencemag.org/content/early/2020/03/30/science.abb6105)

Effect of Wuhan travel ban. Cities as variables in a SIR-like model, estimates on travel flows.

#### [MERS basic reproduction number (BioMed Eng OnLine (2017) 16:79)](https://biomedical-engineering-online.biomedcentral.com/track/pdf/10.1186/s12938-017-0370-7)

Authors fit SIR model to data, least-square fit, they find a $$R_0$$ around 8 (!).
How did they manage to suppress MERS?

#### [Uri Alon: Adaptive cyclic exit strategies from lockdown (Medium post on preprint, 7 April)](https://medium.com/@urialonw/adaptive-cyclic-exit-strategies-from-lockdown-to-suppress-covid-19-and-allow-economic-activity-4900a86b37c7)

4 day work+10 day lockdown, antiphased for 2 groups of households.
Review of deterministic, stochastic and also *network* SEIR model, different cyclic lockdown strategies.

Antiphasing (staggering) uses the timeline of the disease and infectiousness:
![_config.yml](https://miro.medium.com/max/770/0*MWxESwBV56QMF9rc)

#### [Imperial: Report 12: The Global Impact of COVID-19 and Strategies for Mitigation and Suppression (26 March 2020)](https://www.imperial.ac.uk/media/imperial-college/medicine/mrc-gida/2020-03-26-COVID19-Report-12.pdf)

Global estimates:
- *without intervention*: 7 billion infections and 40 millon deaths in 2020
- *mitigation*: with 60% reduction of social contacts, 20 million deaths avoided, all health care systems overwhelmed, in low income setting by factor of 25.
- *suppression*: 30-39 million deaths can be avoided (compared to no intervention strategy), depending on timing

Household size/structure is critical, differences result in different *attack rates* by age groups. Number of hospital beds/1000 population from [World Bank](https://data.worldbank.org/indicator?tab=all).
Estimates for 3 strategies of unmitigated, mitigation, mitigation+enhanced social distancing for elderly:
- hospitalisation rate: $$\sim$$ 3%, 2%, 2% (esimates for difference world regions on Fig 4).
- critical care: 1%, 0.5%, 0.2%
- deaths: 0.6-0.8%, 0.4%, 0.2%

'Despite higher rates of contact across older age-groups, we predict a lower incidence of severe
disease, hospitalisation and deaths in lower income settings. This is driven by the younger average age
of these populations.' (Figure 5)

Simulations for countries in different income groups: how ICU capacity would be exceeded under different suppression strategies and mitigation (Figure 6).
Table 1 summarizes estimates by regions. Two suppression scenarios with 0.2 and 1.6 deaths/100K population/week.
Unmitigated (world, total): 40M deaths, 1.9M deaths with suppression with trigger 0.2/100K pop/week, 10.4M with suppression with trigger 1.6/100K pop/week. Difference $$\sim$$ 5-fold between two suppression strategies in most regions.

Model is age-structured SIR-model incorporating demographic structure and rates of contact. Comorbidities not taken into account. Full model stochastic age-structured SEIR model.

Excel spreadsheet with results [available online](https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-Global-unmitigated-mitigated-suppression-scenarios.xlsx).
[Covid-data used by Imperial models (cited by other publication)](https://zenodo.org/record/3730771#.XptEtZ9fir4)

<!---
```python
from scipy.integrate import odeint
import numpy as np
import matplotlib.pyplot as plt
%matplotlib inline
!pip install mpld3
import mpld3
mpld3.enable_notebook()
```
--->

#### [Macroeconomics of epidemics](https://www.kellogg.northwestern.edu/faculty/rebelo/htm/epidemics.pdf)

Interaction terms between economic variables and epidemiological ones are via consumption and work hour variables:
- consumption: $$\pi_1(S_t C_t^S) (I_t C_t^I)$$, $$C_t$$ consumption spending
- work: $$\pi_2(S_t N_t^S) (I_t N_t^I)$$, $$N_t$$ is work hours
and a general term $$\pi_3 S_t I_t$$

Newly infected: $$T_t$$, therefore susceptibles: $$S_{t+1}=S_t - T_t$$.  
Number of infected: $$I_{t+1}=I_t + T_t - (\pi_r + \pi_d) I_t $$  
Zoonotic introduction of virus into population: $$I_0{=}\epsilon,\ S_0{=}1{-}\epsilon$$  

How do the epidemiological variables affect the economic ones?
Pre-epidemic, the population is made up of identical agents optimizing the utility function:
$$u(c_t,n_t)=ln(c_t) - \frac{\phi}{2} n_t^2$$  

Following the outbreak we have the modified version of this utility function per compartments:
$$U_t^j$$: 'lifetime utility' of agent $$j$$ ($$j=s,i,r$$).

Agents have the budget constraint: $$(1+\mu_t)c_t^j=w_t \phi^j n_t^j + \Gamma_t$$
with $$\mu_t$$ tax on consumption, $$w_t$$ real wage, $$\phi^j$$ labour productivity, $$\phi^j=1$$ for $$j=s,r$$ and $$\phi^j{=}1$$ for $$j{=}I$$.

'Lifetime utility' functions for compartments (subpopulations):
- S (susceptible): $$U^s_t=u(c_t,n_t) + \beta [(1-\tau_t)U^s_{t+1} + \tau_t U^i_{t+1} ]$$, where $$\tau_t$$ is the probability that a susceptible person gets infected. This probability linearly increases with consumption and work, and the utilities of being susceptible or infected in next time step are inversely and proportionally scaled with $$\tau_t$$.
- $$U^i_t$$: Similar lifetime utility function for infected people, but dependence only on recovery and death rates.

First order conditions (first derivative equals 0) for consumption, work hours, $$\tau_t$$ calculated with Lagrange multipliers. Market clearing equilibrium for goods and labor, balanced gov. budget assumed (clearly not technically true, is this important?).  

To model healthcare collapse, quadratic dependence of mortality rate on total number of infected.
Treatment option introduces another parameter ($$\delta_c$$) from infected to recovered, this is probability of a cure discovered in a time period.
Vaccine similarly modeled in utility function of susceptibles.

Mapping epidem. parameters from Ferguson (2006) onto model parameters: approx. 1/3, 1/3, 1/3 transmission in household, general community, schools and workplaces. From BLS Time Use Survey authors estimate % of time in buying things, eating outside, this gives estimate for consumption-related transmission.  
Number of students and workers multiplied by estimates of contacts in those environments. This gives estimate for workplace transmission.
Labor productivity for infected people set to 80%, assuming 80% is asymptomatic (?) and those with symptoms do not work.  
Peak of newly infected fraction of the population approximately 7% in the SIR (no utility functions) model.  
In the SIR-Macro model infection impacts the economy by 1) reducing size of workforce 2) through the utility functions, households reduce their consumption and work hours. In turn, their reduced consumption/work decreases the probability of getting infected. Peak of infected lower (5%) at occurs later.
Recession is much more severe due to reduced consumption/work. If mortality rate depends on healthcare being overwhelmed, households absorb this effect via utility function by reducing their economic activity, exacerbating recession.
Vaccine or effective drugs have opposite effect, households cut back less.

Containment measures are modeled as a tax on consumption. Optimization is done on how containment measures are introduced in time.
The model assumes that infections cannot be completely suppressed if no vaccine, until population immunity achieved. Therefore early strong containment has high economic cost but followed still by an outbreak. In this framework containment should be escalated gradually as $$I$$ grows. But China, Korea seems to show that suppression is possible. Costs of containment policies referred to as 'Ramsey problem': costs vs. maximizing social welfare.

A 'smart containment' scenario is also modeled where it is assumed that planners know the health status of everyone and can maximimize overall social utility by blocking all infected from working. In this case there is no cost to containment, but this requires perfect knowledge. Ie. huge social returns on testing.

#### [Modeling the impact of social distancing, testing, contact tracing and household quarantine on second-wave scenarios of the COVID-19 epidemic (Vespignani)](https://cosnet.bifi.es/wp-content/uploads/2020/05/main.pdf)

Agent based model of Boston area, 85K agents (64K adults, 21K children). Compartments distinguish between asymptomatic and symptomatic.
Different reopening scenarios varying in testing and tracing efficiency, calculating peak incidences.
Data is from 6 months of anonymized survey.
Interactions modeled as a contact network with weights proportional to amount of time (normalised by total observation time) two agents spent in same location. 83K locations are defined (from Foursquare).
Weights within households (inversely) proportional to size of household.
Public space, schools, households three layers.

<!---###############################################################################################################################--->
<!---###############################################################################################################################--->

### <ins>Tools</ins>

#### [Interactive modeling (Shiny app)](https://alhill.shinyapps.io/COVID19seir/)  
This is an ODE model assuming complete homogeneity. Three **I** populations with different rates of transmission.

#### [Shiny app of SIR model (Digital contact tracing for SARS-CoV-2)](https://bdi-pathogens.shinyapps.io/covid-19-transmission-routes)

Adjustable parameters, generates graphs interactively.

#### [SEIRSPLUS: Python package for stochastic and network based SEIR model](https://github.com/ryansmcgee/seirsplus)

Python package to set up epidemiological models easily, used in Uri Alon study.

#### [SocialmixR R package has survey data on mixing patterns](https://github.com/sbfnk/socialmixr).

Survey on France mixing patterns in [PloS ONE 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0133203).


<!---##############################################################################################################################--->
<!---##############################################################################################################################--->
<!---##############################################################################################################################--->

### <ins>Data and reports</ins>

#### [Secondary attack rate and super-spreading events for SARS-CoV-2 (Lancet, 27 Febr)](https://www.thelancet.com/action/showPdf?pii=S0140-6736%2820%2930462-1)
Estimates for some 'super-spreader' events in table.

#### [Epidemiological data from the COVID-19 outbreak, real-time case information](https://www.nature.com/articles/s41597-020-0448-0.pdf)

#### [Fundamental principles of epidemic spread highlight the immediate need for large-scale serological surveys to assess the stage of the SARS-CoV-2 epidemic](https://www.medrxiv.org/content/10.1101/2020.03.24.20042291v1)

#### [Testing everyone instead of contact tracing (Sten Linnarsson, Karolinska)](https://medium.com/@sten.linnarsson/to-stop-covid-19-test-everyone-373fd80eb03b)

Medium note on a preprint.
If $$c\ p > (R_0-1)/(R_0-R_q)$$, then exponential decay of outbreak. $$R_0$$ ~ 2.4, $$R_q$$ ~ 0.3 (Wuhan estimate).
c: compliance to self-quarantine after testing positive  
p: true positive rate

Fastest test currently: RT-LAMP technology, 10-30 mins, based on RNA detection. Polymerase with reverse transcriptase activity amplifies viral RNA ---> H+ release ---> pH sensitive dye.
But: it requires 65C incubation (tap water?).
Alternatives:
- rolling circle replication
- in vitro viral replication assays

Lockdown cost dwarfs testing cost.

#### [NN Taleb: Tail Risk of Contagious Diseases](https://www.researchers.one/media/documents/282-m-corona2.pdf)

#### [Why everyone should wear a mask](https://medium.com/@Cancerwarrior/covid-19-why-we-should-all-wear-masks-there-is-new-scientific-rationale-280e08ceee71)

#### [Estimates of the severity of coronavirus disease 2019: a model-based analysis (Lancet, 30 March)](https://www.thelancet.com/journals/laninf/article/PIIS1473-3099(20)30243-7/fulltext)

Estimates on CFR and IFR from Hubei and China in general.

#### [IHME (Institute for Health Metrics and Evaluation) predictions about peaks](http://www.healthdata.org/covid/updates)
Preds made 05 April are for France 15K deaths by August, UK 66K.
This was revised upwards to France (22.5K) and downwards for UK (37.5K).

#### [Preparedness and vulnerability of African countries against importations of COVID-19: a modelling study](https://www.thelancet.com/action/showPdf?pii=S0140-6736%2820%2930411-6)

Importation risk from China vs health care system capacity

#### [Ron Milo: COVID by the numbers (eLife, updated paper)](https://elifesciences.org/articles/57309/)

Estimates on size, mutation rate, genome of virus.
Nucleotide identity with other coronaviruses:
- bat CoV: 96%
- pangolin CoV: 91%
- SARS-CoV-1: 80%
- MERS: 55%
- common cold CoV: 50%

#### [The early phase of the COVID-19 outbreak in Lombardy, Italy (20 Mar, arXiv)](https://arxiv.org/abs/2003.09320)

Early estimates on epidemic in Lombardy (hospitalisation, intensive care, deaths), arguing for aggressive containment strategies.

#### [Tomas Pueyo: The hammer and the dance (Medium, 19 March)](https://medium.com/@tomaspueyo/coronavirus-the-hammer-and-the-dance-be9337092b56)

Uses simple SIR model to argue why suppression is needed, as mitigation leads to enormous death toll (some estimates on side-effects).
Suppression buys time for producing equipment, maybe drugs.
Not original research, but summarizes Imperial's 16 March study.

#### [Cluster of COVID-19 in northern France: A retrospective closed cohort study](https://www.medrxiv.org/content/10.1101/2020.04.18.20071134v1.full.pdf)

Oise heavily exposed to SARS-CoV-2. Infection attack rate (IAR) from antibody detection.
171/661 had antibodies, **26% IAR**, 0% IFR (fatality). Hospitalisation rate 5%.
Anosmia (smell blindness) and ageusia (loss of taste) good predictors of infection.
IAR for smokers 7% vs. 28% (smoking: 75% decrease in risk of infection). Asymptomatic infections 17%.
High school: 41% IAR, among parents only 10%. 661 participants in total. Median age 37, 38% male. 40% age 15-17, only 2 people over 65. Secondary IAR in households 10-11% (both for parents and siblings). In Shenzhen similar study found 15%.
ELISA antibody tests were also made on blood samples of blood donors in the area, 3% IAR.
Oise was one of the early epicenters of the epidemic in France and these numbers are results of period before lockdown. Low prevalence numbers suggest herd immunity cannot be quickly established.

#### [Animal passage experiments and possibility of accidental escape](https://www.newsweek.com/controversial-wuhan-lab-experiments-that-may-have-started-coronavirus-pandemic-1500503)

Description of animal passage experiments (with ferrets) since 2011. PREDICT program. No evidence of such experiments in Wuhan lab.
