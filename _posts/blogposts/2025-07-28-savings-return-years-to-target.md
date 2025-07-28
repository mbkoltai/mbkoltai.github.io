---
layout: post
title: Savings Goal Time Calculator
tags: data-visualisation finance money
excerpt: Years needed to reach target as a function of annual input and RoI
secondary: blogposts
mathjax: true
---


This is a simple calculator that shows how many years are needed to get to a given savings goal, as a function of the yearly savings rate and the rate of return. The calculation is in nominal terms, so not adjusting for inflation.

<a href="https://mbkoltai.shinyapps.io/years_to_save_reinvest_to_reach_amount/" class="button">Time to savings goal calculator</a>

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

**<u>Code base and data sources</u>**  
[R code for graphs](https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/savings-goal-time-calculator)  
