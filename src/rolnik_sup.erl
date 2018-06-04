% @doc rolnik top level supervisor.
% @end
-module(rolnik_sup).

-behavior(supervisor).

% API
-export([start_link/0]).

% Callbacks
-export([init/1]).

%--- API -----------------------------------------------------------------------

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%--- Callbacks -----------------------------------------------------------------

init([]) -> 
    Devices_Supervisor = #{id => rolnik_devices_sup,
                        start => {rolnik_devices_sup, start_link, []},
                        type => supervisor,
                        modules => [rolnik_devices_sup]},
    Event_Manager = #{id => rolnik_event,
                        start => {rolnik_event, start_link, []},
                        type => worker,
                        modules => [rolnik_event]},
    Rest_Supervisor = #{id => rolnik_rest_sup,
                      start => {rolnik_rest_sup, start_link, []},
                      type => supervisor,
                      modules => [rolnik_rest_sup]},
    {ok, {#{strategy => one_for_one},
          [Devices_Supervisor, Event_Manager, Rest_Supervisor]}}.

