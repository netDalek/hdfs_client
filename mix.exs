defmodule HdfsClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :hdfs_client,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ibrowse, ">= 0.0.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
