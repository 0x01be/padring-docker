FROM 0x01be/ninja as build

RUN apk --no-cache add --virtual padring-build-dependencies \
    git \
    build-base \
    cmake &&\
    apk --no-cache add --virtual padring-doc-dependencies \
    doxygen \
    graphviz \
    texlive-full \
    ghostscript

ENV REVISION=master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/ax3ghazy/padring.git /padring &&\
    mkdir -p /opt/padring/bin &&\
    mkdir -p /opt/padring/doc &&\
    mkdir -p /padring/build

WORKDIR /padring/build

RUN cmake -G Ninja ..
RUN ninja
RUN cmake -G Ninja -DBUILD_DOC=yes ..
RUN cp /padring/build/padring /opt/padring/bin/

WORKDIR /padring/
RUN doxygen doc/Doxyfile.in
WORKDIR /padring/doc/latex
RUN make
RUN cp -R /padring/doc/* /opt/padring/doc/

FROM alpine

RUN apk --no-cache add --virtual padring-runtime-dependencies \
    libstdc++

COPY --from=build /opt/padring/ /opt/padring/

RUN adduser -D -u 1000 padring

WORKDIR /workspace

RUN chown padring:padring /workspace

USER padring

ENV PATH $PATH:/opt/padring/bin/

