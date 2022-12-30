#!/bin/bash

mkdir ~/tpop
curl -o ~/apache-tinkerpop-gremlin-server-3.6.1-bin.zip https://dlcdn.apache.org/tinkerpop/3.6.1/apache-tinkerpop-gremlin-server-3.6.1-bin.zip 
unzip ~/apache-tinkerpop-gremlin-server-3.6.1-bin.zip -d ~/tpop


curl -o ~/apache-tinkerpop-gremlin-console-3.6.1-bin.zip https://dlcdn.apache.org/tinkerpop/3.6.1/apache-tinkerpop-gremlin-console-3.6.1-bin.zip
unzip ~/apache-tinkerpop-gremlin-console-3.6.1-bin.zip  -d ~/tpop

cd ~/tpop

sed -i 's/gremlin.tinkergraph.vertexIdManager=LONG/gremlin.tinkergraph.vertexIdManager=ANY/g' ~/tpop/apache-tinkerpop-gremlin-server-3.6.1/conf/tinkergraph-empty.properties

sed -i 's/channelizer: org.apache.tinkerpop.gremlin.server.channel.WebSocketChannelizer/channelizer: org.apache.tinkerpop.gremlin.server.channel.WsAndHttpChannelizer/g' ~/tpop/apache-tinkerpop-gremlin-server-3.6.1/conf/gremlin-server.yaml
