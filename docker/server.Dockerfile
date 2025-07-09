FROM ubuntu:latest

# Install any necessary dependencies
RUN apt-get update && apt-get install -y

# Copy the built server files into the Docker image
COPY build/linux/cshark-at-sea-server.x86_64 /server/cshark-at-sea-server.x86_64
COPY build/linux/cshark-at-sea-server.pck /server/cshark-at-sea-server.pck

# Make the server executable
RUN chmod +x /server/cshark-at-sea-server.x86_64

# Define the command to run your dedicated server
CMD ["/server/cshark-at-sea-server.x86_64"]
