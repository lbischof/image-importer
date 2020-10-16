FROM lbischof/face_recognition:latest

RUN apt-get install -y --fix-missing \
    exiftool \
    inotify-tools \
    fdupes \
    jhead \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

WORKDIR /app

RUN adduser --uid 1000 --group --system importer

COPY entrypoint.sh .
COPY recognition.py .

RUN chmod 700 entrypoint.sh && \
    chown importer entrypoint.sh

USER importer

ENTRYPOINT ["/app/entrypoint.sh"]
