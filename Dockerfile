FROM tensorflow/tensorflow:latest-py3-jupyter
RUN apt-get update && apt-get install -y \
  git \
  nano \
  vim \
  wget \
  curl \
  unzip

WORKDIR ~/
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN apt-get install -y protobuf-compiler \
  python-pil \
  python-lxml \
  python-tk

RUN pip install \
  pillow \
  jupyter \
  matplotlib \
  tensorflow

WORKDIR /tensorflow

RUN git clone https://github.com/tensorflow/models.git

WORKDIR models
WORKDIR research

RUN curl -L -o protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip \
    && unzip protobuf.zip \
    && ./bin/protoc object_detection/protos/*.proto --python_out=.

ENV PYTHONPATH=${PYTHONPATH}:/tensorflow/models/research:/tensorflow/models/research/slim
RUN python setup.py install

RUN python object_detection/builders/model_builder_test.py

CMD ["echo", "Running tensorflow docker"]