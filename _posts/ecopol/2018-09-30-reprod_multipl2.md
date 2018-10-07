---
layout: post
title: The reproduction schema and the 'Keynesian multiplier', part 2
tags: political-economy economic-models economic-reproduction multiplier keynesian classical-political-economy marxian-economics
excerpt: The reproduction schema and input-output analysis
secondary: ecopol
mathjax: true
---

In this post I follow up on [my previous post](https://mbkoltai.github.io/reprod_multipl/) where I discussed the idea of a 'multiplier' that relates total (net) income to net investment of a given economic system. Both there and here I  follow [a book](http://www.worldcat.org/title/marxian-reproduction-schema-money-and-aggregate-demand-in-a-capitalist-economy/oclc/946076663) by Andrew Trigg. One problem with this approach is that it analyzes the system only in terms of net income (wages and profit) and does not include how the capital stock within the system also has to be reproduced.  
A framework wherein the reproduction of all components of output can be analyzed is the so-called reproduction schema. The reproduction schema (developed in the 2nd Volume of Capital by Karl Marx) describes how in a given cycle of production the total social capital including both 'variable' (human labour) and 'constant' (machines) capital can be reproduced and potentially expanded by capital accumulation. While Marx used numerical examples, the schema can be better analyzed with the help of input-output tables and the tools of linear algebra.  
Below in *Table 1* is a numerical example of *simple* reproduction, meaning that the amount of constant capital does not change from one period of production to the another. All the surplus value (profit) that is produced (or rather, received for the surplus fraction of the output) is consumed by the owners of capital, and not reinvested (accumulated).  

| Departments | Constant capital $$C_i$$ | Variable capital $$V_i$$  | Surplus value $$S_i$$ | Total output $$W_i$$ |
| :-------------: |:------------------:| :---------------:|:----------:|:----------:|
| D1      | 4000 | 1000 | 1000     |   6000  |
| D2      | 2000  | 500  | 500  | 3000 |
|  $$\sum$$ | 6000  | 1500  | 1500  | 9000 |

*Table 1: simple reproduction*

Again, department 1 $$D_1$$ produces means of production (*MoP*), and $$D_2$$ *CoG*, each represented by a row, $$W_i$$ standing for the total output. I prefer to normalize this table by the total output of the economy (9000), to see quantities in fractional terms, getting:

| Departments | Constant capital $$C_i$$ | Variable capital $$V_i$$  | Surplus value $$S_i$$ | Total output $$W_i$$ |
| :-------------: |:------------------:| :---------------:|:----------:|:----------:|
| $$D_1$$      | 4/9 | 1/9 | 1/9     |   2/3  |
| $$D_2$$      | 2/9  | 1/18  | 1/18  | 1/3 |
|   $$\sum$$    | 2/3  | 1/6  | 1/6  | 1 |

*Table 1: simple reproduction* (normalized)

As can be seen, constant capital produced (2/3) is equal to constant capital consumed in this cycle of production (sum of the column $$C_i$$). The amount of *CoG* produced $$W_2 = V_1 + V_2 + S_1 + S_2 = 1/3$$, so all profits will be spent on buying up consumer goods (throughout it is assumed there is no saving from wages either).

This would be unrealistic if it were meant as a model of a capitalist economy, since capitalism is about growth (accumulation), but it is useful analytically. For if there is expansion, simple reproduction is still embedded within the growing economic system, but now it adds new units to its capital stock on top of it.

A model of a growing economy is *expanded reproduction*, a numerical example of which is in *Table 2* below

| Departments | Constant capital $$C_i$$ | Variable capital $$V_i$$  | Surplus value $$S_i$$ | Total output $$W_i$$ |
| :-------------: |:------------------:| :---------------:|:----------:|:----------:|
| $$D_1$$      | 4000 | 1000 | 1000     |   6000  |
| $$D_2$$      | 1500  | 750  | 750  | 3000 |
| $$\sum$$ | 5500  | 1750  | 1750  | 9000 |

*Table 2: expanded reproduction*

Let us normalize again:

| Departments | Constant capital $$C_i$$ | Variable capital $$V_i$$  | Surplus value $$S_i$$ | Total output $$W_i$$ |
| :-------------: |:------------------:| :---------------:|:----------:|:----------:|
| $$D_1$$      | 4/9     | 1/9   | 1/9     |   2/3  |
| $$D_2$$      | 1/6     | 1/12  | 1/12    | 1/3 |
| $$\sum$$ | 11/18  | 7/36  | 7/36    | 1 |

*Table 2: expanded reproduction (normalized)*

It can be seen that more constant capital is produced ($$W_1 = 2/3 = 12/18$$) than consumed ($$C_1 + C_2 = 11/18 $$), ie. accumulation is now possible, 1/18 (~5.6%) more constant capital will be available in the next round of production.
Correspondingly all income is now less than all consumption goods (*CoG*) produced:
$$V_1 + V_2 + S_1 + S_2 = 7/18 < W_1 = 6/18 $$, as some of the profit, namely 1/18 will be directed to accumulation. It is not at all trivial how the incomes and the outputs match, and what is the temporal sequence, I'll return to this later.
The (to-be-)accumulated capital $$\Delta W$$ is
$$
\Delta W = W_1 - (C_1+C_2) = V_1 + S_1 - C_2 = 1/18
\tag{1}\label{eq1}
$$

ie. it is net income in $$D_1$$ minus the constant capital consumed in the *CoG* department $$D_2$$.  
This matches the part of total net income $$Y$$ not spent on consumption, which is  
$$Y - W_2 = Y_1 + Y_2 - (Y_2 + C_2) = Y_1 - C_2 = V_1 + S_1 - C_2 = 1/18
\tag{2}\label{eq2}$$

Getting back to input-output analysis, we obviously have a case here of two sub-systems (departments) each using the other's output as an input, while - if there is expansion - some of the output is not used as an input in the present. Consumption from profit ($$u$$) is one component of this final output and it is not redirected into the system as an input at all. The addition to the capital stock ($$dC$$) is not used as an input in the present cycle, although it will be in the next. Finally, there can be an addition to the labour force ($$dV$$) too in the next period covered by unconsumed *CoG*. This last category was not visible in *Table 2*, as the use of the outputs as inputs was not contained there. It shows that capitalists can spend some of their profit not on personal consumption ($$u$$), but expanding the labour force ($$dV$$). Either way ($$dV$$ or $$u$$), this will go into buying up the output of $$D_2$$. Total surplus value will have to equal total final product, $$S_1 + S_2 = dC + dV + u$$.

Now we can turn *Table 2* into an input-output (I/O) table. If we read the I/O table row-wise, we have the production of one department, arranged into columns by the *use* of that part of the output by itself, the other department or for the 'final product'. If we read down a column, we have all the inputs for a given department (or for a type of final product).

|  | $$D_1$$ (inputs) | $$D_2$$ (inputs) | dC (new C) | dV (new V) | u (capitalist consum.) | $$ W_i$$ ($$\sum$$)|
| :----: |:----:| :----:|:----:|:----:|:----:|:----:|
| $$D_1$$ (outputs)| $$X_{11}$$=4/9     | $$X_{12}$$=1/6   | 1/18 |      |       | 2/3 |
| $$D_2$$ (outputs) | 1/9     | 1/12  |      | 1/60 | 11/90   | 1/3 |
| $$S_i$$         | 1/9     | 1/12  |      |      |       |     |
| $$W_i$$         | 2/3     | 1/3   |      |      |       | 1   |

*Table 3: I/O table of expanded reproduction from Table 2*

$$X_{ij}$$ stands for the amount of *capital* goods (*MoP*) produced by department *i* used as an input by department *j*. The gross (physical) output of department *i* is denoted as $$X_j$$. We can then define input coefficients $$a_{ij} = X_{ij}/X_j$$ as the ratio of the gross output of department *j* and the *MoP* it builds into this output from department *i*. This is the same as saying that $$a_{ij}$$ the share of the input coming from department $$D_i$$ into one unit of output of $$D_j$$. For instance $$a_{12} = X_{12}/X_2 = (1/6)/(1/3) = 1/2 $$, of the output of $$D_2$$ comes from the output (*MoP*) of $$D_1$$.
Consumer goods are not industrial inputs, so these input coefficients refer only to the output of $$D_1$$. One could say that the workers in both industries consumer consumer goods (output of $$D_2$$) in the same way, but this is rather after the production process than a part of it. At any rate I'll use the notation in Trigg's book to reproduce the derivation.  
For $$D_2$$ instead of $$a_{ij}$$, we have the product $$h_i l_j$$. $$l_j$$ is the labour coefficient $$l_j = L_j/X_j$$, where $$L_j$$ is the number of labour units employed in $$D_j$$ and $$X_j$$ (same as $$W_j$$ before) the gross output, ie. it is basically the share of wages in gross output (technically it still has to be multiplied by a wage rate). $$h_i$$ (which is defined for $$h_2$$ only) is $$h_i = B_i/L$$, or concretely $$h_2 = B_2/L$$, the ratio of total consumption of the 2nd physical good (ie. *CoG*) to the total volume of labour units. Now the term $$B_2$$ I was not sure how to interpret. Is it total consumption of *CoG*, ie. is it equal to $$X_2$$? In this case the equality would not work out, since $$M_{21} = 1/9 = h_2 l_1 X_1 = h_2 \frac{1}{3} \frac{2}{3} = h_2 \frac{2}{9}$$, therefore $$h_2=1/2$$ (by $$M_{21}$$ I mean 2nd row 1st column of matrix). Therefore $$B_2 = 7/36$$, which is equal to total wages (or consumption from wages since we assume all wages are spent), ie. $$B_2 = V_1 + V_2$$. Then $$h_2 = B_2/L = \frac{V_1+V_2}{L}$$ means the ratio of worker consumption to all labour performed, it is basically the labour share (again there is some issue here about money vs. physical units, but let us put that aside for the moment). There is also here the assumption that $$h_2$$, the labour share is the same in both sectors. The product $$l_1 h_2$$ in turn means the share of living labour in the gross output of $$D_2$$ times the *CoG* labour receives per unit of labour. In summary it is the amount of *CoG* to be 'inputted' (wage paid to workers that will be spent on *CoG*) to the department for a unit of its output, this is how it is equivalent to $$a_{ij}$$ in input-output terms.

Finally to go from physical/labour units to prices there is a price for units of *MoP* and *CoG*, $$p_1$$ and $$p_2$$. Then we can write the entire I/O matrix symbolically:


|  | $$D_1$$ (inputs) | $$D_2$$ (inputs) | dC (new C) | dV (new V) | u (capitalist consum.) | $$ W_i$$ (total output)|
| :----: |:----:| :----:|:----:|:----:|:----:|:----:|
| $$D_1$$ (outputs)| $$p_1 a_{11} X_1 = p_1 X_{11}$$  | $$p_1 a_{12} X_2 = p_1 X_{12}$$ | $$p_1 dA$$ |   |  | $$p_1 X_1$$ |
| $$D_2$$ (outputs) | $$p_2 h_2 l_1 X_1$$     | $$p_2 h_2 l_2 X_2$$ |      | $$p_2 dh$$ | $$ p_2 C_k$$ | $$p_2 X_2$$ |
| $$S_i$$         | $$S_1$$     | $$S_2$$  |      |      |       |     |
| $$W_i$$         | $$p_1 X_1$$  | $$p_2 X_2$$   |      |      |       |   |

*Table 4: I/O table of expanded reproduction in Leontief categories*

The term $$p_2 h_2 l_2 X_2$$ for instance means the amount of *CoG* to be used by the workers of $$D_2$$, equal to *(unit price) x (labour share in net income) x (share of net income (living labour) in gross output of $$D_2$$) x (gross output of $$D_2$$)*.

The term $$p_1 a_{12} X_2$$ is the money output of $$D_1$$ required by $$D_2$$, and it is the *MoP* used up by $$D_2$$, equal to *(unit price) x (units of MoP used for one unit of gross output of $$D_2$$) x (gross output of $$D_2$$)*).


