#!/bin/bash

mkdir ~/tpop
curl https://dlcdn.apache.org/tinkerpop/3.6.1/apache-tinkerpop-gremlin-server-3.6.1-bin.zip | unzip ~/tpop/
curl https://dlcdn.apache.org/tinkerpop/3.6.1/apache-tinkerpop-gremlin-console-3.6.1-bin.zip | unzip ~/tpop/
cd ~/tpop
sed -i 's/gremlin.tinkergraph.vertexIdManager=LONG/gremlin.tinkergraph.vertexIdManager=ANY/g' conf/tinkergraph-empty.properties
sed -i 's/channelizer: org.apache.tinkerpop.gremlin.server.channel.WebSocketChannelizer/channelizer: org.apache.tinkerpop.gremlin.server.channel.WsAndHttpChannelizer/g' conf/gremlin-server.yaml
