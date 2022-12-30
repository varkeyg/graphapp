
# Build the image. Make sure to run in the directory where the Dockerfile file is available
docker build -t graph_app_image .

# Remove the container if it already exists
docker stop graph_app_container
docker rm /graph_app_container

# Create a volume for data on the parent host
docker volume create graph_data



# Run the container & Mount the volumes
docker run --name graph_app_container --expose 8182 \
--mount source=graph_data,target=/home/graph-user/graph_data -p 8182:8182 -t -d graph_app_image

docker exec graph_app_container /home/graph-user/tpop/apache-tinkerpop-gremlin-server-3.6.1/bin/gremlin-server.sh start

docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' graph_app_container

docker exec -it graph_app_container /bin/bash

