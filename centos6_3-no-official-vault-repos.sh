### This is to overcome the error.
### Remove all other '.repo' files.
# Determining fastest mirrors
# http://vault.centos.org/6.8/os/x86_64/repodata/repomd.xml: [Errno 14] problem making ssl connection
# Trying other mirror.
# Error: Cannot retrieve repository metadata (repomd.xml) for repository: base. Please verify its path and try again

~$ vi /etc/yum.repos.d/CentOS-Vault.repo

[base]
name=CentOS-6.8 - Base - Vault
baseurl=http://linuxsoft.cern.ch/centos-vault/6.8/os/$basearch/
gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[updates]
name=CentOS-6.8 - Updates - Vault
baseurl=http://linuxsoft.cern.ch/centos-vault/6.8/updates/$basearch/
gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[extras]
name=CentOS-6.8 - Extras - Vault
baseurl=http://linuxsoft.cern.ch/centos-vault/6.8/extras/$basearch/
gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1


### Other options
https://archive.kernel.org/centos-vault/6.8/
https://mirror.nsc.liu.se/centos-store/6.8/
