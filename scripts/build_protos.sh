#!/bin/bash
set -e

# Script to generate code from proto files for multiple languages

# Define directories
PROTO_SRC="protos"
GEN_CPP="gen/cpp"
GEN_PYTHON="gen/python"
GEN_JAVA="gen/java"

# Create output directories if they don't exist
mkdir -p "$GEN_CPP" "$GEN_PYTHON" "$GEN_JAVA"

# Use a single include path so that the proto file paths are relative to the proto root.
INCLUDES="-I$PROTO_SRC"

# Find all proto files under protos/
PROTO_FILES=$(find "$PROTO_SRC" -name "*.proto")

echo "=== Generating code for Protocol Buffers ==="
echo "Found $(echo $PROTO_FILES | wc -w) proto file(s)"

# Generate C++ code
echo "Generating C++ code..."
for proto_file in $PROTO_FILES; do
  protoc $INCLUDES --cpp_out="$GEN_CPP" --grpc_out="$GEN_CPP" --plugin=protoc-gen-grpc="$(which grpc_cpp_plugin)" "$proto_file"
done

# Generate Python code
echo "Generating Python code..."
for proto_file in $PROTO_FILES; do
  # Compute relative directory (strip off the proto root)
  rel_dir="${proto_file#$PROTO_SRC/}"
  rel_dir=$(dirname "$rel_dir")
  
  # Ensure target directory exists
  mkdir -p "$GEN_PYTHON/$rel_dir"

  python3 -m grpc_tools.protoc $INCLUDES --python_out="$GEN_PYTHON" --grpc_python_out="$GEN_PYTHON" "$proto_file"

  # Fix Python imports for gRPC generated file and ensure proper package structure
  module=$(basename "$proto_file" .proto)
  pb_file="$GEN_PYTHON/${rel_dir}/${module}_pb2.py"
  grpc_file="$GEN_PYTHON/${rel_dir}/${module}_pb2_grpc.py"
  
  if [ -f "$pb_file" ]; then
    sed -i -E "s/^import (.*_pb2)/from . import \1/" "$grpc_file" 2>/dev/null || true
    touch "$GEN_PYTHON/$rel_dir/__init__.py"
  fi
done

# Generate Java code
echo "Generating Java code..."
for proto_file in $PROTO_FILES; do
  protoc $INCLUDES --java_out="$GEN_JAVA" "$proto_file"
done

# Generate Go code (if protoc-gen-go is available)
if command -v protoc-gen-go &> /dev/null; then
  echo "Generating Go code..."
  for proto_file in $PROTO_FILES; do
    protoc $INCLUDES --go_out="$GEN_GO" --go-grpc_out="$GEN_GO" \
      --go_opt=module=finance/options \
      --go-grpc_opt=module=finance/options \
      "$proto_file"
  done
else
  echo "Skipping Go code generation (protoc-gen-go not installed)"
fi

# Generate C# code
echo "Generating C# code..."
for proto_file in $PROTO_FILES; do
  protoc $INCLUDES --csharp_out="$GEN_CSHARP" "$proto_file"
done

echo "=== Protocol Buffer code generation complete ==="
echo "Output files are in the gen/ directory"
