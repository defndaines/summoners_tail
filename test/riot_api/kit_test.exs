defmodule RiotAPI.KitTest do
  @moduledoc """
  Tests against the `RiotAPI.Kit` module.
  """

  use ExUnit.Case

  describe "match_participants/1" do
    test "participants from valid MatchDTO" do
      match_dto = "priv/samples/match_dto.json" |> File.read!() |> Jason.decode!()

      assert RiotAPI.Kit.match_participants(match_dto) == [
               "1V2eCFBB_an5U8QVaM4bvl7jOSDbupDJdb2ggsujQGnmWmRMXosHIIt-eV7qEjUKYjG302tfqhxHwg",
               "z82KmpXbASfa5_ilCXjGWYKnS5a5lo488hEcSgWZAVBmjd0ljrBzXF5JvY8KYCnfpvLKQJYeXPmQQg",
               "y9BEMM2HOtFeO6K9X4FrfhhpKmvH6vWt2clAM1_rVDXKnZ5xrc_CIqHGE0cZsfYS2J27PCECytkwZg",
               "mSl_5UmhEX2lwL3l2RqmCQoiMdE4wgdyeQ4sVIDT6chDR9wf5RWMGhq_ngwmCwyvpiJmkC0_alL29A",
               "gO3bDD_gWDQ2TdzjidDbnyCj0R9aX7Qt9poX2TML2G2iWWMBs4y833TH5gKy-4fiO3keKpOXUbB2oA",
               "TuRm2NGGN2kO35mh0fsw-Ep-qdog_0VvsBsCRyBQTfTyPdJ-4y4ysW5ryprb-z6-0niz3gCuGoadXw",
               "8KgDPgT605fLSi2pMpOOMA2Sb_UWerqMANTcKiIeTr7pe8QsWJNnqA2LWq8BCrXfFYsm1I1hp6zmcg",
               "x62eXWYPN2Scd4XXVGpLTmo_SFDCBlMxh4jxRzmPF4FRfUUB50_oXXDwN5KF_q-287f3OPz8m-2Zuw",
               "9vzEMHplqMhGIu4tfpwpmtQ7JatpkBvSSf1IMrE7cLbackPkWdWs3rc4NJraCBh2REc2PVNk_caB6g",
               "iApL0O6LMDfGY2xdr1kN_N15ucmDpwMs5tdB2ihJH0gjjcJY1C95tjNCcvgD-dqdF-blErtM1m8a2Q"
             ]
    end
  end

  describe "match_participant_map/1" do
    test "map of PUUIDs to summoner names from valid MatchDTO" do
      match_dto = "priv/samples/match_dto.json" |> File.read!() |> Jason.decode!()

      participant_map = RiotAPI.Kit.match_participant_map(match_dto)

      assert map_size(participant_map) == 10

      assert participant_map[
               "1V2eCFBB_an5U8QVaM4bvl7jOSDbupDJdb2ggsujQGnmWmRMXosHIIt-eV7qEjUKYjG302tfqhxHwg"
             ] == "allie"

      assert participant_map[
               "9vzEMHplqMhGIu4tfpwpmtQ7JatpkBvSSf1IMrE7cLbackPkWdWs3rc4NJraCBh2REc2PVNk_caB6g"
             ] == "ImNOTaLoli"
    end
  end

  describe "summoner_puuid/1" do
    test "PUUID from valid SummonerDTO" do
      summoner_dto = "priv/samples/summoner_dto.json" |> File.read!() |> Jason.decode!()

      assert RiotAPI.Kit.summoner_puuid(summoner_dto) ==
               "1V2eCFBB_an5U8QVaM4bvl7jOSDbupDJdb2ggsujQGnmWmRMXosHIIt-eV7qEjUKYjG302tfqhxHwg"
    end
  end

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
