---
layout: post
title: Expanded reproduction and the Kalecki principle
tags: political-economy economic-models classical-political-economy marxian-economics kalecki demand
excerpt: Profits = investment + capitalist consumption?
secondary: ecopol
mathjax: true
---

In this post, following [Trigg's book](http://www.worldcat.org/title/marxian-reproduction-schema-money-and-aggregate-demand-in-a-capitalist-economy/oclc/946076663) on reproduction schemas, I will explore how the work of Michał Kalecki contributes to answering the question where the demand for the surplus part of total output comes from.
One can explore in more detail how surplus value is allocated by its use: some of it is used for expanding the capital stock ($$dC_i$$), some for expanding the workforce $$dV_i$$) and some for capitalist consumption ($$u_i$$), the subscript $$i$$ referring to departments.
Also, Department 2 can be disaggregated into two departments, $$D_2$$ producing consumption goods ($$CoG$$) for capitalists and $$D_3$$ producing $$CoG$$ for workers.
Using the same table as in the previous post, with $$D_2$$ split into two and surplus value allocated by use, we have the table:

| Departments | Constant capital $$C_i$$ | Variable capital $$V_i$$  | Surplus value $$S_i$$ | ~ | ~ | Total output $$W_i$$ |
| |  |   | $$u_i$$ | $$dC_i$$ | $$dV_i$$ |  |
| :-------------: |:------------------:| :---------------:|:----------:|:----------:|
| $$D_1 $$      | 4000 | 1000 | 500   | 400 | 100  |   6000  |
| $$D_2 $$      | 550 | 275 | 220 | 36 $$\frac{2}{3}$$ | 18 $$\frac{1}{3}$$ | 1100 |
| $$D_3 $$      | 950 | 475 | 380 | 63 $$\frac{1}{3}$$ | 31 $$\frac{2}{3}$$ | 1900 |
| $$\sum$$ | 5500  | 1750  | 1100 | 500 | 150  | 9000 |

*Table 1: Three-sector (expanded) reproduction schema*

The $$C_i$$ column is the amount of constant capital used up in the given period of production, in this case 5500. The columns that represent surplus value/product are different from the columns $$C_i$$ and $$V_i$$, because the former are the final outputs from this period of production, and they are not used as inputs in this period. Since there is accumulation (the capital stock is incremented), the output of $$D_1$$ ($$W_1=6000$$) is more than the total input of *MoP*, $$C_1=5500$$.
If however we add to $$C_i$$ the additional units of constant capital ($$dC_i$$), and do the same with $$V_i$$ and $$dV_i$$, creating '*ex post*' variables $$C_i$$\* and $$V_i$$\*, then the row sums and columns match:

| Departments | $$C_i$$\* | $$V_i$$*  | Capitalist consumption $$u_i$$ | Total output $$W_i$$ |
| :-------------: |:------------------:| :---------------:|:----------:|:----------:|
| $$D_1$$      | 4400 | 1100 | 500  |   6000  |
| $$D_2$$      | 586 $$\frac{2}{3}$$ | 293 $$\frac{1}{3}$$ | 220 | 1100 |
| $$D_3$$      | 1013 $$\frac{1}{3}$$ | 506 $$\frac{2}{3}$$ | 380   | 1900 |
| $$\sum$$ | 6000  | 1900  | 1100  | 9000 |

*Table 2: 'ex post' three-sector reproduction schema (quantities at the end of period)*

The columns $$C_i$$ and $$V_i$$ I would interpret as the inputs of *MoP* and labour (workforce/wages) in the *next* period, respectively, whereas $$u_i$$ is the part of the profit received in sector $$i$$ that is spent on consumption by owners, instead of accumulation. So $$C_i$$* and $$V_i$$ are mixed variables in the sense that some of it is the input in the current period and some the increment added in the current, but used in the next period.
We have the equalities of outputs by sector to outputs grouped by use:  
$$W_1 = C_1$$* $$ + C_2$$* $$+ C_3$$* $$ = C_1 + dC_1 + C_2 + dC_2 + C_3 + dC_3 $$  
$$W_2 = u_1 + u_2 + u_3$$  
$$W_3 = V_1$$* $$+ V_2$$* $$+ V_3$$* $$ = V_1 + dV_1 + V_2 + dV_2 + V_3 + dV_3$$
$$\tag{1}\label{outputs_use} $$  

