defmodule Mix.Tasks.Smoothie.Init do
  use Mix.Task
  @shortdoc "Initializes smoothie"
  @package_version "elixir-smoothie@3.X"
  @root "./"
  @assets "./assets"
  @standard_opts [into: IO.stream(:stdio, :line), cd: @root]
  @new_opts [into: IO.stream(:stdio, :line), cd: @assets]

  def run(_) do
    try do
      do_init()
    rescue
      _error ->
        System.cmd "npm", ["i", @package_version, "--save-dev", @new_opts]
    end
  end

  defp do_init() do
    case File.read("yarn.lock") do
      {:ok, _} ->
        System.cmd("yarn", ["add", @package_version, "--dev"], @standard_opts)
      {:error, :enoent} ->
        System.cmd("yarn", ["add", @package_version, "--dev"], @new_opts)
      {:error, _} ->
        System.cmd "npm", ["i", @package_version, "--save-dev", @standard_opts]
    end
  end

end
