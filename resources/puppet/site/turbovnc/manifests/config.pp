class turbovnc::config {
  case $turbovnc::ensure {
    present: {
      # Manage /etc/sysconfig/tvncservers, e.g.:
      # VNCSERVERARGS[1]="-geometry 800x600 -nohttpd -localhost"
      # VNCSERVERARGS[2]="-geometry 1024x768 -nohttpd -localhost"
      $turbovnc::servers.each |Integer $id, Hash $params| {
        augeas { "turbovnc::config::vncserverargs${id}":
          incl    => '/etc/sysconfig/tvncservers',
          lens    => 'Shellvars.lns',
          context => '/files/etc/sysconfig/tvncservers',
          changes => "set VNCSERVERARGS\\[${id}\\] '\"${params['args']}\"'",
        }
      }

      # Manage /etc/sysconfig/tvncservers, e.g.:
      # VNCSERVERS="1:root 2:root"
      $_vncservers = join(
        $turbovnc::servers.map |Integer $id, Hash $params| {
          "${id}:${params['user']}"
        }
      ,' ')

      augeas { "turbovnc::config::vncservers":
        incl    => '/etc/sysconfig/tvncservers',
        lens    => 'Shellvars.lns',
        context => '/files/etc/sysconfig/tvncservers',
        changes => "set VNCSERVERS '\"${_vncservers}\"'",
      }
    }

    absent: {
      file { '/etc/sysconfig/tvncservers':
        ensure => $turbovnc::ensure,
      }
    }

    default: {
      fail("Invalid ensure state '${turbovnc::ensure}'")
    }
  }
}
