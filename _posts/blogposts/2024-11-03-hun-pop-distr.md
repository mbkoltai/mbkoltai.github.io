---
layout: post
title: Magyarország lakosság-eloszlása településméret szerint
tags: politics demographics hungary elections data-visualisation
excerpt: (Shiny app)
secondary: blogposts
mathjax: true
---


Az alábbi interaktív grafikon és kalkulátor azt mutatja meg, hogy 
az ország - teljes illetve választásra jogosult - lakossága hogyan oszlik el településméret szerint. 

## datawrapper

<iframe title="Magyarország lakosság-eloszlása településméret szerint" aria-label="Scatter Plot" id="datawrapper-chart-5LEw2" src="https://datawrapper.dwcdn.net/5LEw2/3/" scrolling="no" frameborder="0" style="width: 0; min-width: 100% !important; border: none;" height="599" data-external="1"></iframe><script type="text/javascript">window.addEventListener("message",function(a){if(void 0!==a.data["datawrapper-height"]){var e=document.querySelectorAll("iframe");for(var t in a.data["datawrapper-height"])for(var r,i=0;r=e[i];i++)if(r.contentWindow===a.source){var d=a.data["datawrapper-height"][t]+"px";r.style.height=d}}});</script>



## Shinyapp: 
<a href="https://mbkoltai.shinyapps.io/shinyapp_HU_pop_distr/" class="button">Magyarország település-szerkezete</a>

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

<!--
\[A fenti verzió a shinyapps.io szerveren fut, amelynek havi felhasználási limitje van.
Ha nem működik, 
<a href="https://mbkoltai.github.io/hun-pop-distr-shiny" target="_blank" 
   style="display: inline-block; 
          padding: 0px 2px; 
          border: 2px solid #0056b3; 
          border-radius: 3px; 
          background-color: #0056b3; 
          color: white; 
          text-decoration: none; 
          cursor: pointer; 
          transition: color 0.3s, border-color 0.3s;"
 onmouseover="this.style.color='red'; this.style.borderColor='red';"
 onmouseout="this.style.color='white'; this.style.borderColor='#0056b3';">
klikk a lokálisan futó (statikus html) változatra</a>.
Ez utóbbi verzió igénybe vehet kb. 30 másodpercet míg betölt.\]
--> 

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
