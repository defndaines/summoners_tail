# Summoners Tail

This project tracks a Summoner via the
[Riot Games API](https://developer.riotgames.com/apis). Given a summoner, it
will then track the opponent summoners from their last five games, watching
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

## Limitations

### SSL Cert

Note that the first implementation is using straight OTP `:httpc` for making
request to the Riot Games API. Out of the box, this does not properly verify
SSL certs, so this will result in a warning when run for the first time:
```
06:59:36.305 [warning] Description: 'Authenticity is not established by certificate path validation'
     Reason: 'Option {verify, verify_peer} and cacertfile/cacerts is missing'
```

### Testing

Right now, the `RG_API` environment variable has to be set in order to run
tests. This is not ideal.

Simple workaround for now is to run with an empty variable
```shell
RG_API="" mix test
```
