FROM elixir:latest

WORKDIR /app

COPY mix.exs mix.lock ./

RUN mix deps.get

COPY . .

RUN mix compile

# Generate the Swagger documentation
RUN mix phx.swagger.generate

EXPOSE 4000  

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix phx.server"]
