#
class pachev_ftp_server_1_path_traversal::config {
  # Create user
  user { 'ftpusr':
    ensure     => present,
    uid        => '507',
    gid        => 'root',
    home       => 'home/ftpusr',
    managehome => true
  }

  # Create directory conf
  file { 'opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf':
    ensure  => 'directory',
    require => Exec['build-ftpserver'],
  }

  # Create directory ftproot
  file { 'opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot':
    ensure  => 'directory',
    require => Exec['build-ftpserver'],
  }

  # Create directory logs
  file { 'opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs':
    ensure  => 'directory',
    require => Exec['build-ftpserver'],
  }

  # Create pachevftp.service
  file { 'opt/pachev_ftp/pachevftp.service':
    ensure => present,
    source => 'puppet:///modules/pachev_ftp_server_1_path_traversal/files/pachevftp.service'
  }

  # Create conf/fsys.cfg
  file { 'conf/fsys.cfg':
    ensure  => present,
    source  => 'puppet:///modules/pachev_ftp_server_1_path_traversal/files/fsys.cfg',
    require => file['opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf'],
  }

  # Create conf/users.cfg
  file { 'conf/users.cfg':
    ensure  => present,
    source  => 'puppet:///modules/pachev_ftp_server_1_path_traversal/files/users.cfg',
    require => file['opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf'],
  }

  # Create logs/fserver.log
  file { 'logs/fserver.log':
    ensure  => present,
    source  => 'puppet:///modules/pachev_ftp_server_1_path_traversal/files/fserver.log',
    require => file['opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs'],
  }

  # Create directory for the flag
  file { 'home/ftpusr/pachev_ftp':
    ensure  => directory,
    require => User['ftpusr'],
  }

  # Create flag file
  file { 'home/ftpusr/pachev_ftp/flagtest.txt':
    ensure  => present,
    source  => 'puppet:///modules/pachev_ftp_server_1_path_traversal/files/flagtest.txt',
    require => file['home/ftpusr/pachev_ftp'],
  }

  # Port forwarder - Make sure you save net.ipv4.conf.all.route_localnet=1 in /etc/sysctl.conf otherwise it won't be persistent
  # sudo sysctl -w net.ipv4.conf.all.route_localnet=1
  # echo 'net.ipv4.conf.all.route_localnet=1' >> /etc/sysctl.conf
  # sudo iptables -t nat -I PREROUTING -p tcp --dport 21 -j DNAT --to 127.0.0.1:2121
  exec { 'port-forward-route':
    command => 'sysctl -w net.ipv4.conf.all.route_localnet=1'
  }

  exec { 'port-forward-route-persist':
    command => "echo 'net.ipv4.conf.all.route_localnet=1' >> /etc/sysctl.conf",
    require => Exec['port-forward-route'],
  }

  exec { 'iptables':
    command => 'iptables -t nat -I PREROUTING -p tcp --dport 21 -j DNAT --to 127.0.0.1:2121',
    require => Exec['port-forward-route'],
  }
}
