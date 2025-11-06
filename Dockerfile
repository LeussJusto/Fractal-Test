### Simple Dockerfile for Phoenix development with Docker
FROM elixir:1.15-alpine

# Install build dependencies (cmake needed for crc32cer/kafka dependencies)
RUN apk add --no-cache build-base git nodejs npm cmake

WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy dependency files (mix.lock is optional but recommended)
COPY mix.exs mix.lock* ./
COPY config config

# Install dependencies
RUN mix deps.get && mix deps.compile

# Copy application code
COPY . .

# Expose Phoenix port
EXPOSE 4000

# Start Phoenix server
CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix phx.server"]
