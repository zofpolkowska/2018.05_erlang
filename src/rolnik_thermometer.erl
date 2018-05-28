-module(rolnik_thermometer).

-behaviour(gen_statem).

-include("../include/thermometer.hrl").

% API
-export([start_link/1]).

% Callbacks
-export([callback_mode/0, init/1, terminate/3, code_change/4]).
-export([reachable/3]).

%--- API -----------------------------------------------------------------------
start_link(ID) ->
    gen_statem:start_link(?MODULE, [ID], []).


%--- Callbacks -----------------------------------------------------------------
callback_mode() -> state_functions.

init([ID]) ->
    {ok, reachable, #thermometer{id = ID}, [{state_timeout,10000,read_temperature}]}.

reachable({call,Caller}, read_temperature, T) ->
    Temp = read_temperature(T#thermometer.id),
    Caller ! {ok, Temp},
    {keep_state_and_data, [{state_timeout,10000,read}]};

reachable(state_timeout, read_temperature, T) ->
    Temp = read_temperature(T#thermometer.id),
    N_T = T#thermometer{last_temperature = Temp}, 
    rolnik_event:notify(update, N_T),
    {next_state, reachable, N_T, [{state_timeout,1000,read_temperature}]}.

terminate(_Reason, _State, _Data) ->
    void.


code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%--- Internal ------------------------------------------------------------------

read_temperature(ID) ->
    onewire_ds18b20:convert(ID, 500),
    onewire_ds18b20:temp(ID).
 
