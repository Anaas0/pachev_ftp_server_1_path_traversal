# Adjust file paths to suite SecGen.
class pachev_ftp_server_1_path_traversal::service {
  require pachev_ftp_server_1_path_traversal::config

  file { '/etc/systemd/system/pachevftp.service':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/pachevftp.service',
    notify  => Service['pachevftp'],
    require => File['/opt/pachev_ftp/pachevftp.service'],
  }
  service { 'pachevftp':
    ensure  => running,
    enable  => true,
    require => Exec['iptables'],
  }
}
