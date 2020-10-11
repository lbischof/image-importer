FROM alpine

WORKDIR /app

RUN apk add --no-cache bash exiftool inotify-tools fdupes

COPY entrypoint.sh .

RUN addgroup -g 1000 -S importer && \
    adduser -u 1000 -S importer -G importer && \
    chmod 700 entrypoint.sh && \
    chown importer entrypoint.sh

USER importer

CMD ["/app/entrypoint.sh"]
