###
### Docker section for development env only ####
###

# Docker ENV variables
CONTAINER_NAME = nucleobits-backend-container
IMAGE_NAME = nucleobits-backend-image
GRPC_IMAGE_NAME = grpc-build-env
DOCKER_DIR = ./docker

# Build GRPC and Protocol Buffers environment
docker-build-grpc:
	@if [ -z "$$(docker images -q $(GRPC_IMAGE_NAME))" ]; then \
		echo "Building gRPC Docker Image: $(GRPC_IMAGE_NAME)..."; \
		docker build -f $(DOCKER_DIR)/Dockerfile.grpc -t $(GRPC_IMAGE_NAME) $(DOCKER_DIR); \
	else \
		echo "gRPC Docker Image $(GRPC_IMAGE_NAME) already exists."; \
	fi

# Build the Nucleobits backend
docker-build-nb:
	@if [ -z "$$(docker images -q $(IMAGE_NAME))" ]; then \
		echo "Building Nucleobits Backend Docker Image: $(IMAGE_NAME)..."; \
		docker build -f $(DOCKER_DIR)/Dockerfile.nucleobits-backend -t $(IMAGE_NAME) $(DOCKER_DIR); \
	else \
		echo "Nucleobits Backend Docker Image $(IMAGE_NAME) already exists. Use target 'docker-clean' to build a new image..."; \
	fi

docker-build: docker-build-grpc docker-build-nb

# Build a clean docker image
docker-clean-build: docker-clean docker-build

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
	@if [ $$(docker images -aq $(IMAGE_NAME)) ]; then \
		docker rmi $(IMAGE_NAME); \
	fi

# Do the same for volumes
	@if [$$(docker volume ls -q)]; then \
		docker volume rm $(docker volume ls -q); \
	fi

# And networks
	@if [$$(docker network ls -q)]; then \
		docker network rm $(docker network ls -q); \
	fi

# Remove all dangling images locally and system-wide
	@docker image prune -f
	@docker system prune -a -f
	@docker builder prune -a -f

###
### End Docker section ###
###

PROTOBUF_ABSL_DEPS = absl_absl_check absl_absl_log absl_algorithm absl_base absl_bind_front absl_bits absl_btree absl_cleanup absl_cord absl_core_headers absl_debugging absl_die_if_null absl_dynamic_annotations absl_flags absl_flat_hash_map absl_flat_hash_set absl_function_ref absl_hash absl_layout absl_log_initialize absl_log_severity absl_memory absl_node_hash_map absl_node_hash_set absl_optional absl_span absl_status absl_statusor absl_strings absl_synchronization absl_time absl_type_traits absl_utility absl_variant
PROTOBUF_UTF8_RANGE_LINK_LIBS = -lutf8_validity

HOST_SYSTEM = $(shell uname | cut -f 1 -d_)
SYSTEM ?= $(HOST_SYSTEM)
CXX = g++
CPPFLAGS += `pkg-config --cflags protobuf grpc absl_flags absl_flags_parse`
CXXFLAGS += -std=c++20

ifeq ($(SYSTEM), Darwin)
LDFLAGS += -L/usr/local/lib `pkg-config --libs --static protobuf grpc++ absl_flags absl_flags_parse $(PROTOBUF_ABSL_DEPS)`\
	$(PROTOBUF_UTF8_RANGE_LINK_LIBS) \
	-pthread\
	-lgrpc++_reflection\
	-ldl
else
LDFLAGS += -L/usr/local/lib `pkg-config --libs --static protobuf grpc++ absl_flags absl_flags_parse $(PROTOBUF_ABSL_DEPS)`\
	$(PROTOBUF_UTF8_RANGE_LINK_LIBS) \
	-pthread\
	-Wl,--no-as-needed -lgrpc++_reflection -Wl,--as-needed\
	-ldl
endif

PROTOC = protoc
GRPC_CPP_PLUGIN = grpc_cpp_plugin
GRPC_CPP_PLUGIN_PATH ?= `which $(GRPC_CPP_PLUGIN)`

PROTOS_PATH = src/protos

## Behold! The weeds!
vpath %.proto $(PROTOS_PATH)

.PRECIOUS: %.grpc.pb.cc
%.grpc.pb.cc: %.proto
	$(PROTOC) -I $(PROTOS_PATH) --grpc_out=. --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) $<

.PRECIOUS: %.pb.cc
%.pb.cc: %.proto
	$(PROTOC) -I $(PROTOS_PATH) --cpp_out=. $<

clean:
	rm -rf *.o *.pb.cc *.pb.h nucleobits

all: nucleobits

dev-all: docker-build

nucleobits: helloworld.pb.o helloworld.grpc.pb.o nucleobits.o
	$(CXX) $^ $(LDFLAGS) -o $@

# Phony targets
.PHONY: all clean docker-build docker-run docker-clean docker-build-grpc docker-build-nb
