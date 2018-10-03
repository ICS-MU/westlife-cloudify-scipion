class onedata (
  $host,
  $token,
  $workspace,
  $ensure              = $onedata::params::ensure,
  $package             = $onedata::params::package,
  $version             = $onedata::params::version,
  $mountpoint          = $onedata::params::mountpoint,
  $sync_user           = $onedata::params::sync_user,
  $sync_group          = $onedata::params::sync_group,
  $sync_scratch_dir    = $onedata::params::sync_scratch_dir,
  $sync_scripts_dir    = $onedata::params::sync_scripts_dir,
  $sync_scripts_conf   = $onedata::params::sync_scripts_conf,
  $repo_manage         = $onedata::params::repo_manage,
  $repo_class          = $onedata::params::repo_class,
  $repo_baseurl        = $onedata::params::repo_baseurl,
  $repo_enabled        = $onedata::params::repo_enabled,
  $repo_gpgcheck       = $onedata::params::repo_gpgcheck,
  $repo_gpgkey_id      = $onedata::params::repo_gpgkey_id,
  $repo_gpgkey_content = $onedata::params::repo_gpgkey_content,
  $repo_gpgkey_file    = $onedata::params::repo_gpgkey_file
) inherits onedata::params {

  if $repo_manage and $repo_class {
    require $repo_class
  } 

  contain onedata::install
  contain onedata::config
  contain onedata::service
  contain onedata::sync

  case $ensure {
    present: {
      Class['onedata::install']
        -> Class['onedata::config']
        -> Class['onedata::service']
        -> Class['onedata::sync']
    }

    absent: {
      Class['onedata::sync']
        -> Class['onedata::service']
        -> Class['onedata::config']
        -> Class['onedata::install']
    }

    default: {
      fail("Invalid ensure state ${ensure}")
    }
  }
}
