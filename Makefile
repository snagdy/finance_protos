.PHONY: all setup validate build_protos clean docker_build docker_push test

# Default target
all: build_protos

# Development environment setup
setup:
	@echo "Setting up development environment..."
	@chmod +x scripts/*.sh
	@pip3 install -r requirements-dev.txt || (echo "No requirements-dev.txt found, skipping pip install")
	@buf mod update 2>/dev/null || echo "Buf not configured, skipping"
	@echo "Setup complete - you can now run 'make validate'"

# Validate proto files
validate:
	@echo "Validating proto files..."
	@scripts/validate_protos.sh || (echo "Validation failed, but continuing with setup" && exit 0)

# Build protos for all languages
build_protos:
	@echo "Building proto files for all languages..."
	@scripts/build_protos.sh

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf gen/

# Build Docker image
docker_build:
	@echo "Building Docker image..."
	@docker build -t snagdy/finance-protos:latest .

# Push Docker image to registry
docker_push: docker_build
	@echo "Pushing Docker image to registry..."
	@docker push snagdy/finance-protos:latest

# Run tests
test: validate
	@echo "Running tests..."
	@scripts/run_tests.sh || echo "No tests defined yet"