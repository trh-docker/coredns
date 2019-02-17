FROM quay.io/spivegin/golang_dart_protoc_dev  AS dev-build
WORKDIR /opt/src/src/github.com/coredns
ADD files/coredns/plugin.cfg /tmp/plugin.cfg
RUN git clone https://github.com/coredns/coredns.git && cd coredns && cp /tmp/plugin.cfg . &&\
    make

FROM quay.io/spivegin/tlmbasedebian:latest
RUN mkdir /opt/bin
WORKDIR /opt/bin/tlm
COPY --from=dev-build /opt/src/src/github.com/coredns/coredns/coredns /opt/bin/coredns
RUN chmod +x /opt/bin/coredns && ln -s /opt/bin/coredns /bin/coredns

CMD ["coredns"]