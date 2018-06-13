-module(rolnik_devices_sup).
-behavior(supervisor).

%API
-export([start_link/0]).

%Callbacks
-export([init/1]).

%--- API -----------------------------------------------------------------------

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%--- Callbacks -----------------------------------------------------------------

init([]) ->
    Devices = [
               worker(pmod_hygro, []), %% device driver
               worker(rolnik_thermometer, [ds18b20]), %% device manager
               worker(rolnik_hygro, [pmod_hygro]) %% device manager
              ],
    {ok, {{one_for_one, 5, 60}, Devices}}.

%--- Internal ------------------------------------------------------------------
worker(Module, Args) ->
    #{ id => Module,
       start => {Module, start_link, Args},
       modules => [Module]}.
