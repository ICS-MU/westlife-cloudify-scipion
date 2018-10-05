class onedata::params {
  $ensure = present
  $package = 'oneclient'
  $version = latest
  $mountpoint = '/mnt/onedata'

  $repo_manage = true
  $repo_rooturl = 'https://packages.onedata.org/'
  $repo_gpgkey_id = 'BC7CC544'
  $repo_gpgkey_content = template('onedata/bc7cc544.pub')

  # synchronization scripts
  $sync_user = 'scipion'
  $sync_group = 'scipion'
  $sync_scratch_dir = '/data/ScipionUserData'
  $sync_scripts_dir = '/opt/onesync'
  $sync_scripts_conf = '/opt/onesync/sync-onedata-working.conf'

  case $::operatingsystem {
    'Ubuntu': { $repo_class = 'onedata::repo::apt'
      $repo_repos = 'main'
      $repo_release = $facts['os']['distro']['codename']
      $repo_baseurl = "${repo_rooturl}/apt/ubuntu/${facts['os']['distro']['codename']}"
      $repo_enabled = undef
      $repo_gpgcheck = undef
      $repo_gpgkey_file = undef
    }

    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
}
