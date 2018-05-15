module amp.{{ feature_set.api }}.loader;

private {
    import amp.{{ feature_set.api }}.functions;
    import amp.{{ feature_set.api }}.enumerations;
    import amp.{{ feature_set.api }}.types;
}


alias Loader = void* delegate(const(char)*);


{% include 'loader/' + spec.name + '.volt' %}

private {
{% for extension in chain(feature_set.features, feature_set.extensions) %}
fn load_{{ extension.name }}(load : Loader) {
    {% set commands = extension.get_requirements(spec, feature_set=feature_set).commands %}
    {% if commands %}
    if (!{{ extension.name }}) return;
    {% for command in commands %}
    {{ command.name }} = cast(typeof({{ command.name }}))load("{{ command.name }}");
    {% endfor %}
    {% endif %}
}
{% endfor %}
}