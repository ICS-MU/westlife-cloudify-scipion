class onedata::sync {
  cron { 'onesync-working-to-onedata':
    ensure  => $onedata::ensure,
    command => "cd ${onedata::sync_scripts_dir} && ./working-to-onedata",
    user    => $onedata::sync_user,
    minute  => '*/30',
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
        -> User[$onedata::sync_user]

      Cron['onesync-working-to-onedata']
        -> User[$onedata::sync_user]
    }

    default: {
      fail("Unsupported ensure state ${onedata::ensure}")
    }
  }

  # do initial or final sync
  exec { 'onesync':
    command  => $_cmd,
    user     => $onedata::sync_user,
    provider => shell,
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    onlyif   => [
      "test -x ${onedata::sync_scripts_dir}/onedata-to-working",
      "test -x ${onedata::sync_scripts_dir}/working-to-onedata",
    ],
  }
}
