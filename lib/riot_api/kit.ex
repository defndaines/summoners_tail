defmodule RiotAPI.Kit do
  @moduledoc """
  Functions for handling responses from the the Riot Games API.
  """

  @doc """
    Given a MatchDTO, extract a list of participants PUUIDs.
  """
  def match_participants(dto), do: get_in(dto, ["metadata", "participants"])

  @doc """
  Given a SummonerDTO, extract the PUUID, which is often necessary as the input to different API
  calls.
  """
  def summoner_puuid(dto), do: dto["puuid"]

  @doc """
  Summoner regions are more finer grained that match regions, so we need to be able to convert
  between the two.

  Per Match documentation:
  > The AMERICAS routing value serves NA, BR, LAN, LAS, and OCE. The ASIA routing value serves KR
  > and JP. The EUROPE routing value serves EUNE, EUW, TR, and RU.

  NOTE: I don't know the official Riot name for this distinction, so using the terms relative to
  the two API types I am supporting at this time.
  """
  def summoner_region_to_match_region("NA" <> _rest), do: {:ok, "AMERICAS"}
  def summoner_region_to_match_region("BR" <> _rest), do: {:ok, "AMERICAS"}
  def summoner_region_to_match_region("LA" <> _rest), do: {:ok, "AMERICAS"}
  def summoner_region_to_match_region("OC" <> _rest), do: {:ok, "AMERICAS"}
  def summoner_region_to_match_region("JP" <> _rest), do: {:ok, "ASIA"}
  def summoner_region_to_match_region("KR" <> _rest), do: {:ok, "ASIA"}
  def summoner_region_to_match_region("EU" <> _rest), do: {:ok, "EUROPE"}
  def summoner_region_to_match_region("RU" <> _rest), do: {:ok, "EUROPE"}
  def summoner_region_to_match_region("TR" <> _rest), do: {:ok, "EUROPE"}
  def summoner_region_to_match_region(region), do: {:error, "unknown region"}
end
