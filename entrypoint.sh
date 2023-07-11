#!/bin/bash

PAGE_TITLE=${PAGE_TITLE:-API}

R_LIBRARY=$(R --slave -e "cat(.libPaths()[[1]])")

sed -i 's/RapiDoc/'"${PAGE_TITLE}"'/g' "${R_LIBRARY}"/rapidoc/dist/index.html

echo "user:x:$(id -u):0::/home/user:/sbin/nologin" >> /etc/passwd

"$@"
