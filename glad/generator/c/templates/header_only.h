{% include spec.name + '.h' %}

/* Source */
#ifdef GLAD_{{ feature_set.api|upper }}_IMPLEMENTATION
{% include spec.name + '.c' %}

#endif /* GLAD_{{ feature_set.api|upper }}_IMPLEMENTATION */

