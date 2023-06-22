FROM ubuntu:20.04@sha256:0e0402cd13f68137edb0266e1d2c682f217814420f2d43d300ed8f65479b14fb

ENV R_VERSION=4.3.0
ENV TERM=xterm
ENV CRAN=https://packagemanager.rstudio.com/all/__linux__/focal/latest
ENV TZ=Etc/UTC
ENV OPENBLAS_NUM_THREADS=1
ENV OMP_THREAD_LIMIT=1
ENV HOME=/home/user
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV R_HOME=/usr/local/lib/R

COPY install_R.sh install_R.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init.R /home/user/init.R
COPY robots.txt /home/user/robots.txt

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion \
      ca-certificates \
      curl \
      devscripts \
      file \
      fonts-texgyre \
      g++ \
      gdal-bin \
      gfortran \
      gpg-agent \
      gsfonts \
      libblas-dev \
      libbz2-* \
      libcurl4 \
      libcurl4-openssl-dev \
      libgdal-dev \
      libgeos-dev \
      libicu* \
      libjq-dev \
      libjpeg-turbo* \
      liblzma* \
      libopenblas-dev \
      libpangocairo-* \
      libpcre2* \
      libpng16* \
      libpq-dev \
      libproj-dev \
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
      unzip \
      zip \
      zlib1g \
 && apt-get autoremove --purge -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/*

RUN /install_R.sh

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -sfI -o /dev/null 0.0.0.0:8000/healthz || exit 1

RUN install2.r -e \
  renv \
  covr \
  DT \
  logger \
  plumber \
  rapidoc \
  tictoc

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libxml2-dev \
 && apt-get autoremove --purge -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /home/user

ENTRYPOINT ["entrypoint.sh"]

CMD ["Rscript", "--vanilla", "init.R"]
