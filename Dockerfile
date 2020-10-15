FROM lbischof/face_recognition

RUN apt-get install -y --fix-missing \
    exiftool \
    inotify-tools \
    fdupes \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

WORKDIR /app

RUN adduser --uid 1000 --group --system importer && \
    pip3 install face_recognition scikit-learn

RUN apt-get install -y jhead

COPY entrypoint.sh .
COPY recognition.py .

RUN chmod 700 entrypoint.sh && \
    chown importer entrypoint.sh

USER importer

ENTRYPOINT ["/app/entrypoint.sh"]
