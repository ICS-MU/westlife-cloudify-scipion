class scipion (
  $ensure       = $scipion::params::ensure,
  $source_url   = $scipion::params::source_url
) inherits scipion::params {

  unless defined(Class['scipion::user']) {
    class { 'scipion::user':
      ensure => $ensure,
    }
  }

  require java

  contain scipion::install

  case $ensure {
    present: {
      contain scipion::config

      Class['scipion::user']
        -> Class['scipion::install']
        -> Class['scipion::config']
    }

    absent: {
      Class['scipion::install']
        -> Class['scipion::user']
    }

    default: {
      fail("Unsupported ensure state: ${ensure}")
    }
  }
}
