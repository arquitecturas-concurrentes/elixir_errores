defmodule BandasMusicalesTest do
  use ExUnit.Case

  test "the truth about genesis" do
    critic = BandasMusicales.crear_critico
    assert BandasMusicales.juzgar(critic, "Genesis", "The Lambda Lies Down on Broadway") == {:ok, "They are terrible!"}
  end

  test "the truth about Rage Against..." do
    critic = BandasMusicales.crear_critico
    assert BandasMusicales.juzgar(critic, "Rage Against the Turing Machine", "Unit Testify") == {:ok, "They are great!"}
  end
end
