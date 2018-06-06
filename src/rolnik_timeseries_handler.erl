-module(rolnik_timeseries_handler).
-include("../include/records.hrl").

-behavior(gen_event).

% Callbacks
-export([init/1, handle_event/2, handle_call/2, handle_info/2,
         terminate/2, code_change/3, format_status/2]).

%-- Callbacks ------------------------------------------------------------------
init([]) ->
    {ok, #state{metrics = []}}.

handle_event({new, Metric}, State) ->
    ets:new(Metric, [
                      named_table,
                      ordered_set,
                      {keypos, #metric.timestamp},
                      {read_concurrency, true}
                     ]),
    Metrics = State#state.metrics,
    NewState = #state{metrics = [Metric|Metrics]},
    {ok, NewState};

handle_event({update, Value, Metric}, State) ->
    E = #metric{sample = Value, timestamp = timestamp()},
    ets:insert(Metric, E),
    {ok, State};

handle_event(_Event, State) ->
    {ok, State}.

handle_call({list, Metric}, State) ->
    Records = ets:tab2list(Metric),
    {ok, Records, State};

handle_call({json, Metric}, State) ->
    Reply = export_json(Metric),
    {ok, Reply, State};
handle_call(metrics, State) ->
    {ok, State#state.metrics, State}.

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
    Ms * 1000000 + S + 960121085.

export_json(Target) ->
    Records = ets:tab2list(Target),
    Datapoints = lists:map(fun(R) ->
                                   [R#metric.sample, R#metric.timestamp] end,
                          Records),
    jsone:encode([#{target => Target, datapoints => Datapoints}],
                 [{float_format, [{decimals, 4}, compact]}]).
