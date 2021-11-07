#
class pachev_ftp_server_1_path_traversal::install {
  # Install directory will be /opt/pachev_ftp/
  # Flag with be in /home/ftpusr/
  # Server Path - /opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftp_server

  ############################################## ~PROXY SETTINGS START~ ###############################################

  exec { 'set-nic-dhcp':
    command => 'sudo dhclient ens3',
  }

  exec { 'set-sid':
    command => "sudo sed -i 's/172.33.0.51/172.22.0.51/g' /etc/systemd/system/docker.service.d/* /etc/environment /etc/apt/apt.conf /etc/security/pam_env.conf",
  }

  exec { 'set-proxy_env':
    command => 'export http_proxy=172.22.0.51:3128; export https_proxy=172.22.0.51:3128',
  }

  ##############################################  ~PROXY SETTINGS END~  ###############################################

  # Install Rust
  package { 'install-rustc':
    ensure => 'rustc'
  }
  ensure_packages('rustc')

  # Require .zip
  file { '/opt/pachev_ftp/':
    ensure  => file,
    source  => 'puppet:///modules/pachev_ftp_server_1_path_traversal/files/pachev_ftp-master.zip',
    require => User['ftpusr'],
  }

  # Unzip
  exec { 'unzip-pachev-ftp-master':
    require => Package['install-rustc'],
    command => 'unzip pachev_ftp-master.zip',
    cwd     => '/opt/pachev_ftp/',
    creates => '/opt/pachev_ftp/pachev_ftp-master/',
  }

  # Update Cargo
  exec { 'update-cargo':
    require => Exec['unzip-pachev-ftp-master'],
    command => 'cargo update',
    cwd     => '/opt/pachev_ftp/pachev_ftp-master/ftp_server/',
  }

  # Cargo build 
  exec { 'build-ftpserver':
    require => Exec['update-cargo'],
    command => 'cargo build --release',
    cwd     => '/opt/pachev_ftp/pachev_ftp-master/ftp_server/',
  }

  # (Make sure files are in the correct spot)

  # Undo proxy settings
  ############################################## ~PROXY SETTINGS UNDO START~ ##############################################
  exec { 'undo-proxy-http':
    require => Exec['build-ftpserver'],
    command => 'unset http_proxy',
  }

  exec { 'undo-proxy-https':
    require => Exec['undo-proxy-http'],
    command => 'unset http_proxys',
  }

  exec { 'restart-networking':
    require => Exec['undo-proxy-https'],
    command => 'service networking restart'
  }

  ##############################################  ~PROXY SETTINGS UNDO END~  ##############################################

}
