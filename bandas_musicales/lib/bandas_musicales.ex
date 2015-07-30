defmodule BandasMusicales do
  def crear_critico do
    spawn(fn -> critico() end)
  end

  def critico do
    receive do
      {pid, {"Rage Against the Turing Machine", "Unit Testify"}} ->
          send pid, {self, "They are great!"};
      {pid, {"System of a Downtime", "Memoize"}} ->
          send pid,{self, "They're not Johnny Crash but they're good."};
      {pid, {"Johnny Crash", "The Token Ring of Fire"}} ->
          send pid,{self, "Simply incredible."};
      {pid, {_Band, _Album}} ->
          send pid, {self, "They are terrible!"}
    end
    critico
  end

  def juzgar(pid, banda, album) do
    send pid, {self, {banda, album}}
    receive do
      {critic, critica} -> send self, {:ok, critica}
    after 2000 ->
      :timeout
    end
  end

end
