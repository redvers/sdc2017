defmodule Sdc2017.Mixfile do
  use Mix.Project

  def project do
    [app: :sdc2017,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Sdc2017.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:erl_img, git: "https://github.com/mochi/erl_img"},
      {:gen_state_machine, "~> 2.0"},
      {:extwitter, "~> 0.8.6"},
#      {:graphmath, "~> 1.0.2"},
#      {:amnesia, "~> 0.2.4"},
#      {:syn, "~> 1.5.0"},
#      {:ranch, git: "https://github.com/ninenines/ranch"},
#      {:graphmath, "~> 1.0.2"},
      {:extwitter, "~> 0.8.6"}
    ]
  end
end
