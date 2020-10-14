FROM python:3.6-slim-stretch

RUN apt-get -y update
RUN apt-get install -y --fix-missing \
    build-essential \
    cmake \
    gfortran \
    git \
    wget \
    curl \
    graphicsmagick \
    libgraphicsmagick1-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
    python3-dev \
    python3-numpy \
    software-properties-common \
    zip \
    exiftool \
    inotify-tools \
    fdupes \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

RUN cd ~ && \
    mkdir -p dlib && \
    git clone -b 'v19.9' --single-branch https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    python3 setup.py install --yes USE_AVX_INSTRUCTIONS

WORKDIR /app

RUN adduser --uid 1000 --group --system importer && \
    pip3 install face_recognition scikit-learn

RUN apt-get install -y jhead

COPY entrypoint.sh .
COPY recognition.py .

RUN chmod 700 entrypoint.sh && \
    chown importer entrypoint.sh

USER importer


CMD ["/app/entrypoint.sh"]
