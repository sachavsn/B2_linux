#!/bin/sh

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.1.1 nginx.node3 nginx.node3
192.168.1.41 gitea.node1 gitea.node1
192.168.1.42 mariadb.node2 mariadb.node2
192.168.1.44 nfs.node4 nfs.node4" > /etc/hosts

yum install -y epel-release
yum install -y nginx

echo "# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  tp4linux.gitea.com;
        root         /usr/share/nginx/html;
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;
        location / {
            proxy_pass http://192.168.1.41:3000;
        }
        error_page 404 /404.html;
        location = /404.html {
        }
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}" > /etc/nginx/nginx.conf

systemctl start nginx
systemctl enable nginx

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload

yum install -y nfs-utils
mkdir /mnt/nginx
mount 192.168.1.44:/home/vagrant/nginx /mnt/nginx

echo "#!/bin/sh
cp /etc/nginx/nginx.conf /mnt/nginx" > /mnt/nginx/backup.sh

echo "0 * * * * /mnt/nginx/backup.sh" > /var/spool/cron/vagrant

bash <(curl -Ss https://my-netdata.io/kickstart.sh)
echo 'SEND_DISCORD="YES"
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/769958282147790878/p1nXmaiXoyWwxkQTMGa3KnndnPHAqMJuCRA7eB79yFy0f4K_Kiv_3NYlyX3hpgn9-tia"
DEFAULT_RECIPIENT_DISCORD="alarms"' > /etc/netdata/health_alarm_notify.conf