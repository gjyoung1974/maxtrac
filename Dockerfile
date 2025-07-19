FROM debian:12 AS build
WORKDIR /src
RUN apt-get update && apt-get install -y --no-install-recommends \
    automake gcc g++ make libncurses-dev nasm libsdl-net1.2-dev libsdl2-net-dev libswscale-dev libfreetype-dev libxkbfile-dev libxrandr-dev \
    curl ca-certificates unzip patch
RUN curl -L -O https://downloads.sourceforge.net/project/dosbox/dosbox/0.74-3/dosbox-0.74-3.tar.gz
COPY libserial-0.74.3.diff .
RUN tar -zxvf dosbox-0.74-3.tar.gz && \
    cd dosbox-0.74-3 && \
    patch -p0 -i ../libserial-0.74.3.diff && \
    ./configure --prefix=/dosbox && \
    make -j && \
    make install
RUN curl -L -O https://archive.org/download/motorola.tar/motorola.tar.gz
RUN tar -xvzf ./motorola.tar.gz

FROM debian:12-slim
ENV TERM=xterm-256color
ENV RUN_XTERM=no
ENV DISPLAY_WIDTH=1024
ENV DISPLAY_HEIGHT=768

RUN apt-get update && apt-get install -y --no-install-recommends \
    libncurses6 libsdl-net1.2 libsdl2-net-2.0-0 libswscale6 libfreetype6 libxkbfile1 libxrandr2 libgl1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=build /dosbox /dosbox
COPY --from=build /src/motorola /motorola
COPY MAXTRAC.CFG /motorola/MAXTRAC.CFG
WORKDIR /root/.dosbox
COPY dosbox-0.74-3.conf .
WORKDIR /root
CMD [ "/dosbox/bin/dosbox" ]
