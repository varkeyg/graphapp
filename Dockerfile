
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
RUN apt-get install -y bash-completion
RUN apt-get install -y jq

RUN useradd -m graph-user
RUN usermod -aG sudo graph-user

USER graph-user
CMD ["/bin/bash"]

ENV PATH=$PATH:~/java/openlogic-openjdk-11.0.17+8-linux-x64/bin
COPY java.sh .

RUN ./java.sh

ENV PATH=$PATH:~/tpop/apache-tinkerpop-gremlin-server-3.6.1/bin:~/tpop/apache-tinkerpop-gremlin-console-3.6.1/bin
COPY tpop.sh .
RUN ./tpop.sh


EXPOSE 8182 



#RUN curl "http://localhost:8182?gremlin={g=TinkerGraph.open().traversal()}"


# curl "http://localhost:8182?gremlin={g.addV('person').property('name','Geo')}"
#RUN curl "http://172.17.0.2:8182?g.V().count()"

WORKDIR /home/graph-user

RUN git clone https://github.com/varkeyg/graphapp.git 


