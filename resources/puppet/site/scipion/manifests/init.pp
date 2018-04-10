class scipion {
  require java

  $binary_folder = 'http://scipion.cnb.csic.es/downloads/scipion/software/binary/'
  #$binary_file = 'scipion_v1.0.1_with_chimera.tgz'
  $binary_file = 'scipion_v1.2_2018-04-02_linux64.tgz'

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
  # Create Data directory if not exists

  file { 'Data':
    ensure => directory,
    path => '/data',
    before => File['ScipionUserData'],
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
    before  => File['/home/cfy/Desktop/scipion.desktop']
  }

  ##############################################################
  # Create a desktop shortcut
  file {'/home/cfy/Desktop/scipion.desktop':
    ensure => present,
    source => 'puppet:///modules/scipion/Scipion.desktop',
    owner   => 'cfy',
    group   => 'cfy',
    before => Exec['chimera']
  }

  exec {'chimera':
    command => 'python /opt/scipion/scipion install --no-xmipp chimera > /tmp/chimera.log',
    user    => 'cfy',
    environment => 'HOME=/home/cfy',
    provider => 'shell',
    before  => Exec['relion'],
  }

  ##############################################################
  # Install relion
  #
  exec {'relion':
    command => 'python /opt/scipion/scipion install --no-xmipp relion-2.0 > /tmp/relion.log',
    user    => 'cfy',
    environment => 'HOME=/home/cfy',
    provider => 'shell',
    #before  => Exec['ctffind4'],
  }

  ##############################################################
  # Install ctffind4
  #
  exec {'ctffind4':
    command => 'python /opt/scipion/scipion install --no-xmipp ctffind4 > /tmp/ctffind4.log',
    user    => 'cfy',
    environment => 'HOME=/home/cfy',
    provider => 'shell',
    before  => Exec['motioncor2'],
  }
  ##############################################################
  # Install motioncor2
  #
  exec {'motioncor2':
    command => 'python /opt/scipion/scipion install --no-xmipp motioncor2 > /tmp/motioncor2.log',
    user    => 'cfy',
    environment => 'HOME=/home/cfy',
    provider => 'shell',
    before  => File['create_service'],
  }

  ##############################################################
  # Create directory /services

  file { 'create_service':
    ensure  => directory,
    owner   => 'cfy',
    group   => 'cfy',
    path    => '/services',
    before  => File['delete_binary'],
  }

  ##############################################################
  # Delete Scipion binary tar file

  file { 'delete_binary':
    ensure  => absent,
    path    => '/opt/${binary_file}',
    before  => Exec['delete_packages_binaries']
  }

  ##############################################################
  # Delete Packages binary tar files

  exec { 'delete_packages_binaries':
    command => 'rm /opt/scipion/software/em/*.tgz',
    user    => 'cfy',
    environment => 'HOME=/home/cfy',
    provider => 'shell'
  }
}
