#!/bin/bash

mkdir /app/prosody
mkdir /app/prosody/data 
mkdir /app/prosody/data/etc 
mkdir /app/prosody/data/lib 
mkdir /app/prosody/data/usr

rm -r /app/prosody/data/etc/*
rm -r /app/prosody/data/lib/*
rm -r /app/prosody/data/usr/*
cp -r /etc/prosody/ /app/prosody/data/etc 
cp -r /var/lib/prosody/ /app/prosody/data/lib 
cp -r /usr/lib/prosody/ /app/prosody/data/usr

touch /app/prosody/data/backup.log
echo "$(date) | Config and Data Backup" >> /app/prosody/data/backup.log