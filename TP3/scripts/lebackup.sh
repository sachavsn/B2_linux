#!/bin/bash

backup_name="/srv/site1"
name=site1
destination="/sauvegarde/site1"
tar -czf ${name}$(date '+%Y%m%d_%H%M').tar.gz --absolute-names ${backup_name}/index.html
mv ${name}$(date '+%Y%m%d_%H%M').tar.gz ${destination}
