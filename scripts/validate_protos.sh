#!/bin/bash
set -e

# Script to validate Protocol Buffer files for syntax errors and style

echo "=== Validating Protocol Buffer Files ==="

# Find all proto files
PROTO_FILES=$(find protos -name "*.proto")
PROTO_DIRS=$(find protos -type d | sort | uniq)

if [ -z "$PROTO_FILES" ]; then
  echo "No proto files found!"
  exit 1
fi

echo "Found $(echo $PROTO_FILES | wc -w) proto files to validate"

# Create include paths for protoc
INCLUDES=""
for dir in $PROTO_DIRS; do
  INCLUDES="$INCLUDES -I$dir"
done

# Validate syntax using protoc
echo "Checking syntax..."
for proto_file in $PROTO_FILES; do
  echo "  $proto_file"
  # Use /dev/null as output to just check syntax without generating files
  protoc $INCLUDES --experimental_allow_proto3_optional --proto_path=. --cpp_out=/tmp $proto_file
done

# Check if protolint exists and use it for style validation
if command -v protolint &> /dev/null; then
  echo "Checking style with protolint..."
  protolint lint protos/
elif [ -f ".protolint.yaml" ]; then
  echo "protolint not found but .protolint.yaml exists. Skipping style check."
  echo "Consider installing protolint: https://github.com/yoheimuta/protolint"
fi

# Check if buf exists and use it for additional validation
if command -v buf &> /dev/null && [ -f "buf.yaml" ]; then
  echo "Checking with buf..."
  buf lint
elif command -v buf &> /dev/null; then
  echo "buf found but no buf.yaml configuration. Skipping buf checks."
  echo "Consider setting up buf: https://buf.build/docs/get-started-buf-yaml"
fi

# Optional: Check for consistent naming conventions
echo "Checking naming conventions..."
grep -l "option java_package" $PROTO_FILES > /dev/null || echo "  Warning: Some proto files may be missing java_package option"
grep -l "option go_package" $PROTO_FILES > /dev/null || echo "  Warning: Some proto files may be missing go_package option"

echo "=== Validation complete ==="
echo "All proto files passed syntax validation."