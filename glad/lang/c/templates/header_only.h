{% include spec.name + '.h' %}

/* Source */
#ifdef GLAD_{{ spec.name | upper }}_IMPLEMENTATION
{% include spec.name + '.c' %}

#endif /* GLAD_{{ spec.name | upper }}_IMPLEMENTATION */

