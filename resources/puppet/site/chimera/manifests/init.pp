class chimera (
  $version     = $chimera::params::version,
  $destination = $chimera::params::destination
) inherits chimera::params {

  file { '/tmp/.chimera':
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0700',
  }

  file { '/tmp/.chimera/get_chimera.sh':
    ensure => file,
    source => 'puppet:///modules/chimera/get_chimera.sh',
    mode   => '0700',
  }

  exec { 'get_chimera.sh':
    command     => '/tmp/.chimera/get_chimera.sh',
    #creates     => '/tmp/.chimera/chimera',
    creates     => "${destination}/bin/chimera",
    environment => ["VERSION=${version}", "OUTPUT=/tmp/.chimera/chimera"],
    logoutput   => true,
    require     => File['/tmp/.chimera/get_chimera.sh'],
  }

  exec { 'chimera::install':
    command   => "echo '${destination}' | /tmp/.chimera/chimera",
    creates   => "${destination}/bin/chimera",
    provider  => shell,
  }
}
