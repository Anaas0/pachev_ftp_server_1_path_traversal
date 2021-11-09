#
class pachev_ftp_server_1_path_traversal::install {

Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ], environment => [ 'http_proxy=172.22.0.51:3128', 'https_proxy=172.22.0.51:3128' ] }
  ############################################## ~PROXY SETTINGS START~ ###############################################

  exec { 'set-nic-dhcp':
    command   => 'sudo dhclient ens3',
    notify    => Exec['set-sed'],
    logoutput => true,
  }

  exec { 'set-sed':
    command   => "sudo sed -i 's/172.33.0.51/172.22.0.51/g' /etc/systemd/system/docker.service.d/* /etc/environment /etc/apt/apt.conf /etc/security/pam_env.conf",
    notify    => Exec['set-https-env'],
    logoutput => true,
  }

  ##############################################  ~PROXY SETTINGS END~  ###############################################

  # Install Rust
  ensure_resource('package', 'rustc',{
    ensure => present,
    notify => User['ftpusr'],
  })

  # Create /opt/pachev_ftp directory
  file { '/opt/pachev_ftp':
    ensure => 'directory',
    notify => File['/opt/pachev_ftp/pachev_ftp-master.zip'],
  }

  # Require .zip
  file { '/opt/pachev_ftp/pachev_ftp-master.zip':
    source  => '/home/unhcegila/puppet-modules/pachev_ftp_server_1_path_traversal/files/pachev_ftp-master.zip',
    require => User['ftpusr'],
    notify  => Exec['unzip-pachev-ftp-master'],
  }

  # Unzip
  exec { 'unzip-pachev-ftp-master':
    command   => 'unzip pachev_ftp-master.zip',
    cwd       => '/opt/pachev_ftp/',
    creates   => '/opt/pachev_ftp/pachev_ftp-master/',
    require   => Package['rustc'],
    notify    => Exec['update-cargo'],
    logoutput => true,
  }

  # Update Cargo
  exec { 'update-cargo':
    command   => 'cargo update',
    cwd       => '/opt/pachev_ftp/pachev_ftp-master/ftp_server/',
    require   => Exec['unzip-pachev-ftp-master'],
    notify    => Exec['build-ftpserver'],
    logoutput => true,
  }

  # Cargo build 
  exec { 'build-ftpserver':
    command   => 'cargo build --release',
    cwd       => '/opt/pachev_ftp/pachev_ftp-master/ftp_server/',
    require   => Exec['update-cargo'],
    notify    => Exec['restart-networking'],
    logoutput => true,
  }

  # Undo proxy settings
  ############################################## ~PROXY SETTINGS UNDO START~ ##############################################

  exec { 'restart-networking':
    command   => 'service networking restart',
    require   => Exec['undo-proxy-https'],
    notify    => File['/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf'],
    logoutput => true,
  }

  ##############################################  ~PROXY SETTINGS UNDO END~  ##############################################
}
