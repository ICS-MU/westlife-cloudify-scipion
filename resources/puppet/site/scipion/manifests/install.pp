class scipion::install {
  $_ensure_dir = $scipion::ensure ? {
    present => directory,
    default => absent,
  }

  file { '/tmp/.scipion':
    ensure  => $_ensure_dir,
    purge   => true,
    recurse => true,
    force   => true,
    mode    => '0700',
  }

  case $scipion::ensure {
    present: {
      $_name = basename($scipion::source_url)

      archive { "/tmp/.scipion/${_name}":
        source       => $scipion::source_url,
        extract      => true,
        extract_path => '/opt/',
        creates      => '/opt/scipion/scipion',
        require      => File['/tmp/.scipion'],
        before       => File['/opt/scipion'],
      }
    }

    absent: {
    }

    default: {
      fail("Invalid ensure state: ${scipion::ensure}")
    }
  }

  file { '/opt/scipion':
    ensure  => $_ensure_dir,
    owner   => $scipion::user::user_name,
    group   => $scipion::user::group_name,
    force   => true,
    backup  => false,
    recurse => true,
  }
}
