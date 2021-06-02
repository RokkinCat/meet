defmodule Meet.Repo do
  use Ecto.Repo,
    otp_app: :meet,
    adapter: Ecto.Adapters.Postgres
end
