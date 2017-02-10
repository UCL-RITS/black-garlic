{% set compiler = salt["spack.compiler"]() %}
{% set python = salt["pillar.get"]("python", "python3") %}
{% set mpilib = salt["pillar.get"]("mpi", "openmpi")  %}
{% set project = sls.split(".")[-1] %}
{% set workspace = salt["funwith.workspace"](project) %}

{{project}} spack packages:
  spack.installed:
    - pkgs: &spack_packages
      - GreatCMakeCookoff
      - {{mpilib}} %{{compiler}}
      - eigen -fftw -metis -mpfr -scotch -suitesparse %{{compiler}}
      - gbenchmark %{{compiler}}
      - catch %{{compiler}}
      - spdlog %{{compiler}}
{% if compiler == "intel" %}
      - openblas %gcc
{% else %}
      - openblas %{{compiler}}
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
    - cwd: {{workspace}}/src/sopt
{% if compiler == "gcc" %}
    - footer: |
        setenv("CXXFLAGS", "-Wall -Wno-parentheses -Wno-deprecated-declarations")
        setenv("BLA_VENDOR", "OpenBLAS")
{% elif compiler != "intel" %}
    - footer: |
        setenv("BLA_VENDOR", "OpenBLAS")
{% endif %}
