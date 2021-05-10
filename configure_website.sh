#!/bin/bash

sudo mkdir /var/www/cybersecurity

i=1
while [ $i -ne 11 ]; do
  cat "<html><head><title>Site $1</title></head><body><p>Blue Team 5</p></body></html>" > "/var/www/cybersecurity/$1.html"
  i=(($i+1))
done

