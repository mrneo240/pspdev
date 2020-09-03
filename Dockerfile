FROM gcc:9.3 as builder

MAINTAINER HaydenKow <hayden@hkowsoftware.com>

ENV TOOLCHAIN_VERSION c66533b38083d5c0f707e1e458d63fde30051e52

# Setup path and vars for the SDK
ENV PSPDEV=/pspdev \
    PSPSDK=$PSPDEV/pspsdk \
    PATH=$PATH:$PSPDEV/bin:$PSPSDK/bin \
    LANG=C.UTF-8

RUN export PSPDEV=/pspdev \
    && export PSPSDK=$PSPDEV/pspsdk \
    && export PATH=$PATH:$PSPDEV/bin:$PSPSDK/bin \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --no-upgrade \
        build-essential \
        cmake \
        doxygen \
        bison \
        flex \
        libarchive-dev \
        libgpgme-dev \
        libsdl1.2-dev \
        libusb-dev \
        texinfo \
        libgmp3-dev \
        libmpfr-dev \
        libelf-dev \
        libmpc-dev \
        libfreetype6-dev \
        subversion \
        tcl \
        unzip \
    && echo "dash dash/sh boolean false" | debconf-set-selections \
    && dpkg-reconfigure --frontend=noninteractive dash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/mrneo240/psptoolchain_upstream.git /toolchain \
    && cd /toolchain \
    && git checkout -qf $TOOLCHAIN_VERSION \
    && mkdir -p /pspdev \
    && ./toolchain.sh \
    && rm -rf \
      /pspdev/test.tmp \
      /toolchain

WORKDIR /src
CMD ["/bin/bash"]

FROM ubuntu:20.04

# Setup path and vars for the SDK
ENV PSPDEV=/pspdev \
    PSPSDK=$PSPDEV/pspsdk \
    LANG=C.UTF-8 \
    TZ=America/Los_Angeles
ENV PATH "$PATH:$PSPDEV/bin"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --no-upgrade \
        automake \
#        libtool \ # Otherwise we pull in gcc
        make \
        cmake \
        doxygen \
        meson \
        unzip \
    && echo "dash dash/sh boolean false" | debconf-set-selections \
    && dpkg-reconfigure --frontend=noninteractive dash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /pspdev /pspdev
WORKDIR /src
CMD ["/bin/sh"]