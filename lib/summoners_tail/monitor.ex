defmodule SummonersTail.Monitor do
  @moduledoc """
  Server for tracking summoners and any new matches they've completed.
  """

  use GenServer

  require Logger

  alias RiotAPI.HTTPC.Match

  @period :timer.minutes(1)

  def start(), do: GenServer.start_link(__MODULE__, [])

  @doc """
  Add a summoner to be monitored. To monitor, we need the PUUID and name of the summoner, as well
  as the `match_region`, which is one of AMERICAS, ASIA, or EUROPE.
  """
  def add_summoner({puuid, name}, match_region) do
    GenServer.cast(
      __MODULE__,
      {:add,
       %{
         region: match_region,
         matches: [],
         name: name,
         puuid: puuid,
         stop_at: DateTime.add(DateTime.now!("Etc/UTC"), 3600)
       }}
    )
  end

  # ##########
  # GenServer bits

  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @impl GenServer
  def init(state) do
    schedule_check()
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:check, state) do
    # Check each summoner independently, potentially removing them from the state if they are no
    # longer monitored.
    new_state =
      state
      |> Enum.map(fn summoner -> Task.async(fn -> check_summoner(summoner) end) end)
      |> Enum.reduce([], fn task, acc ->
        summoner = Task.await(task)

        if map_size(summoner) == 0 do
          acc
        else
          [summoner | acc]
        end
      end)

    # Putting this after updating state will lead to drift, but this also prevents flooding the
    # server with requests if the previous ones haven't wrapped up for any reason.
    schedule_check()

    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:add, summoner}, state) do
    # TODO: Schedule removal
    {:noreply, [summoner | state]}
  end

  # ##########
  # Support functions

  defp schedule_check(), do: Process.send_after(__MODULE__, :check, @period)

  defp check_summoner(%{puuid: puuid, region: region, matches: []} = summoner) do
    # When there are no matches recorded for a summoner, we only need to look them up.
    case Match.recent(puuid, region) do
      {:ok, match_ids} ->
        %{summoner | matches: match_ids}

      {:error, %{code: 429, message: 'Too Many Requests'}} ->
        # If we are hitting the rate limit, drop monitoring.
        Logger.warn("Exceeding rate limit for provided account, dropping #{puuid}")
        %{}

      error ->
        Logger.warn("Issue getting matches for #{puuid}: #{inspect(error)}")
        summoner
    end
  end

  defp check_summoner(%{name: name, stop_at: stop_at} = summoner) do
    # If we have passed the deadline, stop monitoring.
    case DateTime.compare(DateTime.now!("Etc/UTC"), stop_at) do
      :lt ->
        update_matches(summoner)

      _gt_or_eq ->
        Logger.debug("No longer monitoring #{name}")
        %{}
    end
  end

  defp update_matches(%{puuid: puuid, name: name, region: region, matches: matches} = summoner) do
    case Match.recent(puuid, region) do
      {:ok, match_ids} ->
        if match_ids == matches do
          summoner
        else
          for match_id <- match_ids -- matches do
            Logger.info("Summoner #{name} completed match #{match_id}")
            %{summoner | matches: match_ids}
          end
        end

      {:error, %{code: 429, message: 'Too Many Requests'}} ->
        # If we are hitting the rate limit, drop monitoring.
        Logger.warn("Exceeding rate limit for provided account")
        %{}

      error ->
        Logger.warn("Issue getting matches for #{puuid}: #{inspect(error)}")
        summoner
    end
  end
end
