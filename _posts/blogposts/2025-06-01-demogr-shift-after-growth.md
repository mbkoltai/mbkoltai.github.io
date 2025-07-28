---
layout: post
title: Age distributions of growing, shrinking and stable populations
tags: demographics data-visualisation ecology growth population
excerpt: The three basic demographic shapes
secondary: blogposts
mathjax: true
---

Here's a quick model exploring how population aging behaves after a fertility shock.


<!-- 
```r
ages <- seq(0, 100, by = 1)
pop <- exp(-0.05 * ages)
``` -->
<!-- $$ \frac{d\vec{x}}{dt} = \vec{b} + (K_{\text{age}} - K_{\text{death}}) \vec{x} $$ -->

## Constant birth rate

<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \frac{d\vec{x}}{dt} = \vec{b} + (K_{\text{age}} - K_{\text{death}})\vec{x} \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (1) </div>
</div>


$$\vec{b}$$ is a column vector with the first entry the number of births per time unit (eg. year), and its other (n-1) entries 0s.
$$K_{age}$$ is the ageing matrix that contains the coefficient of ageing parameters in its diagonal (times minus one) standing for people moving out of their age group, and the same coefficients in the subdiagonal below, representing ageing into each group from the adjacent younger group. The ageing coefficient equals the inverse of the time unit used in the equations.
$$K_{death}$$ is a diagonal matrix containing the mortality coefficients (deaths per capita per time unit of the equations). All coefficients need to be positive to be physically meaningful (though death rates can be practically zero in some age groups).

This is a first-order, nonhomogeneous linear system and it will have a stable solution. 
After some basic rearrangement, the steady state solution is:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \bar{x} = - (K_{\text{age}} - K_{\text{death}})^{-1} \vec{b}  \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (2) </div>
</div>

and for a given age group $$j$$, and for yearly time resolution ($$a=1$$):
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \bar{x}_j = \frac{b}{a} \frac{1}{\prod_{k=1}^{j} (1+d_k/a) } = \frac{b}{\prod_{i=1}^{j} (1+d_k) } \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (3) </div>
</div>


Deaths shrink any cohort as they move through life, and since the coefficients are positive, with increasing age ($$j$$) the size of the age groups will shrink exponentially. Actually, death rates themselves increase with age (after early childhood) in an approximately exponential fashion:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ log(d_k) \sim \gamma_1 + \gamma_2 k \] 
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (4) </div>
</div>

In fact the age-dependent mortality rate looks like this in high-income countries (this is for France in 2022): 
<div style="text-align: center;">
<figure style="display:inline-block;border:1px solid #888; padding:8px; border-radius:1px; text-align:center; background-color:#ddd;">
<a href="{{site.baseurl}}/images/demogr_stable_pop/mort_rate_approx.png">
<img src="{{site.baseurl}}/images/demogr_stable_pop/mort_rate_approx.png" alt="_config.yml" style="width: 700px;" />
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 700px;"> <strong>Figure 1</strong> Age-dependent mortality rates (estimates and inter- and extra-polation)</figcaption>
  </figure>
</div>

Nevertheless, the rates are very low in the early childhood groups as well, so we can approximate the mortality rate as 
$$log(d_k) \approx -11.2 + 0.1 k$$ and the stationary solution as:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \bar{x}_j = \frac{b}{\prod_{k=1}^{j} (1+d_k)} \approx \frac{b}{\prod_{k=1}^{j} (1+exp(\gamma_1+\gamma_2 k))} \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (5) </div>
</div>

which shows that the stationary age distribution will decay _super_-exponentially with age, because exponentially growing terms (death rates) are exponentiated in the denominator.

Let us compare this approximation with the full solution:

<div style="text-align: center;">
<figure style="display:inline-block;border:1px solid #888; padding:8px; border-radius:1px; text-align:center; background-color:#ddd;">
<a href="{{site.baseurl}}/images/demogr_stable_pop/constant_birth_age_struct_exact_approx.png">
<img src="{{site.baseurl}}/images/demogr_stable_pop/constant_birth_age_struct_exact_approx.png" alt="_config.yml" style="width:900px;"/>
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 700px;"> <strong>Figure 2</strong> Exact and approximate (red line) solutions of the stationary age distribution</figcaption>
  </figure>
</div>

and we find that it works remarkably well, even with a rough linear fit estimated by eye from Fig. 1. In reality, the size of the age groups in the first decades are almost constant, because death rates are so low, so the cohorts are moving through time undiminished. Mathematically this is expressed by the term within the exponential being strongly negative, so the exponential is near zero, and therefore we are exponentiating $$\approx 1$$. From the age of 50 the size starts to shrink and this then accelerates, resulting in super-exponential decay.

