defmodule Failer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Failer.Repo,
      FailerWeb.Telemetry,
      {Phoenix.PubSub, name: Failer.PubSub},
      FailerWeb.Endpoint,
      FailerWeb.LiveViewCrashLoopLog
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Failer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FailerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
