#!/bin/bash

chgrp -R 0 /home/user /usr/local/lib/R/site-library

chmod -R g=u /home/user /etc/passwd /usr/local/lib/R/site-library
