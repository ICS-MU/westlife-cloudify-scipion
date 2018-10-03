$_ensure = $facts['cloudify_ctx_operation_name'] ? {
  delete  => absent,
  stop    => absent,
  default => present,
}

# clean firewall rules
resources { 'firewall':
  purge => true,
}

Package {
  require => Class['apt::update'],
}

include apt
include firewall
include westlife::volume

# CUDA runtime
# setup CUDA only if release specified
$cuda_release = lookup('cuda::release')
if (length("${cuda_release}")>0) {        ## and ($facts['has_nvidia_gpu']==true) {
  kmod::load { 'nouveau':
    ensure => absent,
  }

  class {'cuda':
    ensure          => $_ensure,
    install_toolkit => false,
    require         => Kmod::Load['nouveau'],
  }

  case $_ensure {
    present: {
      exec { 'nvidia-xconfig':
        command => '/usr/bin/nvidia-xconfig -a --use-display-device=None --virtual=1920x1200 --preserve-busid',
        unless  => '/bin/grep nvidia /etc/X11/xorg.conf',
        require => Class['cuda'],
      }

      Class['cuda']
        -> Class['onedata']
    }

    absent: {
      Class['onedata']
        -> Class['cuda']
    }

    default: {
      fail("Unsupported ensure state: ${_ensure}")
    }
  }
}

# X environment
ensure_packages(['lightdm', 'xfce4', 'xterm', 'mesa-utils'])

class { 'turbovnc':
  ensure    => $_ensure,
  passwords => { 'scipion' => lookup('westlife::vnc::password') },
  servers   => {
    1 => {
      'user' => 'scipion',
      'args' => '-geometry 1024x768 -nohttpd',
#      'args' => '-geometry 1024x768 -nohttpd -xstartup openbox',
    },
  },
  before => File['10-xhost.conf'],
}

file {'10-xhost.conf':
  path => "/etc/lightdm/lightdm.conf.d/10-xhost.conf",
  content => "[SeatDefaults]\ndisplay-setup-script=xhost +",
}
#include chimera

############################################################
# Install Scipion prerequisities

# add repository
# sudo add-apt-repository ppa:openjdk-r/ppa
#apt::ppa { 'ppa:openjdk-r/ppa': }
#
#exec {'add-apt-repository':
#  command => 'sudo add-apt-repository ppa:openjdk-r/ppa',
#  path    => '/usr/bin/',
#}
#
#exec { 'apt-get-update':
#  command => "/usr/bin/apt-get update",
#  require => Exec['add-apt-repository'],
#}

apt::ppa { 'ppa:openjdk-r/ppa':
  ensure => $_ensure,
}

# openjdk-8-jdk
package { ['libopenmpi-dev','openmpi-bin','gfortran','cmake']:
  ensure => $_ensure,
  #require => Exec['apt-get-update'],
  require => Apt::Ppa['ppa:openjdk-r/ppa'],
}

package { ['tk-dev','python-pip']:
  ensure => $_ensure,
  #require => Exec['apt-get-update'],
  require => Apt::Ppa['ppa:openjdk-r/ppa'],
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

# ##############################################################
# # Create NFS shares (TODO)
# 
# class { '::nfs':
#   server_enabled => true
# }
# nfs::server::export{ '/data/ScipionUserData':
#   ensure  => 'mounted',
#   clients => '(rw,sync,no_root_squash,no_subtree_check)'
# }
# 
# nfs::server::export{ '/opt':
#   ensure  => 'mounted',
#   clients => '(rw,sync,no_root_squash,no_subtree_check)'
# }

class { 'scipion':
  ensure => $_ensure,
}

if $_ensure == present {
  Class['scipion'] -> Class['turbovnc']
} else {
  Class['turbovnc'] -> Class['scipion']
}


##############################################################
# Download Onedata client

class {'onedata':
  ensure => $_ensure,
}

#############################################################
# Install websockify&novnc

class { 'novnc':
  ensure => $_ensure,
}

class { 'websockify':
  ensure      => $_ensure,
  source_port => 8000,
  target_addr => 'localhost',
  target_port => 5901,
  web         => '/opt/novnc',
  require     => Class['novnc'],
}
