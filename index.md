---
title: home
layout: default
---


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

/* Media query for smaller screens (e.g., phones) */
@media only screen and (max-width: 768px) {
  .img-label {
    font-size: 1em; /* Adjust font size for smaller screens */
  }
}

/* Optionally, you can add more media queries for different screen sizes */
@media only screen and (max-width: 480px) {
  .img-label {
    font-size: 0.8em; /* Further adjust font size for very small screens */
  }
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
  /* height: 100%; */
  background: white; /* Light gray */
  /* opacity: 0.7;
}
</style>

<div class="image-grid">

<a href="{{ site.baseurl }}/about" class="image-wrapper">
  <div class="placeholder-box"></div>
  <div class="img-label">about</div>
</a>


  <a href="{{ site.baseurl }}/science/" class="image-wrapper">
  <img src="{{site.baseurl}}/images/multistable/double_inhib_bistable_symm_manytrajs_n4.jpg" alt="science">
<div class="img-label">science</div>
  </a>

<!--  <a href="{{ site.baseurl }}/ecopol/" class="image-wrapper">
  <img src="{{ site.baseurl }}/images/D1_multiplier.png" alt="econ">
  <div class="img-label">economics</div>
  </a>
-->

<a href="{{ site.baseurl }}/blog/tags" class="image-wrapper">
<img src="{{ site.baseurl }}/images/website_basics/tags_white.png" alt="tags">
  <div class="img-label">tags</div>
</a>

<a href="{{ site.baseurl }}/blogposts" class="image-wrapper">
  <img src="{{site.baseurl}}/images/illusionglob/world_pop_gdp_exports_log_yaxis_2insets_textboxes.png" alt="blog">
  <div class="img-label">blog</div>
</a>



</div>
