-module(rolnik_metrics_handler).    
-include("../include/records.hrl").

-behavior(gen_event).

% Callbacks
-export([init/1, handle_event/2, handle_call/2, handle_info/2,
         terminate/2, code_change/3, format_status/2]).

init([]) ->
    L = env(rolnik, folsom),
    M = #metric{name = proplists:get_value(gauge, L, temperature),
                sample_interval = env(rolnik, sample_interval),
                refresh_interval = env(rolnik, refresh_interval)},
    folsom_metrics:new_gauge(M#metric.name),
    {ok, M}.

handle_event({update, T}, M) ->
    Temp = T#device.sample,
    folsom_metrics:notify({temperature, Temp}),
    {ok, M};

handle_event({error, _T}, M) ->
    % TODO
    {ok, M};

handle_event(_Event, State) ->
    {ok, State}.

handle_call(_Request, State) ->
    Reply = ok,
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
env(App, Identifier) ->
    {ok, E} = application:get_env(App, Identifier),
    E.
