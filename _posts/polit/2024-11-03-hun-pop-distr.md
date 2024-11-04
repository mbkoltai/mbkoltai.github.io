---
layout: post
title: Magyarország lakosság-eloszlása településméret szerint 
tags: politics demographics hungary elections data-visualisation
excerpt: (in Hungarian)
secondary: polit
mathjax: true
---


Az alábbi interaktív grafikon és kalkulátor azt mutatja meg, hogy 
az ország - teljes illetve választásra jogosult - lakossága hogyan oszlik el településméret szerint. 

<a href="https://mbkoltai.shinyapps.io/shinyapp_HU_pop_distr/" class="button">Magyarország település-szerkezete</a>

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

\[A fenti verzió a shinyapps.io szerveren fut, amelynek havi felhasználási limitje van.
Ha nem működik, 
<a href="https://mbkoltai.github.io/hun-pop-distr-shiny" target="_blank" style="display: inline-block; 
padding: 2px 6px; border: 2px solid #007BFF; border-radius: 5px; color: #007BFF; 
text-decoration: none; cursor: pointer; transition: background-color 0.3s, color 0.3s;" 
   onmouseover="this.style.backgroundColor='#007BFF'; this.style.color='black';" 
   onmouseout="this.style.backgroundColor='#007BFF'; this.style.color='white';"> klikk a lokálisan futó (statikus html) változatra</a> . 
Ez utóbbi verzió igénybe vehet kb. 30 másodpercet míg betölt.\]

## Interaktív opciók

1) _Teljes illetve választásra jogosult lakosság eloszlásának vizualizációja_:  
- x-tengely: településméret  
- y-tengely: hány lakos/választó vagy az összes lakos/választó hány %-a él adott településméretig bezárólag  
- interaktív adatpontok: a pontok fölé mozogva látható a települések neve, a lakosok száma, illetve hogy az ország hány lakosa/hány %-a él (kumulatíve) az adott településméretig  
- a "szám" illetve "százalék" mezőkre kattintva lehet választani, hogy a lakosok/választók számát, vagy a lakosság/választásra jogosult népesség százalékát mutassa  
- a piros adatpontok az összes lakost, a zöldek a választásra jogosultakat mutatják (a "lakók"/"választók"-ra kattintva lekapcsolható az adott adattípus)

2) _Adott településméret-sávban lakók számának/százalékának kiszámolása_:  
- adj meg egy minimum és maximum értéket a településméretre  
- az app kiszámolja hányan / az ország (teljes/választásra jogosult) lakosságának hány %-a él az adott településméret-sávban  
