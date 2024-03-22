# docker manifest inspect ubuntu:20.04 -v | jq '.[0].Descriptor.digest'
FROM ubuntu:20.04@sha256:48c35f3de33487442af224ed4aabac19fd9bfbd91ee90e9471d412706b20ba73

ENV R_VERSION=4.3.3
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

RUN R -s -e " \
  options(warn = 2); \
  utils::install.packages( \
    c( \
      'covr', \
      'DT', \
      'emayili', \
      'logger', \
      'plumber', \
      'rapidoc', \
      'tictoc' \
    ) \
  )"

RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      gdal-bin \
      libfribidi-dev \
      libgdal-dev \
      libgeos-dev \
      libglpk-dev \
      libharfbuzz-dev \
      libmagick++-dev \
      libproj-dev \
      libxml2-dev \
 && apt-get autoremove --purge -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/*

RUN R -s -e " \
  options(warn = 2); \
  utils::install.packages( \
    c( \
      'igraph', \
      'magick', \
      'renv', \
      'sf' \
    ), \
    repos = 'https://cloud.r-project.org' \
  )"

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
