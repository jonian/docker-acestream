# Use debian buster (10)
FROM python:3.7-slim-buster AS build

# https://docs.acestream.net/products/#linux
ENV ACE_VER 3.1.75rc4
ENV ACE_SRC "https://download.acestream.media/linux/acestream_${ACE_VER}_ubuntu_18.04_x86_64_py3.7.tar.gz"
ENV ACE_DIR /acestream

# Install build dependencies
RUN apt-get -q update                          \
 && apt-get install -y --no-install-recommends \
        build-essential                        \
        libsqlite3-dev                         \
        ca-certificates                        \
        curl

# Install dependencies and acestream engine
RUN mkdir $ACE_DIR && cd $ACE_DIR          \
 && curl $ACE_SRC | tar xzf -              \
 && pip install --user -r requirements.txt


# Use debian buster (10)
FROM debian:buster-slim AS main

ENV ACE_DIR /acestream
ENV PATH $ACE_DIR:$PATH

# Install dependencies and acestream engine
RUN apt-get -q update                          \
 && apt-get install -y --no-install-recommends \
        libpython3.7                           \
        python3.7-minimal                      \
        libsqlite3-0                           \
        netcat                                 \
        net-tools                              \
 && apt-get clean                              \
 && rm -rf /var/lib/apt/lists/*                \
          /var/cache/*

COPY --from=build /usr/local/lib/python3.7/site-packages/pkg_resources /usr/lib/python3.7/dist-packages/pkg_resources
COPY --from=build /root/.local/lib/python3.7/site-packages /usr/lib/python3.7/dist-packages
COPY --from=build $ACE_DIR $ACE_DIR

# Set python 3.7 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7 0

# Copy entrypoint scripts
COPY ./print_token.py /
COPY ./start.sh /

# Make entrypoint executable
RUN chmod +x /start.sh

# Let docker know how to test container health
HEALTHCHECK CMD nc -zv localhost 6878 || exit 1

# Start acestream (client console only)
ENTRYPOINT [ "/start.sh" ]
