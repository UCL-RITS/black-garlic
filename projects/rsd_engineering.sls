{% set compiler = salt["spack.compiler"]() %}
{% set python = salt['spack.python']() %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{salt['spack.python_exec']()}}
    - pip_upgrade: True
    - use_wheel: True
    - pip_pkgs: 
      - pip
      - numpy
      - scipy
      - pytest
      - pytest-cov
      - jupyter
      - matplotlib
      - git+https://github.com/jakevdp/JSAnimation.git

UCL/rsd-engineeringcourse:
  github.latest:
    - target: {{workspace}}/src/{{project}}
    - unless: test -d {{workspace}}/src/{{project}}/.git

{{project}}:
  funwith.modulefile:
    - cwd: {{workspace}}/src/{{project}}
    - virtualenv: {{workspace}}/{{python}}
