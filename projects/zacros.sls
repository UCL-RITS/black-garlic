{% set compiler = salt['pillar.get']('compiler', 'gcc') %}
{% set python = salt['pillar.get']('python', 'python2') %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{python}}
    - pip_upgrade: True
    - use_wheel: True
    - pip_pkgs: [pip, numpy, scipy, pandas, jupyter]

{{project}}:
  funwith.modulefile:
    - cwd: {{workspace}}/src/{{project}}
    - virtualenv: {{workspace}}/{{python}}

UCL/Zacros:
  github.latest:
    - target: {{workspace}}/src/{{project}}
    - unless: test -d {{workspace}}/src/{{project}}/.git
