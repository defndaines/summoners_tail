import Config

config :summoners_tail,
  api_token: System.get_env("RG_API"),
  base_uri_fragment: ".api.riotgames.com/lol/"

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
