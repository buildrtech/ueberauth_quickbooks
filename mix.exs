defmodule UeberauthQuickbooks.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :ueberauth_quickbooks,
      version: @version,
      name: "Ueberauth Quickbooks",
      package: package(),
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/buildrtech/ueberauth_quickbooks",
      homepage_url: "https://github.com/buildrtech/ueberauth_quickbooks",
      description: description(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger, :ueberauth, :oauth2]]
  end

  defp deps do
    [
      {:oauth2, "~> 0.9"},
      {:ueberauth, "~> 0.4"},

      # dev/test dependencies
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs do
    [extras: ["README.md", "CONTRIBUTING.md"]]
  end

  defp description do
    "An Ueberauth strategy for using Quickbooks to authenticate your users"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Michael Stock"],
      licenses: ["MIT"],
      links: %{Quickbooks: "https://github.com/buildrtech/ueberauth_quickbooks"}
    ]
  end
end
