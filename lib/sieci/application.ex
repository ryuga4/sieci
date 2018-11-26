defmodule Sieci.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  import Supervisor.Spec

  use Application

  def start(_type, _args) do

    IO.puts "Śmiga"
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Sieci.Worker.start_link(arg)
      # {Sieci.Worker, arg},
      Sieci.Repo,
      Sieci.Server.Server
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sieci.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
