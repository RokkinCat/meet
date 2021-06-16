defmodule Meet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Meet.Repo,
      # Start the Telemetry supervisor
      MeetWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Meet.PubSub},
      # Start the Endpoint (http/https)
      MeetWeb.Endpoint,
      {Finch, name: Finch.Meet}
      # Start a worker by calling: Meet.Worker.start_link(arg)
      # {Meet.Worker, arg}
    ]

    :ets.new(:calendar, [:set, :public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Meet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MeetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
