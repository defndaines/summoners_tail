defmodule RiotAPI.Match do
  @moduledoc """
  Behaviour module for interacting with the Riot Games API for Matches. 

  Documentation for the latest version of the API at the time of writing is
  https://developer.riotgames.com/apis#match-v5

  When requesting match information, a region must always be provided. Valid regions at this time
  are: "AMERICAS", "ASIA", and "EUROPE".
  """

  @doc """
  Get a list of the most recent match IDs for a given PUUID (Player Universally Unique ID). Must
  pass a region. Optional count can be passed, otherwise the five most recent match IDs will be
  returned. If no matches can be found by that PUUID, or there is any other issue with retrieving
  information, identify the error.
  """
  @callback recent(puuid :: String.t(), region :: String.t(), count :: pos_integer()) ::
              {:ok, [String.t()]} | {:error, reason :: term()}
end
