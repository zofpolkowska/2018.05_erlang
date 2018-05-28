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
    Devices_Supervisor = #{id => rolnik_thermometer_sup,      
                        start => {rolnik_thermometer_sup, start_link, []},     
                        restart => permanent,   
                        type => supervisor,
                        modules => [rolnik_thermometer_sup]},
    Event_Manager = #{id => rolnik_event,      
                        start => {rolnik_event, start_link, []},     
                        restart => permanent,   
                        type => worker,
                        modules => [rolnik_event]},
    {ok, {#{strategy => one_for_one}, 
          [Devices_Supervisor, Event_Manager]}}.

