CC = gcc
CFLAGS = -Wall -g

# Project's files.
SRCS = $(wildcard src/*.c)
OBJS = $(SRCS:.c=.o)
EXECUTABLE = nucleobits

# Docker ENV variables
CONTAINER_NAME = nucleobits-backend
IMAGE_NAME = nucleobits-backend

# Specify the target
all: $(EXECUTABLE)

# Link the object files into a binary
$(EXECUTABLE): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Compile the source files into object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean target
clean:
	# Clean up the object files and the executable
	rm -rf $(OBJS) $(EXECUTABLE)

	# Docker clean-up
	# Stop the docker container if its running...
	@docker ps -a -q | xargs -r docker stop
	# Remove the docker container if it exists...
	@docker ps -a -q | xargs -r docker rm
	# Remove the docker image if it exists...
	@docker images -a -q | xargs -r docker rmi
	

# Phony targets
.PHONY: all clean
