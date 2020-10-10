FROM alpine

WORKDIR /app

RUN apk add --no-cache bash exiftool inotify-tools

COPY entrypoint.sh .
RUN chmod 700 entrypoint.sh

CMD ["/app/entrypoint.sh"]
