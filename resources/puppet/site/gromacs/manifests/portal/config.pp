class gromacs::portal::config {
  # defaults 
  Ini_setting {
    path    => "${::gromacs::portal::code_dir}/data/gmx_serverconf.ini",
    section => 'server_settings',
    notify  => Exec['config_server.sh'],
  }

  Exec {
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
  }

  # GROMACS data directory
  file { $::gromacs::portal::data_dir:
    ensure => directory,
    mode   => '0777', #TODO
    owner  => $::apache::user,
    group  => $::apache::group,
    before => Exec['config_server.sh'],
  }

  # server settings
  ini_setting { 'gmx_serverconf.ini-STR_BASEDIR':
    setting => 'STR_BASEDIR',
    value   => $::gromacs::portal::code_dir,
  }

  ini_setting { 'gmx_serverconf.ini-STR_GRID_POOL_DIR':
    setting => 'STR_GRID_POOL_DIR',
    value   => $::gromacs::portal::data_dir,
  }

  ini_setting { 'gmx_serverconf.ini-STR_SERVER_URL':
    setting => 'STR_SERVER_URL',
    value   => $::gromacs::portal::_server_url,
  }

  ini_setting { 'gmx_serverconf.ini-STR_SERVER_CGI':
    setting => 'STR_SERVER_CGI',
    value   => $::gromacs::portal::_server_cgi,
  }

  ini_setting { 'gmx_serverconf.ini-STR_ADMIN_EMAIL':
    setting => 'STR_ADMIN_EMAIL',
    value   => $::gromacs::portal::admin_email,
  }

  # gromacs options
  ini_setting { 'gmx_serverconf.ini-INT_GROMACS_CPU_NR':
    section => 'gromacs_options',
    setting => 'INT_GROMACS_CPU_NR',
    value   => $::gromacs::portal::gromacs_cpu_nr,
  }

  # configure gromacs
  exec { 'config_server.sh':
    command   => "${::gromacs::portal::code_dir}/config_server.sh",
    cwd       => $::gromacs::portal::code_dir,
    logoutput => true,
  }

  # fix permission
  $_find_type = "find ${::gromacs::portal::code_dir} -type"

  exec { 'fix-gromacs-portal-dirs':
    command => "${_find_type} d -exec chmod g+rwx {} \\;",
    require => Exec['config_server.sh'],
  }

  exec { 'fix-gromacs-portal-files':
    command => "${_find_type} f -exec chmod g+rw {} \\;",
    require => Exec['config_server.sh'],
  }

  exec { 'fix-gromacs-portal-owner':
    command => "chown -R ${::apache::user}:${::apache::group} ${::gromacs::portal::code_dir}",
    require => Exec['config_server.sh'],
  }

  # job manager
  cron { 'gmx_gridmanager':
    command     => "cd ${::gromacs::portal::data_dir} && /var/www/gromacs/cron/gmx_gridmanager.sh &>>/tmp/gmx_gridmanager.log",
    minute      => '1-59/2', #odd
    user        => $::gromacs::user::user_name,
    environment => "MAILTO=${::gromacs::portal::admin_email}",
    require     => File[$::gromacs::portal::data_dir],
  }

  cron { 'gmx_jobcontroller':
    command     => "cd ${::gromacs::portal::code_dir}/cron/ && ./gmx_jobcontroller.sh &>>/tmp/gmx_jobcontroller.log",
    minute      => '*/2', #even
    user        => $::gromacs::user::user_name,
    environment => "MAILTO=${::gromacs::portal::admin_email}",
  }

  cron { 'gmx_postprocessor':
    command     => "cd ${::gromacs::portal::code_dir}/cron/ && ./gmx_postprocessor.sh &>>/tmp/gmx_postprocessor.log",
    minute      => '*/5',
    user        => $::gromacs::user::user_name,
    environment => "MAILTO=${::gromacs::portal::admin_email}",
  }
}
