import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :failer, Failer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "failer_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :failer, FailerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Z0w2o/SuHVxD4hTkm9c5o3m3GL3c9ezz02FX8yapppYI5LCiZZXVMXBw6Iirit7p",
  server: false

# In test we don't send emails.
config :failer, Failer.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
