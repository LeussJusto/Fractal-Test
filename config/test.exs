import Config

# Configuración de Redix/Valkey para entorno de test
config :redix, :valkey,
  host: "valkey",
  port: 6379

# Configuración de la base de datos
config :fractal, Fractal.Repo,
  username: System.get_env("DB_USER") || "root",
  password: System.get_env("DB_PASSWORD") || "",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "fractal_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# No se levanta servidor durante test
config :fractal, FractalWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "r9ykMeUQ4r3CAEKMBhZBpKCl4/Zxj8pYyAR6fenWx1aHagbdjKr4ICJbsXWTunOD",
  server: false

# Correos falsos
config :fractal, Fractal.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false
config :logger, level: :warning

# Inicializa plugs en runtime para test
config :phoenix, :plug_init_mode, :runtime
