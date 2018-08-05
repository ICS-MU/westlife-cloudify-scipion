class turbovnc::install {
  $_ensure_dir = $turbovnc::ensure ? {
    present => directory,
    default => absent,
  }

  file { '/tmp/.turbovnc':
    ensure  => $_ensure_dir,
    purge   => true,
    recurse => true,
    force   => true,
    mode    => '0700',
  }

  if ($turbovnc::ensure == 'present') {
    archive { '/tmp/.turbovnc/turbovnc':
      source  => $turbovnc::_package,
      extract => false,
      require => File['/tmp/.turbovnc'],
      before  => Package[$turbovnc::package],
    }
  }

  package { $turbovnc::package:
    ensure   => $turbovnc::ensure,
    source   => '/tmp/.turbovnc/turbovnc',
    provider => $turbovnc::package_provider,
  }

  # install other packages
  ensure_packages(
    $turbovnc::packages_xorg,
    { 'ensure' => $turbovnc::ensure }
  )
}
