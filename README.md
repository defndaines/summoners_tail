# Summoners Tail

This project tracks a Summoner via the
[Riot Games API](https://developer.riotgames.com/apis). Given a summoner, it
will then track the other summoners from their last five matches, watching
their activity for an hour.

## Usage

At this time, this project is expected to run from IEx. It requires a API key
from Riot Games. You can register and attain a key at
https://developer.riotgames.com/

Development API keys are good for 24 hours, but are subject to rate limiting.

You can pass the token by setting the environment variable in your shell
```shell
export RG_API=RGAPI-abcdef12-3456-####-####-####-############
```

### Recent Summoners

To invoke from IEx,
```elixir
summoner_name = "Allie"
region = "NA1"

participants = SummonersTail.recent_summoners(summoner_name, region)
```

## Limitations

### Validation

The code isn't doing much defensive validation at this time. For example, if a
function expects an ID, it assumes it is being passed a valid ID returned by a
previous API call. Only the summoner name is escaped, partly because the API
supports spaces in names and so this needed to be covered.

### Abstraction

There is some repetitive code. I generally follow a "rule of three", where
after the third piece of similar code I abstract it out to a common function.
There's room for that here, but I haven't tackled it yet.

### Lifecycle

At this time, if the `Monitor` crashes, there is no recovery. This is aligned
with the expectation that everything is running from IEx at the moment.
