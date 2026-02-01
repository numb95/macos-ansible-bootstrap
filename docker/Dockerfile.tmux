FROM ubuntu:22.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    tmux \
    git \
    python3 \
    python3-pip \
    locales \
    curl \
    ca-certificates \
    openssh-client \
  && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

RUN useradd -m -s /bin/bash ansible
USER ansible
WORKDIR /repo

RUN python3 -m pip install --user --upgrade pip \
  && python3 -m pip install --user ansible

ENV PATH=/home/ansible/.local/bin:$PATH
ENV LANG=en_US.UTF-8
