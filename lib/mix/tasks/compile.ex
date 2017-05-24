defmodule Mix.Tasks.Smoothie.Compile do
  use Mix.Task
  require Logger
  @shortdoc "Compiles smoothie templates"

  def run(argv) do
    Mix.Tasks.Loadpaths.run([])

    modules = Application.get_env(:smoothie, :modules, :nil) ||
    raise("Smoothie: No smoothie modules options found to compile. Set config :smoothie, modules: [MyApp.MyModule].")

    path = Path.join([File.cwd!(), "node_modules/.bin/elixir-smoothie"])
    path = File.exists?(path) && path || Path.join([File.cwd!(), "assets/node_modules/.bin/elixir-smoothie"])

    html_only = html_only?(argv) |> Atom.to_string()

    for module <- modules do
      # try to ensure the project is compiled and that __smoothie__ functions are available first
      try do
        module.__smoothie_template_path__()
      rescue
        _e in UndefinedFunctionError ->
          Mix.Shell.IO.info("module.__smoothie_template_path__() function has not been defined")
          Mix.Shell.IO.info("Perhaps  #{Mix.Project.config()[:app]} has not been compiled yet.")
          Mix.Shell.IO.yes?("Do you wish to compile #{Mix.Project.config()[:app]} ?") && Mix.Tasks.Compile.run([])
      end
      env = [
        {"SMOOTHIE_TEMPLATE_DIR", module.__smoothie_template_path__()},
        {"SMOOTHIE_BUILD_TEMPLATE_DIR", module.__smoothie_template_build_path__()},
        {"SMOOTHIE_LAYOUT_FILE", module.__smoothie_layout_path__()},
        {"SMOOTHIE_USE_FOUNDATION", if(module.__smoothie_use_foundation__(), do: "true", else: "false")},
        {"SMOOTHIE_SCSS_FILE", module.__smoothie_scss_path__()},
        {"SMOOTHIE_CSS_FILE", module.__smoothie_css_path__()},
        {"SMOOTHIE_HTML_ONLY", html_only}
      ]
      System.cmd(path, [], env: env, into: IO.stream(:stdio, :line))
    end
    # force recompilation to ensure changes are realized for the smoothie modules
    Mix.Tasks.Compile.run(["--force"])
  end

  defp html_only?(argv) do
    case OptionParser.parse(argv, switches: ["html-only": :boolean]) do
      {[html_only: html_only], [], []} ->
        html_only
      _ ->
        Application.get_env(:smoothie, :html_only, false)
    end
  end
end
