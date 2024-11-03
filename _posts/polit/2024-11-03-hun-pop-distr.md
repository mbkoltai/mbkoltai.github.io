---
layout: post
title: Magyarország lakosság-eloszlása településméret szerint 
tags: politics demographics hungary elections data-visualisation
excerpt: (in Hungarian)
secondary: polit
mathjax: true
---


Az alábbi ShinyApp-pel tanulmányozható az ország teljes illetve választásra jogosult lakosságának mekkora része él adott méretű településeken. Az app betöltése igénybe vehet kb. 20-30 másodpercet.

<a href="https://mbkoltai.github.io/hun-pop-distr-shiny/" class="button">Magyarország település-szerkezete</a>

<style>
.button {
    display: inline-block;
    padding: 10px 20px;
    font-size: 22px;
    color: white;
    background-color: #007bff; /* Button background color */
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

### Interaktív opciók

1) _Teljes illetve választásra jogosult lakosság eloszlásának vizualizációja_:  
- x-tengely: településméret  
- y-tengely: hány lakos/választó vagy az összes lakos/választó hány %-a él adott településméretig bezárólag  
- interaktív adatpontok: a pontok fölé mozogva látható a települések neve, a lakosok száma, illetve hogy az ország hány lakosa/hány %-a él (kumulatíve) az adott településméretig  
- a "szám" illetve "százalék" mezőkre kattintva lehet választani, hogy a lakosok/választók számát, vagy a lakosság/választásra jogosult népesség százalékát mutassa  
- a piros adatpontok az összes lakost, a zöldek a választásra jogosultakat mutatják (a "lakók"/"választók"-ra kattintva lekapcsolható az adott adattípus)

2) _Adott településméret-sávban lakók számának/százalékának kiszámolása_:  
- adj meg egy minimum és maximum értéket a településméretre  
- az app kiszámolja hányan / az ország (teljes/választásra jogosult) lakosságának hány %-a él az adott településméret-sávban  
