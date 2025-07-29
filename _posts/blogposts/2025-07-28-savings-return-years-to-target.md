---
layout: post
title: Savings Goal Time Calculator
tags: data-visualisation finance money savings
excerpt: Years to goal as a function of annual saving and RoI
secondary: blogposts
mathjax: true
---


<a href="https://mbkoltai.shinyapps.io/years_to_save_reinvest_to_reach_amount/" class="button">Time to savings target calculator</a>

<style>
.button {
    display: inline-block;
    padding: 10px 20px;
    font-size: 22px;
    color: white;
    background-color: #0056b3; /* Button background color */
    border: 2px solid transparent; /* Transparent border by default */
    border-radius: 5px;
    text-align: center;
    text-decoration: none;
    transition: border-color 0.3s; /* Smooth transition for border color */
}
.button:hover {
    background-color: #0056b3; /* Darker shade on hover */
    border-color: red; /* Change border color to red on hover */
}
</style>

This is a simple Shinyapp calculator visualising how many years are needed to get to a given savings goal, as a function of the yearly savings rate and the rate of return. The calculation is in nominal terms, so not adjusting for inflation.
The formula assumes that all savings from income are continuously reinvested, along with all returns generated. In this case, the formula for wealth in year _n_ is:

<div style="display: flex; justify-content: center; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    $$ \text{target} = \frac{y}{r} \left((1 + r)^n - 1\right) $$
  </div>
</div>

Where:
- *y*: amount saved per year  
- *r*: annual return rate
- *n*: number of years  

Given a fixed target, the number of years required to reach it is:

<div style="display: flex; justify-content: center; margin-bottom: 1em;">
  <div style="background-color: #e0e0e0; padding: 12px; border-radius: 6px;">
    $$ n = \log_{1 + r} \left( \frac{\text{target}}{y / r} + 1 \right) $$
  </div>
</div>


This (_n_) is the value shown in the Shinyapp calculator/heatmap, as a function of:
- the target amount (adjustable)  
- *y*: amount saved per year  
- *r*: annual return rate



**<u>Code base and data sources</u>**  
[R code for graphs](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/savings-goal-time-calculator)  
