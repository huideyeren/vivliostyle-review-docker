FROM node:slim as node
FROM ruby:slim as ruby
FROM python:slim as python
FROM openjdk:24-slim as java

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && update-locale en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt update && \
    apt install -y autoconf \ 
                       bison \
                       build-essential \
                       libssl-dev \
                       libyaml-dev \
                       libreadline6-dev \
                       zlib1g-dev \
                       libncurses5-dev \
                       libffi-dev \
                       libgdbm6 \
                       libgdbm-dev \
                       libdb-dev \
                       locales \
                       git-core \
                       zip \
                       unzip \
                       fontconfig \
                       apt-utils \
                       bash \
                       curl \
                       sudo \
                       librsvg2-bin \
                       libssl-dev \
                       libreadline-dev \
                       sudo \
                       cron \
                       libcairo2-dev \
                       libffi-dev \
                       zlib1g-dev && \
                       libatk-bridge2.0-0 \
                       libgtk-3-0 \
                       libasound2 \
                       pandoc \
                       mecab \
                       mecab-ipadic-utf8 \
                       libmecab-dev \
                       libgbm-dev \
                       file \
                       xz-utils \
                       poppler-data \
                       graphviz \
                       poppler-utils && \
                       apt clean

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable pnpm

RUN mkdir -p /opt
COPY --from=node /usr/local/bin/node /usr/local/bin

RUN pnpm install -g textlint-plugin-review \
textlint-rule-preset-japanese \
textlint-rule-general-novel-style-ja \
@vivliostyle/cli

RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc && \
    gem update && \
    gem install pandoc2review

RUN which pandoc2review

RUN pip3 install anshitsu \
                blockdiag \
                blockdiag[pdf] \
                reportlab \
                svglib \
                svgutils \
                cairosvg \
                PyPDF2

RUN mkdir /java && \
    curl -sL https://sourceforge.net/projects/plantuml/files/plantuml.jar \
          > /java/plantuml.jar

RUN git clone https://github.com/neologd/mecab-ipadic-neologd.git && \
    cd mecab-ipadic-neologd && \
    sudo bin/install-mecab-ipadic-neologd -y && \
    sudo echo dicdir = /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd > /etc/mecabrc

RUN mkdir /docs
WORKDIR /docs
