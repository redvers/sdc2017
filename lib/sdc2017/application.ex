defmodule Sdc2017.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Sdc2017.Worker.start_link(arg1, arg2, arg3)
      worker(SDC2017.UDP, []),
      worker(SDC2017.OLED, [{128,64}]),
      supervisor(Registry, [:duplicate, :badgeapps])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sdc2017.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
