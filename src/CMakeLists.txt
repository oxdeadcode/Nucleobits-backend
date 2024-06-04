cmake_minimum_required(VERSION 3.8)

project(Nucleobits)

# Proto file
get_filename_component(hw_proto "/protos/nucleobits.proto" ABSOLUTE)
get_filename_componenet(hw_proto_path "${hw_proto}" PATH)

# Generated sources
set(hw_proto_srcs "${CMAKE_CURRENT_BINARY_DIR}/nucleobits.pb.cc")
set(hw_proto_hdrs "${CMAKE_CURRENT_BINARY_DIR}/nucleobits.pb.h")
set(hw_grpc_src "${CMAKE_CURRENT_BINARY_DIR}/nucleobits.grpc.pb.cc")
set(hw_grpc_hdrs "${CMAKE_CURRENT_BINARY_DIR}/nucleobits.grpc.pb.h")
add_custom_command(
  OUTPUT "${hw_proto_srcs}" "${hw_proto_hdrs}" "${hw_grpc_srcs}" "${hw_grpc_hdrs}"
  COMMAND ${_PROTOBUF_PROTOC}
  ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}"
    --cpp_out "${CMAKE_CURRENT_BINARY_DIR}"
    -I "${hw_proto_path}"
    --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
    "${hw_proto}"
  DEPENDS "${hw_proto}"
  )

# Include generated *.ph.h files
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

# hw_grpc_proto
add_library(
  ${hw_grpc_srcs}
  ${hw_grpc_hdrs}
  ${hw_proto_srcs}
  ${hw_proto_hdrs}
  )
target_link_libraries(
  hw_grpc_proto
  ${_REFLECTION}
  ${_GRPC_GRPCPP}
  ${_PROTOBUF_LIBPROTOBUF}
  )

# Target nucleobits
add_executable("nucleobits-backend.cpp")
target_link_libraries(
  "nucleobits"
  hw_grpc_proto
  absl::flags
  absl::flags_parse
  ${_REFLECTION}
  ${_GRPC_GRPCPP}
  ${_PROTOBUF_LIBPROTOBUF}
  )
