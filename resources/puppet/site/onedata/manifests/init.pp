class onedata (
  $ensure        = $onedata::params::ensure,
  $installer_url = $onedata::params::installer_url,
  $package       = $onedata::params::package
) inherits onedata::params {

  contain onedata::install
}
