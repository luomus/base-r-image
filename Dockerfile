FROM ubuntu:20.04@sha256:3246518d9735254519e1b2ff35f95686e4a5011c90c85344c1f38df7bae9dd37

ENV R_VERSION=4.3.1
ENV TERM=xterm
ENV CRAN=https://packagemanager.posit.co/cran/__linux__/focal/latest
ENV TZ=Etc/UTC
ENV OPENBLAS_NUM_THREADS=1
ENV OMP_THREAD_LIMIT=1
ENV HOME=/home/user
ENV LANG=en_US.UTF-8
ENV R_HOME=/usr/local/lib/R
ENV LC_ALL=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

COPY install_R.sh install_R.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY permissions.sh /usr/local/bin/permissions.sh
COPY init.R /home/user/init.R
COPY robots.txt /home/user/robots.txt
COPY .Rprofile /home/user/.Rprofile

RUN echo \
     "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula" \
     "select true" | debconf-set-selections \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion \
      ca-certificates \
      cmake \
      curl \
      devscripts \
      file \
      fonts-texgyre \
      g++ \
      gfortran \
      gpg-agent \
      gsfonts \
      libblas-dev \
      libbz2-* \
      libcurl4 \
      libcurl4-openssl-dev \
      libicu* \
      libjq-dev \
      libjpeg-turbo* \
      liblzma* \
      libopenblas-dev \
      libpangocairo-* \
      libpcre2* \
      libpng16* \
      libpq-dev \
      libreadline8 \
      libsodium-dev \
      libssl-dev \
      libtiff* \
      libudunits2-dev \
      libz-dev \
      locales \
      lsb-release \
      make \
      nano \
      pandoc \
      pkg-config \
      software-properties-common \
      ttf-mscorefonts-installer \
      unzip \
      zip \
      zlib1g \
 && fc-cache -f \
 && apt-get autoremove --purge -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/*

RUN /install_R.sh

RUN install2.r -e \
  covr \
  DT \
  logger \
  plumber \
  rapidoc \
  remotes \
  tictoc

RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      gdal-bin \
      libfribidi-dev \
      libgdal-dev \
      libgeos-dev \
      libharfbuzz-dev \
      libmagick++-dev \
      libproj-dev \
      libxml2-dev \
 && apt-get autoremove --purge -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/*

RUN install2.r -r https://cloud.r-project.org -e sf renv

RUN mkdir -p \
  /home/user/archives \
  /home/user/coverage \
  /home/user/data \
  /home/user/logs \
  /home/user/stage \
  /home/user/tmp \
  /home/user/var

WORKDIR /home/user

ENTRYPOINT ["entrypoint.sh"]

CMD ["Rscript", "--vanilla", "init.R"]
