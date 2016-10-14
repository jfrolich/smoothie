defmodule Css.Mailer do
  use Smoothie,
    template_dir: Path.join(["templates"]),
    layout_file: Path.join(["templates", "layout", "layout.html.eex"]),
    css_file: Path.join(["templates", "layout", "style.css"]),
    use_foundation: false
end