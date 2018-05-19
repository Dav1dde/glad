{% include spec.name + '.h' %}

/* Source */
#ifdef GLAD_{{ feature_set.name|upper }}_IMPLEMENTATION
{% include spec.name + '.c' %}

#endif /* GLAD_{{ feature_set.name|upper }}_IMPLEMENTATION */

