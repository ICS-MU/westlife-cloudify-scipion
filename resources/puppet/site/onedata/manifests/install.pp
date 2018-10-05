class onedata::install {
  $_ensure_dir = $onedata::ensure ? {
    present => directory,
    default => $onedata::ensure
  }

  $_ensure_pkg = $onedata::ensure ? {
    present => $onedata::version,
    default => $onedata::ensure,
  }

  package { $onedata::package:
    ensure => $_ensure_pkg,
  }

  # mount point
  # Note: directory should be empty after clean unmount.
  # If not, we better fail during the directory delete
  # on purpose.
  file { $onedata::mountpoint:
    ensure => $_ensure_dir,
    force  => true,
  }

  # scratch dir
  file { $onedata::sync_scratch_dir:
    ensure  => directory,
    force   => true,
    backup  => false,
    recurse => true,
  }

  # synchronization scripts
  file { $onedata::sync_scripts_dir:
    ensure  => $_ensure_dir,
    force   => true,
    backup  => false,
    recurse => true,
    mode    => '0755',
  }

  if $onedata::ensure == 'present' {
    File[$onedata::sync_scratch_dir] {
      owner => $onedata::sync_user,
      group => $onedata::sync_group,
    }

    File[$onedata::sync_scripts_dir] {
      source       => 'puppet:///modules/onedata',
      sourceselect => all,
    }

    file { $onedata::sync_scripts_conf:
      ensure  => $onedata::ensure,
      content => epp('onedata/sync-onedata-working.conf.epp'),
      require => File[$onedata::sync_scripts_dir],
    }
  }
}
