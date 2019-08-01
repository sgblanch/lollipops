FROM golang:alpine AS builder

RUN apk update && \
    apk add --no-cache git ca-certificates fontconfig msttcorefonts-installer tzdata && \
    update-ca-certificates && \
    update-ms-fonts && \
    fc-cache -f && \
    adduser -D -g '' lollipops

WORKDIR $GOPATH/src/github.com/pbnjay/lollipops
COPY . .

RUN go get -d -v
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/lollipops


########################################################################
FROM scratch

LABEL description="Lollipops command-line tool to generate variant annotation diagrams"
LABEL url="https://github.com/pbnjay/lollipops"
LABEL maintainer="Jeremy Jay <jeremy@pbnjay.com>"

# Pull in a number of files from builder image
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=builder /usr/share/fonts/truetype/msttcorefonts/Arial.ttf /usr/share/fonts/truetype/msttcorefonts/arial.ttf
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

#   TODO:
#    - limit entries in passwd (root, nobody, lollipops?)
#    - do we need /etc/group?
#    - why do I need to pull in libc?
#    - do we need /tmp? /dev entries?

COPY --from=builder /go/bin/lollipops /go/bin/lollipops

USER lollipops

ENTRYPOINT ["/go/bin/lollipops"]
CMD ["-legend", "-labels", "TP53", "R248Q#7f3333@131", "R273C", "R175H", "T125@5"]