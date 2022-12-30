
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
RUN apt-get install -y openjdk-18-jdk
RUN apt-get install -y jq

RUN useradd -m graph-user
RUN usermod -aG sudo graph-user

USER graph-user
CMD ["/bin/bash"]

ENV PATH=$PATH:~/java/jdk-15.0.2/bin
COPY java.sh .

RUN ./java.sh


ENV PATH="$PATH:/home/graph-user/graph_data/apache-tinkerpop-gremlin-server-3.6.1/bin:/home/graph-user/graph_data/apache-tinkerpop-gremlin-console-3.6.1/bin"

WORKDIR "/home/graph-user/graph_data"
RUN wget https://dlcdn.apache.org/tinkerpop/3.6.1/apache-tinkerpop-gremlin-server-3.6.1-bin.zip
RUN wget https://dlcdn.apache.org/tinkerpop/3.6.1/apache-tinkerpop-gremlin-console-3.6.1-bin.zip
RUN unzip apache-tinkerpop-gremlin-server-3.6.1-bin.zip
RUN unzip apache-tinkerpop-gremlin-console-3.6.1-bin.zip
RUN rm apache-tinkerpop-gremlin-server-3.6.1-bin.zip
RUN rm apache-tinkerpop-gremlin-console-3.6.1-bin.zip

RUN sed -i 's/gremlin.tinkergraph.vertexIdManager=LONG/gremlin.tinkergraph.vertexIdManager=ANY/g' /home/graph-user/graph_data/apache-tinkerpop-gremlin-server-3.6.1/conf/tinkergraph-empty.properties
RUN sed -i 's/channelizer: org.apache.tinkerpop.gremlin.server.channel.WebSocketChannelizer/channelizer: org.apache.tinkerpop.gremlin.server.channel.WsAndHttpChannelizer/g' /home/graph-user/graph_data/apache-tinkerpop-gremlin-server-3.6.1/conf/gremlin-server.yaml
RUN chmod +x /home/graph-user/graph_data/apache-tinkerpop-gremlin-server-3.6.1/bin/gremlin-server.sh

EXPOSE 8182 

#RUN CMD ["/home/graph-user/graph_data/apache-tinkerpop-gremlin-server-3.6.1/bin/gremlin-server.sh", “start”, “FOREGROUND”]

#RUN curl "http://localhost:8182?gremlin={g=TinkerGraph.open().traversal()}"


# curl "http://localhost:8182?gremlin={g.addV('person').property('name','Geo')}"
#RUN curl "http://172.17.0.2:8182?g.V().count()"


RUN git clone https://github.com/varkeyg/graphapp.git

RUN echo "run gremlin server by running gremlin-server.sh start"
RUN echo "run gremlin client by running gremlin.sh"

