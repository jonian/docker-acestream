# Use debian stretch (9)
FROM debian:stretch-slim

# http://wiki.acestream.org/wiki/index.php/Download
ENV ACE_VER 3.1.49
ENV ACE_SRC "http://acestream.org/downloads/linux/acestream_${ACE_VER}_debian_9.9_x86_64.tar.gz"
ENV ACE_DIR /acestream
ENV PATH $ACE_DIR:$PATH

# Install dependencies and acestream engine
RUN apt-get -q update                          \
 && apt-get install -y --no-install-recommends \
        libpython2.7                           \
        netcat                                 \
        net-tools                              \
        python-minimal                         \
        python-pkg-resources                   \
        python-m2crypto                        \
        python-apsw                            \
        python-lxml                            \
        curl                                   \
 && apt-get clean                              \
 && rm -rf /var/lib/apt/lists/*                \
           /var/cache/*                        \
 && mkdir $ACE_DIR                             \
 && cd $ACE_DIR                                \
 && curl $ACE_SRC | tar xzf -

# Copy entrypoint scripts
COPY ./print_token.py /
COPY ./start.sh /

# Make entrypoint executable
RUN chmod +x /start.sh

# Let docker know how to test container health
HEALTHCHECK CMD nc -zv localhost 6878 || exit 1

# Start acestream (client console only)
ENTRYPOINT [ "/start.sh" ]
