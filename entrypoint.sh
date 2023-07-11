#!/bin/bash

BRANCH=${BRANCH:-main}

PAGE_TITLE=${PAGE_TITLE:-API}

if [ "${BRANCH}" != "main" ]; then

PAGE_TITLE=${PAGE_TITLE}-dev

fi

sed -i 's/RapiDoc/'"${PAGE_TITLE}"'/g' \
  /usr/local/lib/R/site-library/rapidoc/dist/index.html

echo "user:x:$(id -u):0::/home/user:/sbin/nologin" >> /etc/passwd

"$@"
