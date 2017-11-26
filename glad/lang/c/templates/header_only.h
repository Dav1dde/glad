{% include spec.name + '.h' %}

/* Source */
#ifdef GLAD_{{ spec.name | upper }}_IMPLEMENTATION
{% include spec.name + '.c' %}

#endif

{% if options.loader %}
{% include 'loader/loader.h' %}
{% endif %}
