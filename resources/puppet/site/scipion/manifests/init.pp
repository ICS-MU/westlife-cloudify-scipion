class scipion {
  require java

  $binary_folder = 'http://webserver.ics.muni.cz/westlife/'
  #$binary_file = 'scipion_v1.0.1_with_chimera.tgz'
  $binary_file = 'scipion_v1.1_2017-06-14_with_chimera.tgz'

  ############################################################
  # Download binary version
  wget::fetch { 'Download binary':
    source      => "${binary_folder}${binary_file}",
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
  # Create ~/.config/scipion directory
  file {['/home/cfy/.config','/home/cfy/.config/scipion']:
    ensure => directory,
    owner   => 'cfy',
    group   => 'cfy',
    before => File['/home/cfy/.config/scipion/scipion.conf']
}

  ##############################################################
  # Copy scipion.conf to .config
  file {'/home/cfy/.config/scipion/scipion.conf':
    ensure => present,
    source => 'puppet:///modules/scipion/scipion.conf',
    owner   => 'cfy',
    group   => 'cfy',
    before => Exec['configure']
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

}
