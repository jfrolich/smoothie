# Changelog

## v3.1.0

- Option to set the `:template_build_dir` in `config smoothie: ...`
- Anticipate new directory structure for pre phoenix 1.3 and post phoenix 1.3
- Update dependencies for documentation generation
- Slight change to the way the path is generated, same outcome but allows for where
the user enters `../../path` - before this would not expand to the correct path. With
changes, it should do so. Might be needed for umbrella apps and if putting templates
`../assets` directory.
- Added test for expected empty mock function on compilation failure
- Added test for where the `:template_build_dir` is being used.
- Minor changes to syntax and readme.
- Requires upgrading to new companion of elixir-smoothie, `> 2.0.5`.


## v3.0.0

- This release is a breaking change.

[breaking changes]
When you pass attributes to the template function (such as welcome_html(user: user)),
previously you needed <%= user %> in your template to reference the user attribute.
This worked by using a naive implementation,
and this is why in the previous version it was impossible to do other things in
elixir syntax than just including that variable
(for instance <%= String.upcase(user) %> would not work).
This is changed in 3.0.0 however we need to change our templates to invoke
attributes using module attributes: <%= @user %>.
This is more in line of how the templating works in the rest of elixir,
and allows us to build more flexible templates.