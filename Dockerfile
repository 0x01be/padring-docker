FROM 0x01be/ninja as builder

RUN apk --no-cache add --virtual padring-build-dependencies \
    git \
    build-base \
    cmake \
    doxygen \
    graphviz \
    texlive-full \
    ghostscript

RUN git clone --depth 1 https://github.com/YosysHQ/padring.git /padring

RUN mkdir -p /opt/padring/bin
RUN mkdir -p /opt/padring/doc
RUN mkdir -p /padring/build
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

COPY --from=builder /opt/padring/ /opt/padring/

ENV PATH $PATH:/opt/padring/bin/

VOLUME /workspace
WORKDIR /workspace

