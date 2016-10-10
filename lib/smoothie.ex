defmodule Smoothie do
  require EEx

  defmacro __using__(opts) do

    quote bind_quoted: [opts: opts] do

      otp_app = Keyword.fetch!(opts, :otp_app)
      smoothie_config = Keyword.fetch!(opts, :config)
      template_path = [Mix.Project.build_path, '..', '..'] ++ [Application.get_env(otp_app, smoothie_config)[:template_dir]]
      build_path = template_path ++ ["build"]
      template_files = File.ls!(Path.join(build_path))

      # Ensure the macro is recompiled when the templates are changed
      Enum.each(template_files, fn(file) ->
        external_resource = Path.join(build_path ++ [file])
      end)

      Enum.each(template_files, fn(file) ->
        # read the contents of the template
        template_contents = File.read!(Path.join(build_path ++ [file]))

        # capture variables that are defined in the template
        variables =
          Regex.scan(~r/<%=(.*?)%>/, template_contents)
          |> Enum.map(fn(match) ->
            match
            |> Enum.at(1)
            |> String.trim(" ")
            |> String.to_atom()
          end)
          |> Enum.uniq

        # create assignment macro code for in the function block
        variable_assignments = quote do: (unquote(variables)
        |> Enum.map(fn(name) ->
          quote do
            unquote(Macro.var(name, nil)) = args[unquote(name)]
          end
        end)
        )

        # generate function name from file name
        template_name =
          file
          |> String.replace(".eex", "")
          |> String.replace(".html", "_html")
          |> String.replace(".txt", "_text")
          |> String.to_atom

        compiled = quote do: EEx.compile_string(unquote(template_contents), [])

        def unquote(template_name)(args) do
          unquote(variable_assignments)
          unquote(compiled)
        end
      end)

    end
  end


end