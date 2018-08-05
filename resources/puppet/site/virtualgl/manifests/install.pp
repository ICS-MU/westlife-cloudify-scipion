class virtualgl::install {
  $_ensure_dir = $virtualgl::ensure ? {
    present => directory,
    default => absent,
  }

  file { '/tmp/.virtualgl':
    ensure  => $_ensure_dir,
    purge   => true,
    recurse => true,
    force   => true,
    mode    => '0700',
  }

  if ($virtualgl::ensure == 'present') {
    archive { '/tmp/.virtualgl/virtualgl':
      source  => $virtualgl::_package,
      extract => false,
      require => File['/tmp/.virtualgl'],
      before  => Package[$virtualgl::package],
    }
  }

  package { $virtualgl::package:
    ensure   => $virtualgl::ensure,
    source   => '/tmp/.virtualgl/virtualgl',
    provider => $virtualgl::package_provider,
  }
}
