defmodule RiotAPI.MatchTest do
  use ExUnit.Case
  import Tesla.Mock
  alias RiotAPI.Match

  describe "recent/3" do
    test "with valid response" do
      puuid = "zbS8gpGwGtZ5h5PVanKyjxy4z8FltI9huyfGU1bZSUklWY_cGZQ1X_sCCMUinbXMeEeArskNOK4f3Q"

      response =
        "priv/samples/matches-by_puuid-#{puuid}.json"
        |> File.read!()
        |> Jason.decode!()

      mock(fn %{method: :get} -> {:ok, %Tesla.Env{status: 200, body: response}} end)

      {:ok, body} = Match.recent(puuid, "AMERICAS")
      assert response == body
    end

    test "invalid region returns error" do
      assert Match.recent("puuid", "ANTARCTICA") == {:error, "invalid region"}
    end
  end

  describe "info/2" do
    test "with valid response" do
      response =
        "priv/samples/matches-NA1_4053583588.json"
        |> File.read!()
        |> Jason.decode!()

      mock(fn %{method: :get} -> {:ok, %Tesla.Env{status: 200, body: response}} end)

      {:ok, body} = Match.info("NA1_4053583588", "AMERICAS")
      assert response == body
    end

    test "invalid region returns error" do
      assert Match.info("AN_4053830000", "ANTARCTICA") == {:error, "invalid region"}
    end
  end
end
