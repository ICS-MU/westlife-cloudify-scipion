class cuda::params {
  $repo_manage = true
  $repo_rooturl = 'http://developer.download.nvidia.com/compute/cuda/repos'
  $repo_gpgkey_id = 'F60F4B3D7FA2AF80'
  $repo_gpgkey_content = template('cuda/7fa2af80.pub')
  $package_runtime = 'cuda-runtime'
  $package_toolkit = 'cuda-toolkit'
  $install_runtime = true
  $install_toolkit = true

  case $::operatingsystem {
    'RedHat','CentOS','Scientific','OracleLinux': {
      $repo_class = '::cuda::repo::yum'
      $repo_baseurl = "${repo_rooturl}/rhel${::operatingsystemmajrelease}/${::architecture}"
      $repo_enabled = 1
      $repo_gpgcheck = 1
      $repo_gpgkey_file = '/etc/pki/rpm-gpg/RPM-GPG-KEY-cuda'
    }

    'Ubuntu': {
      $_osrelease = delete($::operatingsystemmajrelease, '.')  # e.g. '14.04' -> '1404'

      $repo_class = '::cuda::repo::apt'
      $repo_baseurl = "${repo_rooturl}/ubuntu${_osrelease}/${::hardwaremodel}"
      $repo_enabled = undef
      $repo_gpgcheck = undef
      $repo_gpgkey_file = undef
    }

    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
}
