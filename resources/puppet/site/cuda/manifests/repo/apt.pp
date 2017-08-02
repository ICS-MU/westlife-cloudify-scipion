class cuda::repo::apt {
  apt::source { 'cuda':
    location => $::cuda::repo_baseurl,
    release  => '/',
    repos    => '',
    key      => {
      'id'      => $::cuda::repo_gpgkey_id,
      'content' => $::cuda::repo_gpgkey_content,
    },
  }
}
