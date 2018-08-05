class websockify::params {
  $ensure = present
  $ssl_enabled = false
  $ssl_email = 'root@localhost'
  $ssl_domains = [ $facts['networking']['fqdn'] ]

  # daemon
  $web = undef
  $source_addr = undef
  $source_port = undef
  $target_addr = 'localhost'
  $target_port = undef
}
