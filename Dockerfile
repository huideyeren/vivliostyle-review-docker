FROM ubuntu:latest
LABEL maintainer="takakura.yusuke@gmail.com"

# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

# updated 2025-04-22
ENV REVIEW_VERSION 5.10.0
ENV NODEJS_VERSION 22

ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# setup
RUN apt update && \
    apt install -y --no-install-recommends \
      locales git-core curl ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen en_US.UTF-8 && update-locale en_US.UTF-8

# for Debian Bug#955619
RUN mkdir -p /usr/share/man/man1

# install Re:VIEW environment
RUN apt update && \
    apt install -y --no-install-recommends \
      zip ruby-zip \
      ruby-nokogiri mecab ruby-mecab mecab-ipadic-utf8 poppler-data \
      plantuml \
      ruby-dev build-essential libmecab-dev \
      mecab-jumandic- mecab-jumandic-utf8- \
      poppler-utils libyaml-dev ghostscript imagemagick && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# setup Re:VIEW
RUN gem install bundler rake -N && \
    gem install review -v "$REVIEW_VERSION" -N && \
    gem install pandoc2review -N && \
    gem install rubyzip -N

# install node.js environment
RUN apt update && \
    apt install -y --no-install-recommends \
      gnupg && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash -
RUN apt update && \
    apt install -y --no-install-recommends \
      nodejs && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# install texlive & pandoc
RUN apt update && \
    apt install -y --no-install-recommends \
    texlive-plain-generic \
    texlive-lang-japanese \
    texlive-lang-cyrillic \
    texlive-lang-greek \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    lmodern \
    fonts-lmodern \
    tex-gyre \
    texlive-pictures \
    texlive-luatex \
    texlive-xetex \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-ipafont \
    ghostscript \
    gsfonts \
    zip \
    sudo \
    curl \
    xz-utils \
    file \
    mecab \
    mecab-ipadic-utf8 \
    libmecab-dev \
    pandoc && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# install mecab-ipadic-neologd
RUN git clone https://github.com/neologd/mecab-ipadic-neologd.git && \
    cd mecab-ipadic-neologd && \
    sudo bin/install-mecab-ipadic-neologd -y && \
    sudo echo dicdir = /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd > /etc/mecabrc

# Playwright support with fonts. This consumes ~350MB
RUN apt update && apt -y install --no-install-recommends fonts-noto-cjk-extra fonts-noto-color-emoji fonts-ipafont libatk1.0-0 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN npm install -g playwright && rm -rf /root/.cache/ms-playwright/firefox* /root/.cache/ms-playwright/webkit* && gem install playwright-runner -N && playwright install

# install Vivliostyle
RUN pnpm install -g @vivliostyle/cli @mermaid-js/mermaid-cli
