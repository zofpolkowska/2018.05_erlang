-module(rolnik_toppage_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([handle/2]).


init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    {[
      {<<"application/json">>, handle}
     ], Req, State}.

handle(Req, State) ->
    Body = rolnik_event:call(rolnik_timeseries_handler, {json, temperatures}),
    case is_binary(Body) of
        false ->
            {<<>>, Req, State};
        true ->
            {Body, Req, State}
    end.

