#!/usr/bin/bash

openssl req -x509 -nodes -days 365 -subj /CN=Synergy -newkey rsa:2048 -keyout Synergy.pem -out Synergy.pem
