{% from slspath+"/map.jinja" import consul with context %}

consul-config:
  file.managed:
    - name: /etc/consul.d/config.json
    {% if consul.service != False %}
    - watch_in:
       - service: consul
    {% endif %}
    - user: consul
    - group: consul
    - require:
      - user: consul
    - contents: |
        {{ consul.config | json }}

{% for script in consul.scripts %}
consul-script-install-{{ loop.index }}:
  file.managed:
    - source: {{ script.source }}
    - name: {{ script.name }}
    - makedirs: true
    - template: jinja
    - user: {{ script.user | default('consul') }}
    - group: {{ script.group | default('consul') }}
    - mode: 0755
{% endfor %}

consul-services-config:
  file.managed:
    - source: salt://{{ slspath }}/files/services.json
    - name: /etc/consul.d/services.json
    - template: jinja
    {% if consul.service != False %}
    - watch_in:
       - service: consul
    {% endif %}
    - user: consul
    - group: consul
    - require:
      - user: consul
    - context:
        services: |
          {{ consul.services | json }}

consul-checks-config:
  file.managed:
    - source: salt://{{ slspath }}/files/checks.json
    - name: /etc/consul.d/checks.json
    - template: jinja
    {% if consul.service != False %}
    - watch_in:
       - service: consul
    {% endif %}
    - user: consul
    - group: consul
    - require:
      - user: consul
    - context:
        checks: |
          {{ consul.checks | json }}
