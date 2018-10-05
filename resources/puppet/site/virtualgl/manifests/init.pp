class virtualgl (
  $ensure           = $virtualgl::params::ensure,
  $version          = $virtualgl::params::version,
  $package          = $virtualgl::params::package,
  $package_url_base = $virtualgl::params::package_url_base,
  $package_url_name = $virtualgl::params::package_url_name,
  $package_provider = $virtualgl::params::package_provider
) inherits virtualgl::params {

  $_package = inline_template("${package_url_base}${package_url_name}")

  contain virtualgl::install
}
