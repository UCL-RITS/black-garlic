{% set python = salt['spack.python']() %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

UCL-RITS/research-software-development:
  github.latest:
    - target: {{workspace}}/src/{{project}}
    - unless: test -d {{workspace}}/src/{{project}}/.git

{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{salt['spack.python_exec']()}}
    - pip_upgrade: True
    - use_wheel: True
    - pip_pkgs: [pip, numpy, scipy, pandas, jupyter, requests, matplotlib]

{{project}}:
  funwith.modulefile:
    - cwd: {{workspace}}/src/{{project}}/scripts
    - virtualenv: {{workspace}}/{{python}}