Expressed in words:  
-  $$W_1$$, total output of *MoP* (means of production) = *MoP* needed for replacement and accumulation ($$C_i + dC_i$$)  
- $$W_2$$, total output of *CoG* for capitalists = profit extracted by capitalists, spent on personal consumption.
- $$W_3$$, total output of *CoG* for workers (replacement and new workforce)' = total wage bill (of workers in *new* period, including newly hired workers)

<!--- It is the parts of the output used for accumulation, $$dC + dV$$ whose realization (source of demand) is not trivial. $$V$$ and $$C$$ are spent at the beginning of the period and the demand for $$u$$ comes from the private wealth of the owners (that they then receive as profits for their companies). If the entire surplus part is in the form of capitalist consumption $$u$$, then there is no demand problem: all the demand for $$u$$ comes from owners' private funds, which then they receive back as the profit of their companies in $$D_2$$. But how about expanded reproduction?   -->


We also have the sectoral equalities:  
$$W_1 = (C_1 + dC_1) + (V_1 + dV_1) + u_1 \\
W_2 = (C_2 + dC_2) + (V_2 + dV_2) + u_2  \\
W_3 = (C_3 + dC_3) + (V_3 + dV_3) + u_3
\tag{2}\label{sectoral_outputs}$$  

There is one more rearrangement: defining gross profits $$P_i$$* as total output minus *ex post* variable capital, ie. $$P_i$$* $$= W_i - V_i$$\*. At this point it's not yet clear how to interpret gross profits meaningfully. *Ex post* variable capital will be spent in the next period of production from gross revenue, but this is also true for $$C_i$$\*. At any rate, if we reorder terms this way, adding $$C_i$$\* to $$u_i$$, we get the table with gross profits:


| Departments | $$V_i$$*  | $$P_i$$* | Total output $$W_i$$ |
| :-------------: |:------------------:| :---------------:|:----------:|:----------:|
| $$D_1$$      | 1100 | 4900  |   6000  |
| $$D_2$$      | 293 $$\frac{1}{3}$$ | 806 $$\frac{2}{3}$$ | 1100 |
| $$D_3$$      | 506 $$\frac{2}{3}$$ | 1393 $$\frac{1}{3}$$ | 1900 |
| $$\sum$$ | 1900  | 7100  | 9000 |

*Table 3: Kalecki's interpretation of the three-sector schema (ex post variable capital and gross profits)*

This is the same as grouping the terms in the output as:  
$$W_i = (V_i + dV_i) + (C_i + dC_i + u_i)$$

An equality becomes visible from this table, namely that the surplus of *CoG* that $$D_3$$ produces (surplus in the sense that it is in excess of the wage bill of its own workers) is equal to the wage bill of the other two sectors:  
$$P_3 = V_1$$\* $$+ V_2$$\*
$$\tag{3}\label{wage_goods_gross_profit}$$

If we then add the gross profits of the other two sectors, $$P_1$$\* and $$P_2$$\*, we get:  
$$P_1 + P_2 + P_3 = V_1$$\* $$+ P_1 + V_2$$\* $$+ P_2$$  
$$P = W_1 + W_2$$  
$$\tag{4}\label{total_gross_profit_outputs_equal}$$

This means that total gross profit in the economy is equal to the (gross) output of the sector producing capital goods ($$D_1$$) and capitalist *CoG* ($$D_2$$). Since gross profit is defined as all spending on capital goods (replacement + incremental) and capitalist consumption, and these are supplied by sectors 1 and 2.

Trigg writes that Kalecki interpreted this '*ex post* identity' as following: '*[T]he money expenditures by capitalists upon consumption and investment that generate the resultant volume of profits*', or shortly '*capitalists earn what they spend*'.
<!---Again, on a first sight, to me this sounds like causation backwards in time, as those investments and consumption expenditures can only happen at the end of the current period or at the beginning of the next one, once the owners have already received these profits.-->
It is easy to see that 'capitalists earn what they spend' is true in the case of simple reproduction where the personal consumption of owners provides the demand for the surplus product, and returns to them as profit, but it less clear for expanded reproduction. In expanded reproduction some of the surplus product takes the form of new constant capital and new workers, so the demand must come from advanced amounts of money by the 'departments' (companies) themselves, not capitalists as consumers. To clearly see how this is possible, I need to write explicitly the sequence of payments/sales and production.  

For now I'll go on with the derivation as in the book. The three-sector schema can be represented in an input-output table as below:  

