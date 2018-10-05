class turbovnc::params {
  $ensure = present
  $version = '2.1.1'
  $package = 'turbovnc'
  $package_url_base = 'https://sourceforge.net/projects/turbovnc/files/<%= @version %>/'
  $service = 'tvncserver'
  $servers = {}
  $passwds = {}

  case $facts['operatingsystem'] {
    'Debian', 'Ubuntu': {
      $packages_xorg = ['xserver-xorg']
      $package_url_name = "turbovnc_<%= @version %>_${facts['os']['architecture']}.deb"
      $package_provider = dpkg
    }

    default: {
      fail("Unsupported OS: ${facts['operatingsystem']}")
    }
  }
}
