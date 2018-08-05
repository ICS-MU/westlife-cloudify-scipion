---

define(SQ,')

############################################
# Provisioner
#
# Note: Uncomment one of the following provisioners
# to choose between OCCI or Host-pool

define(_PROVISIONER_, occi)dnl
# define(_PROVISIONER_, hostpool)dnl


############################################
# OCCI authentication options

# OCCI server URL, defaults to the CESNET's FedCloud site
occi_endpoint: 'https://carach5.ics.muni.cz:11443'

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
# Host-pool plugin options

# Host-pool service endpoint
hostpool_service_url: 'http://127.0.0.1:8080'

# Host-pool nodes remote user
hostpool_username: 'root'

# Host-pool nodes remote user
hostpool_private_key: | ifelse(_PROVISIONER_,`hostpool',`
esyscmd(`/bin/bash -c 'SQ`set -o pipefail; cat resources/ssh_hostpool/id_rsa | sed -e "s/^/  /"'SQ)
ifelse(sysval, `0', `', `m4exit(`1')')dnl
',`')

############################################
# Contextualization

# remote user for accessing the portal instances
cc_username: 'cfy'

# SSH public key for remote user
cc_public_key: |
esyscmd(`/bin/bash -c 'SQ`set -o pipefail; cat resources/ssh_cfy/id_rsa.pub | sed -e "s/^/  /"'SQ)
ifelse(sysval, `0', `', `m4exit(`1')')dnl

# SSH private key (filename or inline) for remote user
cc_private_key: |
esyscmd(`/bin/bash -c 'SQ`set -o pipefail; cat resources/ssh_cfy/id_rsa | sed -e "s/^/  /"'SQ)
ifelse(sysval, `0', `', `m4exit(`1')')dnl

############################################
# Main node (portal, batch server) deployment parameters

# OS template
#olin_occi_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'
#olin_occi_os_tpl: 'uuid_enmr_egi_ubuntu_server_14_04_lts_cerit_sc_161'
#olin_occi_os_tpl: 'uuid_enmr_gpgpu_egi_ubuntu_server_16_04_lts_cerit_sc_268'
olin_occi_os_tpl: 'uuid_enmr_egi_ubuntu_server_16_04_lts_cerit_sc_271'
#olin_occi_os_tpl: 'uuid_enmr_gpgpu_egi_ubuntu_server_16_04_lts_cerit_sc_269'
#olin_occi_os_tpl: 'uuid_gputestmc_gpgpu_egi_ubuntu_server_16_04_lts_cerit_sc_269'
#olin_occi_os_tpl:  'uuid_gputestmc_egi_ubuntu_server_16_04_lts_cerit_sc_270'

# sizing
olin_occi_resource_tpl: 'medium'

# availability zone
olin_occi_availability_zone: 'uuid_fedcloud_cerit_sc_103'

# network
olin_occi_network: ''

# network pool
olin_occi_network_pool: ''

# scratch size (in GB)
olin_occi_scratch_size: 2

# list of filter tags for the Host-pool
olin_hostpool_tags: ['olin']




############################################
# Worker node deployment parameters

# OS template
#worker_occi_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'
#worker_occi_os_tpl: 'uuid_enmr_egi_ubuntu_server_14_04_lts_cerit_sc_161'
#worker_occi_os_tpl: 'uuid_enmr_gpgpu_egi_ubuntu_server_16_04_lts_cerit_sc_268'
worker_occi_os_tpl: 'uuid_enmr_egi_ubuntu_server_16_04_lts_cerit_sc_271'

# sizing
worker_occi_resource_tpl: 'medium'

# availability zone
worker_occi_availability_zone: 'uuid_fedcloud_cerit_sc_103'

# network
worker_occi_network: ''

# network pool
worker_occi_network_pool: ''

# scratch size (in GB)
worker_occi_scratch_size: 2

# list of filter tags for the Host-pool
worker_hostpool_tags: ['worker']


############################################
# Worker nodes count (autoscaling)
#
# Note: Following parameters are specified as m4 macros, because
# in the blueprint where they are required, inputs can't be used for
# on that place :( Please, respect the different syntax.
#
# In the m4 processed files, these parameters are hidden
#
define(_WORKERS_,       1)dnl	# initial workers count
define(_WORKERS_MIN_,   1)dnl	# minimum workers with autoscaling
define(_WORKERS_MAX_,   3)dnl	# maximum workers with autoscaling


############################################
# Application

# VNC password
olin_vnc_password: 'Scipion4All'

# version of CUDA Toolkit deployed on GPU workers
cuda_release: '8.0'

# enable SSL secured access to the VNC secured by Let's Encrypt
websockify_ssl_enabled: true  # if True, setup valid admin e-mail below

# your valid contact e-mail address
#websockify_ssl_email: 'root@localhost'
websockify_ssl_email: 'holer@ics.muni.cz'

# vim: set syntax=yaml
