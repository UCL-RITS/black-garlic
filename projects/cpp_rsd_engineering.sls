{% set compiler = salt["spack.compiler"]() %}
{% set python = salt['pillar.get']('python', 'python3') %}
{% set mpilib = salt['pillar.get']('mpi', 'openmpi') %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{{project}} spack packages:
  spack.installed:
    - pkgs: &spack_packages
    - {{mpilib}} %{{compiler}}

{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{python}}
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

UCL-RITS/research-computing-with-cpp:
  github.latest:
    - target: {{workspace}}/src/{{project}}
    - unless: test -d {{workspace}}/src/{{project}}/.git

{{project}}:
  funwith.modulefile:
    - spack: *spack_packages
    - cwd: {{workspace}}/src/{{project}}
    - virtualenv: {{workspace}}/{{python}}

{{project}} packages:
  pkg.installed:
    - pkgs:
      - pandoc
      - graphviz
      - wget

{{project}} itk:
  pkg.installed:
    - name: insighttoolkit
    - tap: homebrew/science

{{project}} liquid:
  gem.installed:
    - name: liquid

{{project}} jekyll:
  gem.installed:
    - name: jekyll

{{project}} redcarpet:
  gem.installed:
    - name: redcarpet

{{workspace}}/julia/v0.5/REQUIRE:
  file.managed:
    - contents: |
        DataFrames
        FactCheck
        FixedSizeArrays
        Cxx
        IJulia
    - makedirs: True

julia metadir:
  github.latest:
    - name: JuliaLang/METADATA.jl
    - target: {{workspace}}/julia/v0.5/METADATA
    - force_fetch: True

update julia packages:
  cmd.run:
    - name: julia -e "Pkg.resolve()"
    - env:
      - JULIA_PKGDIR: {{workspace}}/julia
      - JUPYTER: {{workspace}}/bin/jupyter

add to modulefile:
  file.append:
    - name: {{salt['funwith.defaults']('modulefiles')}}/{{project}}.lua
    - text: setenv("JULIA_PKGDIR", "{{workspace}}/julia")
