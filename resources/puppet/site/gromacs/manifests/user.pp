class gromacs::user (
  $user_name       = $::gromacs::params::user_name,
  $user_id         = $::gromacs::params::user_id,
  $user_groups     = $::gromacs::params::user_groups,
  $user_shell      = $::gromacs::params::user_shell,
  $user_home       = $::gromacs::params::user_home,
  $user_system     = $::gromacs::params::user_system,
  $group_name      = $::gromacs::params::group_name,
  $group_id        = $::gromacs::params::group_id,
  $group_system    = $::gromacs::params::group_system,
  $public_key      = $::gromacs::params::public_key,
  $private_key_b64 = $::gromacs::params::private_key_b64
) inherits gromacs::params {

  group { $group_name:
    gid    => $group_id,
    system => $group_system,
  }

  user { $user_name:
    uid        => $user_id,
    gid        => $group_id,
    groups     => $user_groups,
    shell      => $user_shell,
    home       => $user_home,
    managehome => true,
    system     => true,
    require    => Group[$group_name],  #TODO-Apache
  }

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
}