The full system for expanded reproduction can be captured for both departments (after cancelling out the price terms), inputs matching outputs as:

$$
a_{11}X_1 + a_{12} X_2 + da = X_1
\tag{3}\label{eq3}
$$

$$
h_2 l_1 X_1 + h_2 l_2 X_2 + dh + C_k = X_2
\tag{4}\label{eq4}
$$

Or in matrix notation:

$$
\begin{bmatrix} X_1\\ X_2\\ \end{bmatrix} = \begin{bmatrix} a_{11} & a_{12}\\ 0 & 0\\ \end{bmatrix}
\begin{bmatrix} X_1\\ X_2\\ \end{bmatrix} + \begin{bmatrix} 0\\ h_2\\ \end{bmatrix}
\begin{bmatrix} l_1 & l_2 \end{bmatrix} \begin{bmatrix} X_1\\ X_2\\ \end{bmatrix}
+ \begin{bmatrix} da\\ dh + C_k \end{bmatrix}
\tag{5}\label{eq5}
$$

The vector on the right represents 'final demand' (or final output), these parts of the output do not replace the capital stock and labour used up in this period of production, but can be used to expand the labour force and the capital stock, or spent on consumption by the owners who receive the profits. Final demand does not include consumption of workers from wages, as this is to reproduce the existing labour force.

