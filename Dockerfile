FROM 0x01be/ninja as build

ENV REVISION=master
RUN apk --no-cache add --virtual padring-build-dependencies \
    git \
    build-base \
    cmake &&\
    apk --no-cache add --virtual padring-doc-dependencies \
    doxygen \
    graphviz \
    texlive-full \
    ghostscript &&\
    git clone --depth 1 --branch ${REVISION} https://github.com/ax3ghazy/padring.git /padring &&\
    mkdir -p /opt/padring/bin &&\
    mkdir -p /opt/padring/doc &&\
    mkdir -p /padring/build

WORKDIR /padring/build

RUN cmake -G Ninja .. &&\
    ninja &&\
    cmake -G Ninja -DBUILD_DOC=yes ..

WORKDIR /padring/
RUN doxygen doc/Doxyfile.in
WORKDIR /padring/doc/latex
RUN make
RUN cp -R /padring/doc/* /opt/padring/doc/
    cp /padring/build/padring /opt/padring/bin/

FROM 0x01be/base

COPY --from=build /opt/padring/ /opt/padring/

WORKDIR /workspace

RUN apk --no-cache add --virtual padring-runtime-dependencies \
    libstdc++ &&\
    adduser -D -u 1000 padring &&\
    chown padring:padring /workspace

USER padring
ENV PATH=${PATH}:/opt/padring/bin/

