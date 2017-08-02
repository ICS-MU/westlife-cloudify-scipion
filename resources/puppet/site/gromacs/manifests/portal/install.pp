class gromacs::portal::install {
  ensure_packages($::gromacs::portal::packages)

  # Apache
  class { '::apache':
    mpm_module    => 'prefork',
    default_vhost => false,
  }

  contain ::apache::mod::php

  $_custom_fragment = "
  <Directory '${::gromacs::portal::code_dir}/cgi'>
    Options +ExecCGI
    AddHandler cgi-script .cgi
  </Directory>
"

  ::apache::vhost { 'http':
    ensure          => present,
    port            => 80,
    docroot         => $::gromacs::portal::code_dir,
    manage_docroot  => true,
    docroot_owner   => 'apache',
    docroot_group   => 'apache',
    custom_fragment => $_custom_fragment,
  }

  # SSL via Let's Encrypt
  if $::gromacs::portal::enable_ssl {
    class { '::letsencrypt':
      email => $::gromacs::portal::admin_email,
    }

    letsencrypt::certonly { $::fqdn:
      plugin               => 'standalone',
      manage_cron          => true,
      cron_success_command => '/bin/systemctl reload httpd.service',
      before               => ::Apache::Vhost['https'],
    }

    ::apache::vhost { 'https':
      ensure          => present,
      port            => 443,
      docroot         => $::gromacs::portal::code_dir,
      manage_docroot  => false,
      docroot_owner   => 'apache',
      docroot_group   => 'apache',
      ssl             => true,
      ssl_cert        => "/etc/letsencrypt/live/${::fqdn}/cert.pem",
      ssl_chain       => "/etc/letsencrypt/live/${::fqdn}/chain.pem",
      ssl_key         => "/etc/letsencrypt/live/${::fqdn}/privkey.pem",
      custom_fragment => $_custom_fragment,
    }

    # redirect http->https
    ::Apache::Vhost['http'] {
      redirect_status => 'permanent',
      redirect_dest   => "${::gromacs::portal::_server_url}/"
    }
  }


  #TODO: vcsrepo
  $_portal_arch = '/tmp/gromacs-portal.tar.gz'

  file { $_portal_arch:
    ensure => file,
    source => 'puppet:///modules/gromacs/private/gromacs-portal.tar.gz',
  }

  archive { $_portal_arch:
    extract      => true,
    extract_path => $::gromacs::portal::code_dir,
    creates      => "${::gromacs::portal::code_dir}/cgi",
    user         => $::apache::user,
    group        => $::apache::group,
    require      => Class['::apache'],
  }
}
