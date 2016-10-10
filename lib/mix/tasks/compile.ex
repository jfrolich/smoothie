defmodule Mix.Tasks.Smoothie.Compile do
  use Mix.Task
  @shortdoc "Compiles smoothie templates"

  def run(_) do
    otp_app = Mix.Project.config[:app]
    configs = Application.get_env(otp_app, :smoothie_configs)

    for config <- configs do
      path = Path.join([File.cwd!, "node_modules/.bin/elixir-smoothie"])
      env = [
        {"MAIL_TEMPLATE_DIR", Application.get_env(otp_app, config)[:template_dir]},
        {"LAYOUT_TEMPLATE_DIR", Application.get_env(otp_app, config)[:layout_dir]}
        ]
      System.cmd(path, [], env: env, into: IO.stream(:stdio, :line))
    end

  end
end
