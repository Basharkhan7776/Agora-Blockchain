FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /app

# Copy our source code
COPY . .

# Build the project
RUN forge build

# Set the entrypoint to anvil (local testnet) or forge
CMD ["anvil", "--host", "0.0.0.0"]