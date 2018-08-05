class cuda (
  $release,
  $ensure              = $cuda::params::ensure,
  $repo_manage         = $cuda::params::repo_manage,
  $repo_class          = $cuda::params::repo_class,
  $repo_baseurl        = $cuda::params::repo_baseurl,
  $repo_enabled        = $cuda::params::repo_enabled,
  $repo_gpgcheck       = $cuda::params::repo_gpgcheck,
  $repo_gpgkey_id      = $cuda::params::repo_gpgkey_id,
  $repo_gpgkey_content = $cuda::params::repo_gpgkey_content,
  $repo_gpgkey_file    = $cuda::params::repo_gpgkey_file,
  $package_runtime     = $cuda::params::package_runtime,
  $package_toolkit     = $cuda::params::package_toolkit,
  $install_runtime     = $cuda::params::install_runtime,
  $install_toolkit     = $cuda::params::install_toolkit
) inherits cuda::params {

  if $repo_manage and $repo_class {
    require $repo_class
  } 

  if $install_runtime {
    contain cuda::runtime

    if $install_toolkit {
      Class['cuda::runtime'] ->
        Class['cuda::toolkit']
    }
  }

  if $install_toolkit {
    contain cuda::toolkit
  }
}
