class gromacs (
  $version         = $::gromacs::params::version,
  $prebuilt_suffix = $::gromacs::params::prebuilt_suffix,
  $packages        = $::gromacs::params::packages
) inherits gromacs::params {

  contain ::gromacs::user

  ensure_packages($packages)

  #TODO
  file { '/tmp/gromacs.tar.xz':
    ensure => file,
    source => "puppet:///modules/gromacs/gromacs-${version}${prebuilt_suffix}.tar.xz",
  }

  archive { '/tmp/gromacs.tar.xz':
    extract      => true,
    extract_path => '/',
    creates      => "/opt/gromacs/",
  }
}
