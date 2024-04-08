defmodule ReceptorPRT.Application do
  use Application

  defp poolboy_config(size) do
    [
      name: {:local, :worker},
      worker_module: PoolboyPRT.Worker,
      size: size,
      max_overflow: 2
    ]
  end

  @impl true
  def start(_type, _args) do
    {:ok, yaml_content} = ReceptorPRT.Config.load()
    {:ok, prt} = Map.fetch(yaml_content, "prt")
    {:ok, api} = Map.fetch(yaml_content, "api")
    %{"pool_size" => pool_size} = api

    children = [
      :poolboy.child_spec(:worker, poolboy_config(pool_size)),
      Supervisor.child_spec({Task, fn -> ReceptorPRT.start(prt) end},
        restart: :permanent
      )
    ]

    opts = [strategy: :one_for_all, name: ReceptorPRT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
