class gromacs::portal (
  $packages       = $gromacs::params::portal_packages,
  $code_dir       = $gromacs::params::portal_code_dir,
  $data_dir       = $gromacs::params::portal_data_dir,
  $server_url     = $gromacs::params::portal_server_url,
  $server_cgi     = $gromacs::params::portal_server_cgi,
  $admin_email    = $gromacs::params::portal_admin_email,
  $gromacs_cpu_nr = $gromacs::params::portal_gromacs_cpu_nr,
  $enable_ssl     = $gromacs::params::portal_enable_ssl
) inherits gromacs::params {

  $_proto = $enable_ssl ? {
    true    => 'https',
    default => 'http'
  }

  if ($server_url) {
    $_server_url = $server_url
  } else {
    $_server_url = "${_proto}://${::fqdn}"
  }

  if ($server_cgi) {
    $_server_cgi = $server_cgi
  } else {
    $_server_cgi = "${_server_url}/cgi/"
  }

  require ::gromacs::user
  contain ::gromacs::portal::install
  contain ::gromacs::portal::config

  Class['::gromacs::portal::install']
    -> Class['::gromacs::portal::config']
}
