# Use debian buster (10)
FROM python:2.7-slim-buster AS build

# https://docs.acestream.net/products/#linux
ENV ACE_VER 3.1.74
ENV ACE_SRC "https://download.acestream.media/linux/acestream_${ACE_VER}_debian_10.5_x86_64.tar.gz"
ENV ACE_DIR /acestream

ENV APSW_VER 3.24.0-r1
ENV APSW_SRC "https://github.com/rogerbinns/apsw/releases/download/${APSW_VER}/apsw-${APSW_VER}.zip"

# Install build dependencies
RUN apt-get -q update                          \
 && apt-get install -y --no-install-recommends \
        build-essential                        \
        libsqlite3-dev                         \
        ca-certificates                        \
        curl

# Install python dependencies
RUN pip install --user --no-cache-dir \
        $APSW_SRC                     \
        lxml                          \
        requests                      \
        isodate                       \
        pycryptodome

# Install acestream engine
RUN mkdir $ACE_DIR && cd $ACE_DIR                     \
 && curl $ACE_SRC | tar xzf -                         \
 && rm $ACE_DIR/lib/requests-2.12.5-py2.7.egg         \
 && rm $ACE_DIR/lib/lxml-3.7.2-py2.7-linux-x86_64.egg


# Use debian buster (10)
FROM debian:buster-slim AS main

ENV ACE_DIR /acestream
ENV PATH $ACE_DIR:$PATH

# Install dependencies and acestream engine
RUN apt-get -q update                          \
 && apt-get install -y --no-install-recommends \
        libpython2.7                           \
        python-minimal                         \
        libxslt1.1                             \
        libsqlite3-0                           \
        netcat                                 \
        net-tools                              \
 && apt-get clean                              \
 && rm -rf /var/lib/apt/lists/*                \
          /var/cache/*

COPY --from=build /usr/local/lib/python2.7/site-packages/pkg_resources /usr/lib/python2.7/dist-packages/pkg_resources
COPY --from=build /root/.local/lib/python2.7/site-packages /usr/lib/python2.7/dist-packages
COPY --from=build $ACE_DIR $ACE_DIR

# Copy entrypoint scripts
COPY ./print_token.py /
COPY ./start.sh /

# Make entrypoint executable
RUN chmod +x /start.sh

# Let docker know how to test container health
HEALTHCHECK CMD nc -zv localhost 6878 || exit 1

# Start acestream (client console only)
ENTRYPOINT [ "/start.sh" ]
