defmodule RiotAPI.HTTPC.Match do
  @moduledoc """
  Implementation of the Match behaviour using `:httpc`.
  """

  @behaviour RiotAPI.Match

  @valid_regions ~w{AMERICAS ASIA EUROPE}

  @api_token System.fetch_env!("RG_API")

  @impl RiotAPI.Match
  def recent(puuid, region, count \\ 5)

  def recent(puuid, region, count) when region in @valid_regions do
    url =
      Enum.join([
        "https://",
        String.downcase(region),
        ".api.riotgames.com/lol/match/v5/matches/by-puuid/",
        puuid,
        "/ids?",
        URI.encode_query(%{"start" => 0, "count" => count})
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

  def recent(_, _, _), do: {:error, "invalid region"}
end
