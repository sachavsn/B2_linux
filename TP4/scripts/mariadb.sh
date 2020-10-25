#!/bin/bash

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.1.1 mariadb.node2 mariadb.node2
192.168.1.41 gitea.node1 gitea.node1
192.168.1.43 nginx.node3 nginx.node3
192.168.1.44 nfs.node4 nfs.node4" > /etc/hosts

yum install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb

firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --reload

echo "[mysqld]
bind-address = 192.168.1.41
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd
[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
#
# include all files from the config directory
#
!includedir /etc/my.cnf.d" > /etc/my.cnf

yum install -y nfs-utils
mkdir /mnt/db
mount 192.168.1.44:/home/vagrant/mariadb /mnt/mariadb

echo "#!/bin/sh
mysql -u root -proot giteadb > bdd-dump.sql
mv ./bdd-dump.sql /mnt/mariadb" > /mnt/db/backup.sh

echo "0 * * * * /mnt/db/backup.sh" > /var/spool/cron/vagrant

bash <(curl -Ss https://my-netdata.io/kickstart.sh)
echo 'SEND_DISCORD="YES"
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/769958282147790878/p1nXmaiXoyWwxkQTMGa3KnndnPHAqMJuCRA7eB79yFy0f4K_Kiv_3NYlyX3hpgn9-tia"
DEFAULT_RECIPIENT_DISCORD="alarms"' > /etc/netdata/health_alarm_notify.conf