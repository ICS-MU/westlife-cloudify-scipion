define turbovnc::password (
  $password,
  $user     = $title,
  $group    = $title,
) {
  if ($user == 'root') {
    $_home = "/${user}"
  } else {
    $_home = "/home/${user}"
  }

  $_vnc_file = "${_home}/.vnc/passwd"
  $_password = shellquote($password)

  file { "${_home}/.vnc/":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0700',
  }

  file { $_vnc_file:
    ensure => file,
    owner  => $user,
    group  => $group,
    mode   => '0600',
    before => Exec["turbovnc::password::${user}"],
  }

  exec { "turbovnc::password::${user}":
    command     => "echo ${_password} | /opt/TurboVNC/bin/vncpasswd -f >${_vnc_file}",
    unless      => "echo ${_password} | /opt/TurboVNC/bin/vncpasswd -f >${_vnc_file}.new; diff -q ${_vnc_file} ${_vnc_file}.new",
    environment => "HOME=${_home}",
    provider    => shell,
    before      => Class['turbovnc::service'],
    require     => Class['turbovnc::install'],
  }
}
