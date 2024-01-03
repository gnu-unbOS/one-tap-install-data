FROM debian:latest
RUN apt-get update && apt-get -y install tor && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY torrc /etc/tor/torrc
CMD /usr/bin/tor
