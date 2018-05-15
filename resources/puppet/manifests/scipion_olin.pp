# clean firewall rules
resources { 'firewall':
  purge => true,
}

include ::firewall
include wget
include ::westlife::volume
#include ::archive


$onedataurl = 'http://get.onedata.org/oneclient.sh'


#letsencrypt

class { '::letsencrypt':
        email               => 'pesa@ics.muni.cz',
        unsafe_registration => true,
      }

letsencrypt::certonly { $fqdn:
        plugin               => 'standalone',
        manage_cron          => true,
        cron_before_command  => '/bin/systemctl stop websockify.service',
        cron_success_command => '/bin/systemctl restart websockify.service',
        suppress_cron_output => true,
        before               => Class['websockify'],
      }



# CUDA runtime
kmod::load { 'nouveau':
  ensure => absent,
}

class {'cuda':
  release         => '8.0',
  install_toolkit => false,
  require         => Kmod::Load['nouveau'],
}

exec { 'nvidia-xconfig':
  command => '/usr/bin/nvidia-xconfig -a --use-display-device=None --virtual=1920x1200 --preserve-busid',
  unless  => '/bin/grep nvidia /etc/X11/xorg.conf',
  require => Class['cuda'],
}

# X environment
ensure_packages(['lightdm', 'xfce4', 'xterm', 'mesa-utils'])

class { 'turbovnc':
  passwords => { 'cfy' => lookup('westlife::vnc::password') },
  servers   => {
    1 => {
      'user' => 'cfy',
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

exec {'add-apt-repository':
  command => 'sudo add-apt-repository ppa:openjdk-r/ppa',
  path    => '/usr/bin/',
}

exec { 'apt-get-update':
  command => "/usr/bin/apt-get update",
  require => Exec['add-apt-repository'],
}

# openjdk-8-jdk
package { ['libopenmpi-dev','openmpi-bin','gfortran','cmake']:
  ensure => present,
  require => Exec['apt-get-update'],
}
package { ['tk-dev','python-pip']:
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

class {'scipion':
}

##############################################################
# Download Onedata client
class {'onedata':
}

#############################################################
#Install websockify&novnc
class {'websockify':
}
