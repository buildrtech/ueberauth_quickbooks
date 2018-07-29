# Überauth Quickbooks

> Quickbooks OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [Quickbooks Developers](https://developer.intuit.com).

1. Add `:ueberauth_quickbooks` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_quickbooks, "~> 0.1"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_quickbooks]]
    end
    ```

1. Add Quickbooks to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        quickbooks: {Ueberauth.Strategy.Quickbooks, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Quickbooks.OAuth,
      client_id: System.get_env("QUICKBOOKS_CLIENT_ID"),
      client_secret: System.get_env("QUICKBOOKS_CLIENT_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.SessionController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", SessionController, :request
      get "/:provider/callback", SessionController, :callback
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured URL you can initiate the request through:

    /auth/quickbooks

```elixir
config :ueberauth, Ueberauth,
  providers: [
    quickbooks: {Ueberauth.Strategy.Quickbooks}
  ]
```

## License

Please see [LICENSE](https://github.com/buildrtech/ueberauth_quickbooks/blob/master/LICENSE) for licensing details.

