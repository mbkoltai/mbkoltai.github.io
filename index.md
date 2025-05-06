---
title: home
layout: default
---

<!--
# About
My name is Mihaly Koltai, I am a research scientist and this is a website on my scientific work as well as some other interests I have.

I have worked on mathematical modelling of biological systems since 2010, in the fields of systems biology and infectious disease modelling.

I obtained a PhD from Ruprecht-Karls-Universität Heidelberg (Germany) in 2016 with a [thesis](https://archiv.ub.uni-heidelberg.de/volltextserver/20847/) on quantitative modelling of microbial signalling pathways.
After my PhD I worked at Institut Curie (France), at LSHTM (UK) and currently at Imperial College London (UK).
For an academic CV [click here](https://raw.githubusercontent.com/mbkoltai/mbkoltai.github.io/refs/heads/source/images/mihalykoltai_CV.pdf).

For published scientific work as well as some blog posts on scientific topics [click here](https://mbkoltai.github.io/science/).

I also have an interest in economics, politics and some other topics, for posts on these click on one of the sub-pages in the header.
-->


<style>
.image-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}


.image-grid a {
  display: block;
  width: 30%;
  position: relative;
  /* transition: transform 0.2s; */
  text-align: center;
  color: black;
  text-decoration: none;
}

.image-grid img {
  width: 100%;
  border: 1px solid black;
  /* transition: border 0.3s ease; */
  opacity: 0.5; /* Semi-transparent */
}

.image-grid a:hover img {
  border: 3px solid red;
}

.img-label {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  /* color: blue; */
  font-size: 1.7em;
  font-weight: bold;
  /* background: rgba(255, 255, 255, 0.4); */
  pointer-events: none; /* lets clicks go through to the image link */
  /* transition: color 0.3s ease; */
}

.grid {
  background: transparent; /* No background on the grid itself */
}

.image-wrapper {
  background: transparent; /* Makes sure the background of the grid wrapper is transparent */
  position: relative;
  width: 30%;
  padding: 0;
  text-decoration: none;
  display: inline-block;
}

.image-wrapper img {
  width: 100%;
  height: auto; /* Keeps natural aspect ratio */
  display: block;
}

.image-wrapper:hover .img-label {
  color: red;
}

.placeholder-box {
  width: 100%; /* Ensures it fills the container width */
  /* border: 1px solid black; */
  /* height: 0; */
  /*background: #eee; /* Light gray */
  /* opacity: 0.7;
}
</style>

<div class="image-grid">

<a href="{{ site.baseurl }}/about" class="image-wrapper">
  <div class="placeholder-box"></div>
  <div class="img-label">about</div>
</a>


  <a href="{{ site.baseurl }}/science/" class="image-wrapper">
  <img src="{{ site.baseurl }}/images/double_inhib_bistable_symm_manytrajs_n4.jpg" alt="science">
<div class="img-label">science</div>
  </a>

  <a href="{{ site.baseurl }}/ecopol/" class="image-wrapper">
  <img src="{{ site.baseurl }}/images/D1_multiplier.png" alt="econ">
  <div class="img-label">economics</div>
  </a>

  <a href="{{ site.baseurl }}/polit" class="image-wrapper">
  <img src="{{ site.baseurl }}/images/illusionglob/world_pop_gdp_exports_log_yaxis_2insets_textboxes.png" alt="history">
  <div class="img-label">history/politics</div>
  </a>

<a href="{{ site.baseurl }}/blog/tags" class="image-wrapper">
<img src="{{ site.baseurl }}/images/website_basics/tags_white.png" alt="tags">
  <div class="img-label">tags</div>
  </a>

</div>