Using column vectors one can write Equation \eqref{eq5} as:

$$
\mathbf{X} = \mathbf{A X} + \mathbf{h} [\mathbf{l X}] + \mathbf{F}
\tag{6}\label{eq6}
$$

with **F** representing the column vector of final demand.

We want to recover the multiplier relationship of Equation 9 of the [previous post](http://www.mbkoltai.github.io/reprod_multipl). To do that, the '*net output*' is first defined as $$Q = (I - A)X$$, with $$I$$ the identity matrix. Writing it explicitly this is:

$$
Q = (I - A) X = \begin{bmatrix} 1 - a_{11} & - a_{12}\\ 0 & 1\\ \end{bmatrix} \begin{bmatrix} X_1\\ X_2\\ \end{bmatrix} = \\ =
\begin{bmatrix} X_1 - a_{11}X_1 - a_{12} X_2 \\ X_2\\ \end{bmatrix}
= \mathbf{h} [\mathbf{l X}] + \mathbf{F}
\tag{7}\label{eq7}
$$

 So '*net output*' means for $$D_1$$ its gross output minus the part that is to replace the constant capital used up in this period of production, and for $$D_2$$ its entire output.
 If we say *MoP* produced in the current period is also used up in this period (its part directed to replacement, $$I-A$$), whereas all *CoG* is used up after production, then it is maybe more intuitive why the net product is defined as $$\mathbf{h} [\mathbf{l X}] + \mathbf{F}$$, the second and third terms on the RHS of Equation \eqref{eq5} and \eqref{eq6}. There is here a temporal order of events, ie. movements of money and movements and use of physical goods that is not trivial and I want to reconstruct later on in detail.

First though I will follow through with the derivation of Chapter 2. Using Equation \eqref{eq7} and $$\mathbf{v} = l (I-A)^{-1} $$, Equation \eqref{eq6} can be re-expressed as:  
$$
Q \frac{v}{l} = A Q \frac{v}{l} + h [l Q \frac{v}{l}] + F = A Q \frac{v}{l} + h [v Q ] + F
$$

Subtracting $$ A Q \frac{v}{l} $$, the left-side simplifies to    
$$
\frac{v}{l}Q (I-A) = (I-A)^{-1} (I-A) Q = Q
$$

So that we have

$$
Q = h [v Q ] + F
\tag{8}\label{eq8}
$$

This is a relationship between:

- the net product $$Q$$ as defined in Eq. \eqref{eq7}  
- $$\mathbf{h}$$ that is the column vector $$ \begin{bmatrix}  0 \\  h_2 \\ \end{bmatrix} $$, $$h_2 = B_2/L = \frac{V_1+V_2}{L}$$, the ratio of worker consumption to all labour performed  
- $$\mathbf{v}$$, which is the row vector of 'vertically integrated labour coefficients'.

To understand $$\mathbf{v}$$, let us do the multiplication:

$$
\mathbf{v} = l (I - A)^{-1} =
\begin{bmatrix} l_1 & l_2 \end{bmatrix} \begin{bmatrix} \frac{1}{1 - a_{11}} & \frac{a_{12}}{1-a_{11}} \\ 0 & 1\\ \end{bmatrix} =
\begin{bmatrix} \frac{l_1}{1 - a_{11}} & l_1 \frac{a_{12}}{1-a_{11}} + l_2 \end{bmatrix}
\tag{9}\label{eq9}
$$

This is not very intuitive, but if we realize that $$a_{11}X_1 = X_{11} = C_1$$ and $$a_{12}X_2 = X_{12} = C_2$$ (since $$C_1$$ and $$C_2$$ are the amounts of constant capital transferred into the output, while $$X_11$$ and $$X_{12}$$ are parts of the output of $$D_2$$ that go into replacement) and that $$X_i = L_i + C_i$$, then $$\mathbf{v}$$ simplifies to $$\mathbf{v} = \begin{bmatrix} 1 & 1 \end{bmatrix} $$. This is because I previously dropped unit prices $$p_1$$ and $$p_2$$ (by setting them to 1).


Continuing, let us note that $$\mathbf{v} Q$$ is a scalar, since $$\mathbf{v}$$ is a 2-column row vector and $$Q$$ a 2-row column vector. Therefore if we multiply both sides of Equation \eqref{eq8} by $$\mathbf{v}$$, we get  
$$
\mathbf{v}Q = \mathbf{v} h [v Q ] + \mathbf{v} F
\tag{10}\label{eq10}
$$

Moving the first term on the LHS and factoring out $$\mathbf{v}Q$$, we finally arrive at  
$$
\mathbf{v}Q = \frac{1}{1 - \mathbf{v} h} \mathbf{v} F
\tag{11}\label{eqmult}
$$

which is again a multiplier relationship, very similar to Equation 9 in the [previous post](http://www.mbkoltai.github.io/reprod_multipl) where only net income was considered, but not constant capital. It is a relationship between final demand (net investment) $$\mathbf{v} F$$ and the net income (all new value added = wages + profits) $$vQ$$.
$$\mathbf{v} h$$ is a scalar, as is $$\mathbf{v} F$$ and $$\mathbf{v} Q$$.

$$vQ$$ is net income (= total employment of labour units = total new value added) because $$ \mathbf{v} = l (I - A)^{-1} $$ and $$Q = (I - A)X$$ (net product = to-be-accumulated capital $$dA$$ + all output of $$D_2$$, ie $$ X_2 = h_2 l_1 X_1 + h_2 l_2 X_2 + dh + C_k $$ ). Therefore

$$
\mathbf{v}Q = \mathbf{l} \mathbf{X} = \begin{bmatrix} L_1/X_1 & L_2/X_2 \end{bmatrix} \begin{bmatrix} X_1 \\ X_2 \end{bmatrix} = L_1 + L_2
\tag{12}\label{eq12}
$$

so the meaning of this term is quite clear.

As for $$\mathbf{v} h$$ in the denominator, it is the *propensity to consume*. As discussed above $$h$$ is the labour share (wages to net income/total labour) or in other words workers' consumption divided by total labour performed ($$h_2 = B_2/L$$).
In the 'net income' ('Keynesian') analysis of the previous post (see Equation 1 and 9), though $$b$$ was *all* consumption, whereas here $$B_2$$ is only consumption from wages, so the multiplier formulas are not identical. Since $$\mathbf{v} = [1 \ 1] $$ and $$\mathbf{h} = \begin{bmatrix} 0 \\ h_2 \end{bmatrix} $$, then the product is
$$
$$\mathbf{v} h$$ = h_2 = B_2 / L
$$
or the part of new value added paid out as wages and spent on consumption.

Finally, the product $$v F$$ is *total number of labour units required to produce final demand*, or the total value of the products corresponding to final demand, and if $$v = [1 \ 1]$$, then $$\mathbf{v} \mathbf{F} = F_1 + F_2 = dA + dH + C_k$$.

In summary, Equation \eqref{eqmult} expresses the relationship between net income, workers' consumption and final demand (the surplus product). The multiplier relationship can be derived in the two-department model of the reproduction schema, that considers constant capital as well. A difference is that the ratio of net income to final demand here is $$1/(1- vh)$$ where $$\mathbf{v h} $$ is workers' consumption per unit of labour, and not total consumption [as previously](https://mbkoltai.github.io/reprod_multipl/). (Or: labour embodied $$\mathbf{v}$$ in the bundle consumed by workers per unit of labour.) Then $$e = 1 - \mathbf{v h}$$ is the per capita share of surplus value extracted from each unit of labour. If we say that for simplicity $$\mathbf{v} = \mathbf{p}$$, so that net money output is $$y = \mathbf{v Q} = \mathbf{p Q}$$ and money final demand $$f = \mathbf{vF} = \mathbf{pF}$$, then Equation \eqref{eqmult} can be expressed as a 'macro income multiplier':

$$
y = \frac{1}{e}f
$$

So the concept of surplus value and the multiplier relationship between final demand and net money output can be related in a 2-sector model taking into account constant capital. Or, if you like, the concepts of classical political economy (such as surplus value) and those of 'Keynesian economics' can be related through the reproduction schemas.

To me this relationship is an algebraic one between parts of the total output classified with respect to their use: the net output and the part that can be consumed by owners or take the form of *MoP* and *CoG* to *expand* the capital stock (over replacement) and the workforce. The second chunk ($$\mathbf{F}$$ in the above notation), that is the surplus part of the output, is in fact a part of the first ($$\mathbf{v Q}$$). In other words final demand is the part of the net output that represents surplus accumulation (=new workers + new constant capital) and consumption.
This is not a causal relationship in my understanding, but an algebraic identity. In fact, these purchases from profit for consumption and accumulation occur at the end of a period of production, and first what we should explain is where the demand for these parts of the total output come from. It is this question that I want to address in my next post.

### Reference

[Andrew Trigg, Marxian reproduction schema: money and aggregate demand in a capitalist economy. Routledge, 2009](http://www.worldcat.org/title/marxian-reproduction-schema-money-and-aggregate-demand-in-a-capitalist-economy/oclc/946076663)
