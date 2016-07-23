{% set compiler = salt['pillar.get']('compiler', 'gcc') %}
{% set python = salt['pillar.get']('python', 'python2') %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{{project}} spack packages:
  spack.installed:
    - pkgs: &spack_packages
      - GreatCMakeCookoff
      - eigen -fftw -metis -mpfr -scotch -suitesparse %{{compiler}}
      - gbenchmark %{{compiler}}
      - Catch %{{compiler}}
      - spdlog %{{compiler}}
{% if compiler in ["gcc", "intel"] %}
      - openblas %gcc
{% endif %}

{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{python}}
    - pip_upgrade: True
    - use_wheel: True
    - pip_pkgs: [pip, numpy, scipy, pytest, pandas, cython, pyWavelets, jupyter]


libtiff:
  pkg.installed


astro-informatics/sopt:
  github.latest:
    - target: {{workspace}}/src/sopt
    - unless: test -d {{workspace}}/src/sopt/.git


bico:
  funwith.modulefile:
    - spack: *spack_packages
    - virtualenv: {{workspace}}/{{python}}
{% if compiler == "gcc" %}
    - footer: |
        setenv("CXXFLAGS", "-Wall -Wno-parentheses -Wno-deprecated-declarations")
        setenv("BLA_VENDOR", "OpenBlas")
{% elif compiler == "intel" %}
    - footer: |
        setenv("BLA_VENDOR", "OpenBlas")
{% endif %}
