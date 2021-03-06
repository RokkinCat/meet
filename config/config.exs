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

config :meet,
  timezone: "America/Chicago",
  email: "nick@rokkincat.com",
  name: "Nick Gartmann",
  meeting_length: 60,
  video_link: "https://whereby.com/nickgartmann",
  urls: [
    "https://calendar.google.com/calendar/ical/nick%40rokkincat.com/private-71a05a1c5852bc2c87de0256645b8220/basic.ics",
    "https://3.basecamp.com/3992585/my/schedules/feed/2JvLsyCPTbryXJWWvhmFKX6K.ics"
  ]


# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
