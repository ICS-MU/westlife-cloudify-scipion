class onedata::config {
  $_ensure_dir = $onedata::ensure ? {
    present => directory,
    default => $onedata::ensure
  }

  file { '/etc/oneclient.env':
    ensure  => $onedata::ensure,
    content => epp('onedata/oneclient.env.epp'),
    mode    => '0640',
  }

  file {'/etc/systemd/system/oneclient.service':
    ensure  => $onedata::ensure,
    content => epp('onedata/oneclient.service.epp'),
  }
}
