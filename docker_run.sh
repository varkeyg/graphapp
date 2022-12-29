
# Build the image. Make sure to run in the directory where the Dockerfile file is available
sudo docker build -t graph_app_image .

# Remove the container if it already exists
sudo docker rm /graph_app_container

# Create a volume for data on the parent host
sudo docker volume create graphapp



# Run the container & Mount the volumes
sudo docker run --name dev_container \
--mount source=graphapp,target=/home/graph-user/graphapp -it graph_app_image
