# Smoothie

Smoothie is a library that will create beautiful emails for your elixir application. It handles inlining of styles, and converting your html templates to plain text.

Follow the installation instructions to set up Smoothie. After that we can use it in the following way in our project:

Let's suppose we are using the excellent Mailgun library to send our emails. Then we set up a Mailer module in the following location: `web/mailers/mailer.ex`, with the following content:

```elixir
defmodule MyApp.Mailer do
  # your mailgun config here
  @config %{...}
  use Mailgun.Client, @config

  def welcome_email(user) do
    send_email to: user.email_address,
               from: "support@acme.com",
               subject: "Welcome!",
               text: "Welcome #{user.name}"
    :ok
  end
end
```

Pretty boring right. So lets add smoothie. First we need a layout, lets try this one (save as: `web/mailers/templates/layout/layout.html.eex`):

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width">
  <style type="text/css">
    @media screen and (min-width: 581px) {
      .container {
        width: 580px !important;
      }
    }
  </style>
</head>
<body>
  <table class="body-wrap">
    <tr>
      <td class="container">
        <table>
          <tr>
            <td align="center" class="masthead">
              <h1><%= title %></h1>
            </td>
          </tr>
          <tr>
            <td class="content">
              {content}
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td class="container">
        <table>
          <tr>
            <td class="content footer" align="center">
              <p>Sent by <a href="http://www.acme.com">Acme</a></p>
              <p><a href="mailto:hello@acme.com">hello@acme.com</a></p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

Also, lets add a stylesheet. We can use sass for this! save in `web/mailers/templates/layout/style.scss`. If you just want to use css you can save it as `style.css`.

```scss
$action-color: #50E3C2;

@media only screen and (min-device-width: 581px) {
  .container {
    width: 580px !important;
  }
}


// Global
* {
  margin: 0;
  padding: 0;
  font-size: 100%;
  font-family: 'Avenir Next', "Helvetica Neue", "Helvetica", Helvetica, Arial, sans-serif;
  line-height: 1.65;
}

img {
  max-width: 100%;
  margin: 0 auto;
  display: block;
}

body,
.body-wrap {
  width: 100% !important;
  height: 100%;
  background: #efefef;
  -webkit-font-smoothing:antialiased;
  -webkit-text-size-adjust:none;
}

a {
  color: $action-color;
  text-decoration: none;
}

.text-center {
  text-align: center;
}

.text-right {
  text-align: right;
}

.text-left {
  text-align: left;
}

// Button
.button {
  display: inline-block;
  color: white;
  background: $action-color;
  border: solid $action-color;
  border-width: 10px 20px 8px;
  font-weight: bold;
  border-radius: 4px;
}

// Typography
h1, h2, h3, h4, h5, h6 {
  margin-bottom: 20px;
  line-height: 1.25;
}
h1 {
  font-size: 32px;
}
h2 {
  font-size: 28px;
}
h3 {
  font-size: 24px;
}
h4 {
  font-size: 20px;
}
h5 {
  font-size: 16px;
}

p, ul, ol {
  font-size: 16px;
  font-weight: normal;
  margin-bottom: 20px;
}

// layout
.container {
  display: block !important;
  clear: both !important;
  margin: 0 auto !important;
  max-width: 580px !important;

  table {
    width: 100% !important;
    border-collapse: collapse;
  }

  .masthead {
    padding: 80px 0;
    background: #50E3C2;
    color: white;

    h1 {
      margin: 0 auto !important;
      max-width: 90%;
      text-transform: uppercase;
    }
  }

  .content {
    background: white;
    padding: 30px 35px;

    &.footer {
      background: none;

      p {
        margin-bottom: 0;
        color: #888;
        text-align: center;
        font-size: 14px;
      }

      a {
        color: #888;
        text-decoration: none;
        font-weight: bold;
      }
    }
  }
}
```

Now create the template for our email, we can save this in `web/mailers/templates/welcome.html.eex`

```html
<h2>Hi <%= name %>,</h2>

<p>Welcome!</p>

<p>Cheers,</p>

<p><em>—The Acme</em></p>
```

Alright we're all set up, lets make sure this template works in Smoothie:

```elixir
defmodule MyApp.Mailer do
  # your mailgun config here
  @config %{...}
  use Mailgun.Client, @config
  use Smoothie

  def welcome_email(user) do
    template_params = [
      title: "Big Welcome!",
      name: user.name,
    ]

    send_email to: user.email_address,
               from: "support@acme.com",
               subject: "Welcome!",
               text: welcome_text(template_params),
               html: welcome_html(template_params)
    :ok
  end
end
```

The last thing to do is to compile the templates, we need to do this everytime when we change the templates or the layout:

```
> mix smoothie.compile
Preparing to compile the following template files:
- welcome.html.eex
Created welcome.html.eex
Created welcome.txt.eex
Done 🙏
```

Done! Now we are able to send very beautifully styled templates with styles inlined so it works in every email client, and for we also have a nice plain text version of the email!

## Installation

Smoothie can be installed as:

  1. Add `smoothie` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:smoothie, "~> 0.1.0"}]
    end
    ```

  2. Ensure `smoothie` is started before your application:

    ```elixir
    def application do
      [applications: [:smoothie]]
    end
    ```

  3. Specify the locations of your templates, edit `config/confix.exs` in your Elixir project and add the following config:

    ```elixir
      config :smoothie, template_dir: Path.join(["web", "mailers", "templates"])
    ```

    It can also be in any other directory, just provide the correct directory here.

    It is really important to make sure this directory exists, otherwise your project will not compile.

  4. The only thing left is install the npm package that smoothie relies on in your project, we can do this with the following command:

    ```
      > mix smoothie.init
    ```

    if you want to do it manually, that's also possible use:

    ```
      > npm i elixir-smoothie --save-dev
    ```


Smoothie needs to install a npm library to do the css inlining, so make sure you have npm initialized in your project (a `package.json` file in your project's root)
