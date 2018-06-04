-module(rolnik_json_handler).    
-include("../include/records.hrl").

-behavior(gen_event).

% Callbacks
-export([init/1, handle_event/2, handle_call/2, handle_info/2,
         terminate/2, code_change/3, format_status/2]).


%-- Callbacks ------------------------------------------------------------------
init([]) ->
    {ok, <<"[0, 0]">>}.

handle_event(bind, State) ->
    Temperature = float_to_list(
          folsom_metrics:get_metric_value(temperature),
          [{decimals, 4}]),
    Part = list_to_binary(["\[",
                               Temperature,
                               ", ",
                               timestamp(),
                               "]"]),
    NewState = list_to_binary([State, ",", Part]),
    {ok, NewState};

handle_event(_Event, State) ->
    {ok, State}.

handle_call({get, Metric}, State) ->
    Reply = build_json(Metric, State),
    %Reply = State,
    {ok, Reply, State}.

handle_info(_Info, State) ->
    {ok, State}.

terminate(_Arg, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

format_status(_Opt, Status) ->
    Status.

%--- Internal ------------------------------------------------------------------
timestamp() ->
    {Ms, S, _} = os:timestamp(),
    integer_to_binary(Ms * 1000000 + S + 960121085). %TODO fix getting the timestamp 

build_json(_Metric, Datapoints) ->
    list_to_binary([
                    "{\"target\" : ",
                    "\"temperature\",",
                    "\"datapoints\" : [",
                    Datapoints,
                    "]}"
                   ]).
