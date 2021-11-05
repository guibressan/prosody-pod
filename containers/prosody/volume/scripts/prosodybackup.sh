#!/usr/bin/env sh

mkdir -p /app/prosody/data/etc
mkdir -p /app/prosody/data/lib
mkdir -p /app/prosody/data/usr

rm -rfv /app/prosody/data/etc/*
rm -rfv /app/prosody/data/lib/*
rm -rfv /app/prosody/data/usr/*
cp -r /etc/prosody/ /app/prosody/data/etc
cp -r /var/lib/prosody/ /app/prosody/data/lib
cp -r /usr/lib/prosody/ /app/prosody/data/usr

touch /app/prosody/data/backup.log
echo "$(date) | Config and Data Backup" >> /app/prosody/data/backup.log