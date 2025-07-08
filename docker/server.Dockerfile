FROM ubuntu:latest

# Install any necessary dependencies
RUN apt-get update && apt-get install -y

# Copy the built server files into the Docker image
COPY build/linux/dedicated_server.x86_64 /server/dedicated_server.x86_64

# Make the server executable
RUN chmod +x /server/dedicated_server.x86_64

# Define the command to run your dedicated server
CMD ["/server/dedicated_server.x86_64"]
