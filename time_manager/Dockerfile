FROM elixir:1.14-alpine

RUN apk add --no-cache build-base git inotify-tools

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

COPY mix.exs ./

RUN mix deps.get

COPY . .

RUN mix compile

EXPOSE 4000

CMD ["mix", "phx.server"]
