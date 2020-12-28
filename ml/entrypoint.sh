#!/bin/bash

envsubst < secrets.ini.in > secrets.ini

python3 mlapi.py -c mlapiconfig.ini
