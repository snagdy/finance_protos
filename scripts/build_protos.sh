#!/bin/bash
set -e

# Script to generate code from proto files for multiple languages

# Create output directories if they don't exist
mkdir -p gen/cpp
mkdir -p gen/python
mkdir -p gen/java
mkdir -p gen/go
mkdir -p gen/csharp

# Find all proto files
PROTO_FILES=$(find protos -name "*.proto")
PROTO_DIRS=$(find protos -type d | sort | uniq)

# Create include paths for protoc
INCLUDES=""
for dir in $PROTO_DIRS; do
  INCLUDES="$INCLUDES -I$dir"
done

echo "=== Generating code for Protocol Buffers ==="
echo "Found $(echo $PROTO_FILES | wc -w) proto files"

# Generate C++ code
echo "Generating C++ code..."
for proto_file in $PROTO_FILES; do
  protoc $INCLUDES --cpp_out=gen/cpp $proto_file
done

# Generate Python code
echo "Generating Python code..."
for proto_file in $PROTO_FILES; do
  python3 -m grpc_tools.protoc $INCLUDES --python_out=gen/python --grpc_python_out=gen/python $proto_file
  
  # Fix Python imports (this is needed for Python 3 compatibility)
  dir=$(dirname $proto_file)
  module=$(basename $proto_file .proto)
  pb_file="gen/python/${dir}/${module}_pb2.py"
  grpc_file="gen/python/${dir}/${module}_pb2_grpc.py"
  
  if [ -f "$pb_file" ]; then
    sed -i -E "s/^import.*_pb2/from . &/" $grpc_file 2>/dev/null || true
    
    # Create __init__.py files to make it a proper Python package
    mkdir -p $(dirname $pb_file)
    touch $(dirname $pb_file)/__init__.py
  fi
done

# Generate Java code
echo "Generating Java code..."
for proto_file in $PROTO_FILES; do
  protoc $INCLUDES --java_out=gen/java $proto_file
done

# Generate Go code (if protoc-gen-go is available)
if command -v protoc-gen-go &> /dev/null; then
  echo "Generating Go code..."
  for proto_file in $PROTO_FILES; do
    protoc $INCLUDES --go_out=plugins=grpc:gen/go $proto_file
  done
else
  echo "Skipping Go code generation (protoc-gen-go not installed)"
fi

# Generate C# code
echo "Generating C# code..."
for proto_file in $PROTO_FILES; do
  protoc $INCLUDES --csharp_out=gen/csharp $proto_file
done

echo "=== Protocol Buffer code generation complete ==="
echo "Output files are in the gen/ directory"