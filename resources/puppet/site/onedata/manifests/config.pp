class onedata::config {
  case $onedata::ensure {
    present: {
      file { $onedata::mountpoint:
        ensure => directory,
      }

      $_one_mount = "oneclient -i -H ${onedata::host} -t ${onedata::token} ${onedata::mountpoint}"

      exec { $_one_mount:
        unless  => "egrep '^oneclient ${onedata::mountpoint} ' /proc/mounts",
        path    => '/bin:/usr/bin:/sbin:/usr/sbin',
        require => File[$onedata::mountpoint],
      }
    }

    absent: {
#      mount { $onedata::mountpoint:
#        ensure => absent,
#      }

      $_one_umount = "umount -f -l ${onedata::mountpoint}"

      exec { $_one_umount:
        onlyif => "egrep '^oneclient ${onedata::mountpoint} ' /proc/mounts",
        path   => '/bin:/usr/bin:/sbin:/usr/sbin',
        before => File[$onedata::mountpoint],
      }

      file { $onedata::mountpoint:
        ensure => absent,
        force  => true,
        backup => false,
      }
    }
  }
}
