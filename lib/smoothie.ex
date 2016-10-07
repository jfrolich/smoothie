defmodule Smoothie do
  require EEx

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)

      generate_views()
    end
  end

  # location of the template path
  @template_path [Mix.Project.build_path, '..', '..'] ++ [Application.get_env(:smoothie, :template_dir)]

  # location of the build path
  @build_path @template_path ++ ["build"]

  # create the template and build folder at compile time if not exists
  unless File.exists?(Path.join(@build_path)), do: File.mkdir_p!(Path.join(@build_path))

  @template_files File.ls!(Path.join(@build_path))
  |> Enum.filter(fn(file) -> String.contains?(file, ".eex") end)

  # Ensure the macro is recompiled when the templates are changed
  @template_files
  |> Enum.each(fn(file) ->
    @external_resource Path.join(@build_path ++ [file])
  end)

  defmacro generate_views do
    @template_files
    |> Enum.map(fn(file) ->
      # read the contents of the template
      template_contents = File.read!(Path.join(@build_path ++ [file]))

      # capture variables that are defined in the template
      variables =
        Regex.scan(~r/<%=[^\w]*(\w+)[^\w]*%>/, template_contents)
        |> Enum.map(fn(match) ->
          match
          |> Enum.at(1)
          |> String.to_atom
        end)
        |> Enum.uniq

      # create assignment macro code for in the function block
      variable_assignments = variables |> Enum.map(fn(name) ->
        quote do
          unquote(Macro.var(name, nil)) = args[unquote(name)]
        end
      end)

      # generate function name from file name
      template_name =
        file
        |> String.replace(".eex", "")
        |> String.replace(".html", "_html")
        |> String.replace(".txt", "_text")
        |> String.to_atom

      compiled = EEx.compile_string(template_contents, [])

      quote do
        def unquote(template_name)(args) do
          unquote(variable_assignments)
          unquote(compiled)
        end
      end
    end)
  end
end
