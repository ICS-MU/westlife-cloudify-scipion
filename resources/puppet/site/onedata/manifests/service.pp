class onedata::service {
  $_ensure_service = $onedata::ensure == present

  service { 'oneclient':
    ensure => $_ensure_service,
    enable => $_ensure_service,
  }
}
