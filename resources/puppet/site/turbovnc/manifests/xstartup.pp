define turbovnc::xstartup (
  $password,
  $user     = $title
) {
  if ($user == 'root') {
    $_home = "/${user}"
  } else {
    $_home = "/home/${user}"
  }

  $_vnc_file = "${_home}/.vnc/xstartup.turbovnc"

  file { $_vnc_file:
    ensure => file,
    owner  => $user,
    mode   => '0755',
    require => Package['xfce4'],
    content => '
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
exit 0
',
}
}
