defmodule SummonersTail do
  @moduledoc """
  Documentation for `SummonersTail`.
  """

  alias RiotAPI.HTTPC.Match
  alias RiotAPI.HTTPC.Summoner
  alias RiotAPI.Kit

  require Logger

  @doc """
  Get a list of recent summoners (by name) a given summoner has played with.
  """
  def recent_summoners(summoner_name, region) do
    with {:ok, summoner} <- Summoner.by_name(summoner_name, region),
         puuid <- Kit.summoner_puuid(summoner),
         {:ok, match_region} <- Kit.summoner_region_to_match_region(region),
         {:ok, match_ids} <- Match.recent(puuid, match_region) do
      {_summoner_name, participants} =
        match_participants(match_ids, match_region)
        |> Map.pop(puuid)

      Map.values(participants)
    end
  end

  # Grab the MatchDTO for each match ID and extract the participants.
  defp match_participants(match_ids, match_region) do
    match_ids
    |> Enum.map(fn match_id -> Task.async(fn -> Match.info(match_id, match_region) end) end)
    |> Enum.reduce(%{}, fn task, acc ->
      case Task.await(task) do
        {:ok, match} ->
          match |> Kit.match_participant_map() |> Map.merge(acc)

        error ->
          Logger.error("Problem retrieving match", error)
          acc
      end
    end)
  end
end
