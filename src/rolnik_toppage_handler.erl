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
    Last = folsom_metrics:get_metric_value(temperature),
    
    %Body = list_to_binary(["\[\"",
    %                       float_to_list(Last, [{decimals, 4}]),
    %                       "\"\]"]),
    Body = rolnik_event:call(rolnik_json_handler, {get, temperature}),
    case is_binary(Body) of
        false ->
            {<<>>, Req, State};
        true ->
            {Body, Req, State}
    end.

