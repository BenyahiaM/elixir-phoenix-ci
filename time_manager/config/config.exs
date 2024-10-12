  # This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :time_manager, TimeManager.Repo,
  database: "time_manager_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :time_manager,
  ecto_repos: [TimeManager.Repo],
  generators: [timestamp_type: :utc_datetime]

config :time_manager, TimeManagerWeb.Auth.Guardian,
  issuer: "time_manager",
  secret_key: "your_secret_key"

# Configures the endpoint
config :time_manager, TimeManagerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: TimeManagerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TimeManager.PubSub,
  live_view: [signing_salt: "IrN6UJOh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

  #Configures Swagger
config :time_manager, :phoenix_swagger,
       swagger_files: %{
         "priv/static/swagger.json" => [
           router: TimeManagerWeb.Router,     # phoenix routes will be converted to swagger paths
           endpoint: TimeManagerWeb.Endpoint  # (optional) endpoint config used to set host, port and https schemes.
         ]
       }

config :my_app, MyApp.Web.Endpoint,
       url: [host: "localhost"]

  # Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
