############################################
# OCCI authentication options

# OCCI server URL, defaults to the CESNET's FedCloud site
#occi_endpoint: 'https://carach5.ics.muni.cz:11443'
occi_endpoint: 'https://nova3.ui.savba.sk:8787/occi1.1'

# OCCI authentication method, valid options: x509, token, basic, digest, none
occi_auth: 'x509'

# OCCI username for basic or digest authentication, defaults to "anonymous"
occi_username: ''

# OCCI password for basic, digest and x509 authentication
occi_password: ''

# OCCI path to user's x509 credentials
occi_user_cred: '/tmp/x509up_u1000'

# OCCI path to CA certificates directory
occi_ca_path: ''

# OCCI using VOMS credentials; modifies behavior of the X509 authN module
occi_voms: True


############################################
# Contextualization

# remote user for accessing the portal instances
cc_username: 'cfy'

# SSH public key for remote user
cc_public_key: 'include(`resources/ssh_cfy/id_rsa.pub')'

# SSH private key (filename or inline) for remote user
# TODO: better dettect CFM path
cc_private_key_filename: 'ifdef(`_CFM_',`/opt/manager/resources/blueprints/_CFM_BLUEPRINT_/resources/ssh_cfy/id_rsa',`resources/ssh_cfy/id_rsa')'


############################################
# Main node (portal, batch server) deployment parameters

# OS template
#olin_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'
#olin_os_tpl: 'uuid_enmr_egi_ubuntu_server_14_04_lts_cerit_sc_161'
#olin_os_tpl: 'uuid_enmr_gpgpu_egi_ubuntu_server_16_04_lts_cerit_sc_268'
#olin_os_tpl:  'uuid_gputestmc_egi_ubuntu_server_16_04_lts_cerit_sc_270'

# Image for EGI Ubuntu 14.04 [Ubuntu/14.04/VirtualBox]
#olin_os_tpl: '7ccf5309-4a00-4ba7-a744-423fe121638a'

# Image for EGI CentOS 7 [CentOS/7/VirtualBox]
#olin_os_tpl: '9b6748ad-bc31-4dbe-9c97-dff49e711b1a'

# Image for EGI Docker Ubuntu 16.04 [Ubuntu/16.04/VirtualBox]
olin_os_tpl: 'db5ad854-8a36-4e75-b064-3b09fd61eff4'

# Flavor: m1.medium
olin_resource_tpl: '3'

# sizing
#olin_resource_tpl: 'medium'

# availability zone
#olin_availability_zone: 'uuid_fedcloud_cerit_sc_103'

# scratch size (in GB)
#olin_scratch_size: 30

# network
olin_network: 'http://nova3.ui.savba.sk:8774/occi1.1/network/PUBLIC'

# network pool
olin_network_pool: ''




############################################
# Worker node deployment parameters

# OS template
#worker_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'
#worker_os_tpl: 'uuid_enmr_egi_ubuntu_server_14_04_lts_cerit_sc_161'
worker_os_tpl: 'uuid_enmr_gpgpu_egi_ubuntu_server_16_04_lts_cerit_sc_268'

# sizing
worker_resource_tpl: 'medium'

# availability zone
worker_availability_zone: 'uuid_fedcloud_cerit_sc_103'

# scratch size (in GB)
worker_scratch_size: 30


############################################
# Worker nodes count (autoscaling)
#
# Note: Following parameters are specified as m4 macros, because
# in the blueprint where they are required, inputs can't be used for
# on that place :( Please, respect the different syntax.
#
# In the m4 processed files, these parameters are hidden
#
define(_WORKERS_,       2)dnl	# initial workers count
define(_WORKERS_MIN_,   1)dnl	# minimum workers with autoscaling
define(_WORKERS_MAX_,   3)dnl	# maximum workers with autoscaling


# vim: set syntax=yaml
