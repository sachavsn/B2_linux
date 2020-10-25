#!/bin/sh

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.1.1 gitea.node1 gitea.node1
192.168.1.42 mariadb.node2 mariadb.node2
192.168.1.43 nginx.node3 nginx.node3
192.168.1.44 nfs.node4 nfs.node4" > /etc/hosts

yum install -y wget
yum install -y git

firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --reload

wget -O gitea https://dl.gitea.io/gitea/1.12.5/gitea-1.12.5-linux-amd64
chmod +x gitea

adduser git
passwd -f -u git

mkdir -p /var/lib/gitea
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea

echo "[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target
[Service]
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/gitea.service

systemctl daemon-reload
systemctl enable gitea
systemctl start gitea

yum install -y nfs-utils
mkdir /mnt/gitea
mount 192.168.1.44:/home/vagrant/gitea /mnt/gitea

echo "#!/bin/sh
tar -czf backup.tar.gz /etc/gitea/
cp ./backup.tar.gz /mnt/gitea" > /mnt/gitea/backup.sh

echo "0 * * * * /mnt/gitea/backup.sh" > /var/spool/cron/vagrant

bash <(curl -Ss https://my-netdata.io/kickstart.sh)
echo 'SEND_DISCORD="YES"
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/769958282147790878/p1nXmaiXoyWwxkQTMGa3KnndnPHAqMJuCRA7eB79yFy0f4K_Kiv_3NYlyX3hpgn9-tia"
DEFAULT_RECIPIENT_DISCORD="alarms"' > /etc/netdata/health_alarm_notify.conf