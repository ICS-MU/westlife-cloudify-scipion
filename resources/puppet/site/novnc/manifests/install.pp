class novnc::install {
  vcsrepo { $novnc::directory:
    ensure    => $novnc::ensure,
    provider  => $novnc::vcs_provider,
    source    => $novnc::vcs_source,
    depth     => $novnc::vcs_depth,
  }

  if ($novnc::ensure == 'present') and size($novnc::index_symlink)>0 {
    file { "${novnc::directory}/index.html":
      ensure => symlink,
      target => $novnc::index_symlink,
    }
  }
}
