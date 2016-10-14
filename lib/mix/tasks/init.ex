defmodule Mix.Tasks.Smoothie.Init do
  use Mix.Task
  @shortdoc "Initializes smoothie"

  def run(_) do
    System.cmd "npm", ["i", "elixir-smoothie@2.X", "--save-dev"], into: IO.stream(:stdio, :line)
  end
end
