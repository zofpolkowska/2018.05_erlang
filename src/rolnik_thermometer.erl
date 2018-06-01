-module(rolnik_thermometer).

-behaviour(gen_statem).

-include("../include/records.hrl").

% API
-export([start_link/1]).

% Callbacks
-export([callback_mode/0, init/1, terminate/3, code_change/4, format_status/2]).
-export([reachable/3, unreachable/3]). %TODO  unplugged/3

%--- API -----------------------------------------------------------------------
start_link(ID) ->
    gen_statem:start_link({local, ?MODULE}, ?MODULE, [ID], []).

%--- Callbacks -----------------------------------------------------------------
callback_mode() -> state_functions.

init([ID]) ->
    {ok, Interval} = application:get_env(rolnik, sample_interval),
    {ok, reachable, #device{id = ID, type = thermometer}, [{state_timeout,Interval,{read, Interval}}]}.

reachable(state_timeout, {read, Interval}, T) ->
    _Last = T#device.sample,
    Now = read_temperature(T),
    case T#device.sample of
        E when is_number(E) ->
            rolnik_event:notify({update, Now}),
            {next_state, reachable, Now, [{state_timeout,Interval,{read, Interval}}]};
        _ ->
            {next_state, unreachable, Now, [{state_timeout, Interval, {check, Interval}}]}
    end.

unreachable(state_timeout, {check, Interval}, T) ->
    rolnik_event:notify({error, T}), % TODO
    {next_state, reachable, T, [{state_timeout, Interval, {read, Interval}}]}.


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
    TempConverted = Temp, %TODO 
    T#device{sample = TempConverted}.
    
