FROM fpco/stack-build:lts-20.5 AS build
WORKDIR /opt/build

# Install dependencies
COPY package.yaml stack.yaml *.cabal ./
RUN stack setup && stack build --dependencies-only

# Copy the rest of the source code and build the project
COPY . .
RUN stack build --system-ghc && stack install

# Final stage
FROM ubuntu:18.04
RUN mkdir -p /opt/myapp
ARG BINARY_PATH
WORKDIR /opt/myapp

ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev

# Copy binary from build stage
COPY --from=build /root/.local/bin .
CMD ["./github-remainder"]
