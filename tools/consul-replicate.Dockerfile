# eg. build command
# docker build \
#  -t fjolsvin/consul-replicate . --file consul-replicate.Dockerfile

FROM golang:alpine AS go-pkg-builder
RUN apk add --no-cache git
RUN go env -w GO111MODULE=off && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade -U -a && \
    apk add build-base make git bash ncurses upx
WORKDIR "/go/src/github.com/hashicorp"
RUN git clone \
        --depth 1 \
        --branch "master" \
        "https://github.com/hashicorp/consul-replicate.git" \
        "/go/src/github.com/hashicorp/consul-replicate"
WORKDIR "/go/src/github.com/hashicorp/consul-replicate"
RUN TERM=xterm \
  GO111MODULE=off \
  go build -o "/go/bin/consul-replicate" && \
    strip "/go/bin/consul-replicate" && \
    upx "/go/bin/consul-replicate"
# RUN echo "nobody:x:65534:65534:Nobody:/:" > /etc_passwd
# FROM scratch
# COPY --from=go-pkg-builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# COPY --from=go-pkg-builder /etc_passwd /etc/passwd
# COPY --from=go-pkg-builder --chown=65534:0 "/go/bin/consul-replicate" /entrypoint
# USER nobody
# ENTRYPOINT ["/entrypoint"]
