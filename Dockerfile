FROM fpco/stack-build:lts-20.5 as build
RUN mkdir /opt/build
COPY . /opt/build
RUN cd /opt/build && stack build --system-ghc && stack install


FROM ubuntu:18.04
RUN mkdir -p /opt/myapp
ARG BINARY_PATH
WORKDIR /opt/myapp

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev

COPY --from=build /root/.local/bin .
CMD ["./github-remainder-exe"]
