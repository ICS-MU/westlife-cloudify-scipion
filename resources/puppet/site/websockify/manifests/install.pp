class websockify::install {
#vcsrepo { "/opt/novnc/":
#  ensure    => present,
#  provider  => git,
#  source    =>'https://github.com/novnc/noVNC',
#  depth     => '1',
#  before => Service['websockify'],
#}

  $_ensure = $websockify::ensure ? {
    present => present,
    default => absent,
  }

  package { 'websockify':
    ensure   => $_ensure,
    provider => 'pip',
  }
}
