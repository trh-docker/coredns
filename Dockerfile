  
FROM quay.io/spivegin/gitonly:latest AS git

FROM quay.io/spivegin/golang:v1.15.2  AS dev-build
WORKDIR /opt/src/src/github.com/coredns

RUN ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa && git config --global user.name "quadtone" && git config --global user.email "quadtone@txtsme.com"
COPY --from=git /root/.ssh /root/.ssh
RUN ssh-keyscan -H github.com > ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts

#COPY --from=gover /opt/go /opt/go
ENV deploy=c1f18aefcb3d1074d5166520dbf4ac8d2e85bf41 \
    GO111MODULE=on \
    GOPROXY=direct \
    GOSUMDB=off \
    GOPRIVATE=sc.tpnfc.us 
RUN git config --global url.git@github.com:.insteadOf https://github.com/ &&\
    git config --global url.git@gitlab.com:.insteadOf https://gitlab.com/ &&\
    git config --global url."https://${deploy}@sc.tpnfc.us/".insteadOf "https://sc.tpnfc.us/"
RUN apt-get update && apt-get -y upgrade &&\
    apt-get install -y unzip wget git build-essential &&\
    apt-get -y autoclean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ADD files/coredns/plugin.cfg /tmp/plugin.cfg
RUN git clone https://github.com/coredns/coredns.git &&\
    cd coredns && cp /tmp/plugin.cfg . &&\
    go mod vendor &&\
    make

FROM quay.io/spivegin/tlmbasedebian:latest
RUN mkdir /opt/bin
WORKDIR /opt/tlm
COPY --from=dev-build /opt/src/src/github.com/coredns/coredns/coredns /opt/bin/coredns
RUN chmod +x /opt/bin/coredns && ln -s /opt/bin/coredns /bin/coredns

CMD ["coredns"]