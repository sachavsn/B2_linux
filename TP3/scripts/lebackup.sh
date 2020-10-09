#!/bin/bash

sudo firewall-cmd --add-port=7777/tcp --permanent
sudo firewall-cmd --reload
