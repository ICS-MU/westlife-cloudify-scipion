class novnc::params {
  $ensure = present
  $directory = '/opt/novnc'
  $vcs_provider = 'git'
  $vcs_source = 'https://github.com/novnc/noVNC'
  $vcs_depth = 1
  $index_symlink = 'vnc.html'
}
