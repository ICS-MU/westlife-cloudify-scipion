class onedata::repo::apt {
  apt::source { 'onedata':
    ensure   => $onedata::ensure,
    location => $onedata::repo_baseurl,
    release  => $onedata::repo_release,
    repos    => $onedata::repo_repos,
    key      => {
      'id'      => $onedata::repo_gpgkey_id,
      'content' => $onedata::repo_gpgkey_content,
    },
  }
}
