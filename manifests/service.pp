#Starts the Pachev FTP Server service.
class pachev_ftp_server_1_path_traversal::service {
  require pachev_ftp_server_1_path_traversal::config
  file { '/etc/systemd/system/pachevftp.service':
    ensure => present,
    source => '/opt/pachevftp/pachevftp.service',
    notify => Service['pachevftp'],
  }
  service { 'pachevftp':
    ensure  => running,
    enable  => true,
    require => Exec['iptables'],
  }
}
