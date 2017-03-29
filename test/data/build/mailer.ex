defmodule Build.Mailer do
  use Smoothie,
    template_dir: Path.join(["templates"]),
    template_build_dir: Path.join(["templates", "build"]),
    layout_file: Path.join(["templates", "layout", "layout.html.eex"]),
    scss_file: Path.join(["templates", "layout", "style.scss"])
  @user "Elixir Developer"

  def text(), do: welcome_text([user: @user])
  def html(), do: welcome_html([user: @user])
end