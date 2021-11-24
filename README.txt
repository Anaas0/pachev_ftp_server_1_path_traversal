The FTP server is installed in: 
    /opt/

All the information such as FTP usernames, passwords and roles are in: 
    /opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/conf/users.cfg
The attacker could change the exploit to get this file. Or could just go for the flags file.

Data from the FTP clients is stored at:
    /opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot/
The application creates a subdirectory with the users name.

Flags location: 
    /home/ftpusr/pachev_ftp/flag.txt

Hint file location:
    /opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release/ftproot/ftpusr/hint_file.txt

The FTP server can be started with:
    ./ftp_server -p 2121
in the binary directory but if you use the full path from root it always fails. So i havent managed to get the servive file to work due to this.