#
class pachev_ftp_server_1_path_traversal::install {
  # Install directory will be /opt/pachev_ftp/
  # Flag with be in /home/ftpusr/
  # Server Path - /opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftp_server

  ############################################## ~PROXY SETTINGS START~ ###############################################

  exec { 'set-nic-dhcp':
    command => 'sudo dhclient ens3',
    notify  => Exec['set-sed'],
  }

  exec { 'set-sed':
    command => "sudo sed -i 's/172.33.0.51/172.22.0.51/g' /etc/systemd/system/docker.service.d/* /etc/environment /etc/apt/apt.conf /etc/security/pam_env.conf",
    notify  => Exec['set-proxy_env'],
  }

  exec { 'set-proxy_env':
    command => 'export http_proxy=172.22.0.51:3128; export https_proxy=172.22.0.51:3128;',
    notify  => Package['install-rustc'],
  }

  ##############################################  ~PROXY SETTINGS END~  ###############################################

  # Install Rust
  package { 'install-rustc':
    ensure => 'rustc',
    notify => User['ftpusr'],
  }
  ensure_packages('rustc')

  # Require .zip
  file { '/opt/pachev_ftp/':
    ensure  => file,
    source  => 'puppet:///modules/pachev_ftp_server_1_path_traversal/files/pachev_ftp-master.zip',
    require => User['ftpusr'],
    notify  => Exec['unzip-pachev-ftp-master'],
  }

  # Unzip
  exec { 'unzip-pachev-ftp-master':
    command   => 'unzip pachev_ftp-master.zip',
    cwd       => '/opt/pachev_ftp/',
    creates   => '/opt/pachev_ftp/pachev_ftp-master/',
    require   => Package['install-rustc'],
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
    notify    => Exec['undo-proxy-http'],
    logoutput => true,
  }

  # (Make sure files are in the correct spot)

  # Undo proxy settings
  ############################################## ~PROXY SETTINGS UNDO START~ ##############################################
  exec { 'undo-proxy-http':
    command   => 'unset http_proxy',
    require   => Exec['build-ftpserver'],
    notify    => Exec['undo-proxy-https'],
    logoutput => true,
  }

  exec { 'undo-proxy-https':
    command   => 'unset http_proxys',
    require   => Exec['undo-proxy-http'],
    notify    => Exec['restart-networking'],
    logoutput => true,
  }

  exec { 'restart-networking':
    command   => 'service networking restart',
    require   => Exec['undo-proxy-https'],
    notify    => File['opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf'],
    logoutput => true,
  }

  ##############################################  ~PROXY SETTINGS UNDO END~  ##############################################

}
