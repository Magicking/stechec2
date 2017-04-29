FROM debian:jessie-slim
MAINTAINER Sylvain Laurent

# Install needed packages
RUN apt-get update &&\
    apt-get install -y build-essential pkg-config libzmq3-dev python-yaml \
                  libgtest-dev libgflags-dev gcovr curl \
                  ruby vim

RUN curl -L https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz > \
    /tmp/go1.8.1.tar.gz
RUN echo 'a579ab19d5237e263254f1eac5352efcf1d70b9dacadb6d6bb12b0911ede8994 ' \
    '/tmp/go1.8.1.tar.gz' | sha256sum -c - && \
    tar -C /usr/local/ -xzvf /tmp/go1.8.1.tar.gz && \
    rm /tmp/go1.8.1.tar.gz
# TODO purge apt packages
WORKDIR /src
COPY doc /src/doc
COPY games /src/games
COPY pkg /src/pkg
COPY src /src/src
COPY waf.py /src/waf.py
COPY wscript /src/wscript
COPY tools /src/tools

RUN  ./waf.py configure --with-games=tictactoe --prefix=/usr
RUN  ./waf.py build install

RUN stechec2-generator player tictactoe player_env
