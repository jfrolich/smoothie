defmodule Mix.Tasks.Smoothie.Init do
  use Mix.Task
  @shortdoc "Initializes smoothie"
  @package_version "elixir-smoothie@2.X"

  def run(_) do
    case File.read("yarn.lock") do
      {:ok, _} ->
        System.cmd "yarn", ["add", @package_version, "--dev"], into: IO.stream(:stdio, :line)
      {:error, _} ->
        System.cmd "npm", ["i", @package_version, "--save-dev"], into: IO.stream(:stdio, :line)
    end
  end
end
