# Remove proxy environment settings.
# Adjust file paths to suite SecGen.
class pachev_ftp_server_1_path_traversal::config {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ], environment => [ 'http_proxy=172.22.0.51:3128', 'https_proxy=172.22.0.51:3128' ] }
  # Create user
  user { 'ftpusr':
    ensure     => present,
    uid        => '507',
    gid        => 'root',#
    home       => '/home/ftpusr',
    managehome => true,
    notify     => File['/opt/pachev_ftp/'],
  }

  # Create directory conf
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf':
    ensure  => 'directory',
    require => Exec['build-ftpserver'],
    notify  => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot'],
  }

  # Create directory ftproot
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot':
    ensure  => 'directory',
    require => Exec['build-ftpserver'],
    notify  => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs'],
  }

  # Create directory logs
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs':
    ensure  => 'directory',
    require => Exec['build-ftpserver'],
    notify  => File['/opt/pachev_ftp/pachevftp.service'],
  }

  # Create pachevftp.service
  file { '/opt/pachev_ftp/pachevftp.service':
    ensure => present,
    source => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/pachevftp.service',
    notify => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/fsys.cfg'],
  }

  # Create conf/fsys.cfg
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/fsys.cfg':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/fsys.cfg',
    require => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf'],
    notify  => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/users.cfg'],
  }

  # Create conf/users.cfg
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/users.cfg':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/users.cfg',
    require => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf'],
    notify  => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs/fserver.log'],
  }

  # Create logs/fserver.log
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs/fserver.log':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/fserver.log',
    require => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs'],
    notify  => File['/home/ftpusr/pachev_ftp'],
  }

  # Create directory for the flag
  file { '/home/ftpusr/pachev_ftp':
    ensure  => directory,
    require => User['ftpusr'],
    notify  => File['/home/ftpusr/pachev_ftp/flag.txt'],
  }

  # Create flag file
  file { '/home/ftpusr/pachev_ftp/flag.txt':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/flag.txt',
    require => File['/home/ftpusr/pachev_ftp'],
    notify  => Exec['port-forward-route'],
  }

  # Port forwarder - Make sure you save net.ipv4.conf.all.route_localnet=1 in /etc/sysctl.conf otherwise it won't be persistent
  # sudo sysctl -w net.ipv4.conf.all.route_localnet=1
  # echo 'net.ipv4.conf.all.route_localnet=1' >> /etc/sysctl.conf
  # sudo iptables -t nat -I PREROUTING -p tcp --dport 21 -j DNAT --to 127.0.0.1:2121
  exec { 'port-forward-route':
    command => 'sysctl -w net.ipv4.conf.all.route_localnet=1',
    notify  => Exec['port-forward-route-persist'],
  }

  exec { 'port-forward-route-persist':
    command => "echo 'net.ipv4.conf.all.route_localnet=1' >> /etc/sysctl.conf",
    require => Exec['port-forward-route'],
    notify  => Exec['iptables'],
  }

  exec { 'iptables':
    command => 'iptables -t nat -I PREROUTING -p tcp --dport 21 -j DNAT --to 127.0.0.1:2121',
    require => Exec['port-forward-route'],
    notify  => File['/etc/systemd/system/pachevftp.service'],
  }
}
