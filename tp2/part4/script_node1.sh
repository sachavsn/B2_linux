#!/bin/sh
#svoisin
#30/09/2020
#Script tp1

echo "192.168.2.22 node2.tp2.b2" >> /etc/hosts
mkdir /srv
mkdir /srv/site1
mkdir /srv/site2
touch /srv/site1/index.html
touch /srv/site2/index.html

# On met les permissions
chmod -R 755 /srv/site1
chmod -R 755 /srv/site2
chown -R vagrant:vagrant /srv/site1
chown -R vagrant:vagrant /srv/site1
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https


# Configuration nginx
echo "worker_processes 1;
error_log nginx_error.log;
events {
    worker_connections 1024;
}
http {
     server {
       listen 80;
        server_name node1.tp1.b2;
        location / {
                return 301 /site1;
        }
        location /site1 {
                alias /srv/site1;
        }
        location /site2 {
                alias /srv/site2;
        }
}
server {
        listen 443 ssl;
        server_name node1.tp2.b2;
        ssl_certificate server.crt;
        ssl_certificate_key server.key;
        location / {
            return 301 /site1;
        }
        location /site1 {
            alias /srv/site1;
        }
        location /site2 {
            alias /srv/site2;
        }
        location ~ /netdata/(?<ndpath>.*) {
            proxy_redirect off;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Host \$host;
            proxy_set_header X-Forwarded-Server \$host;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_pass_request_headers on;
            proxy_set_header Connection 'keep-alive';
            proxy_store off;
            proxy_pass http://netdata/\$ndpath\$is_args\$args;
            gzip on;
            gzip_proxied any;
            gzip_types *;
        }
    }
}" > /etc/nginx/nginx.conf

echo "Index site 1" > /srv/site1/index.html
echo "Index site 2" > /srv/site2/index.html

# Le certificat https
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=node1.tp2.b2"
mv server.crt /etc/nginx
mv server.key /etc/nginx
systemctl start nginx

# Script de sauvegarde

touch tp2.script.sh
mkdir sauvegarde
mkdir sauvegarde/site1
mkdir sauvegarde/site2
adduser backup

echo '#!/bin/bash
# On crée une variable qui va récupérer la fin de l argument
# Si l argument est /toto/tata/titi, alors on récupère titi
backup_name="$(basename $1)"
# On crée une variable qui sera la destination de notre fichier de sauvegarde
destination="sauvegarde/${backup_name}"
if [ ! -d ${1} ]
then
        echo "le dossier demandé n existe pas $1"
        exit 1
fi
# On rentre dans la boucle si le dossier est vide
if [ ! -e ${1}/index.html ]
then
        echo "le dossier demandé ne contient pas d index.html"
        exit 1
fi
if [ ! -d ${destination} ]
then
        mkdir ${destination}
fi
# On compresse le fichier
tar -czf ${backup_name}$(date "+%Y%m%d_%H%M").tar.gz --absolute-names ${1}/index.html
# On déplace le fichier qui vient d être créé
mv ${backup_name}$(date "+%Y%m%d_%H%M").tar.gz ${destination}
# On rentre dans la boucle s il y a plus de 7 fichier dans le dossier
if [[ $(ls -Al ${destination} | wc -l) > 7 ]]
then
        rm ${destination}/$(ls -tr1 ${destination} | grep -m 1 "")
fi
' > tp2.script.sh

chmod +x tp2.script.sh
yum install crontabs
systemctl start crond.service

# on installe netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait


# Les firewalls
firewall-cmd --add-port=19999/tcp --permanent
firewall-cmd --reload
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https
