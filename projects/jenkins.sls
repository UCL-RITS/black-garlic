# expects a few pillars in secrets.sls:
# jenkins_token:
#     staging: xxxxx
#     production: xxxxx
# slack_token:
#     rits: xxxx
#     ccs: xxx
#     bico: xxx

{% set project = sls.split('.')[-1] %}
{% set workspace = salt['funwith.workspace'](project) %}

ucl-rits/jenkins-job-builder-files:
  github.latest:
    - target: {{workspace}}/src/{{project}}
    - unless: test -d {{workspace}}/src/{{project}}/.git

UCL/jenkjobs:
  github.latest:
    - target: {{workspace}}/src/JenkJobs
    - unless: test -d {{workspace}}/src/JenkJobs/.git

UCL-RITS/rc_puppet:
  github.latest:
    - target: {{workspace}}/src/rc-puppet
    - unless: test -d {{workspace}}/src/rc-puppet/.git

UCL-RITS/rcps-buildscripts:
  github.latest:
    - target: {{workspace}}/src/buildscripts
    - unless: test -d {{workspace}}/src/buildscripts/.git

{{workspace}}:
  virtualenv.managed:
    - python: python2
    - use_wheel: True
    - pip_upgrade: True
    - pip_pkgs:
      - pip
      - jupyter
      - numpy
      - scipy
      - pytest
      - pandas
      - cython
      - python-jenkins
      - jenkins-job-builder
      - git+https://github.com/UCL/jenkjobs


{{workspace}}/bin/production.sh:
  file.managed:
    - mode: 0775
    - contents: |
        #! /usr/local/bin/zsh
        echo "UCL RSDT Jenkins" > {{workspace}}/src/{{project}}/jenkinsdescription.yaml
        jenkins-jobs --ignore-cache --conf {{workspace}}/.production.ini "$@"


{{workspace}}/bin/staging.sh:
  file.managed:
    - mode: 0775
    - contents: |
        #! /usr/local/bin/zsh
        echo "UCL RSDT Jenkins (Staging)" > {{workspace}}/src/{{project}}/jenkinsdescription.yaml
        jenkins-jobs --ignore-cache --conf {{workspace}}/.staging.ini "$@"

{{workspace}}/src/{{project}}/purify-slack-token:
  file.managed:
    - mode: 0500
    - contents: {{salt['pillar.get']('slack_token:bico')}}

{{workspace}}/src/{{project}}/ucl-rits-slack-token:
  file.managed:
    - mode: 0500
    - contents: {{salt['pillar.get']('slack_token:rits')}}

{{project}}:
  funwith.modulefile:
    - workspace: {{workspace}}
    - cwd: {{workspace}}/src/{{project}}
    - virtualenv: {{project}}


{{workspace}}/.staging.ini:
  file.managed:
    - contents: |
        [jenkins]
        user=mdavezac
        password={{salt['pillar.get']('jenkins_token:staging')}}
        url=http://staging.development.rc.ucl.ac.uk/

{{workspace}}/.production.ini:
  file.managed:
    - contents: |
        [jenkins]
        user=mdavezac
        password={{salt['pillar.get']('jenkins_token:production')}}
        url=http://jenkins.rc.ucl.ac.uk

{{workspace}}/src/jenkins/branch.yaml:
  file.managed:
    - contents: production

{{workspace}}/bin/build.zsh:
  file.managed:
    - contents: ssh jenkins_legion "bash -l" < $1
    - mode: 700
