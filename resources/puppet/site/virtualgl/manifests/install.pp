class virtualgl::install {
  file { '/tmp/.virtualgl':
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0700',
  }

  archive { '/tmp/.virtualgl/virtualgl':
    source  => $virtualgl::_package,
    extract => false,
    require => File['/tmp/.virtualgl'],
  }

  package { $virtualgl::package:
    ensure   => present,
    source   => '/tmp/.virtualgl/virtualgl',
    require  => Archive['/tmp/.virtualgl/virtualgl'],
    provider => $virtualgl::package_provider,
  }
}
