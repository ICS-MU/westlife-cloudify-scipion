# CUDA runtime
kmod::load { 'nouveau':
  ensure => absent,
}

class { 'cuda':
  release         => '7.0',
  install_toolkit => false,
  require         => Kmod::Load['nouveau'],
}

exec { 'nvidia-xconfig':
  command => '/usr/bin/nvidia-xconfig -a --use-display-device=None --virtual=1920x1200 --preserve-busid',
  unless  => '/bin/grep nvidia /etc/X11/xorg.conf',
  require => Class['cuda'],
}

# X environment
ensure_packages(['lightdm', 'openbox', 'xterm', 'mesa-utils'])

file_line { 'openbox-menu-chimera':
  ensure  => present,
  line    => '  <item label="Chimera"><action name="Execute"><execute>vglrun /opt/chimera/bin/chimera</execute></action></item>',
  after   => '^\s*\<menu id="root',
  path    => '/etc/xdg/openbox/menu.xml',
  require => Package['openbox'],
}

file { '/etc/lightdm/lightdm.conf.d':
  ensure  => directory,
  require => Package['lightdm'],
}

file { '/etc/lightdm/lightdm.conf.d/autologin.conf':
  ensure  => file,
  require => Package['openbox'],
  content => '
[SeatDefaults]
user-session=openbox
greeter-session=gtk-greeter
autologin-user=cfy
autologin-user-timeout=0
',
}

# TurboVNC
class { 'turbovnc':
  passwords => { 'cfy' => 'Scipion4u' },
  servers   => {
    1 => {
      'user' => 'cfy',
      'args' => '-geometry 800x600 -nohttpd -xstartup openbox',
    },
  },
}

# Chimera
include chimera
