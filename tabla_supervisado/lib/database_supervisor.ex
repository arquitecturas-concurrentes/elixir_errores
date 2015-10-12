defmodule Table.Database.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @manager            Database.EventManager
  @registry           Database.Registry
  @ets_registry       Database.Registry
  @table_supervisor   Table.Supervisor

  def init(:ok) do
    ets = :ets.new(@ets_registry,
                   [:set,
                    :public,
                    :named_table,
                    {:read_concurrency, true}])

    children = [
      worker(GenEvent, [
        [name: @manager]]),

      supervisor(Table.Supervisor, [
        [name: @table_supervisor]]),

      worker(Database.Registry, [
        ets,
        @manager,
        @table_supervisor,
        [name: @registry]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
