-module(rolnik_thermometer_sup).
-behavior(supervisor).

%API
-export([start_link/0, read_temperature/0]).

%Callbacks
-export([init/1]).

%--- API -----------------------------------------------------------------------

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

read_temperature() ->
    read_temperature(pids()).

%--- Callbacks -----------------------------------------------------------------

init([]) ->
    Devices = detect(),
    {ok, {{one_for_one, 5, 60}, Devices}}.

%--- Internal ------------------------------------------------------------------

detect() ->
    IDs = grisp_onewire:transaction(fun() -> grisp_onewire:search() end),
    [child_spec(ID) || ID <- IDs].

child_spec(ID) ->
    {ID,
    {rolnik_thermometer, start_link, [ID]},
    permanent,
    5000,
    worker,
    [rolnik_thermometer]}.

pids() ->
    [Pid || {_,Pid,worker,[rolnik_thermometer]} <- supervisor:which_children(?MODULE)].

read_temperature(Pids) ->
    [gen_statem:call(Pid, read_temperature) || Pid <- Pids].
