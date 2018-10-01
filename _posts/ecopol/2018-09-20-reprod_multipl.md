---
layout: post
title: The reproduction schema and the 'Keynesian multiplier', part 1
tags: political-economy economic-models economic-reproduction multiplier keynesian
excerpt: The 'Keynesian multiplier' in a one and two sector model
secondary: ecopol
mathjax: true
---

In his book [*Marxian reproduction schema: money and aggregate demand in a capitalist economy*](http://www.worldcat.org/title/marxian-reproduction-schema-money-and-aggregate-demand-in-a-capitalist-economy/oclc/946076663) Andrew Trigg mathematically formalizes models of (simple and expanded) reproduction of total social capital coming from classical political economy, and how they connect to the 'Keynesian' idea of the multiplier effect of investment demand. The reproduction schema was first proposed in a consistent form in Volume 2 of Marx's Capital, and later put into a mathematical form by Sraffa, Leontieff and other authors.
I have always been interested in these reproduction schemas and how supply (total output) and demand can be matched if the total output is increasing, that is if there is capital accumulation. I want to go step by step through the derivation in Trigg's book, discussing the meaning of the terms introduced along the way. In this post I will discuss the derivation of the 'Keynesian multiplier' that relates investment demand to (total) net income.

The basic aim of this analysis is to connect the 'multiplier' relationship between investment and total income with a 2-sector (consumption goods and capital goods) model of economic reproduction, where all capital and labour is reproduced and the capital stock is potentially incremented.

In a one-sector model of the economy we have (money units in '\$')

| Periods | Constant capital $$C_1$$ | Variable capital $$V_1$$  | Surplus value $$S_1$$ | Net income $$Y_1$$ | Net investment $$I_1$$ |
| :-------------: |:------------------:| :---------------:|:----------:|:----------:|:----------:|
| 1      | 4000 | 1000 | 1000     |   2000  |     |
| 2      |      |      |      |     |   500  |

At this point the reproduction of constant capital is not considered, only 'net income' (*Y*, I will drop the subscripts here as there is only one department) and its relation to net investment (accumulation). Net income is all income paid in the economy, made up of wages (variable capital, *V*) and profit (surplus value, *S*). The 'multiplier' is the relationship of net investment that happens from the *next* period of production. Then the 'Keynesian income multiplier' is:  
$$
\begin{equation}
Y = \frac{1}{1-b}I
\end{equation}
$$

Where *Y* is again net income (*Y=S+V*), *I* investment and *b* is the 'propensity to consume'. This last term was not very clear to me: does it mean the fraction of net income going to workers' consumption or all consumption? For the identity to work out it has to be  
$$b = \frac{V+S-I}{V+S} = \frac{Y-I}{Y} = 1 - I/Y $$,  
so $$b$$ takes into account *all* income spent on consumption, or in other words the share of wages + profit spent on consumption, assuming all wages are spent on consumption.

This is a mathematical identity, since $$ \frac{1}{1-(1 - I/Y)}I = Y $$. In other words, I don't see a causal relationship here, in fact I would say the causality to be explained runs the other way: the investment in *Period 2* is made possible by the realization of profits in *Period 1*. I would say it has to be shown that everything can be sold with a profit in *Period 1*, then some of this profit can be directed to new investment (and not to the consumption of owners who receive the profits) to increase the capital stock.
Technically, we can say the 'multiplier' effect is 4-fold, 1/4 of the net income will be invested in the next period. However this is not a causal statement as far as I can see, but simply restating the fact that whatever fraction $$\frac{I}{Y}$$ is spent on investment out of total net income, the reciprocal ratio $$\frac{Y}{I}$$ will be - by definition - the reciprocal.

Now we can take the case of a 2-sector economy: the first 'department' $$D_1$$ produces capital goods (means of production) and the second department $$D_2$$ consumer goods.
Then net income in the two departments are:  
$$Y_1 = V_1 + S_1$$  
$$Y_2 = V_2 + S_2 $$  

Then if we apply the 'propensity to consume', *b*, to total net income $$Y=Y_1 + Y_2 = V_1 + S_1 + V_2 + S_2$$, the demand for the output of the two sectors $$D(Y_i)$$ can be expressed as fractions of net income as:  
$$ D(Y_1) = (1-b)Y $$  
$$ D(Y_2) = bY $$  
The fraction of net income spent on consumption buys up the demand of $$D_1$$, and the other part that of $$D_2$$.
Since the output here does not take into account the input from constant capital (machines, materials etc. that were built into the output), only the income components ($$S+V$$), then the net income in the departments have to equal the demand for the output of the departments if the system is in equilibrium. This means that $$Y_i=D(Y_i)$$ and therefore  
$$
\frac{Y_2}{Y_1} = \frac{b}{1-b}                
$$  
Since in this formulation the income (=output) of $$D_1$$ is the same as total consumption $$B$$, and the income (=output) of $$D_2$$ is the same as net investment $$I$$, this formula describes a 'multiplier' relationship again, namely:  
$$
B = \frac{b}{1-b}I
$$  
Trigg writes that the 'traditional Keynesian multiplier' rather relates total net income to investment, which can be obtained from the previous formula by considering that $$B = Y - I$$, which then gives  
$$
Y = \frac{b}{1-b}I + I = \frac{1}{1-b}I,
$$  
yielding the formula obtained from the one-sector model. In other words the 'multiplier relationship' (which as I said above seems to me more an identity than a causal relationship) can be derived in a two-sector model.

The main problem with this description is that it takes no account of the role of constant capital (the capital stock embodied in machines etc), which has to be also reproduced in each cycle of production, and even expanded if there is accumulation. This is so although there is now a department producing capital goods. I want to address this problem in my next post, using the reproduction schemas and input-output analysis.