For any positive birth and death rates this formulation will eventually reach a positive steady state. In fact, the number of births will only scale the whole population size, but for a given vector of death rates the age _distribution_, the _relative_ size of the age groups will be identical. 

The issue with this description is that in reality the birth rate is not a constant, but itself a function of population dynamics, through the number of women of child-bearing age and their fertility rate, ie. the number of children they will have. With fewer births there will be fewer women who can give birth, resulting in yet fewer births and so on - a positive feedback loop. Let's include this in the model as the next step.

## Dynamic birth rates

This positive feedback loop makes the solution more complicated.
We know that women on average should have roughly 2 children plus a bit more to compensate for mortality before reaching child-bearing age. But how does this work out mathematically?

If the number of births is not a constant, but a (linear) function of (some) state variables, this makes the system homogenous:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \frac{d\vec{x}(t)}{dt} = (K_{\text{age}} - K_{\text{death}} + K_{\text{birth}})\vec{x}(t) = A \vec{x}(t) \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (6) </div>
</div>

The matrix of births will be all zeros, except in the first row for those columns that correspond to the child-bearing cohorts, where we will have the fertility rates per time unit (eg. per one year).
Summing up the three matrices, the full ageing-births-deaths matrix $$A$$ will look like this:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
$$
\begin{bmatrix}
-(1+\delta_1) & 0 & \cdots & r_k & \cdots & r_l & 0 \\
1 & -(1+\delta_2) & 0 & \cdots & \cdots & 0 & 0  \\
0 & 1 & -(1+\delta_3) & \cdots & \cdots & 0 & 0  \\
\vdots & \ddots & \ddots & \ddots & \cdots & \vdots & \vdots \\
0 & \cdots & \cdots & 0 & 1 & -(1+\delta_{n-1}) & 0  \\
0 & \cdots & \cdots & \cdots & 0 & 1 & -(1+\delta_n) 
\end{bmatrix}
$$
</div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (7) </div>
</div>

To get the equlibrium condition, we need to distinguish the first age group from the rest. All other age groups have an inflow from the upstream (one year younger) group, and an outflow due to ageing and deaths:
\[  \frac{dx_j(t)}{dt} = x_{j-1} - (1+\delta_j) x_j(t) \text{, for j>1} \]
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \frac{dx_j(t)}{dt} = x_{j-1} - (1+\delta_j) x_j(t) \text{, for j>1} \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (8) </div>
</div>


all $$j>1$$ age groups can be expressed as a function of the first age group, and the equlibrium condition is:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[  \bar{x}_j = \frac {\bar{x}_{j-1}}{1+\delta_j} = 
    \frac{\bar{x}_{1}}{\prod_{i=1}^{j}(1+\delta_i)}
    \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (9) </div>
</div>

The first (newborn) age group is different, because it has a net inflow that is proportional to the size of all the child-bearing groups (groups _k_ to _l_):
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[\frac{dx_1}{dt} = r (x_k + ... + x_l) - x_1(t) \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (10) </div>
</div>

and in equilibrium, using the previous equation expressing every ($j>1$) age group as a function of the first one:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \bar{x}_1 = \sum_{j=k}^{l} r_j \frac{\bar{x}_{1}}{\prod_{i=1}^{j}(1+\delta_i)} \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (11) </div>
</div>

Since $$\bar{x}_1$$ is on both side, it cancels out, and the equlibrium condition is defined as between parameters only:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ 1 = \sum_{j=k}^{l} \frac{r_j}{\prod_{i=1}^{j}(1+\delta_i)} \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (12) </div>
</div>

Assuming that the fertility rate is uniform across the child-bearing cohort will then simplify the formula to:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \frac{1} {r} = \sum_{j=k}^{l} \frac{1} {\prod_{i=1}^{j}(1+\delta_i)} \] 
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (13) </div>
</div>

Which shows how the fertility rate must balance against mortality rates from newborns to the upper limit of the childbearing cohort ($$l$$). Since this is the fertility rate per person, but in reality of course it is only women who give birth, the per woman equilibrium fertility rate will be roughly the double of this value (1/proportion of woman).

Using the same mortality rates as above (France, 2022) we calculate that r needs to be approximately 0.0507 to have a stable population. Assuming a 50-50 gender split, this means that if the childbearing cohort corresponds the 20-40 age band, there would need to be approximately 0.1015 births per person (woman) per year, or 2.03 though life to counterbalance the mortality rates.

We can then calculate the stable age distribution in a number of ways. One is to solve the ODE system numerically. Second, we can use matrix exponentiation and the initial conditions:
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \bar{x} = exp(A t) \cdot \bar{x}(0)  \] 
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (14) </div>
</div>

