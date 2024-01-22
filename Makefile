CC = gcc
CFLAGS = -Wall -g

# Project's files.
SRCS = $(wildcard src/*.c)
OBJS = $(SRCS:.c=.o)
EXECUTABLE = nucleobits

# Docker ENV variables
CONTAINER_NAME = nucleobits-backend-container
IMAGE_NAME = nucleobits-backend-image

# Specify the target
all: $(EXECUTABLE)

# Link the object files into a binary
$(EXECUTABLE): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Compile the source files into object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Build the Docker container
docker-build:
	@if [ -z "$$(docker images -q $(IMAGE_NAME))" ]; then \
		echo "Building Docker image $(IMAGE_NAME)..."; \
		docker build -t $(IMAGE_NAME) .; \
	else \
		echo "Docker image $(IMAGE_NAME) already exists. Use target 'docker-clean' first to build new image..."; \
	fi

# Run the Docker container
docker-run:
	@docker ps -q -f name=$(CONTAINER_NAME) | grep -q . || docker run -d --name $(CONTAINER_NAME) $(IMAGE_NAME)

# Clean the Docker container and images
docker-clean:
# Check if any containers based on the nucleobits-backend image are running and stop them
	@if [ $$(docker ps -q --filter ancestor=$(IMAGE_NAME)) ]; then \
		docker ps -q --filter ancestor=$(IMAGE_NAME) | xargs -r docker stop; \
	fi

# Check if any containers based on the nucleobits-backend image exist and remove them
	@if [ $$(docker ps -a -q --filter ancestor=$(IMAGE_NAME)) ]; then \
		docker ps -a -q --filter ancestor=$(IMAGE_NAME) | xargs -r docker rm; \
	fi

# Check if the nucleobits-backend image exists and remove it
	@if [ $$(docker images -q $(IMAGE_NAME)) ]; then \
		docker rmi $(IMAGE_NAME); \
	fi

# Remove all dangling images
	@docker image prune -f

# Clean target
clean:
# Clean up the object files and the executable
	@echo "Cleaning up object files and executables..."
	@rm -rf $(OBJS) $(EXECUTABLE)

# Phony targets
.PHONY: all clean docker-build docker-run docker-clean

