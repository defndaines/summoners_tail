defmodule RiotAPI.SummonerTest do
  use ExUnit.Case

  import Tesla.Mock

  alias RiotAPI.Summoner

  describe "by_name/2" do
    test "with valid response" do
      response =
        "priv/samples/summoners-by-name-Allie.json"
        |> File.read!()
        |> Jason.decode!()

      mock(fn %{method: :get} -> {:ok, %Tesla.Env{status: 200, body: response}} end)

      {:ok, body} = Summoner.by_name("Allie", "NA1")
      assert response == body
    end

    test "when summoner name is not found" do
      message = "Data not found - summoner not found"

      mock(fn %{method: :get} ->
        {:ok, %Tesla.Env{status: 404, body: %{"status" => %{"message" => message}}}}
      end)

      {:error, reason} = Summoner.by_name("No Such Name", "NA1")
      assert message == reason
    end

    test "invalid region returns error" do
      assert Summoner.by_name("Allie", "AN1") == {:error, "invalid region"}
    end
  end
end
