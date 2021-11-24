# Remove proxy environment settings.
# Adjust file paths to suite SecGen.
class pachev_ftp_server_1_path_traversal::config {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ], environment => [ 'http_proxy=172.22.0.51:3128', 'https_proxy=172.22.0.51:3128' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  #$raw_org = $secgen_parameters['organisation']
  $leaked_filenames = $secgen_parameters['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/users.cfg', '/home/ftpusr/pachev_ftp/flag.txt']
  $strings_to_leak = $secgen_parameters['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/users.cfg maybe?']
  $strings_to_pre_leak = $secgen_parameters['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot/ftpusr/hint_file.txt']

  # Create user
  user { 'ftpusr':
    ensure     => present,
    uid        => '666',
    gid        => 'root',#
    home       => '/home/ftpusr',
    managehome => true,
    notify     => File['/opt/pachev_ftp/'],
  }

  # Create directory conf
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf':
    ensure  => 'directory',
    require => Exec['build-ftpserver'],
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    notify  => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot'],
  }

  # Create directory ftproot
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot':
    ensure  => 'directory',
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    require => Exec['build-ftpserver'],
    notify  => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs'],
  }

  # Create directory logs
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs':
    ensure  => 'directory',
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    require => Exec['build-ftpserver'],
    notify  => File['/opt/pachev_ftp/pachevftp.service'],
  }

  # Create pachevftp.service
  file { '/opt/pachev_ftp/pachevftp.service':
    ensure => present,
    owner  => 'ftpusr',
    mode   => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    source => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/pachevftp.service',
    notify => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/fsys.cfg'],
  }

  # Create conf/fsys.cfg
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/fsys.cfg':
    ensure  => present,
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/fsys.cfg',
    require => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf'],
    notify  => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/users.cfg'],
  }

  # Create conf/users.cfg
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/users.cfg':
    ensure  => present,
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/users.cfg',
    require => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf'],
    notify  => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs/fserver.log'],
  }

  # Create logs/fserver.log
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs/fserver.log':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/fserver.log',
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    require => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs'],
    notify  => File['/etc/.pachevftpconf'],
  }

  # Create hidden file to hold service start arguments
  file { '/etc/.pachevftpconf':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/pachevftpconf',
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    require => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs/fserver.log'],
    notify  => File['/home/ftpusr/pachev_ftp'],
  }

  # Create directory for the flag
  file { '/home/ftpusr/pachev_ftp':
    ensure  => directory,
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    require => User['ftpusr'],
    notify  => File['/home/ftpusr/pachev_ftp/flag.txt'],
  }

  # Create flag file
  file { '/home/ftpusr/pachev_ftp/flag.txt':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/flag.txt',
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    require => File['/home/ftpusr/pachev_ftp'],
    notify  => Exec['port-forward-route'],
  }

  # Hint file
  file { '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot/ftpusr/hint_file.txt':
    ensure  => present,
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/hint_file.txt',
    owner   => 'ftpusr',
    mode    => '0755', # Full permissions for ftpusr, read-execute, read-execute.
    require => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/logs/fserver.log'],
    notify  => File['/home/ftpusr/pachev_ftp'],
  }

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
