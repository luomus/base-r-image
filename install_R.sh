#!/bin/bash
set -e

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen en_US.utf8
/usr/sbin/update-locale LANG=en_US.UTF-8

BUILDDEPS="curl \
  default-jdk \
  libbz2-dev \
  libcairo2-dev \
  libpango1.0-dev \
  libjpeg-dev \
  libicu-dev \
  libpcre2-dev \
  libpng-dev \
  libreadline-dev \
  libtiff5-dev \
  liblzma-dev \
  libx11-dev \
  libxt-dev \
  perl \
  subversion \
  tcl-dev \
  tk-dev \
  texinfo \
  texlive-extra-utils \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-latex-recommended \
  texlive-latex-extra \
  x11proto-core-dev \
  xauth \
  xfonts-base \
  xvfb \
  wget"

apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS

wget https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz
mkdir -p R-${R_VERSION}
chown root:staff  R-${R_VERSION}
chmod g+ws R-${R_VERSION}
tar xzf R-${R_VERSION}.tar.gz --no-same-owner --no-overwrite-dir

cd R-${R_VERSION}
R_PAPERSIZE=letter \
R_BATCHSAVE="--no-save --no-restore" \
R_BROWSER=xdg-open \
PAGER=/usr/bin/pager \
PERL=/usr/bin/perl \
R_UNZIPCMD=/usr/bin/unzip \
R_ZIPCMD=/usr/bin/zip \
R_PRINTCMD=/usr/bin/lpr \
LIBnn=lib \
AWK=/usr/bin/awk \
CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
./configure --enable-R-shlib \
  --disable-memory-profiling \
  --with-readline \
  --with-blas \
  --with-lapack \
  --with-tcltk \
  --disable-nls \
  --with-recommended-packages
make
make install
make clean

echo "options(
  repos = c(CRAN = '${CRAN}'),
  download.file.method = 'libcurl'
)" >> ${R_HOME}/etc/Rprofile.site

echo 'options(
  HTTPUserAgent = sprintf(
    "R/%s R (%s)",
    getRversion(),
    paste(getRversion(), R.version$platform, R.version$arch, R.version$os)
  )
)' >> ${R_HOME}/etc/Rprofile.site

mkdir -p ${R_HOME}/site-library
chown root:staff ${R_HOME}/site-library
chmod g+ws ${R_HOME}/site-library

echo "R_LIBS=\${R_LIBS-'${R_HOME}/site-library:${R_HOME}/library'}" >> \
  ${R_HOME}/etc/Renviron

echo "TZ=${TZ}" >> ${R_HOME}/etc/Renviron

cd /
rm -rf /tmp/*
rm -rf R-${R_VERSION}
rm -rf R-${R_VERSION}.tar.gz
apt-get remove --purge -y $BUILDDEPS
apt-get autoremove --purge -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*
