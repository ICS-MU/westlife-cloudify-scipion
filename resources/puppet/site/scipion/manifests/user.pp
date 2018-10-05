class scipion::user (
  $ensure          = $scipion::params::ensure,
  $user_name       = $scipion::params::user_name,
  $user_id         = $scipion::params::user_id,
  $user_groups     = $scipion::params::user_groups,
  $user_shell      = $scipion::params::user_shell,
  $user_home       = $scipion::params::user_home,
  $user_system     = $scipion::params::user_system,
  $group_name      = $scipion::params::group_name,
  $group_id        = $scipion::params::group_id,
  $group_system    = $scipion::params::group_system,
  $public_key      = $scipion::params::public_key,
  $private_key_b64 = $scipion::params::private_key_b64
) inherits scipion::params {

  group { $group_name:
    ensure => $ensure,
    gid    => $group_id,
    system => $group_system,
  }

  user { $user_name:
    ensure     => $ensure,
    uid        => $user_id,
    gid        => $group_id,
    groups     => $user_groups,
    shell      => $user_shell,
    home       => $user_home,
    managehome => true,
    system     => true,
  }

  if ($ensure == 'present') {
    Group[$user_name]
      -> User[$group_name]

    # SSH keys and configuration
    $_user_home = "${user_home}" ? {
      ''      => "/home/${user_name}",
      default => $user_home
    }

    file { "${_user_home}/.ssh":
      ensure => directory,
      owner  => $user_name,
      group  => $group_name,
      mode   => '0700',
    }

    file { "${_user_home}/.ssh/config":
      ensure  => file,
      owner   => $user_name,
      group   => $group_name,
      mode    => '0600',
      content => '# This file is managed by Puppet
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
',
    }

    if $private_key_b64 {
      $_private_key = base64('decode', $private_key_b64)

      file { "${_user_home}/.ssh/id_rsa":
        ensure  => file,
        content => $_private_key,
        owner   => $user_name,
        group   => $group_name,
        mode    => '0400',
      }
    }

    if $public_key {
      $_public_key_files= [
        "${_user_home}/.ssh/id_rsa.pub",
        "${_user_home}/.ssh/authorized_keys"
      ]

      file { $_public_key_files:
        ensure  => file,
        content => $public_key,
        owner   => $user_name,
        group   => $group_name,
        mode    => '0600',
      }
    }

  } else {
    exec { "pkill-${user_name}":
      command => "pkill -u ${user_name} -9",
      onlyif  => "pgrep -u ${user_name}",
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      before  => User[$user_name],
    }

    User[$user_name]
      -> Group[$group_name]
  }
}
