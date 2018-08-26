class websockify (
  String  $ensure               = $websockify::params::ensure,
  Boolean $ssl_enabled          = $websockify::params::ssl_enabled,
  String  $ssl_email            = $websockify::params::ssl_email,
  Array[String, 1] $ssl_domains = $websockify::params::ssl_domains,
  Optional[String] $source_addr = $websockify::params::source_addr,
  Integer $source_port          = $websockify::params::source_port,
  String $target_addr           = $websockify::params::target_addr,
  Integer $target_port          = $websockify::params::target_port,
  Optional[String] $web         = $websockify::params::web,
  String $binary                = $websockify::params::binary
) inherits websockify::params {

  $_cmd_source = size($source_addr) > 0 ? {
    true    => "${source_addr}:${source_port}",
    default => $source_port
  }

  $_cmd_web = size($web) > 0 ? {
    true    => "--web ${web}",
    default => '',
  }

  $_cmd_ssl = $ssl_enabled ? {
    true    => "--cert /etc/letsencrypt/live/${ssl_domains[0]}/fullchain.pem --key /etc/letsencrypt/live/${ssl_domains[0]}/privkey.pem",
    default => '',
  }

  $_cmd = "${binary} ${_cmd_source} ${target_addr}:${target_port} ${_cmd_web} ${_cmd_ssl}"

  contain websockify::install
  contain websockify::config
  contain websockify::service

  case $ensure {
    present: {
      Class['websockify::install']
        -> Class['websockify::config']
        ~> Class['websockify::service']

      Class['websockify::install']
        ~> Class['websockify::service']
    }

    absent: {
      Class['websockify::service']
        -> Class['websockify::config']
        -> Class['websockify::install']
    }

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
