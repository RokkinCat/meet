# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :meet,
  ecto_repos: [Meet.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :meet, MeetWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "u9PP2owZc84BdE744jJb+3Dud4yp6FRqRt6EzUAcR2HoiSWqvDy+ClrBzeEYltP3",
  render_errors: [view: MeetWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Meet.PubSub,
  live_view: [signing_salt: "D1noAEba"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :meet, :timezone, "America/Chicago"
config :meet, :email, "nick@rokkincat.com"
config :meet, :name, "Nick Gartmann"
config :meet, :meeting_length, 60
config :meet, :video_link, "https://whereby.com/nickgartmann"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
