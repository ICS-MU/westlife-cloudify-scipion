class scipion::params {
  $ensure = present
  $source_url = 'http://webserver.ics.muni.cz/westlife/scipion_v1.1_2017-06-14_with_chimera.tgz'

#  $version = '5.1.4'
#  $url_template = 'https://github.com/ICS-MU/westlife-gromacs/raw/master/gromacs-<%= $version %>-<%= $build %>.tar.xz'
#  $base_dir = '/opt/gromacs'

  $user_name = 'scipion'
  $user_id = undef
  $user_groups = []
  $user_shell = '/bin/bash'
  $user_home = undef
  $user_system = true

  $group_name = 'scipion'
  $group_id = undef
  $group_system = true

  $public_key = undef
  $private_key_b64 = undef
}
