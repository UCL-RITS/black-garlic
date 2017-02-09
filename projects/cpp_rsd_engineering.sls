{% set compiler = salt['pillar.get']('compiler', 'gcc') %}
{% set python = salt['pillar.get']('python', 'python2') %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{{project}} spack packages:
  spack.installed:
    - pkgs: &spack_packages
    - openmpi %clang

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