Alternatively, there is an [eigenvector calculation method](https://pubmed.ncbi.nlm.nih.gov/24018536/) derived for chemical kinetics (which I also used [previously](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-020-03548-9) in yet another context).
Here, we calculate the left ($$L \in \mathbb{R}^{1 \times n}$$) and right ($$R \in \mathbb{R}^{n \times 1}$$) eigenvectors and take those that have zero eigenvalue. For this system, there will only be one of each. Then we need to scale the eigenvectors so that the normalisation condition $$L \cdot R = 1$$ applies.
Following this we can get the stationary solution as 
<div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    \[ \bar{x} = (R \cdot L) \cdot \bar{x}(0) \]
  </div> <div style="background-color: #cccccc; padding: 6px 10px; border-radius: 4px; font-size: 0.9em;"> (15) </div>
</div>

These three calculation methods yield identical results:
<div style="text-align: center;">
<figure style="display:inline-block;border:1px solid #888; padding:8px; border-radius:1px; text-align:center; background-color:#ddd;">
<a href="{{site.baseurl}}/images/demogr_stable_pop/dyn_birth_age_struct_3sols.png">
<img src="{{site.baseurl}}/images/demogr_stable_pop/dyn_birth_age_struct_3sols.png" alt="_config.yml" style="width: 700px;" />
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 700px;"> <strong>Figure 3</strong> Stable age distributions for model with dynamic births. Colored lines correspond to three calculation method. The thinner back line is the age distribution from the model with constant births.</figcaption>
</figure>
</div>

moreover, the age distribution is the same as for the model with constant birth rate (black line).

The two models behave differently with regard to how initial conditions affect the stable population size. 
The simpler model with **constant** births always converges to the same stationary solution _both_ in terms of (total) population size and age distribution:
<div style="text-align: center;">
<figure style="display:inline-block;border:1px solid #888; padding:8px; border-radius:1px; text-align:center; background-color:#ddd;">
<a href="{{site.baseurl}}/images/demogr_stable_pop/const_birth_dyn_init_cond.png">
<img src="{{site.baseurl}}/images/demogr_stable_pop/const_birth_dyn_init_cond.png" alt="_config.yml" style="width: 700px;" />
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 700px;"> <strong>Figure 4</strong> Convergence to stable population size and age distribution from different initial conditions with <strong>constant</strong> birth level. The age group sizes at the initial condition are an exponential function of age.</figcaption>
</figure>
</div>

If births are **dynamic** then diffrent initial conditions result in different stable population sizes, but the age *distribution* (proportions of the total by age) will still be the same:
<div style="text-align: center;">
<figure style="display:inline-block;border:1px solid #888; padding:8px; border-radius:1px; text-align:center; background-color:#ddd;">
<a href="{{site.baseurl}}/images/demogr_stable_pop/dyn_birth_dyn_init_cond.png">
<img src="{{site.baseurl}}/images/demogr_stable_pop/dyn_birth_dyn_init_cond.png" alt="_config.yml" style="width: 700px;" />
</a>
<figcaption style="font-size: 20px; margin-top: 6px; width: 700px;"> <strong>Figure 5</strong> Convergence to stable population size and age distribution from different initial conditions with <strong>dynamic</strong> births. The age group sizes at the initial condition are an exponential function of age.</figcaption>
</figure>
</div>

This makes sense as the balancing between births and deaths captured by the equilibrium conditions above are only about ratios, but do not determine the absolute values of the age group sizes.  
In this way, the model becomes history-dependent, ie. if the non-equilibrium initial population is larger it will converge to a larger equilibrium population size, although the age structure will be the same. In this sense, clearly births being a function of the size of the child-bearing cohort is crucial to have in the model.  
There is an even bigger problem with the constant birth level model: since it always converges to a stable population size, whatever birth level we set it goes to (the same) equilibrium, it cannot keep shrinking or growing. But we need to have this, since a fertility rate above (below) the reproduction rate must lead to a growing (shrinking) population. In this case the model will not reach equilibrium but will exponentially grow (or shrink to zero), without bounds. What is the age structure like in this case?

## Age structure of growing and shrinking populations


**... post still being written ...**

<!--  ```r
# ageing matrix
l_par$K_age <- with(l_par, diag(-rep(d_age,n_age)))
l_par$K_age[row(l_par$K_age)==col(l_par$K_age)+1] <- l_par$d_age
l_par$K_death <- diag(l_par$death_rates_interp)
# stationary sol
l_par$stat_sol_unnorm <- with(l_par, solve(-(K_age-K_death)) %*% c(birth,rep(0,n_age-1)) )
l_par$stat_sol_norm <- with(l_par,stat_sol_unnorm/sum(stat_sol_unnorm))
```  -->
