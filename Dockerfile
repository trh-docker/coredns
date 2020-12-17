FROM quay.io/spivegin/golang:v1.15.2  AS dev-build
WORKDIR /opt/src/src/github.com/coredns
ADD files/coredns/plugin.cfg /tmp/plugin.cfg
RUN apt-get update && apt-get -y upgrade &&\
    apt-get install -y unzip wget git build-essential &&\
    apt-get -y autoclean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN git clone https://github.com/coredns/coredns.git &&\
    cd coredns && cp /tmp/plugin.cfg . &&\
    make

FROM quay.io/spivegin/tlmbasedebian:latest
RUN mkdir /opt/bin
WORKDIR /opt/tlm
COPY --from=dev-build /opt/src/src/github.com/coredns/coredns/coredns /opt/bin/coredns
RUN chmod +x /opt/bin/coredns && ln -s /opt/bin/coredns /bin/coredns

CMD ["coredns"]