use Mix.Config

config :meet, MeetWeb.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :meet, Meet.Mailer,
  adapter: Swoosh.Adapters.Local,
  api_key: "04ef3eff-0d36-4194-8fe4-6dc97e4b07ca"
