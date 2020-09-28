# TP1 : Déploiement classique

## 0. Prérequis

#### Ajout d'un disque

On ajoute un deuxieme dique dans virtual box pour notre vm.

![](https://i.imgur.com/Hl9d2o9.png)

#### Partitionner LVM

On repère les diques à partitionner et on utilise la commande:

```
[svoisin@localhost ~]$ lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0    8G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    7G  0 part
  ├─centos-root 253:0    0  6.2G  0 lvm  /
  └─centos-swap 253:1    0  820M  0 lvm  [SWAP]
sdb               8:16   0    5G  0 disk
sr0              11:0    1 1024M  0 rom
```

Puis le disque sdb est ajouté en tant que pv dansLVM et on vérifie avec pvs.

```
[svoisin@localhost ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

[svoisin@localhost ~]$ sudo pvs
  PV         VG     Fmt  Attr PSize  PFree
  /dev/sda2  centos lvm2 a--  <7.00g    0
  /dev/sdb          lvm2 ---   5.00g 5.00g
```

On crée un Volume groupe:

```
[svoisin@localhost ~]$ sudo vgcreate data /dev/sdb
  Volume group "data" successfully created
```

Puis on crée les 2 LV de 2 et 3 gigas.

```
[svoisin@localhost ~]$ sudo lvcreate -L 2G data -n data1
  Logical volume "data1" created.

[svoisin@localhost ~]$ sudo lvcreate -l 100%FREE data -n data2
  Logical volume "data2" created.
```

On vérifie

```
[svoisin@localhost ~]$ sudo lvs
  LV    VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root  centos -wi-ao----  <6.20g
  swap  centos -wi-ao---- 820.00m
  data1 data   -wi-a-----   2.00g
  data2 data   -wi-a-----  <3.00g
```

On formate ensuite les partitons:

```
[svoisin@localhost ~]$ mkfs -t ext4 /dev/data/data1
mke2fs 1.42.9 (28-Dec-2013)
mkfs.ext4: Permission denied while trying to determine filesystem size

[svoisin@localhost ~]$ sudo !!
sudo mkfs -t ext4 /dev/data/data1
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
131072 inodes, 524288 blocks
26214 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=536870912
16 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

[svoisin@localhost ~]$ sudo mkfs -t ext4 /dev/data/data2
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
196608 inodes, 785408 blocks
39270 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=805306368
24 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

[svoisin@localhost ~]$ sudo mkdir /mnt/data1
```

On crée deux dossier pour pouvoir monter nos partitions:

```
[svoisin@localhost ~]$ sudo mkdir /mnt/site1

[svoisin@localhost ~]$ sudo mkdir /mnt/site2
```

Puis on monte nos partitions:

```
[svoisin@localhost ~]$ sudo mount /dev/data/data1 /mnt/site1

[svoisin@localhost ~]$ sudo mount /dev/data/data2 /mnt/site2

[svoisin@localhost ~]$ mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime,seclabel)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
devtmpfs on /dev type devtmpfs (rw,nosuid,seclabel,size=495604k,nr_inodes=123901,mode=755)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,seclabel)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,seclabel,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,nodev,seclabel,mode=755)
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,seclabel,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd)
pstore on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,pids)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,cpuacct,cpu)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,net_prio,net_cls)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,devices)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,blkio)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,hugetlb)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,cpuset)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,memory)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,perf_event)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,freezer)
configfs on /sys/kernel/config type configfs (rw,relatime)
/dev/mapper/centos-root on / type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
selinuxfs on /sys/fs/selinux type selinuxfs (rw,relatime)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=32,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=12193)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime,seclabel)
debugfs on /sys/kernel/debug type debugfs (rw,relatime)
mqueue on /dev/mqueue type mqueue (rw,relatime,seclabel)
/dev/sda1 on /boot type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
tmpfs on /run/user/1001 type tmpfs (rw,nosuid,nodev,relatime,seclabel,size=101484k,mode=700,uid=1001,gid=1001)
/dev/mapper/data-data1 on /mnt/site1 type ext4 (rw,relatime,seclabel,data=ordered)
/dev/mapper/data-data2 on /mnt/site2 type ext4 (rw,relatime,seclabel,data=ordered)
```

On vérifie que nos partitions ont bien été monté sur /mnt/site1 et site2:

```
[svoisin@localhost ~]$ df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 484M     0  484M   0% /dev
tmpfs                    496M     0  496M   0% /dev/shm
tmpfs                    496M  6.8M  489M   2% /run
tmpfs                    496M     0  496M   0% /sys/fs/cgroup
/dev/mapper/centos-root  6.2G  1.4G  4.9G  23% /
/dev/sda1               1014M  186M  829M  19% /boot
tmpfs                    100M     0  100M   0% /run/user/1001
/dev/mapper/data-data1   2.0G  6.0M  1.8G   1% /mnt/site1
/dev/mapper/data-data2   2.9G  9.0M  2.8G   1% /mnt/site2
```

On va faire un montage automatique au démarrage de la vm en modifiant le fichier /etc/fstab et on vérifie:

```
[svoisin@localhost ~]$    sudo nano /etc/fstab

[svoisin@localhost ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
swap                     : ignored
/mnt/site1               : already mounted
/mnt/site2               : already mounted
```

Pour avoir internet on utilise la carte NAT(ajouter dans virtual box) dans et une route par default:
``
```
[svoisin@node1 ~]$ ip r s
default via 10.0.2.2 dev enp0s3 proto dhcp metric 102
```

Pour bien vérifier qu'on a internet on curl google.com:

```$[svoisin@localhost ~]$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```
 On peut donc voir qu'on a bien internet!

Faire communiquer nos deux vm ensemble:

avoir une route:
```
[svoisin@node1 ~]$ ip r s
192.168.10.0/24 dev enp0s8 proto kernel scope link src 192.168.10.2 metric 101
```
On donne bien un hostname au deux vm(node1 et 2) et dans hosts donner l'ip de l'autre machine avec son nom associé. On reboot.
On peut donc ping les deux machines entre elles:
```
[svoisin@node1 ~]$ ping node2.tp1.b2
PING node2.tp1.b2 (192.168.10.3) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (192.168.10.3): icmp_seq=1 ttl=64 time=0.656 ms
64 bytes from node2.tp1.b2 (192.168.10.3): icmp_seq=2 ttl=64 time=1.23 ms
64 bytes from node2.tp1.b2 (192.168.10.3): icmp_seq=3 ttl=64 time=0.523 ms
64 bytes from node2.tp1.b2 (192.168.10.3): icmp_seq=4 ttl=64 time=0.591 ms
64 bytes from node2.tp1.b2 (192.168.10.3): icmp_seq=5 ttl=64 time=0.878 ms
64 bytes from node2.tp1.b2 (192.168.10.3): icmp_seq=6 ttl=64 time=0.929 ms
^C
--- node2.tp1.b2 ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5007ms
rtt min/avg/max/mdev = 0.523/0.801/1.230/0.241 ms


[svoisin@node2 ~]$ ping node1.tp1.b2
PING node1.tp1.b2 (192.168.10.2) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (192.168.10.2): icmp_seq=1 ttl=64 time=0.695 ms
64 bytes from node1.tp1.b2 (192.168.10.2): icmp_seq=2 ttl=64 time=1.23 ms
64 bytes from node1.tp1.b2 (192.168.10.2): icmp_seq=3 ttl=64 time=0.980 ms
64 bytes from node1.tp1.b2 (192.168.10.2): icmp_seq=4 ttl=64 time=1.08 ms
64 bytes from node1.tp1.b2 (192.168.10.2): icmp_seq=5 ttl=64 time=0.884 ms
64 bytes from node1.tp1.b2 (192.168.10.2): icmp_seq=6 ttl=64 time=0.863 ms
^C
--- node1.tp1.b2 ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5004ms
rtt min/avg/max/mdev = 0.695/0.956/1.230/0.173 ms
```

On crée un nouveau utilisateur avec useradd et on lui donne un mdp et les droits root:
```
sudo useradd admin
sudo passwd admin
sudo visudo dans le fichier admin ALL=(ALL) ALL
```
On regarde les ports ouvert:
```
[user@node1 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client ssh
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
Le port 22 est utilisé pour le ssh.

## 1. Setup serveur Web

On installe nginx:
```
[svoisin@node1 ~]$ sudo yum install epel-release   
[svoisin@node1 ~]$ sudo yum install nginx -y   
```

On crée les fichiers index.html avec du contenu:
```
[svoisin@node1 ~]$ sudo touch /mnt/site1/index.html
[svoisin@node1 ~]$ sudo touch /mnt/site2/index.html
```
On leur donne des permissions:
```
[svoisin@node1 ~]$ sudo chmod 755 /mnt/site1/index.html
[svoisin@node1 ~]$ sudo chmod 755 /mnt/site2/index.html
```

On les associe à un utilisateur et un groupe.

```
sudo chown svoisin:svoisin /mnt/sie1
sudo chown svoisin:svoisin /mnt/site2
```
On ouvre les services http et https:
```
[svoisin@node1 ~]$ sudo firewall-cmd --zone=public --add-service=http
[svoisin@node1 ~]$ sudo firewall-cmd --zone=public --add-service=https
```
On configure nginx:
```
[svoisin@node1 ~]$ sudo nano /etc/nginx/nginx.conf
```
Le code à l'interieur:
```
worker_processes 1;
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
                alias /mnt/site1;
        }

        location /site2 {
                alias /mnt/site2;
        }
}

