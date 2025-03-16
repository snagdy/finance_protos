# Finance Options Protocol Buffers

This repository contains Protocol Buffer definitions for financial options pricing, with a current focus on Black-Scholes model implementation.

## Package Structure

All Protocol Buffers in this repository use the `finance.options` package namespace. This provides a consistent way to import and use the messages across different programming languages.

## Available Models

Currently, this repository includes the following model:

- **Black-Scholes Option Pricer**: Standard model for European options pricing

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

### Example Usage by Language

#### Python
```python
from finance.options.black_scholes_pb2 import BlackScholesParameters, OptionType
from finance.options.black_scholes_pb2_grpc import OptionPricingServiceStub

# Create parameters
params = BlackScholesParameters(
    stock_price=100.0,
    strike_price=105.0,
    risk_free_rate=0.05,
    volatility=0.2,
    time_to_maturity=1.0,
    option_type=OptionType.CALL
)
```

#### C++
```cpp
#include "finance/options/black_scholes.pb.h"

void CalculateOption() {
  finance::options::BlackScholesParameters params;
  params.set_stock_price(100.0);
  params.set_strike_price(105.0);
  params.set_risk_free_rate(0.05);
  params.set_volatility(0.2);
  params.set_time_to_maturity(1.0);
  params.set_option_type(finance::options::OptionType::CALL);
}
```

#### Java
```java
import finance.options.BlackScholes.BlackScholesParameters;
import finance.options.BlackScholes.OptionType;

BlackScholesParameters params = BlackScholesParameters.newBuilder()
    .setStockPrice(100.0)
    .setStrikePrice(105.0)
    .setRiskFreeRate(0.05)
    .setVolatility(0.2)
    .setTimeToMaturity(1.0)
    .setOptionType(OptionType.CALL)
    .build();
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

## Future Enhancements

Planned additions to this repository include:
- Binomial Tree option pricing parameters
- American option pricing parameters
- Greeks calculation parameters

## License

This project is licensed under the MIT License - see the LICENSE file for details.