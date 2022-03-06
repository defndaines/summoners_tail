defmodule RiotAPI.Match do
  @moduledoc """
  Module for interacting with the Riot Games API for Matches. 

  Documentation for the latest version of the API at the time of writing is
  https://developer.riotgames.com/apis#match-v5

  When requesting match information, a region must always be provided. Valid regions at this time
  are: "AMERICAS", "ASIA", and "EUROPE".

  The MatchDTO, as of v5, is a map like the following (fields omitted for space):
  ```
  {
  "metadata": {
  	"dataVersion": "2",
  	"matchId": "NA1_4053830000",
  	"participants": [
  		"1V2eCFBB_an5U8QVaM4bvl7jOSDbupDJdb2ggsujQGnmWmRMXosHIIt-eV7qEjUKYjG302tfqhxHwg",
  		""z82KmpXbASfa5_ilCXjGWYKnS5a5lo488hEcSgWZAVBmjd0ljrBzXF5JvY8KYCnfpvLKQJYeXPmQQg"
  	]
  },
  "info": {
  	"gameCreation": 1632686456000,
  	"gameDuration": 2071161,
  	"gameId": 4053830000,
  	"participants": [...],
  	"platformId": "NA1",
  	"teams": [...]
  }
  }
  ```
  """

  use Tesla

  require Logger

  @api_token Application.compile_env(:summoners_tail, :api_token)
  @url_fragment Application.compile_env(:summoners_tail, :base_uri_fragment)
  @valid_regions ~w{AMERICAS ASIA EUROPE}

  plug(Tesla.Middleware.Headers, [{"X-Riot-Token", @api_token}])
  plug(Tesla.Middleware.JSON)

  @doc """
  Get a list of the most recent match IDs for a given PUUID (Player Universally Unique ID). Must
  pass a region. Optional count can be passed, otherwise the five most recent match IDs will be
  returned. If no matches can be found by that PUUID, or there is any other issue with retrieving
  information, identify the error.
  """
  @spec recent(puuid :: String.t(), region :: String.t(), count :: pos_integer()) ::
          {:ok, [String.t()]} | {:error, reason :: term()}
  def recent(puuid, region, count \\ 5)

  def recent(puuid, region, count) when region in @valid_regions do
    url =
      Enum.join([
        "https://",
        String.downcase(region),
        @url_fragment,
        "match/v5/matches/by-puuid/",
        puuid,
        "/ids?",
        URI.encode_query(%{"start" => 0, "count" => count})
      ])

    case get(url) do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{body: %{"status" => %{"message" => message}}}} -> {:error, message}
      {:error, reason} -> {:error, reason}
    end
  end

  def recent(_, _, _), do: {:error, "invalid region"}

  @doc """
  Get the MatchDTO map given a match ID and a valid region. If no match can be found for that ID,
  or there is any other issue with retrieving information, identify the error.
  """
  @spec info(match_id :: String.t(), region :: String.t()) ::
          {:ok, match_dto :: map()} | {:error, reason :: term()}
  def info(match_id, region) when region in @valid_regions do
    url =
      Enum.join([
        "https://",
        String.downcase(region),
        @url_fragment,
        "match/v5/matches/",
        match_id
      ])

    case get(url) do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{body: %{"status" => %{"message" => message}}}} -> {:error, message}
      {:error, reason} -> {:error, reason}
    end
  end

  def info(_, _), do: {:error, "invalid region"}
end
