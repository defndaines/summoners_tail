defmodule RiotAPI.Summoner do
  @moduledoc """
  Behaviour module for interacting with the Riot Games API for Summoners. 

  Documentation for the latest version of the API at the time of writing is
  https://developer.riotgames.com/apis#summoner-v4

  When requesting summoner information, a region must always be provided. Valid regions at this
  time are: "BR1", "EUN1", "EUW1", "JP1", "LA1", "LA2", "NA1", "OC1", "RU", "TR1".
  """

  @doc """
  Get the SummonerDTO map given the name of a summoner and a valid region. If no summoner can be
  found by that name, or there is any other issue with retrieving information, identify the error.
  """
  @callback by_name(summoner_name :: String.t(), region :: String.t()) ::
              {:ok, map()} | {:error, reason :: term()}
end
