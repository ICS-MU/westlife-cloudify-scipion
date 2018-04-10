class virtualgl::config {

  exec { 'vglserver_config':
    command => '/opt/VirtualGL/bin/vglserver_config -config',
    before => Exec['vglusers']
  }
  exec { 'vglusers':
    command => 'usermod -a -G vglusers cfy',
    path    => '/usr/sbin/'
  }

}
