defmodule SummonersTail.Application do
  @moduledoc false

  use Application

  require Logger

  @impl Application
  def start(_type, _args) do
    children = [
      SummonersTail.Monitor
    ]

    opts = [strategy: :one_for_one, name: SummonersTail.Supervisor]
    Logger.info("Starting application ...")
    Supervisor.start_link(children, opts)
  end
end
