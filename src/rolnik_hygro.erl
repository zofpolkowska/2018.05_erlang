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
    %% ENVs to conf
    {ok, T} = application:get_env(rolnik, sample_interval),
    {ok, loading, #device{type = Driver}, [{state_timeout,T, {enter, T}}]}.

state_name({call,Caller}, _Msg, Data) ->
    {next_state, state_name, Data, [{reply,Caller,ok}]}.

loading(state_timeout, {enter, T}, State) ->
    Driver = State#device.type,
    %List = application:get_env(devices),
    Metrics = [humidity, temperature], %Metrics = proplists:get_value(List, Driver),
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
    {_, H} = gen_server:call(pmod_hygro, humidity),
    rolnik_event:sync_notify({update, H, pmod_hygro_humidity}).
get_temperature(_State) ->
    {_, H} = gen_server:call(pmod_hygro, temperature),
    rolnik_event:sync_notify({update, H, pmod_hygro_temperature}).
