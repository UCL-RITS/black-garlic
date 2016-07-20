{% set compiler = salt['pillar.get']('compiler', 'gcc') %}
{% set python = salt['pillar.get']('python', 'python2') %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{{project}} spack packages:
  spack.installed:
    - pkgs: &spack_packages
      - GreatCMakeCookoff
      - eigen %{{compiler}} -fftw -scotch -metis -suitesparse
      - swig %{{compiler}}

{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{python}}
    - pip_upgrade: True
    - use_wheel: True
    - pip_pkgs: [pip, numpy, scipy, pytest, pandas, cython, behave]

DCPROGS/HJCFIT:
  github.latest:
    - target: {{workspace}}/wtf/src/{{project}}

dcprogs:
  funwith.modulefile:
    - spack: *spack_packages
    - virtualenv: {{workspace}}/{{python}}
{% if compiler == "gcc" %}
    - footer: |
        setenv("CXX", "g++-5")
        setenv("CC", "gcc-5")
{% endif %}
