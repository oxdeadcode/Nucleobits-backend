# Use an offical base image
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
  build-essential \ 
  # Add other dependencies here
  && rm -rf /var/lib/apt/lists/*

# Copy the source code into the container
COPY . /usr/src/nucleobits

# Set the working directory
WORKDIR /usr/src/nucleobits

# Compile the application
RUN make all

# Command to run the application
ENTRYPOINT ["./nucleobits"]
