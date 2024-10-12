FROM elixir:latest

WORKDIR /app

COPY mix.exs mix.lock ./

RUN mix deps.get

COPY . .

RUN mix compile

# Générer la documentation Swagger
RUN mix phx.swagger.generate

# Générer la documentation Swagger
RUN mix phx.swagger.generate

EXPOSE 400

CMD ["sh", "-c","mix ecto.create && mix ecto.migrate && mix deps.get && mix phx.server"]