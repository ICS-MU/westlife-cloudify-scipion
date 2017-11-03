class websockify {

vcsrepo { "/opt/novnc/":
  ensure    => present,
  provider  => git,
  source    =>'https://github.com/novnc/noVNC',
  depth     => '1',
  before => Service['websockify'],
}
exec {'websockify_install':
  command     => "pip install websockify",
  path        => '/usr/bin',
  before => Service['websockify'],
}


file {'/etc/systemd/system/websockify.service':
	ensure => present,
	source => 'puppet:///modules/websockify/websockify.service',
  before => Service['websockify'],
}

service {'websockify':
  ensure => 'running',
  enable => 'true',
}

}
