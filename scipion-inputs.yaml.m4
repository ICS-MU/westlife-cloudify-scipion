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
olin_os_tpl: 'uuid_enmr_egi_ubuntu_server_14_04_lts_cerit_sc_161'

# sizing
olin_resource_tpl: 'medium'

# availability zone
olin_availability_zone: 'uuid_fedcloud_cerit_sc_103'

# scratch size (in GB)
olin_scratch_size: 30


############################################
# Worker node deployment parameters

# OS template
#worker_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'
worker_os_tpl: 'uuid_enmr_egi_ubuntu_server_14_04_lts_cerit_sc_161'

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
