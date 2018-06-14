-module(rolnik_thermometer).

-behaviour(gen_statem).

-include("../include/records.hrl").

% API
-export([start_link/1]).

% Callbacks
-export([callback_mode/0, init/1, terminate/3, code_change/4, format_status/2]).
-export([reachable/3, unreachable/3, loading/3]). %TODO  unplugged/3

%--- API -----------------------------------------------------------------------
start_link(Device) ->
    gen_statem:start_link({local, ?MODULE}, ?MODULE, [Device], []).

%--- Callbacks -----------------------------------------------------------------
callback_mode() -> state_functions.

init([_Device]) ->
    {ok, Interval} = application:get_env(rolnik, sample_interval),
    try grisp_onewire:transaction(fun() -> grisp_onewire:search() end) of
        [ID] ->
            {ok, loading, #device{id = ID, type = thermometer}, [{state_timeout,Interval,{enter, Interval}}]};
        _ ->
            {stop, failed_to_start}
    catch
        _:_ ->
            {stop, failed_to_start}
    end.
loading(state_timeout, {enter, Interval}, T) ->
    rolnik_event:sync_notify({new, temperatures}),
    {next_state, reachable, T, [{state_timeout, Interval, {read, Interval}}]}.

reachable(state_timeout, {read, Interval}, T) ->
    _Last = T#device.sample,
    try read_temperature(T) of
        E when is_number(E) ->
            NT = T#device{sample = E},
            rolnik_event:sync_notify({update, E, temperatures}),
            {next_state, reachable, NT, [{state_timeout,Interval,{read, Interval}}]};
        _ ->
            rolnik_event:sync_notify({update, null, temperatures}),
            {next_state, unreachable, T, [{state_timeout, Interval, {check, Interval}}]}
    catch
        _:_ ->
            rolnik_event:notify({crashed, ?MODULE}),
            {next_state, unreachable, T, [{state_timeout, Interval, {check, Interval}}]}
    end.

unreachable(state_timeout, {check, Interval}, T) ->
    rolnik_event:sync_notify({error, T}), % TODO
    {next_state, reachable, T, [{state_timeout, Interval, {read, Interval}}]}.

%TODO alerted

terminate(_Reason, _State, _Data) ->
    ok.

code_change(_OldVsn, OldState, OldData, _Extra) ->
    {ok, OldState, OldData}.

format_status(_Opt, Status) ->
    Status.

%--- Internal ------------------------------------------------------------------

read_temperature(T) ->
    ID = T#device.id,
    onewire_ds18b20:convert(ID, 500),
    Temp = onewire_ds18b20:temp(ID),
    Temp.
    
