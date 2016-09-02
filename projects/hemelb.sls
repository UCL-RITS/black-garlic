{% set compiler = salt['pillar.get']('compiler', 'gcc') %}
{% set python = salt['pillar.get']('python', 'python2') %}
{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

{{project}} spack packages:
  spack.installed:
    - pkgs: &spack_packages
      - GreatCMakeCookoff
      - boost %{{compiler}}
      - openmpi@1.10.2 %{{compiler}} -tm
      - hdf5 %{{compiler}} -fortran -cxx +mpi ^openmpi
      - gdb %{{compiler}}
      - metis %{{compiler}} +double
      - parmetis %{{compiler}} ^openmpi
      - Tinyxml %{{compiler}}
      - cppunit %{{compiler}}
      - CTemplate %{{compiler}}


{{workspace}}/src/hemelb/build/tmp:
      file.directory


{{workspace}}/{{python}}:
  virtualenv.managed:
    - python: {{python}}
    - pip_upgrade: True
    - use_wheel: True
    - pip_pkgs: [pip, numpy, scipy, pandas, jupyter]


{{project}}:
  funwith.modulefile:
    - spack: *spack_packages
    - cwd: {{workspace}}/src/{{project}}
    - virtualenv: {{workspace}}/{{python}}
