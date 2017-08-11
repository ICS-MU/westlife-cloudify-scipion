tosca_definitions_version: cloudify_dsl_1_3

description: >
  Gromacs portal setup via FedCloud OCCI and Puppet.

define(_NODE_SERVER_,       ifdef(`_CFM_',`gromacs.nodes.MonitoredServer',`gromacs.nodes.Server'))dnl
define(_NODE_TORQUESERVER_, ifdef(`_CFM_',`gromacs.nodes.MonitoredTorqueServer',`gromacs.nodes.TorqueServer'))dnl
define(_NODE_WEBSERVER_,    ifdef(`_CFM_',`gromacs.nodes.MonitoredWebServer', `gromacs.nodes.WebServer'))dnl
define(_NODE_SWCOMPONENT_,  ifdef(`_CFM_',`gromacs.nodes.MonitoredSoftwareComponent', `gromacs.nodes.SoftwareComponent'))dnl

dnl *** From gromacs-inputs.yaml.m4 take only macros, drop regular texts.
divert(`-1')dnl
include(scipion-inputs.yaml.m4)dnl
divert(`0')dnl

imports:
  - http://getcloudify.org/spec/cloudify/3.4/types.yaml
#  - http://getcloudify.org/spec/fabric-plugin/1.3.1/plugin.yaml
  - https://raw.githubusercontent.com/ICS-MU/westlife-cloudify-fabric-plugin/master/plugin.yaml
  - http://getcloudify.org/spec/diamond-plugin/1.3.1/plugin.yaml
  - https://raw.githubusercontent.com/ICS-MU/westlife-cloudify-occi-plugin/master/plugin.yaml
#  - https://raw.githubusercontent.com/ICS-MU/westlife-cloudify-westlife-workflows/master/plugin.yaml
  - types/puppet.yaml
  - types/server.yaml
  - types/softwarecomponent.yaml
#  - types/torqueserver.yaml
  - types/webserver.yaml

inputs:
  # OCCI
  occi_endpoint:
    default: ''
    type: string
  occi_auth:
    default: ''
    type: string
  occi_username:
    default: ''
    type: string
  occi_password:
    default: ''
    type: string
  occi_user_cred:
    default: ''
    type: string
  occi_ca_path:
    default: ''
    type: string
  occi_voms:
    default: False
    type: boolean

  # contextualization
  cc_username:
    default: cfy
    type: string
  cc_public_key:
    type: string
  cc_private_key_filename:
    type: string
  cc_data:
    default: {}

  # VM parameters
  olin_os_tpl:
    type: string
  olin_resource_tpl:
    type: string
  olin_availability_zone:
    type: string
  olin_scratch_size:
    type: integer
  worker_os_tpl:
    type: string
  worker_resource_tpl:
    type: string
  worker_availability_zone:
    type: string
  worker_scratch_size:
    type: integer

  # Application parameters

dsl_definitions:
  occi_configuration: &occi_configuration
    endpoint: { get_input: occi_endpoint }
    auth: { get_input: occi_auth }
    username: { get_input: occi_username }
    password: { get_input: occi_password }
    user_cred: { get_input: occi_user_cred }
    ca_path: { get_input: occi_ca_path }
    voms: { get_input: occi_voms }

  cloud_configuration: &cloud_configuration
    username: { get_input: cc_username }
    public_key: { get_input: cc_public_key }
    data: { get_input: cc_data }

  fabric_env: &fabric_env
    user: { get_input: cc_username }
    key_filename: { get_input: cc_private_key_filename }

  agent_configuration: &agent_configuration
    install_method: remote
    user: { get_input: cc_username }
    key: { get_input: cc_private_key_filename }

  puppet_config: &puppet_config
#    repo: 'https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm'
    repo: 'https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb'
    package: 'puppet-agent'
    download: resources/puppet.tar.gz

node_templates:
  olinNode:
    type: _NODE_SERVER_
    properties:
      name: 'Scipion all-in-one server node'
      resource_config:
        os_tpl: { get_input: olin_os_tpl }
        resource_tpl: { get_input: olin_resource_tpl }
        availability_zone: { get_input: olin_availability_zone }
      agent_config: *agent_configuration
      cloud_config: *cloud_configuration
      occi_config: *occi_configuration
      fabric_env: *fabric_env

  olinStorage:
    type: cloudify.occi.nodes.Volume
    properties:
      size: { get_input: olin_scratch_size }
      availability_zone: { get_input: olin_availability_zone }
      occi_config: *occi_configuration
    relationships:
      - type: cloudify.occi.relationships.volume_contained_in_server
        target: olinNode

  scipion:
    type: _NODE_WEBSERVER_
    instances:
      deploy: 1
    properties:
      fabric_env:
        <<: *fabric_env
        host_string: { get_attribute: [olinNode, ip] }
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/scipion_olin.pp
        hiera:
          westlife::volume::device: /dev/vdc
          westlife::volume::fstype: ext4
          westlife::volume::mountpoint: /data
          westlife::volume::mode: '1777'
    relationships:
      - type: cloudify.relationships.contained_in
        target: olinNode
      - type: cloudify.relationships.depends_on
        target: olinStorage

  workerNode:
    type: _NODE_SERVER_
    properties:
      name: 'Scipion Worker node'
      resource_config:
        os_tpl: { get_input: worker_os_tpl }
        resource_tpl: { get_input: worker_resource_tpl }
        availability_zone: { get_input: worker_availability_zone }
      agent_config: *agent_configuration
      cloud_config: *cloud_configuration
      occi_config: *occi_configuration
      fabric_env: *fabric_env

  scipionWorker:
    type: _NODE_WEBSERVER_
    instances:
      deploy: 1
    properties:
      fabric_env:
        <<: *fabric_env
        host_string: { get_attribute: [workerNode, ip] }
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/scipion_worker.pp
    relationships:
      - type: cloudify.relationships.contained_in
        target: workerNode



outputs:
  web_endpoint:
    description: Scipion portal endpoint
    value:
      url: { concat: ['http://', { get_attribute: [olinNode, ip] }] }
  worker_ip:
    description: Worker IP
    value:
      ip: { get_attribute: [workerNode,ip] }


# vim: set syntax=yaml
