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

You can pass the token by setting the environment variable in your shell:
```shell
export RG_API=RGAPI-abcdef12-3456-####-####-####-############
```

