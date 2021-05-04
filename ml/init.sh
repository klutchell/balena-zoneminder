#!/bin/bash

set -e

secrets_file=/usr/src/app/secrets.ini
# for each var in secrets.ini update it with the env var if available
while IFS='=' read -r var _
do
    [ -n "${!var}" ] && crudini --set "${secrets_file}" secrets "${var}" "${!var}"
done < <(crudini --get --format sh "${secrets_file}" secrets | awk '{print toupper($0)}')

[ -n "${DETECTION_PATTERN}" ] && crudini --set /usr/src/app/mlapiconfig.ini object object_detection_pattern "${DETECTION_PATTERN}"

python3 /usr/src/app/mlapi_dbuser.py -u "${ML_USER}" -p "${ML_PASSWORD}" --force || true

python3 /usr/src/app/check_cuda.py || sleep infinity
python3 /usr/src/app/check_opencv.py || sleep infinity

exec python3 /usr/src/app/mlapi.py -c /usr/src/app/mlapiconfig.ini
