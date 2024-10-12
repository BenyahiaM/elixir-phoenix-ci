import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :time_manager, TimeManager.Repo,
  username: "postgres",
  password: "postgres",
  database: "myapp_test",
  hostname: "db",  # This should match the service name in your workflow
  pool_size: System.schedulers_online() * 2


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :time_manager, TimeManagerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "dl2uxMXWvtE+ifZgeN2ujIxlD/Jw5EtL0wFfN777fb/vaZjPJhNAmFq5Wj0/XCyS",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
