-module(rolnik_hygro).

-behaviour(gen_statem).

-include("../include/records.hrl").

% API
-export([start_link/1]).

% Callbacks
-export([callback_mode/0, init/1, terminate/3, code_change/4]).
-export([state_name/3, loading/3, reachable/3]).


%--- API -----------------------------------------------------------------------
start_link(Driver) ->
    gen_statem:start_link({local, ?MODULE}, ?MODULE, [Driver], []).

%--- Callbacks -----------------------------------------------------------------
callback_mode() -> state_functions.


init([Driver]) ->
    {ok, T} = application:get_env(rolnik, sample_interval),
    {ok, loading, #device{type = Driver}, [{state_timeout,T, {enter, T}}]}.

state_name({call,Caller}, _Msg, Data) ->
    {next_state, state_name, Data, [{reply,Caller,ok}]}.

loading(state_timeout, {enter, T}, State) ->
    Driver = State#device.type,
    %List = application:get_env(devices),
    %Metrics = proplists:get_value(List, Driver),
    Metrics = [humidity, temperature], 
    lists:map(fun(Name) ->
                      metric(Driver, Name) end,
              Metrics),
    {next_state, reachable, State, [{state_timeout,T, {enter, T}}]}.

reachable(state_timeout, {enter, T}, State) ->
    case State#device.type of
        pmod_hygro ->
            get_humidity(State),
            timer:sleep(20),
            get_temperature(State);
        _ ->
            nothing
    end,
    {next_state, reachable, State, [{state_timeout,T, {enter, T}}]}.


terminate(_Reason, _State, _Data) ->
    void.


code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%--- Internal ------------------------------------------------------------------

metric(Driver, Name) ->
    FullName = list_to_atom(atom_to_list(Driver) ++ "_" ++ atom_to_list(Name)),
    rolnik_event:sync_notify({new, FullName}).

get_humidity(_State) ->
    try gen_server:call(pmod_hygro, humidity) of
        {_, H} when is_number(H) ->
            rolnik_event:sync_notify({update, H, pmod_hygro_humidity});
        {_, _} ->
            rolnik_event:sync_notify({update, null, pmod_hygro_humidity})
    catch
        _:_ ->
            rolnik_event:sync_notify({crashed, ?MODULE}),
            rolnik_event:sync_notify({crashed, pmod_hygro})
    end.

get_temperature(_State) ->
    try gen_server:call(pmod_hygro, temperature) of
        {_, T} when is_number(T) ->
            rolnik_event:sync_notify({update, T, pmod_hygro_temperature});
        {_,_} ->
            rolnik_event:sync_notify({update, null, pmod_hygro_temperature})
    catch
        _:_ ->
            rolnik_event:sync_notify({crashed, ?MODULE}),
            rolnik_event:sync_notify({crashed, pmod_hygro})
    end.

