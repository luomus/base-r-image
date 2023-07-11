#!/bin/bash

BRANCH=${BRANCH:-main}

PAGE_TITLE=${PAGE_TITLE:-API}

if [ "${BRANCH}" != "main" ]; then

PAGE_TITLE=${PAGE_TITLE}-dev

fi

R_LIBRARY=$(R --slave -e "cat(.libPaths()[[1]])")

sed -i 's/RapiDoc/'"${PAGE_TITLE}"'/g' "${R_LIBRARY}"/rapidoc/dist/index.html

echo "user:x:$(id -u):0::/home/user:/sbin/nologin" >> /etc/passwd

"$@"
