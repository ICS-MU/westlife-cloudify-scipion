class websockify::config {
  # SSL via Let's Encrypt
  if $websockify::ssl_enabled and ($websockify::ensure == 'present') {
    class { 'letsencrypt':
      email               => $websockify::ssl_email,
      unsafe_registration => true,
    }

    letsencrypt::certonly { 'cert':
      plugin               => 'standalone',
      domains              => $websockify::ssl_domains,
      manage_cron          => true,
      cron_before_command  => '/bin/systemctl stop websockify.service',
      cron_success_command => '/bin/systemctl restart websockify.service',
      suppress_cron_output => true,
    }
  }

  file {'/etc/systemd/system/websockify.service':
    ensure  => $websockify::ensure,
    content => epp('websockify/websockify.service.epp'),
  }
}
