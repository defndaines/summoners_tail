defmodule RiotAPI.Summoner do
  @moduledoc """
  Module for interacting with the Riot Games API for Summoners. 

  Documentation for the latest version of the API at the time of writing is
  https://developer.riotgames.com/apis#summoner-v4

  When requesting summoner information, a region must always be provided. Known regions at this
  time are: "BR1", "EUN1", "EUW1", "JP1", "LA1", "LA2", "NA1", "OC1", "RU", "TR1".

  The SummonerDTO, as of v4, is a map like the following:
  ```
   %{
     "accountId" => "nrc0RQ80Yqcn5JZJM1REjRDZASn4sTVDlfDMGXfhaA",
     "id" => "_i_3eYmgwDKkbZyO9DDFtsTQhu7Vrem_v46ww-bTfoA",
     "name" => "allie",
     "profileIconId" => 14,
     "puuid" => "1V2eCFBB_an5U8QVaM4bvl7jOSDbupDJdb2ggsujQGnmWmRMXosHIIt-eV7qEjUKYjG302tfqhxHwg",
     "revisionDate" => 1632688564000,
     "summonerLevel" => 38
   }}
  ```
  """

  use Tesla

  require Logger

  @api_token Application.compile_env(:summoners_tail, :api_token)
  @url_fragment Application.compile_env(:summoners_tail, :base_uri_fragment)
  @valid_regions ~w{BR1 EUN1 EUW1 JP1 LA1 LA2 NA1 OC1 RU TR1}

  plug(Tesla.Middleware.Headers, [{"X-Riot-Token", @api_token}])
  plug(Tesla.Middleware.JSON)

  @doc """
  Get the SummonerDTO map given the name of a summoner and a valid region. If no summoner can be
  found by that name, or there is any other issue with retrieving information, identify the error.
  """
  @spec by_name(summoner_name :: String.t(), region :: String.t()) ::
          {:ok, map()} | {:error, reason :: term()}
  def by_name(name, region) when region in @valid_regions do
    url =
      Enum.join([
        "https://",
        String.downcase(region),
        @url_fragment,
        "summoner/v4/summoners/by-name/",
        URI.encode(name)
      ])

    case get(url) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{body: %{"status" => %{"message" => message}}}} ->
        {:error, message}

      {:error, reason} ->
        {:error, reason}

      error ->
        Logger.error("unknown issue, #{inspect(error)}")
        {:error, "unparseable response"}
    end
  end

  def by_name(_, _), do: {:error, "invalid region"}
end
