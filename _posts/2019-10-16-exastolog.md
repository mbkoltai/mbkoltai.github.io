---
layout: post
title: Exact solving of stochastic continuous-time logical models
excerpt: By a matrix method from chemical kinetics
tags: cancer systems-biology kinetics tools
---

I recently submitted a manuscript that presents a calculation method to calculate the stationary solution of stochastic, continuous-time logical (Boolean) models.  
I adopted the mathematical technique from the field of chemical kinetics, specifically a number of articles from Jeremy Gunawardena and coauthors. These articles started with a small essay on the thresholding and switching properties of multisite (protein) phosphorylation [in PNAS](https://www.pnas.org/content/102/41/14617) back in 2005 and then with a beautiful paper in Nature on '[unlimited multistability](http://vcp.med.harvard.edu/papers/multistability.pdf)' in 2009.

In these articles the results were still somewhat *ad hoc*, but they showed that the stationary solution of the kinetic equations describing post-translations modifications, which are nonlinear ordinary differential equations with bilinear terms complemented by some algebraic conservations, can be analytically obtained and that if we have multisite species there is no obvious limit to the number of stable steady states that these systems have.
Later on the results were generalized, culminating in the paper '[Laplacian dynamics on general graphs](http://vcp.med.harvard.edu/papers/jg-lap-dyn.pdf)' (2013) where they are most systematically summarized.  

I was fascinated by these papers during my PhD. When I started to work on stochastic Boolean models with continuous time, that we simulated with Monte Carlo simulations (same way as Gillespie algorithm is used for stochastic kinetics) it occurred to me only after some time that if we want to have the stationary solution only then this is in fact identical to the problem described by Gunawardena, so his method can be adopted for the state transition graph of a logical model.  
The result from this work is now on [biorXiv](https://www.biorxiv.org/content/10.1101/794230v1).  
I've also implemented the calculations as a MATLAB toolbox that can be downloaded and used with the help of [this tutorial](https://github.com/mbkoltai/exact-stoch-log-mod/tree/master/doc).
