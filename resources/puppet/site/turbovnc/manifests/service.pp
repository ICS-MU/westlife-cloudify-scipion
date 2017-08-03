class turbovnc::service {
  service { $turbovnc::service:
    ensure    => running,
    enable    => true,
    restart   => "service '${turbovnc::service}' reload",
    hasstatus => false,
    pattern   => 'Xvnc',
  }
}
