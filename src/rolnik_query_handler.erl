-module(rolnik_query_handler).


-export([init/2]).
-export([content_types_provided/2, content_types_accepted/2, allowed_methods/2, resource_exists/2]).
-export([handle_get/2, handle_post/2]).


init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.



content_types_provided(Req, State) ->
    {[
      {<<"application/json">>, handle_get}
     ], Req, State}.

content_types_accepted(Req, State) ->
    {[
      {<<"application/json">>, handle_post}
     ], Req, State}.

allowed_methods(Req, State) ->
    {[
      <<"GET">>, <<"HEAD">>, <<"OPTIONS">>, <<"POST">>
     ], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:method(Req) of
        <<"GET">> ->
            {true, Req, State};
        <<"POST">> ->
            {false, Req, State};
        _ ->
            {false, Req, State}
    end.

handle_post(Req0, State) ->
    Body = rolnik_event:call(rolnik_timeseries_handler, {json, temperatures}),
    Req = cowboy_req:reply(200, #{
                                  <<"content-type">> => <<"application/json">>
                                 }, Body, Req0),
    {{true, <<"path">>}, Req, State}.


handle_get(Req, State) ->
    Body = rolnik_event:call(rolnik_timeseries_handler, {json, temperatures}),
    case is_binary(Body) of
        false ->
            {<<>>, Req, State};
        true ->
            {Body, Req, State}
    end.
