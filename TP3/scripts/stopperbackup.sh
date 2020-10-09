#!/bin/bash

backup_name="/srv/site1"

destination="/sauvegarde/site1"

if [[ $(ls -Al ${destination} | wc -l) > 7 ]]
then
    rm ${destination}/$(ls -tr1 ${destination} | grep -m 1 "")
fi
