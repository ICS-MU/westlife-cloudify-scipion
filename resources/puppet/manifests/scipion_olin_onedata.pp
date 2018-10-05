$_ensure = $facts['cloudify_ctx_operation_name'] ? {
  delete  => absent,
  stop    => absent,
  default => present,
}

# clean firewall rules
resources { 'firewall':
  purge => true,
}

##############################################################
# Install / uninstall Onedata client

class { 'onedata':
  ensure => $_ensure,
}
