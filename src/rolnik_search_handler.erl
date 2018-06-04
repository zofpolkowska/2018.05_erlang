-module(rolnik_search_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([json_metrics/2]).


init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    {[
      {<<"application/json">>, json_metrics}
     ], Req, State}.

json_metrics(Req, State) ->
    Body = <<"[\"temperature\"]">>,
    {Body, Req, State}.

