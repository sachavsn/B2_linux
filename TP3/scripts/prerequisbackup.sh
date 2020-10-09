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

