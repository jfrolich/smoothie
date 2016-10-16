defmodule Mix.Tasks.Smoothie.Compile do
  use Mix.Task
  require Logger
  @shortdoc "Compiles smoothie templates"

  def run(_) do
    Mix.Tasks.Loadpaths.run([])

    modules = Application.get_env(:smoothie, :modules)
    if modules == nil, do: raise("Smoothie: No smoothie modules options found to compile. Set config :smoothie, modules: [MyApp.MyModule].")

    for module <- modules do
      path = Path.join([File.cwd!, "node_modules/.bin/elixir-smoothie"])
      # try to ensure the project is compiled and that __smoothie__ functions are available first
      try do
        module.__smoothie_template_path__
      rescue
        e in UndefinedFunctionError ->
        Mix.Shell.IO.info("module.__smoothie_template_path__ function has not been defined")
        Mix.Shell.IO.info("Perhaps  #{Mix.Project.config()[:app]} has not been compiled yet.")
        Mix.Shell.IO.yes?("Do you wish to compile #{Mix.Project.config()[:app]} ?") && Mix.Tasks.Compile.run([])
      end
      env = [
        {"SMOOTHIE_TEMPLATE_DIR", module.__smoothie_template_path__},
        {"SMOOTHIE_LAYOUT_FILE", module.__smoothie_layout_path__},
        {"SMOOTHIE_USE_FOUNDATION", if(module.__smoothie_use_foundation__, do: "true", else: "false")},
        {"SMOOTHIE_SCSS_FILE", module.__smoothie_scss_path__},
        {"SMOOTHIE_CSS_FILE", module.__smoothie_css_path__},
      ]
      System.cmd(path, [], env: env, into: IO.stream(:stdio, :line))
    end
    # force recompilation to ensure changes are realized for the smoothie modules
    Mix.Tasks.Compile.run(["--force"])
  end
end
