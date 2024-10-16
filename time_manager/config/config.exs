# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :time_manager, TimeManager.Repo,
       username: System.get_env("PGUSER") || "postgres",
       password: System.get_env("PGPASSWORD") || "postgres",
       database: System.get_env("PGDATABASE") || "test_db",
       hostname: System.get_env("PGHOST") || "postgres",
       port: String.to_integer(System.get_env("PGPORT") || "5432"),
       show_sensitive_data_on_connection_error: true,
       pool_size: 10

config :time_manager,
       ecto_repos: [TimeManager.Repo],
       generators: [timestamp_type: :utc_datetime]

config :time_manager, TimeManagerWeb.Auth.Guardian,
       issuer: "time_manager",
       secret_key: "LGUsWLM0Mg47OzXudkQZwuzWaRnf+49FTg8c8aw7EnKu8CGM0SQVn4aQyxXo7Apu"

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

# Configures Swagger
config :time_manager, :phoenix_swagger,
      swagger_files: %{
        "priv/static/swagger.json" => [
          router: TimeManagerWeb.Router,     # phoenix routes will be converted to swagger paths
          endpoint: TimeManagerWeb.Endpoint  # (optional) endpoint config used to set host, port and https schemes.
        ]
      }

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"