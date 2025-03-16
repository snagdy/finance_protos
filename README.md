# Finance Protocol Buffers

This repository contains Protocol Buffer definitions for financial calculations and modeling, with a focus on options pricing.

## Overview

These Protocol Buffer definitions provide standardized message formats for financial data exchange across different services and languages. The current implementation includes specifications for Black-Scholes option pricing.

## Usage

### Importing in Your Project

You can use these protos in your project by pulling our pre-built Docker image:

```bash
# Pull the image (replace with the appropriate version)
docker pull ghcr.io/your-org/finance_protos:latest

# Extract the generated code for your language
docker create --name temp_protos ghcr.io/your-org/finance_protos:latest
docker cp temp_protos:/gen/python/. ./my_project/generated_protos/
docker rm temp_protos
```

### Available Languages

Pre-compiled bindings are available for:
- C++
- Python
- Java
- Go
- C#

### Example Usage

```python
# Python example using the Black-Scholes proto
from options.black_scholes_pb2 import BlackScholesParameters, OptionType
from options.black_scholes_pb2_grpc import OptionPricingServiceStub

# Create parameters
params = BlackScholesParameters(
    stock_price=100.0,
    strike_price=105.0,
    risk_free_rate=0.05,
    volatility=0.2,
    time_to_maturity=1.0,
    option_type=OptionType.CALL
)

# Use in your application...
```

## Development

### Prerequisites

- Docker
- Visual Studio Code with Remote Containers extension

### Getting Started

1. Clone this repository
2. Open in VS Code
3. When prompted, click "Reopen in Container"
4. The development environment will be automatically set up

### Building Locally

```bash
# Validate proto files
make validate

# Generate code for all languages
make build_protos

# Build Docker image
make docker_build
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Validate with `make validate`
4. Submit a pull request

## Versioning

We use semantic versioning. When a new version is tagged, a corresponding Docker image will be automatically built and published.

## License

This project is licensed under the MIT License - see the LICENSE file for details.