---
layout: page
title: Documents
permalink: /docs/
last_update: 2023-01-25 23:03:28
---

# Documents


{% assign thislength = page.url | size %}
{% assign thisdepth = page.url | split: "/" | size | plus: 1 %}
<!-- This depth: {{ thisdepth }} -->

<ul>
    {% for child in site.docs %}
        {% assign prefix = child.url | slice: 0, thislength %}
        {% assign depth = child.url | split: "/" | size %}
        {% if prefix == page.url and thisdepth == depth%}
            <li><a href="{{ child.url | prepend: site.baseurl }}">{{ child.title }}</a>
                {% if child.description %}<sub>{{ child.description }}</sub>{% endif %}
            </li>
        {% endif %}
    {% endfor %}
</ul>

