class cuda::runtime {
  $_ensure = $cuda::ensure ? {
    present => present,
    default => purged,
  }

  $_ensure_drivers = $cuda::ensure ? {
    present => $cuda::version_drivers,
    default => purged,
  }

  ###

  $_release = regsubst($::cuda::release, '\.', '-', 'G')
  $_packages = ["${::cuda::package_runtime}-${_release}"]

  if ($_ensure == 'purged') and ($facts['os']['family'] == 'RedHat') {
    $_packages.each |$name| {
      exec { "yum-autoremove-${name}":
        command => "/usr/bin/yum -y autoremove ${name}",
        onlyif  => "/usr/bin/rpm -qi ${name}",
        notify  => Reboot['cuda-reboot'],
      }
    }
  } else {
    ensure_packages(['cuda-drivers'], {
      'ensure' => $_ensure_drivers,
      'notify' => Reboot['cuda-reboot'],
    })

    ensure_packages($_packages, {
      'ensure' => $_ensure,
      'notify' => Reboot['cuda-reboot']
    })

    if ($cuda::ensure == 'present') {
      Package['cuda-drivers']
        -> Package[$_packages]
    } else {
      Package[$_packages]
        -> Package['cuda-drivers']
    }

    if ($_ensure == 'purged') and ($facts['os']['family'] == 'Debian') {
      exec { 'cuda::runtime::apt-get-autoremove':
        command     => '/usr/bin/apt-get autoremove -fy',
        refreshonly => true,
        subscribe   => [ Package[$_packages], Package['cuda-drivers'] ],
        before      => Reboot['cuda-reboot'],
      }
    }

    if ($facts['os']['family'] == 'RedHat') {
      package { ['kernel', 'kernel-devel']:
        ensure  => latest,
        require => Package[$_packages],
      }
    }
  }

  reboot { 'cuda-reboot':
    apply    => finished,
    when     => refreshed,
    timeout  => 0,
    message  => 'Rebooting to get the NVIDIA drivers working',
  } 
}
