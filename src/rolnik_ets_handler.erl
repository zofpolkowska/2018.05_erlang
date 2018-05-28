-module(rolnik_ets_handler).
-include("../include/thermometer.hrl").

-behaviour(gen_event).

% Callbacks
-export([init/1, handle_event/2, handle_call/2, handle_info/2,
         terminate/2, code_change/3, format_status/2, list/0]).

init([]) ->
    ets:new(?MODULE, [
                      named_table,
                      ordered_set,
                      {read_concurrency, true},
                      {write_concurrency, true},
                      {keypos, #data.pos}
                     ]),
    {ok, ready}.

handle_event({update, T}, State) ->
    New = case ets:last(?MODULE) of
        '$end_of_table' ->
            0;
        Count ->
            (Count + 1) rem ?STORE_MAX
    end,
    Data = 
        #data{pos = New, 
              temperature = T#thermometer.last_temperature, 
              id = list_to_atom(T#thermometer.id)},
    ets:insert(?MODULE, Data),
    {ok, State}.

handle_call(all, State) ->
    {ok, list(), State}.

handle_info(_Info, State) ->
    {ok, State}.

terminate(_Arg, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

format_status(_Opt, Status) ->
    Status.

list() -> 
    ets:tab2list(?MODULE).


%--- Internal ------------------------------------------------------------------
