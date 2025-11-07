FROM elixir:1.15-alpine

RUN apk add --no-cache build-base git nodejs npm cmake

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock* ./
COPY config config

RUN mix deps.get && mix deps.compile

COPY . .

EXPOSE 4000

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix phx.server"]
