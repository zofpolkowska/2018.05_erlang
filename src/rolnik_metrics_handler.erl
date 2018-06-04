-module(rolnik_metrics_handler).    
-include("../include/records.hrl").

-behavior(gen_event).

% Callbacks
-export([init/1, handle_event/2, handle_call/2, handle_info/2,
         terminate/2, code_change/3, format_status/2]).

%-- Callbacks ------------------------------------------------------------------
init([]) ->
    L = env(rolnik, folsom),
    [Name] = proplists:get_value(gauge, L),
    State = 1,
    %TODO move to event create_metric/new
    folsom_metrics:new_gauge(Name),
    {ok, State}.

handle_event({update, T}, State) ->
    Temp = T#device.sample,
    folsom_metrics:notify({temperature, Temp}),
    rolnik_event:notify(bind),
    {ok, State};

handle_event({error, _T}, State) ->
    % TODO
    {ok, State};

handle_event(clean, State) ->
    {ok, State};

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





