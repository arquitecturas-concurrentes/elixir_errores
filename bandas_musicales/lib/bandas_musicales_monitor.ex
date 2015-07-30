defmodule BandasMusicalesMonitoreado do

  def crear_critico do
    spawn(fn -> restarter end)
  end

  def restarter do
    Process.flag(:trap_exit, true)
    pid = spawn_link(fn -> critico() end)
    IO.puts "Registering #{inspect pid} into monitor"
    :erlang.register(:critico, pid)
    receive do
      {:EXIT, {pid, :normal}} -> IO.puts "Normal exit of the process #{inspect pid}"; {:ok}
      {:EXIT, {pid, :shutdown}} -> IO.puts "Process #{inspect pid} shutdown properly"; {:ok}
      {:EXIT, {pid, _}} -> IO.puts "Restarting exited pid #{inspect pid}" ;restarter()
    end
  end

  def critico do
    receive do
      {pid, ref, {"Rage Against the Turing Machine", "Unit Testify"}} ->
          send pid, {ref, "They are great!"};
      {pid, ref, {"System of a Downtime", "Memoize"}} ->
          send pid,{ref, "They're not Johnny Crash but they're good."};
      {pid, ref, {"Johnny Crash", "The Token Ring of Fire"}} ->
          send pid,{ref, "Simply incredible."};
      {pid, ref, {_Band, _Album}} ->
          send pid, {ref, "They are terrible!"}
    end
    critico
  end

  def juzgar(banda, album) do
    ref = make_ref()
    send critico, {self(), ref, {banda, album}}
    receive do
      {critic, critica} -> send self, {:ok, critica}
    after 2000 ->
      :timeout
    end
  end

end
