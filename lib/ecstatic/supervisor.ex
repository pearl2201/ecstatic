defmodule Ecstatic.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {Ecstatic.EventQueue, []},
      # producer last
      {Ecstatic.EventProducer, []}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

end