class onedata::service {
  cron { 'onesync-working-to-onedata':
    ensure  => $onedata::ensure,
    command => "cd ${onedata::sync_scripts_dir} && ./working-to-onedata",
    minute  => '*/5',
  }

  case $onedata::ensure {
    present: {
      $_cmd = "cd ${onedata::sync_scripts_dir} && ./onedata-to-working"

      Exec['onesync']
        -> Cron['onesync-working-to-onedata']
    }

    absent: {
      $_cmd = "cd ${onedata::sync_scripts_dir} && ./working-to-onedata-cleanup"

      Cron['onesync-working-to-onedata']
        -> Exec['onesync']
    }

    default: {
      fail("Unsupported ensure state ${onedata::ensure}")
    }
  }

  # do initial or final sync
  exec { 'onesync':
    command  => $_cmd,
    provider => shell,
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
  }
}
