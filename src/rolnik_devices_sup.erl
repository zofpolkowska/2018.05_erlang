-module(rolnik_devices_sup).
-behavior(supervisor).

%API
-export([start_link/0, detect/0]).

%Callbacks
-export([init/1]).

%--- API -----------------------------------------------------------------------

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%--- Callbacks -----------------------------------------------------------------

init([]) ->
    Devices = detect(),
    {ok, {{one_for_one, 5, 60}, Devices}}.

%--- Internal ------------------------------------------------------------------

detect() ->
    IDs = grisp_onewire:transaction(fun() -> grisp_onewire:search() end),
    [child_spec(ID) || ID <- IDs].

child_spec(ID) ->
    #{ id => ID,
     start => {rolnik_thermometer, start_link, [ID]},
     modules => [rolnik_thermometer]}.
