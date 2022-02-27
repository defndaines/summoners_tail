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
or prefix your call to IEx
```shell
RG_API=RGAPI-### iex -S mix
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

### SSL Cert

Note that the first implementation is using straight OTP `:httpc` for making
requests to the Riot Games API. Out of the box, this does not properly verify
SSL certs, so this will result in a warning when run like
```
06:59:36.305 [warning] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'
```
The code is set to `verify_none` for now to quiet the logging.

### Testing

Right now, the `RG_API` environment variable has to be set in order to run
tests. This is not ideal.

Simple workaround for now is to run with an empty variable
```shell
RG_API="" mix test
```

Most of the code hits external APIs so isn't under test. With more time, I'd
extract this out and ensure that basic flows are covered.

### Abstraction

There is some repetitive code. I generally follow a "rule of three", where
after the third piece of similar code I abstract it out to a common function.
There's room for that here, but I haven't tackled it yet.
