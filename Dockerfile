FROM 0x01be/ninja as builder

RUN apk --no-cache add --virtual padring-build-dependencies \
    git \
    build-base \
    cmake \
    doxygen \
    graphviz

RUN git clone --depth 1 https://github.com/YosysHQ/padring.git /padring

RUN mkdir -p /padring/build
WORKDIR /padring/build

RUN cmake -DCMAKE_INSTALL_PREFIX=/opt/padring/ ..
RUN make

FROM 0x01be/alpine:edge

RUN apk --no-cache add --virtual padring-runtime-dependencies \
    libstdc++

RUN mkdir -p /opt/padring/bin
COPY --from=builder /padring/build/padring /opt/padring/bin/

ENV PATH $PATH:/opt/padring/bin/

