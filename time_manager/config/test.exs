import Config

# Log the current environment
IO.puts("Running in #{System.get_env("MIX_ENV")} environment")

# Database configuration for tests
config :time_manager, TimeManager.Repo,
  username: "postgres",
  password: "postgres",
  database: "myapp_test",
  hostname: "localhost",
  port: 5443,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required, enable it below.
config :time_manager, TimeManagerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "dl2uxMXWvtE+ifZgeN2ujIxlD/Jw5EtL0wFfN777fb/vaZjPJhNAmFq5Wj0/XCyS",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
