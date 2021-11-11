# Adjust file paths to suite SecGen.
class pachev_ftp_server_1_path_traversal::service {
  require pachev_ftp_server_1_path_traversal::config
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ], }
  file { '/etc/systemd/system/pachevftp.service':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/pachevftp.service',
    notify  => Exec['set-perm-one'],
    require => File['/opt/pachev_ftp/pachevftp.service'],
  }
  exec { 'set-perm-one':
    command => 'sudo setfacl -m u:ftpusr:rwx /opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftp_server',
    require => File['/etc/systemd/system/pachevftp.service'],
    notify  => Exec['set-perm-two'],
  }
  exec { 'set-perm-two':
    command => 'sudo setfacl -m u:ftpusr:rwx /etc/systemd/system/pachevftp.service',
    require => Exec['set-perm-one'],
    notify  => Service['pachevftp'],
  }
  service { 'pachevftp':
    ensure  => running,
    enable  => true,
    require => Exec['set-perm-two'],
  }
}
