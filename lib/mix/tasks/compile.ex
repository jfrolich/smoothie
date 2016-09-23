defmodule Mix.Tasks.Smoothie.Compile do
  use Mix.Task
  @shortdoc "Compiles smoothie templates"

  def run(_) do
    System.cmd Path.join([File.cwd!, "node_modules/.bin/elixir-smoothie"]), [], env: [{"MAIL_TEMPLATE_DIR", Application.get_env(:smoothie, :template_dir)}], into: IO.stream(:stdio, :line)
  end
end
