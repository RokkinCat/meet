import Config

if config_env() == :prod do
  secret_key_base = System.get_env("SECRET_KEY_BASE") || raise "Missing SECRET_KEY_BASE config variable"
  app_name = System.get_env("FLY_APP_NAME") || raise "FLY_APP_NAME missing"

  config :meet, MeetWeb.Endpoint,
    server: true,
    url: [host: "#{app_name}.fly.dev", port: 80],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  database_url = System.get_env("DATABASE_URL") || raise "Missing DATABASE_URL"

  config :meet, Meet.Repo,
    url: database_url,
    socket_options: [:inet6],
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

end
