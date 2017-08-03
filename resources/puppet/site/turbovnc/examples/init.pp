class { 'turbovnc':
  passwords => {
    'root' => 'SecretPassword',
  },
  servers => {
    1 => {
      'user' => 'root',
      'args' => '-geometry 800x600 -nohttpd -localhost',
    },
    2 => {
      'user' => 'root',
      'args' => '-geometry 800x600 -nohttpd -xstartup openbox',
    },
  },
}