server {
        listen 443 ssl;

        server_name node1.tp1.b2;
        ssl_certificate server.crt;
        ssl_certificate_key server.key;

        location / {
            return 301 /site1;
        }

        location /site1 {
            alias /mnt/site1;
        }
        location /site2 {
            alias /mnt/site2;
        }
    }
}

```
On génère le certifat https et on déplace les fichiers server.crt et key dans nginx.
```
[svoisin@node1 ~]$ openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt
Generating a 2048 bit RSA privaGenerating a 2048 bit RSA private key
..te key..................+++
........................................+++
writing new private key to 'server.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:
string is too long, it needs to be less than  2 bytes long
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:node1.tp1.b2
Email Address []:
```

```
[svoisin@node1 ~]$ sudo mv server.crt /etc/nginx
[svoisin@node1 ~]$ sudo mv server.key /etc/nginx
```
On start nginx:
```
[svoisin@node1 ~]$ sudo systemctl start nginx
```

Puis on vérifie qu'on peux se connecter aux deux sites avec node2:

```
[svoisin@node2 ~]$ curl -L node1.tp1.b2/site1
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Titre de la page</title>
</head>
<body>
        <h1>C'est le site 1</h2>
</body>
</html>
```

```
[svoisin@node2 ~]$ curl -L node2.tp1.b2/site1
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Titre de la page</title>
</head>
<body>
        <h1>C'est le site 2</h2>
