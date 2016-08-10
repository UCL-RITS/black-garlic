{% set compiler = salt['pillar.get']('compiler', 'gcc') %}
{% set python = salt['pillar.get']('python', 'python3') %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{% set openmp = "-openmp" if compiler != 'clang' else "-openmp"%}
{% set ldflags = "/usr/local/Cellar/gcc/6.1.0/lib/gcc/6/libgfortran.dylib" %}

{% if compiler == "clang" %}
belos spack packages:
  spack.installed:
    - name: belos +mpi {{openmp}} +lapack %{{compiler}} ^openmpi ^openblas {{openmp}}
    - environ:
        LDFLAGS: {{ldflags}}
{% endif %}

{{project}} spack packages:
  spack.installed:
    - pkgs: &spack_packages
      - GreatCMakeCookoff
      - eigen -fftw -metis -mpfr -scotch -suitesparse %{{compiler}}
      - f2c %{{compiler}}
      - gsl %{{compiler}}
      - hdf5 -fortran -cxx -mpi %{{compiler}}
      - Catch %{{compiler}}
      - openmpi %{{compiler}}
      - gbenchmark %{{compiler}}
{% if compiler == "intel" %}
      - openblas %gcc {{openmp}}
      - scalapack +debug %gcc  ^openmpi ^openblas {{openmp}}
      - belos +mpi {{openmp}} +lapack %{{compiler}} ^openmpi ^openblas%gcc{{openmp}}
{% else %}
      - openblas %{{compiler}} {{openmp}}
      - scalapack +debug %{{compiler}}  ^openmpi ^openblas {{openmp}}
      - belos +mpi {{openmp}} +lapack %{{compiler}} ^openmpi ^openblas {{openmp}}
{% endif %}
      - >
        boost %{{compiler}}
        -python  +singlethreaded
        -mpi -multithreaded -program_options -random -regex -serialization
        -signals -system -test -thread -wave


{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{python}}
    - use_wheel: True
    - pip_upgrade: True
    - pip_pkgs: [pip, numpy, scipy, pandas, jupyter, ipywidgets, invoke, paramiko, py]


{{project | upper}}/{{project | upper}}:
  github.latest:
    - target: {{workspace}}/src/{{project}}
    - submodules: True
    - unless: test -d {{workspace}}/src/{{project}}


{{project}} modulefile:
  funwith.modulefile:
    - name: {{project}}
    - cwd: {{workspace}}/src/{{project}}
    - virtualenv: {{workspace}}/{{python}}
    - spack: *spack_packages
    - footer: |
        setenv("BLA_VENDOR", "OpenBLAS")
{% if compiler == "clang" %}
        setenv("LDFLAGS", "{{ldflags}}")
{% elif compiler == "gcc" %}
        setenv("LDFLAGS", "-lgfortran")
        setenv("CXXFLAGS", "-Wno-parentheses -Wno-deprecated-declarations")
{% endif %}
        setenv("JULIA_PKGDIR", "{{workspace}}/julia")


{{project | upper}}/BenchmarkingData:
  github.latest:
    - target: {{workspace}}/src/benchmark_data
    - unless: test -d {{workspace}}/src/benchmark_data

{{workspace}}/julia/v0.4/REQUIRE:
  file.managed:
    - contents: |
        YAML
        DataFrames
    - makedirs: True

JuliaLang/METADATA.jl:
  github.latest:
    - target: {{workspace}}/julia/v0.4/METADATA
    - force_reset: True

update julia packages:
  cmd.run:
    - name: julia -e "Pkg.resolve()"
    - env:
      - JULIA_PKGDIR: {{workspace}}/julia
      - JUPYTER: {{workspace}}/bin/jupyter
