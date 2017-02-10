{% set compiler = salt["spack.compiler"]() %}
{% set python = salt['pillar.get']('python', 'python2') %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{python}}
    - pip_upgrade: True
    - use_wheel: True
    - pip_pkgs: [pip, numpy, scipy, pytest, pandas, cython, jupyter]

UCL/GreatCMakeCookoff:
  github.latest:
    - target: {{workspace}}/src/{{project}}
    - unless: test -d {{workspace}}/src/{{project}}/.git

{{project}}:
  funwith.modulefile:
    - virtualenv: {{workspace}}/{{python}}
    - cwd: {{workspace}}/src/{{project}}
