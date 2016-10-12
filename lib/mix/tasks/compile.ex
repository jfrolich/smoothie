defmodule Mix.Tasks.Smoothie.Compile do
  use Mix.Task
  @shortdoc "Compiles smoothie templates"

  def run(opts) do

    opts = OptionParser.parse(opts)
    |> Tuple.to_list()
    |> List.first()

    use_foundation = opts[:foundation] || :false
    use_layout = if opts[:no_layout] == :true, do: :false, else: :true

    otp_app = Mix.Project.config[:app]
    configs = Application.get_env(otp_app, :smoothie_configs)

    for config <- configs do
      path = Path.join([File.cwd!, "node_modules/.bin/elixir-smoothie"])
      env = [
        {"MAIL_TEMPLATE_DIR", Application.get_env(otp_app, config)[:template_dir]},
        {"LAYOUT_TEMPLATE_DIR", Application.get_env(otp_app, config)[:layout_dir]},
        {"USE_FOUNDATION_EMAILS", Atom.to_string(use_foundation)},
        {"USE_LAYOUT", Atom.to_string(use_layout)}
        ]
      System.cmd(path, [], env: env, into: IO.stream(:stdio, :line))
    end

  end
end
