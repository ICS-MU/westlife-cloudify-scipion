class cuda::toolkit {
  $_ensure = $cuda::ensure ? {
    present => present,
    default => purged,
  }

  $_release = regsubst($::cuda::release, '\.', '-', 'G')
  $_packages = ["${::cuda::package_toolkit}-${_release}"]

  if ($_ensure == 'purged') and ($facts['os']['family'] == 'RedHat') {
    $_packages.each |$name| {
      exec { "yum-autoremove-${name}":
        command => "/usr/bin/yum -y autoremove ${name}",
        onlyif  => "/usr/bin/rpm -qi ${name}",
      }
    }
  } else {
    ensure_packages($_packages, {'ensure' => $_ensure })

    if ($_ensure == 'purged') and ($facts['os']['family'] == 'Debian') {
      exec { 'cuda::toolkit::apt-get-autoremove':
        command     => '/usr/bin/apt-get autoremove -fy',
        refreshonly => true,
        subscribe   => Package[$_packages],
      }
    }
  }
}
