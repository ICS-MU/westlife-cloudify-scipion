class turbovnc::install {
  file { '/tmp/.turbovnc':
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0700',
  }

  archive { '/tmp/.turbovnc/turbovnc':
    source  => $turbovnc::_package,
    extract => false,
    require => File['/tmp/.turbovnc'],
  }

  package { $turbovnc::package:
    ensure   => present,
    source   => '/tmp/.turbovnc/turbovnc',
    require  => Archive['/tmp/.turbovnc/turbovnc'],
    provider => $turbovnc::package_provider,
  }

  # install other packages
  ensure_packages($turbovnc::packages_xorg)
}
