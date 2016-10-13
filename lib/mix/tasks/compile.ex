defmodule Mix.Tasks.Smoothie.Compile do
  use Mix.Task
  require Logger
  @shortdoc "Compiles smoothie templates"


  def run(_) do
    modules = Application.get_env(:smoothie, :modules)
    if modules == nil, do: raise("Smoothie: No smoothie modules options found to compile. Set config :smoothie, module_options: [MyModule].")

    for module <- modules do
      path = Path.join([File.cwd!, "node_modules/.bin/elixir-smoothie"])
      env = [
        {"SMOOTHIE_TEMPLATE_DIR", module.__smoothie_template_path__},
        {"SMOOTHIE_LAYOUT_FILE", module.__smoothie_layout_path__},
        {"SMOOTHIE_USE_FOUNDATION", if(module.__smoothie_use_foundation__, do: "true", else: "false")},
        {"SMOOTHIE_SCSS_FILE", module.__smoothie_scss_path__},
        {"SMOOTHIE_CSS_FILE", module.__smoothie_css_path__},
      ]
      System.cmd(path, [], env: env, into: IO.stream(:stdio, :line))
    end
  end
end