</body>
</html>
```

## 2. Script de sauvegarde


On crée le fichier script:
```
[svoisin@node1 ~]$ sudo touch tp1_backup.sh
````

Création du dossier de sauvegarde
```
[svoisin@node1 ~]$ sudo mkdir backup
```

On crée le user backup:
```
[svoisin@node1 ~]$ sudo adduser backup
```

On ajoute notre script
```
[svoisin@node1 ~]$ sudo nano tp1_backup.sh
```
Le script:
```
#!/bin/sh
#svoisin
#23/09/2020
#Script tp1 (backup pour site)

# les fichiers a sauvegarder du site
backup_fichier="$(basename $1)"

#La destination
ladestination="./backup"

#date
ladate=$(date "+%Y%m%d_%H%M")
name="${backup_fichier}_${ladate}.tar.gz"

backup_doss_path="${1}"

labackup () {
        tar -cvzf "${ladestination}/${name}" "${backup_doss_path}"

}

supprimer_le_fichier() {
    if [[ "$(ls labackup/ | grep ${backup_fichier} | wc -w)" -gt "7" ]]
    then
         ls | grep $"{backup_fichier}" | sort > tmp
         rm -rf $"(head -1 tmp)"
         rm -f tmp
    fi
}

labackup
supprimer_le_fichier
exit 0
```

On configure crontab:
```
[svoisin@node1 ~]$ crontab -e
crontab: installing new crontab
[svoisin@node1 ~]$ crontab -l
01 * * * * ./tp1_backup.sh /mnt/site1
01 * * * * ./tp1_backup.sh /mnt/site2
```

# 3. Monitoring, alerting

On installe Netdata:
```
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

On ouvre son port et on reload.
```
firewall-cmd --add-port=19999/tcp --permanent
firewall-cmd --reload
```

![](https://i.imgur.com/0ALTySv.png)


On doit maintenant le lier à notre serveur discord:

Pour cela on modifie:
```/etc/netdata/edit-config-health_alarm_notify.conf```

on complète la ligne discord:
```
DISCORD_WEBHOOK_URL=""
```
On y met le lien discord.

On ajoute dans le fichier conf de nginx:
```
 location ~ /netdata/(?<ndpath>.*) {
            proxy_redirect off;
            proxy_set_header Host $host;

            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_pass_request_headers on;
            proxy_set_header Connection "keep-alive";
            proxy_store off;
            proxy_pass http://netdata/$ndpath$is_args$args;

            gzip on;
            gzip_proxied any;
            gzip_types *;
```

Maintenant on recevra des notification sur discord.
