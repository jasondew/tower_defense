import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tower_defense, TowerDefenseWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "DvmUvadmb+qydA/snyDEUt66biaZzcwlH6L2XI2APA9RoSv/HycV7Nx2gfLYSVgr",
  server: false

# In test we don't send emails.
config :tower_defense, TowerDefense.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
