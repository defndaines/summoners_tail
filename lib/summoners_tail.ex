defmodule SummonersTail do
  @moduledoc """
  The `SummonersTail` allows a caller to identify other summoners a player has recently played
  with (last five matches). Once those summoners are identified, it will track them for the next
  hour, reporting any new matches they have completed.
  """

  alias RiotAPI.HTTPC.Match
  alias RiotAPI.HTTPC.Summoner
  alias RiotAPI.Kit

  require Logger

  @doc """
  Get a list of recent summoners (by name) a given summoner has played with. The region provided
  must match that expected by the Summoner API, for example "NA1" or "BR1".

  If there is any problem, like an invalid token or name, or issues communicating with the Riot
  Games API, then an `{:error, _}` tuple will be returned.
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
  # When there is an error, log it and pass the accumulated values back.
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
