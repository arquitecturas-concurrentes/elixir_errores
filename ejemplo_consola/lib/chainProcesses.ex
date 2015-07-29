defmodule ChainProcesses do
  def chain(0) do
    receive do
      _ -> {:ok}
      after 2000 -> exit("Chain dies")
    end
  end

  def chain(n) do
    spawn_link(fn -> IO.puts "chaining to #{inspect self}";  chain(n-1) end)
    receive do
      _ -> {:ok}
    end
  end
end
