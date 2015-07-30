require BandasMusicalesMonitoreado

defmodule BandasMusicalesMonitoreadoTest do
  use ExUnit.Case

  test "the truth about genesis" do
    BandasMusicalesMonitoreado.crear_critico
    :timer.sleep(200)
    pid = :erlang.whereis(:critico)
    IO.puts "Killing process pid: #{inspect pid}"
    Process.exit(pid, :kill)

  end

end
