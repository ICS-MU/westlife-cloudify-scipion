class websockify::service {
  $_ensure = $websockify::ensure == present

  service {'websockify':
    ensure => $_ensure,
    enable => $_ensure,
  }
}
