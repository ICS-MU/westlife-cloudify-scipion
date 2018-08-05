class turbovnc::service {
  $_ensure = ($turbovnc::ensure == present)

  service { $turbovnc::service:
    ensure    => $_ensure,
    enable    => $_ensure,
    restart   => "service '${turbovnc::service}' reload",
    hasstatus => false,
    pattern   => 'Xvnc',
  }
}
