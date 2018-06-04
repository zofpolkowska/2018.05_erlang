-module(rolnik_rest_sup).

% API
-export([start_link/0, rest_init/0, rest_stop/0]).

% Callbacks
-export([init/1]).

%--- API -----------------------------------------------------------------------

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%--- Callbacks -----------------------------------------------------------------

init([]) -> 
    {ok, {#{strategy => one_for_one}, []}}.

rest_init() ->
    supervisor:start_child(?MODULE,
                           #{id => rolnik_rest,
                             start => {rolnik_rest, start_link, []},
                             type => worker,
                             modules => [rolnik_rest]}).

rest_stop() ->
    supervisor:terminate_child(?MODULE,
                              rolnik_rest).
