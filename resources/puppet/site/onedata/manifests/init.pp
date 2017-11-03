class onedata {
  wget::fetch { 'Onedata_install_script':
    source      => "${onedataurl}",
    destination =>'/tmp/',
    timeout     => 0,
    verbose     => false,
    before      => Exec['onedata-client'],
  }

  ############################################################
  # Install Onedata client

  exec {'onedata-client':
    command     => "sh /tmp/oneclient.sh",
    path        => '/bin',
    environment => ["PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"]
  }
}
