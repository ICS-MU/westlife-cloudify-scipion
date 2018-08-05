class onedata::install {
  $_ensure_dir = $onedata::ensure ? {
    present => directory,
    default => absent,
  }

  file { '/tmp/.onedata':
    ensure  => $_ensure_dir,
    purge   => true,
    recurse => true,
    force   => true,
    mode    => '0700',
  }

  case $onedata::ensure {
    present: {
      archive { '/tmp/.onedata/oneclient.sh':
        source  => $onedata::installer_url,
        extract => false,
        require => File['/tmp/.onedata'],
      }

      exec { 'onedata::install':
        command => '/bin/sh /tmp/.onedata/oneclient.sh',
        creates => '/opt/oneclient/bin/oneclient',
      }
    }

    absent: {
      package { $onedata::package:
        ensure => $onedata::ensure,
      }
    }

    default: {
      fail("Invalid ensure state: ${onedata::ensure}")
    }
  }
}
