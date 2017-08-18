# clean firewall rules
resources { 'firewall':
  purge => true,
}

include ::firewall
include wget
include ::westlife::volume
#include ::archive

$binary_file = 'scipion_v1.0.1_2016-06-30_linux64.tgz'
$onedataurl = 'http://get.onedata.org/oneclient.sh'
############################################################
# Install Scipion prerequisities

# add repository
# sudo add-apt-repository ppa:openjdk-r/ppa
#apt::ppa { 'ppa:openjdk-r/ppa': }

exec {'add-apt-repository':
  command => 'sudo add-apt-repository ppa:openjdk-r/ppa',
  path    => '/usr/bin/',
}

exec { 'apt-get-update':
  command => "/usr/bin/apt-get update",
  require => Exec['add-apt-repository'],
}

package { ['openjdk-8-jdk','libopenmpi-dev','openmpi-bin','gfortran','cmake']:
  ensure => present,
  require => Exec['apt-get-update'],
}
package { ['tk-dev']:
  ensure => present,
  require => Exec['apt-get-update'],
}


#package { ['mc','gcc-c++','glibc-headers','gcc','cmake']:
#  ensure => present,
#}
#package { ['java-1.8.0-openjdk-devel.x86_64','libXft-devel.x86_64','openssl-devel.x86_64']:
#  ensure => present,
#}
#package { ['libXext-devel.x86_64','libxml++.x86_64','libquadmath-devel.x86_64','libxslt.x86_64']:
#  ensure => present,
#}
#package { ['openmpi-devel.x86_64','gsl-devel.x86_64','libX11.x86_64','gcc-gfortran.x86_64']:
#  ensure => present,
#}


############################################################
# Extract binary file



############################################################
# Download binary version
wget::fetch { 'Download binary':
  source      => "http://dior.ics.muni.cz/~cuda/${binary_file}",
  destination =>'/opt/',
  timeout     => 0,
  verbose     => false,
  before      => Exec['unpack_scipion'],
}

#############################################################
# Extract binary version
exec {'unpack_scipion':
  unless  => '/usr/bin/test -f /opt/scipion/scipion',
  cwd     => '/opt',
  command => "tar xvzf /opt/${binary_file}",
  path    => '/bin/',
  before  => File['own_scipion'],
#  before  => Exec['configure_o'],
}



##############################################################
# Set owner and group

file { 'own_scipion':
  ensure  => directory,
  owner   => 'cfy',
  group   => 'cfy',
  path    => '/opt/scipion',
  recurse => true,
  before  => File['ScipionUserData'],
}

##############################################################
# Create ScipionUserData directory

file { 'ScipionUserData':
  ensure => directory,
  owner   => 'cfy',
  group   => 'cfy',
  path => '/data/ScipionUserData',
  mode => '0644',
  before => File['/home/cfy/ScipionUserData'],
}

##############################################################
# Create ScipionUserData link

file { '/home/cfy/ScipionUserData':
  ensure => link,
  target => '/data/ScipionUserData',
  before  => Exec['configure'],
}


##############################################################
# Configure Scipion

exec {'configure':
  command => 'python /opt/scipion/scipion config 2> /tmp/sciconf.log',
  path    => '/usr/bin/',
  user    => 'cfy',
  environment => 'HOME=/home/cfy',
  before  => File['create_service'],
}


##############################################################
# Install chimera
#
#exec {'chimera':
#  command => 'python /opt/scipion/scipion install chimera 2> /tmp/chimera.log',
#  path    => '/usr/bin/',
#  user    => 'cfy',
#  environment => 'HOME=/home/cfy',
#  after  => Exec['configure'],
#}


##############################################################
# Create directory /services

file { 'create_service':
  ensure  => directory,
  owner   => 'cfy',
  group   => 'cfy',
  path    => '/services',
#  before  => File['delete_binary'],
}

##############################################################
# Delete binary tar file

file { 'delete_binary':
  ensure  => absent,
  path    => '/opt/${binary_file}',

}

##############################################################
# Create NFS shares (TODO)

class { '::nfs':
  server_enabled => true
}
nfs::server::export{ '/data/ScipionUserData':
  ensure  => 'mounted',
  clients => '(rw,sync,no_root_squash,no_subtree_check)'
}

nfs::server::export{ '/opt':
  ensure  => 'mounted',
  clients => '(rw,sync,no_root_squash,no_subtree_check)'
}

##############################################################
# Download Onedata client

wget::fetch { 'Onedata_install_script':
  source      => "${onedataurl}",
  destination =>'/tmp/',
  timeout     => 0,
  verbose     => false,
  before      => Exec['onedata-client'],
}

############################################################
# Install Onedata client

exec {'onedata-client':
  command     => "sh /tmp/oneclient.sh",
  path        => '/bin',
  environment => ["PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"]
}
