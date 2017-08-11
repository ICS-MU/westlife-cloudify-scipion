# Install prerequisities

exec {'add-apt-repository':
  command => 'sudo add-apt-repository ppa:openjdk-r/ppa',
  path    => '/usr/bin/',
}

exec { 'apt-get-update':
  command => "/usr/bin/apt-get update",
  require => Exec['add-apt-repository'],
}

package { ['openjdk-8-jdk','libopenmpi-dev','openmpi-bin','gfortran']:
  ensure => present,
  require => Exec['apt-get-update'],
}
package { ['tk-dev']:
  ensure => present,
  require => Exec['apt-get-update'],
}


# Install NFS client
class { '::nfs':
    client_enabled => true,
}

# Mount ScipionUserData

#Nfs::Client::Mount <<| |>> {
#   ensure => 'mounted',
# }

# Mount /opt

#Nfs::Client::Mount <<| |>> {
#   ensure => 'mounted',
# }
