FROM ubuntu:20.04@sha256:0e0402cd13f68137edb0266e1d2c682f217814420f2d43d300ed8f65479b14fb

ENV R_VERSION=4.3.0
ENV TERM=xterm
ENV CRAN=https://packagemanager.rstudio.com/all/__linux__/focal/latest
ENV TZ=Etc/UTC
ENV OPENBLAS_NUM_THREADS=1
ENV OMP_THREAD_LIMIT=1
ENV HOME=/home/user

COPY install_R.sh install_R.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init.R /home/user/init.R
COPY robots.txt /home/user/robots.txt

RUN /install_R.sh

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl \
      file \
      gdal-bin \
      gpg-agent \
      libcurl4-openssl-dev \
      libgdal-dev \
      libgeos-dev \
      libpq-dev \
      libproj-dev \
      libsodium-dev \
      libssl-dev \
      libudunits2-dev \
      libz-dev \
      pandoc \
      pkg-config \
      software-properties-common \
 && apt-get autoremove -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/*

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -sfI -o /dev/null 0.0.0.0:8000/healthz || exit 1

RUN R -e "install.packages('renv')"

WORKDIR /home/user

ENTRYPOINT ["entrypoint.sh"]

CMD ["Rscript", "--vanilla", "init.R"]
