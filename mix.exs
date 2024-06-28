defmodule Squircle.MixProject do
  use Mix.Project

  def project do
    [
      app: :squircle,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),

      # Docs
      name: "Squircle",
      source_url: "https://github.com/waseigo/squircle",
      homepage_url: "https://overbring.com/software/squircle",
      docs: [
        # The main page in the docs
        main: "Squircle",
        logo: "./assets/logo.png",
        assets: %{"etc/assets" => "assets"},
        extras: ["README.md"]
      ]
    ]
  end

  defp description do
    """
    An Elixir library to generate SVG squircle paths.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Isaak Tsalicoglou"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/waseigo/squircle"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
