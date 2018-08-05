class websockify (
  String  $ensure               = $websockify::params::ensure,
  Boolean $ssl_enabled          = $websockify::params::ssl_enabled,
  String  $ssl_email            = $websockify::params::ssl_email,
  Array[String, 1] $ssl_domains = $websockify::params::ssl_domains,
  Optional[String] $source_addr = $websockify::params::source_addr,
  Integer $source_port          = $websockify::params::source_port,
  String $target_addr           = $websockify::params::target_addr,
  Integer $target_port          = $websockify::params::target_port
) inherits websockify::params {

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
