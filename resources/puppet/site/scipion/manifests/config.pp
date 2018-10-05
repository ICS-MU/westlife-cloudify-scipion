class scipion::config {
  $_ensure_link = $scipion::ensure ? {
    present => link,
    default => absent,
  }

  $_ensure_dir = $scipion::ensure ? {
    present => directory,
    default => absent,
  }

  ##############################################################
  # Create ScipionUserData link

  file { "/home/${scipion::user::user_name}/ScipionUserData":
    ensure => $_ensure_link,
    target => '/data/ScipionUserData',
    before => Exec['configure'],
  }

  ##############################################################
  # Create ~/.config/scipion directory

  $_configs = [
    "/home/${scipion::user::user_name}/.config",
    "/home/${scipion::user::user_name}/.config/scipion"
  ]

  file { $_configs:
    ensure => $_ensure_dir,
    owner  => $scipion::user::user_name,
    group  => $scipion::user::group_name,
  }

  ##############################################################
  # Copy scipion.conf to .config
  file { "/home/${scipion::user::user_name}/.config/scipion/scipion.conf":
    ensure => $scipion::ensure,
    source => 'puppet:///modules/scipion/scipion.conf',
    owner  => $scipion::user::user_name,
    group  => $scipion::user::group_name,
    before => Exec['configure']
  }

  if ($scipion::ensure == 'present') {
    ##############################################################
    # Configure Scipion

    exec {'configure':
      command     => 'python /opt/scipion/scipion config 2> /tmp/sciconf.log',
      path        => '/usr/bin/',
      user        => $scipion::user::user_name,
      environment => "HOME=/home/${scipion::user::user_name}",
      before      => File['/services'],
    }
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

  file { '/services':
    ensure => $_ensure_dir,
    owner  => $scipion::user::user_name,
    group  => $scipion::user::group_name,
    force  => true,
    backup => false,
  }
}
