
FROM ubuntu:22.04


LABEL "Owner"="Geo Varkey"
LABEL "email"="geo.varkey@gmal.com"



# this is for timezone config
ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get upgrade -y
RUN apt-get update

RUN apt-get install -y git  
RUN apt-get install -y openssh-server
RUN apt-get install -y unzip
RUN apt-get install -y tar
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y zip
RUN apt-get install -y vim
RUN apt-get install -y sqlite3


RUN useradd -m graph-user
RUN usermod -aG sudo graph-user

USER apache
CMD ["/bin/bash"]


WORKDIR "/home/apache/gremlin"
RUN wget https://dlcdn.apache.org/tinkerpop/3.6.1/apache-tinkerpop-gremlin-server-3.6.1-bin.zip
RUN wget https://dlcdn.apache.org/tinkerpop/3.6.1/apache-tinkerpop-gremlin-console-3.6.1-bin.zip
RUN unzip apache-tinkerpop-gremlin-server-3.6.1-bin.zip
RUN unzip apache-tinkerpop-gremlin-console-3.6.1-bin.zip

WORKDIR "/home/apache/workspace"
RUN git clone https://github.com/varkeyg/graphapp.git

