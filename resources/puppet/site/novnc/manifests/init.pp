class novnc (
  String  $ensure                 = $novnc::params::ensure,
  String  $directory              = $novnc::params::directory,
  String  $vcs_provider           = $novnc::params::vcs_provider,
  String  $vcs_source             = $novnc::params::vcs_source,
  Integer $vcs_depth              = $novnc::params::vcs_depth,
  Optional[String] $index_symlink = $novnc::params::index_symlink
) inherits novnc::params {

  contain novnc::install
}
