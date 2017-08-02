class cuda::runtime {
  $_release = regsubst($::cuda::release, '\.', '-', 'G')
  $_packages = ["${::cuda::package_runtime}-${_release}"]
  ensure_packages($_packages)

  if ($::osfamily == 'RedHat') {
    package { ['kernel', 'kernel-devel']:
      ensure  => latest,
      require => Package[$_packages],
    }
  }

  reboot { 'cuda-reboot':
    apply     => finished,
    when      => refreshed,
    timeout   => 0,
    subscribe => Package[$_packages],
    message   => 'Rebooting to get the NVIDIA drivers working',
  } 
}
