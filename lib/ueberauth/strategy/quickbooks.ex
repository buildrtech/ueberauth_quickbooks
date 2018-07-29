defmodule Ueberauth.Strategy.Quickbooks do
  @moduledoc """
  Implements an ÜeberauthQuickbooks strategy for authentication with quickbooks.com.

  When configuring the strategy in the Üeberauth providers, you can specify some defaults.

  * `oauth2_module` - The OAuth2 module to use. Default Ueberauth.Strategy.Quickbooks.OAuth

  ````elixir

  config :ueberauth, Ueberauth,
    providers: [
      quickbooks: { Ueberauth.Strategy.Quickbooks }
    ]
  """
  @oauth2_module Ueberauth.Strategy.Quickbooks.OAuth

  use Ueberauth.Strategy,
    default_scope: "com.intuit.quickbooks.accounting",
    oauth2_module: @oauth2_module

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  # When handling the request just redirect to Quickbooks
  @doc false
  def handle_request!(conn) do
    scope = conn.params["scope"] || option(conn, :default_scope)

    opts = [
      redirect_uri: callback_url(conn),
      scope: scope,
      state: random_string(32)
    ]

    opts =
      if conn.params["state"], do: Keyword.put(opts, :state, conn.params["state"]), else: opts

    redirect!(conn, apply(@oauth2_module, :authorize_url!, [opts]))
  end

  # When handling the callback, if there was no errors we need to
  # make two calls. The first, to fetch the Quickbooks auth is so that we can get hold of
  # the user id so we can make a query to fetch the user info.
  # So that it is available later to build the auth struct, we put it in the private section of the conn.
  @doc false
  def handle_callback!(%Plug.Conn{params: %{"code" => code, "realmId" => realm_id}} = conn) do
    params = [
      code: code,
      redirect_uri: callback_url(conn)
    ]

    token = apply(@oauth2_module, :get_token!, [params])

    if token.access_token == nil do
      set_errors!(conn, [
        error(token.other_params["error"], token.other_params["error_description"])
      ])
    else
      conn
      |> store_realm_id(realm_id)
      |> store_token(token)
    end
  end

  # If we don't match code, then we have an issue
  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  defp store_realm_id(conn, realm_id) do
    put_private(conn, :quickbooks_realm_id, realm_id)
  end

  # We store the token for use later when fetching the Quickbooks auth and user and constructing the auth struct.
  @doc false
  defp store_token(conn, token) do
    put_private(conn, :quickbooks_token, token)
  end

  # Remove the temporary storage in the conn for our data. Run after the auth struct has been built.
  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:quickbooks_realm_id, nil)
    |> put_private(:quickbooks_token, nil)
  end

  # The structure of the requests is such that it is difficult to provide cusomization for the uid field.
  # instead, we allow selecting any field from the info struct
  @doc false
  def uid(conn) do
    conn.private[:quickbooks_realm_id]
  end

  @doc false
  def credentials(conn) do
    token = conn.private.quickbooks_token

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
      scopes: []
    }
  end

  @doc false
  def info(_conn) do
    %Info{}
  end

  @doc false
  def extra(conn) do
    token = conn.private.quickbooks_token

    %Extra{
      raw_info: %{
        refresh_token_expires_in: token.other_params["x_refresh_token_expires_in"]
      }
    }
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
