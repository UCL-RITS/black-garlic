{% set compiler = salt["spack.compiler"]() %}
{% set python = salt['pillar.get']('python', 'python3') %}
{% set workspace = salt['funwith.workspace'](project) %}
{% set pyver = python[:-1] + "@" + python[-1] %}

{{project}} spack packages:
  spack.installed:
    - pkgs: &spack_packages
      - boost %{{compiler}} +python ^python@{{pyver}}
      - tbb %{{compiler}}
      - gmsh %{{compiler}}

{{project}}/{{project}}:
  github.present:
    - target: {{prefix}}/src/{{project}}

spack packages:
  spack.installed:
    - pkgs: &spack_packages

{{project}} virtualenv:
  virtualenv.managed:
    - name: {{workspace}}/{{python}}
    - python: {{python}}
    - use_wheel: True
    - pip_upgrade: True
    - pip_pkgs: [pip, numpy, scipy, pytest, pandas, cython, jupyter, mako]

{{project}}:
  funwith.modulefile:
    - prefix: {{prefix}}
    - cwd: {{prefix}}/src/{{project}}
    - spack: &spack_packages
    - virtualenv: True