| | $$D_1$$ (inputs) | $$D_2$$ (inputs) | $$D_3$$ (inputs) | $$S_i$$ | $$S_i$$ | $$S_i$$ | $$W_i$$ |
|     |     |     |     |  $$dC$$ (addit. constant) | $$dV$$ (addit. variable)  |  $$u$$ (capit. consumption)   |   $$W_i$$ (total output)  |
| :---:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|
| $$D_1$$ (outputs by use) | 4000 | 550 | 950 |  500   |     |     |   6000  |
| $$D_2$$   |     |     |     |     |     |  1100   |   1100  |
| $$D_3$$   |  1000  | 275  |  475 |     |   150  |     |  1900  |
| $$S_i$$  | 1000  | 275 | 475 |     |     |     |  1750 |
| $$W_i$$ |  6000 | 1100    | 1900    |     |     |     |  9000   |

As in the [previous post](https://mbkoltai.github.io/reprod_multipl2) (new/net) investment is classified here as final demand (it is not an input in this period of production), specifically as additional constant ($$dC$$) and variable ($$dV$$) capital. Total personal consumption of capitalists is in column $$u$$, under $$S$$.

The equality of Equation \eqref{wage_goods_gross_profit} reads in terms of the I/O table as:  
$$P_3 = W_3-(V_3+dV_3)=(V_1+dV_1)+(V_2 + dV_2) $$

The wage terms are $$V_i = X_{3i}$$, so then the equation is:  
$$W_3 - (X_{33} + dV_3) = (X_{31} + dV_1) + (X_{32} + dV_2) $$  
and since none of the output of $$D_1$$ and $$D_2$$ can take the form of $$dV$$, therefore $$dV_1 = dV_2 = 0$$, then this simplifies to:  
$$W_3 - (X_{33} + dV_3) = X_{31} + X_{32}
\tag{5}\label{use_output_3}$$  

In other words, all the output of $$D_3$$ not used by itself for replacement and expansion of its workforce is, logically, used by the other two sectors.
Also, it is more clearly visible that  
$$S = u + dC + dV = u + I
\tag{6}\label{surplus_investm_capcons}$$  
ie. surplus value (total profit) = capitalist consumption + investment (accumulation).
This equation is not the same as \eqref{total_gross_profit_outputs_equal}, because there gross profit P\* is defined as all spending on capital goods and capitalist consumption, whereas here it is only the part spent on accumulation (*new* capital goods and labour) and capitalist consumption.
This is interpreted by Trigg/Kalecki as '*capitalists cast money into circulation as aggregate demand on capitalist consumption and investment, which is realized as surplus value*' (p. 35). (There is again a nagging question of causality here left unanswered.)

This can be rendered as a 'Kalecki multiplier', by defining capitalist consumption $$u$$ as made up of a constant part $$B_0$$ and a part dependent on profits as a fraction $$\lambda$$ of total profits $$P$$:  
$$u = B_0 + \lambda P
\tag{7}\label{kalecki_u_lambda}$$  

Where $$P$$ is total profits. Since $$P = u + I$$,  
$$P = B_0 + \lambda P + I
\tag{8}\label{eq8}$$  
and therefore
$$P = \frac{B_0 + I}{1-\lambda}
\tag{9}\label{eq9}$$  

Equation \eqref{eq9} represents a 'multiplier' relationship between total profits and total 'exogenous' expenditure by capitalists ($$B_0 + I$$: constant capitalist consumption + new investment), with a multiplier effect of $$1/(1-\lambda)$$.

Since profits consist of capitalist consumption and investment, the components of the final demand $$f$$ ([see previous post](http://mbkoltai.github.io/reprod_multipl2/), Equations 5 and 13), this can be substituted into the macro-income ('Keynesian') multiplier $$y = \frac{1}{e}f$$, yielding

$$y = \frac{1}{e (1-\lambda)} (B_0 + I)
\tag{10}\label{kalecki_multipl}$$

So that the 'Keynesian' multiplier now has the terms $$e$$, the share of surplus value, and the 'Kalecki multiplier' $$1/(1-\lambda)$$, with $$\lambda$$ being the fraction of profits spent on consumption.

Once more, we have a macro-identity here, but the question of whether the necessary amount of money is there to sell all outputs (and if yes where does it come from) in the case of expanded reproduction still hangs over these identities. This question can be addressed in the framework of the monetary circuit, which I will discuss in my next post.

### Reference

[Andrew Trigg, Marxian reproduction schema: money and aggregate demand in a capitalist economy. Routledge, 2009](http://www.worldcat.org/title/marxian-reproduction-schema-money-and-aggregate-demand-in-a-capitalist-economy/oclc/946076663)
