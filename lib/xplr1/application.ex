defmodule Xplr1.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    unless Mix.env() == :prod do
      Dotenv.load()
      Mix.Task.run("loadconfig")
    end

    children = [
      Xplr1Web.Telemetry,
      # Xplr1.Repo,
      {DNSCluster, query: Application.get_env(:xplr1, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Xplr1.PubSub},
      # Start a worker by calling: Xplr1.Worker.start_link(arg)
      # {Xplr1.Worker, arg},
      # Start to serve requests, typically the last entry
      Xplr1Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Xplr1.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Xplr1Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
