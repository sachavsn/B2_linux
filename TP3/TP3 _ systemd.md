# TP3 : systemd

## I. Services systemd

### 1. Intro


afficher le nombre de services systemd dispos sur la machine:

``` 
[vagrant@node1 ~]$ systemctl list-units --type=service --all
```

afficher le nombre de services systemd actifs et en cours d'exécution ("running") sur la machine:

``` 
[vagrant@node1 ~]$ systemctl -t service | grep running | wc -l
16 
```

afficher le nombre de services systemd qui ont échoué ("failed") ou qui sont inactifs ("exited") sur la machine:

``` 
[vagrant@node1 ~]$ systemctl -t service --all | grep -E 'exited|failed' | wc -l
17 
```

afficher la liste des services systemd qui démarrent automatiquement au boot ("enabled"):

``` 
[vagrant@node1 ~]$ systemctl list-unit-files | grep enabled
```


### 2. Analyse d'un service



```
[vagrant@node1 ~]$ sudo systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
```

le path de l'unité nginx.service est :/usr/lib/systemd/system/nginx.service

On affichr le contenu de l’unité sytemd nginx:
```
[vagrant@node1 ~]$ systemctl cat nginx.service
# /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
[vagrant@node1 ~]$
```

-ExecStart précise le chemin du fichier exécutable à lancer.

-ExecStartPre sont les commandes qui se font juste avant la commande ExectStart. Elles font la meme chose que ExectStart.

-PIDFile donne l'emplacement du fichier PID. Cest recommandé si le type est en "forking".

-Type est le type de démarrage du service. Ici il est en forking, c'est à dire que qu'il lance le processus avec le protocol UNIX.

-ExecReload nous donne la commande qui permet de relancer le service.

-Description est une description du service.

-After indique que le service ne peut se lancer qu'apres certains services qui sont précisés.


### 3. Création d'un service

#### A. Serveur web

Dans ``` /etc/systemd/system``` je fais un fichier que je nomme serverweb.service et dedans j'écris:

```
[Unit]
Description=Service qui lance le serveur web
[Service]
Type=simple
user=nginx1
Environment="PORT=1025"
ExecStartPre=sudo /usr/bin/firewall-cmd --add-port=${PORT}/tcp
ExecStart=/usr/bin/python3 -m http.server ${PORT}
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=sudo /usr/bin/firewall-cmd --remove-port=${PORT}/tcp

[Install]
WantedBy=multi-user.target                             
```

je start le service:

```
[vagrant@node1 system]$ sudo systemctl daemon-reload
[vagrant@node1 system]$ sudo systemctl start serverweb.service
```

Je prouve que ça marche en faisant un curl:

```
[vagrant@node1 system]$ curl 192.168.2.31:1025
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="swapfile">swapfile</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
```

Pour que le service se lance au démarrage de la machine:
```
[vagrant@node1 system]$ sudo systmectl enable serverweb.service
```

#### B. Sauvegarde

Tout d'abord on va creer un user pour la sauvegarde:

```
[vagrant@node1 ~]$ sudo useradd backup
[vagrant@node1 ~]$ sudo passwd backup
[vagrant@node1 ~]$ sudo usermod -aG wheel backup
```

Ensuite le fichier .service pour la sauvegarde:

```
sudo vim /etc/systemd/system/lebackup.service
```

Dedans:

```
[Unit]
[Unit]
Description=Le service de backup (tp3)

[Service]
Type=simple
User=backup
RemainAfterExit=yes
PIDFILE=/var/run/backup.pid
ExecStartPre=sudo /home/vagrant/prerequisbackup.sh
ExecStart=sudo /home/vagrant/lebackup.sh
ExecStartPost=sudo /home/vagrant/stopperbackup.sh
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
```

On oublie pas de reload les services.


Ensuite on creer les 3 scripts pour le backup:

```
[vagrant@node1 scriptsave]$ sudo touch prerequisbackup.sh
[vagrant@node1 scriptsave]$ sudo touch lebackup.sh
[vagrant@node1 scriptsave]$ sudo touch stopperbackup.sh
```

Dans prerequisbackup.sh :

```
#!/bin/bash

backup_name='/srv/site1'
destination='/sauvegarde/site1'

if [ ! -d ${backup_name} ]
then
    echo "le dossier demande n'existe  pas ${backup_name}"
        exit 1
fi

if [ ! -e ${backup_name}/index.html ]
then
    echo "le dossier demandé ne contient pas d'index.html"
    exit 1
fi

if [ ! -d ${destination} ]
then
    mkdir ${destination}
fi

```

Dans lebackup.sh :

```
#!/bin/bash

sudo firewall-cmd --add-port=7777/tcp --permanent
sudo firewall-cmd --reload
```

Dans stopperbackup.sh :

```
#!/bin/bash

backup_name="/srv/site1"

destination="/sauvegarde/site1"

if [[ $(ls -Al ${destination} | wc -l) > 7 ]]
then
    rm ${destination}/$(ls -tr1 ${destination} | grep -m 1 "")
fi
```

Puis on fait le timer pour que le backup se fasse toutes les heures:

```
[vagrant@node1 ~]$ sudo touch /usr/lib/systemd/system/backup.timer
```

Dedans:

```
[Unit]
Description=Sauvegarde toutes les heures

[Timer]
OnCalendar=*-*-* *:00:00
Unit=lebackup.service

[Install]
WantedBy=multi-user.target
```

Et on le start:

```
[vagrant@node1 system]$ sudo systemctl start backup.timer
```

On vérifie qu'il est en état de fonction:

```
[vagrant@node1 system]$ systemctl list-timers
NEXT                         LEFT       LAST                         PASSED       UNIT                         ACTIVATES
Fri 2020-10-09 19:00:00 UTC  22min left n/a                          n/a          backup.timer                 lebackup.service
```

## II. Autres features

### 1. Gestion de boot

On récupère une diagramme du boot au format SVG:

```
[vagrant@node1 ~]$ systemd-analyze plot > diagr.svg
```

Les 3 vervices lents sont 

serverweb.service
firewalld.service
swapfile.swap


### 2. Gestion de l'heure

```
[vagrant@node1 ~]$ timedatectl
      Local time: Fri 2020-10-09 21:03:22 UTC
  Universal time: Fri 2020-10-09 21:03:22 UTC
        RTC time: Fri 2020-10-09 21:03:22
       Time zone: UTC (UTC, +0000)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
```

Changer le fuseau horaire:

```
[vagrant@node1 ~]$ sudo timedatectl set-timezone Europe/Paris
```


### 3. Gestion des noms et de la résolution de noms

```
[vagrant@node1 ~]$ hostnamectl
   Static hostname: new.tp3.b2
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 7f2947e40adeff38724fe91b69fg4383
           Boot ID: 9384v34b9dd7281f82jsq19911d2lq4e
    Virtualization: kvm
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1127.19.1.el7.x86_64
      Architecture: x86-64
```

Changer le hostname :
```
[vagrant@node1 ~]$ sudo hostnamectl set-hostname new.tp3.b2
```

Le chamgement :
```
[vagrant@node1 ~]$ hostnamectl
   Static hostname: new.tp3.b2
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 7f2947e40adeff38724fe91b69fg4383
           Boot ID: 9384v34b9dd7281f82jsq19911d2lq4e
    Virtualization: kvm
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1127.19.1.el7.x86_64
      Architecture: x86-64
```