class turbovnc (
  $version          = $turbovnc::params::version,
  $package          = $turbovnc::params::package,
  $package_url_base = $turbovnc::params::package_url_base,
  $package_url_name = $turbovnc::params::package_url_name,
  $package_provider = $turbovnc::params::package_provider,
  $packages_xorg    = $turbovnc::params::packages_xorg,
  $passwords        = $turbovnc::params::passwords,
  $servers          = $turbovnc::params::servers,
  $service          = $turbovnc::params::service
) inherits turbovnc::params {

  $_package = inline_template("${package_url_base}${package_url_name}")

  require java
  require virtualgl

  contain turbovnc::install
  contain turbovnc::config
  contain turbovnc::service

  Class['turbovnc::install']
    -> Class['turbovnc::config']
    ~> Class['turbovnc::service']

  $passwords.each |String $user, String $password| {
    turbovnc::password { $user:
      password => $password,
    }
  }
}
