-module(pmod_hygro).
-behavior(gen_server).

-include("../include/pmod_hygro.hrl").
-record(stat, {slot, mode}).
% API
-export([start_link/0, temperature/1, humidity/1]).

% Callbacks
-export([init/1, handle_call/3, handle_cast/2]).

%--- API -----------------------------------------------------------------------

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%--- Callbacks -----------------------------------------------------------------

init([]) ->
    ok = verify(),
    {ok, #stat{slot = i2c}}.

handle_call(temperature, _From, State) ->
    Temperature = temperature(State),
    {reply, {State#stat.mode, Temperature}, State};

handle_call(humidity, _From, State) ->
    Humidity = humidity(State),
    {reply, {State#stat.mode, Humidity}, State}.

handle_cast(_Request, State) ->
    {noreply, State}.


%--- Internal ------------------------------------------------------------------

verify() ->
    ok.

temperature(_State) ->
    grisp_i2c:msgs([16#40, {write, <<16#00>>}]),  
    timer:sleep(20),
    T = grisp_i2c:msgs([16#40, {read, 2, 16#0800}]),       
    <<Temp:14/unsigned-big,_:2>> = T,
    (Temp / 16384) * 165 - 40.

humidity(_State) ->
    grisp_i2c:msgs([16#40, {write, <<16#01>>}]),
    timer:sleep(20),
    H = grisp_i2c:msgs([16#40, {read, 2, 16#0800}]),
    <<Hum:14/unsigned-big,_:2>> = H,
    (Hum / 16384) * 100.
