defmodule RiotAPI.KitTest do
  @moduledoc """
  Tests against the `RiotAPI.Kit` module.
  """

  use ExUnit.Case

  describe "summoner_region_to_match_region/1" do
    test "converts all known AMERICAS regions" do
      for region <- ~w(BR1 LA1 LA2 NA1 OC1) do
        assert RiotAPI.Kit.summoner_region_to_match_region(region) == {:ok, "AMERICAS"}
      end
    end

    test "converts all known ASIA regions" do
      for region <- ~w(JP1) do
        assert RiotAPI.Kit.summoner_region_to_match_region(region) == {:ok, "ASIA"}
      end
    end

    test "converts all known EUROPE regions" do
      for region <- ~w(EUN1 EUW1 RU TR1) do
        assert RiotAPI.Kit.summoner_region_to_match_region(region) == {:ok, "EUROPE"}
      end
    end

    test "fails on unknown region" do
      # No servers in Antarctica? 
      assert RiotAPI.Kit.summoner_region_to_match_region("AN1") == {:error, "unknown region"}
    end
  end
end
