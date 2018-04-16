FROM debian:stable
MAINTAINER ptp-ops@googlegroups.com

# Install Debian main packages
RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    build-essential ca-certificates cpanminus file flex gawk gcc-multilib git \
    libncurses5-dev libnet-ssleay-perl libcrypt-ssleay-perl libssl-dev \
    openssl pkg-config python rsync subversion unzip wget zlib1g-dev \
  && apt-get clean

# Install modules from CPAN
RUN cpanm --skip-satisfied \
  NetAddr::IP::Lite Getopt::Long JSON LWP::Simple LWP::Protocol::https

ENV BUILD /src/ptpwrt-builder/build
ENV LEDE /src/lede
WORKDIR /src/ptpwrt-builder
