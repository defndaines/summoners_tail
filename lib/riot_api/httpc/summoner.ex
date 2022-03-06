defmodule RiotAPI.HTTPC.Summoner do
  @moduledoc """
  Implementation of the Summoner behaviour using `:httpc`.
  """

  @behaviour RiotAPI.Summoner

  @valid_regions ~w{BR1 EUN1 EUW1 JP1 LA1 LA2 NA1 OC1 RU TR1}

  @api_token Application.compile_env(:riot, :api_token)

  @impl RiotAPI.Summoner
  def by_name(name, region) when region in @valid_regions do
    url =
      Enum.join([
        "https://",
        String.downcase(region),
        ".api.riotgames.com/lol/summoner/v4/summoners/by-name/",
        URI.encode(name)
      ])

    request = {url, [{'X-Riot-Token', @api_token}]}

    case :httpc.request(:get, request, [], []) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} ->
        Jason.decode(body)

      {:ok, {{'HTTP/1.1', code, message}, _headers, _body}} ->
        {:error, %{code: code, message: message}}

      {:error, {:headers_error, :invalid_value}} ->
        {:error, "invalid token"}

      error ->
        error
    end
  end

  def by_name(_, _), do: {:error, "invalid region"}
end
