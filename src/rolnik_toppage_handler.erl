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
    Bind = cowboy_req:binding(metric, Req, <<"temperatures">>),
    Body = case binary_to_atom(Bind, utf8) of
               temperatures ->
                   rolnik_event:call(rolnik_timeseries_handler, {json, temperatures});
               pmod_hygro_temperature ->
                   rolnik_event:call(rolnik_timeseries_handler, {json, pmod_hygro_temperature});
               pmod_hygro_humidity ->
                   rolnik_event:call(rolnik_timeseries_handler, {json, pmod_hygro_humidity});
               _ ->
                   <<"make GET request to /search path and check available metrics\"">>
           end,
    case is_binary(Body) of
        false ->
            {<<>>, Req, State};
        true ->
            {Body, Req, State}
    end.

