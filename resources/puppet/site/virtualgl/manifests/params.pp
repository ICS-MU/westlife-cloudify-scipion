class virtualgl::params {
  $ensure = present
  $version = '2.5.2'
  $package = 'virtualgl'
  $package_url_base = 'https://sourceforge.net/projects/virtualgl/files/<%= @version %>/'

  case $facts['operatingsystem'] {
    'Debian', 'Ubuntu': {
      $package_url_name = "virtualgl_<%= @version %>_${facts['os']['architecture']}.deb"
      $package_provider = dpkg
    }

    default: {
      fail("Unsupported OS: ${facts['operatingsystem']}")
    }
  }
}
