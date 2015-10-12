defmodule Database.Registry do
  use GenServer

  ##
  # Client API
  #

  def start_link(table, event_manager, tablespid, opts \\ []) do
    GenServer.start_link(__MODULE__, {table, event_manager, tablespid}, opts)
  end

  """
  Returns `{:ok, pid}` if the table exists, `:error` otherwise.
  """
  def lookup(table, name) do
    case :ets.lookup(table, name) do
      [{^name, table}] ->
        {:ok, table}
      [] ->
        :error
    end
  end

  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  ##
  # Callbacks
  #

  def init({table, events, tablespid}) do
    refs = :ets.foldl(fn {name, pid}, acc ->
      HashDict.put(acc, Process.monitor(pid), name)
    end, HashDict.new, table)

    {:ok, %{names: table,
            refs: refs,
            events: events,
            tablespid: tablespid}}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call({:create, name}, _from, state) do
    case lookup(state.names, name) do
      {:ok, pid} ->
        {:reply, pid, state}
      :error ->
        {:ok, pid} = Table.Supervisor.start_table(state.tablespid)
        ref = Process.monitor(pid)
        refs = HashDict.put(state.refs, ref, name)
        :ets.insert(state.names, {name, pid})
        GenEvent.sync_notify(state.events, {:create, name, pid})
        {:reply, pid, %{state | refs: refs}}
    end
  end

  def handle_info({:down, ref, :process, pid, _reason}, state) do
    {name, refs} = HashDict.pop(state.refs, ref)
    :ets.delete(state.names, name)

    GenEvent.sync_notify(state.events, {:exit, name, pid})

    {:noreply, %{state | refs: refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
