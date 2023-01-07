
FROM ubuntu:22.04


LABEL "Owner"="Geo Varkey"
LABEL "email"="geo.varkey@gmal.com"



# this is for timezone config
ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get upgrade -y
RUN apt-get update -y && apt-get install -y apt-transport-https
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update -y
RUN apt-get install -y python3.9
RUN apt-get install -y python3-pip
RUN apt-get install -y git  
RUN apt-get install -y openssh-server
RUN apt-get install -y unzip
RUN apt-get install -y tar
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y zip
RUN apt-get install -y vim
RUN apt-get install -y sqlite3
RUN apt-get install -y bash-completion
RUN apt-get install -y jq





RUN pip3 install python-dateutil
RUN pip3 install rdflib==5.0.0
RUN pip3 install numpy==1.23.5
RUN pip3 install graph-notebook

# Enable the visualization widget
RUN jupyter nbextension enable  --py --sys-prefix graph_notebook.widgets

# copy static html resources
RUN python3 -m graph_notebook.static_resources.install
RUN python3 -m graph_notebook.nbextensions.install

# copy premade starter notebooks
RUN python3 -m graph_notebook.notebooks.install --destination ~/notebook/destination/dir




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
RUN git clone https://github.com/awslabs/amazon-neptune-tools.git

# create nbconfig file and directory tree, if they do not already exist
COPY notebook.sh .
RUN ./notebook.sh

EXPOSE 8888


# start jupyter notebook
RUN python3 -m graph_notebook.start_notebook --notebooks-dir ~/notebook
