---
layout: page
permalink: /science/
title: ""
---

### Basic info

I have worked on mathematical modelling of biological systems since 2010, in the fields of systems biology and infectious disease modelling.

I obtained a PhD from Ruprecht-Karls-Universität Heidelberg (Germany) in 2016 with a [thesis](https://archiv.ub.uni-heidelberg.de/volltextserver/20847/) on quantitative modelling of microbial signalling pathways.
After my PhD I worked at Institut Curie (France), at LSHTM (UK) and currently at Imperial College London (UK).

Here is my current [academic profile](https://profiles.imperial.ac.uk/m.koltai) at Imperial College London.

Here is a (relatively) recent [CV]({{site.baseurl}}/images/website_basics/mihalykoltai_CV.pdf).

### Publications

[Google Scholar profile](https://scholar.google.com/citations?user=ykWF9bgAAAAJ&hl=en).

<!--## Talks at conferences

**Exact solving of stochastic-continuous Boolean models of biological networks (poster)**

[*INCOME2019: Integrative pathway modeling in systems biology and systems medicine*](https://www.integrative-pathway-models.de/meetings/former-meetings/income-hackathon-2019/program/index.html)  
18/03/2019, Berlin, Germany

**Ensemble modeling for drug resistance and sensitivity in colon cancer cell lines (talk)**  

[*INCOME2018: Integrative pathway modeling in systems biology and systems medicine*](http://www.integrative-pathway-models.de/meetings/1st-income-conference-and-hackathon/program/index.html)  
15/10/2018, Bernried am Starnberger See, Germany

**Using perturbation data for ensemble modeling to infer vulnerabilities in colon cancer cells (talk)**  
[*Mathematical Perspectives in the Biology and Therapeutics of Cancer*](https://conferences.cirm-math.fr/1752.html)  
12/07/2018, Marseille, France  

**A data-driven logical model of colon cancer for biomarker and drug discovery (talk)**  
[*Interdisciplinary Signalling Workshop*](http://m.signalingworkshop.org/19july/)  
19/07/2017, Visegrád, Hungary
-->

### PhD dissertation

[Quantitative analysis of microbial sensing and motility](https://archiv.ub.uni-heidelberg.de/volltextserver/20847/)  
Ruprecht-Karls-Universität Heidelberg, 2016

---
## Blog posts on scientific topics

<div class="blog-index">
<ul style="list-style-type: none;">
      {%  assign p = '9999' %}
      {%  for post in site.posts%}
    {% if post.secondary == 'science' %}

      {% assign n = post.date | date: "%Y" %}
      {% if n != p %}
      {%      assign p = n%}
            <br /><h5>{{ n }}</h5>
      {% endif %}
  <li style="padding-bottom: 6px;"><code>[{{ post.date | date: "%d %b" }}]</code>&nbsp;
    <a href="{{ post.url }}" style="white-space: normal;"><b>{{ post.title }}</b></a>&nbsp;
      {{ post.excerpt | strip_html | truncatewords: 12 }}
  </li>

            {% endif %}
      {% endfor %}
</ul>
</div>

