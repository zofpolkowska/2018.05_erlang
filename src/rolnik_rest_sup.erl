-module(rolnik_rest_sup).

% API
-export([start_link/0]).

% Callbacks
-export([init/1]).

%--- API -----------------------------------------------------------------------

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%--- Callbacks -----------------------------------------------------------------

init([]) -> 
    Rest = #{id => rolnik_rest,
            start => {rolnik_rest, start_link, []},
            type => worker,
            modules => [rolnik_rest]},
    {ok, {#{strategy => one_for_one}, [Rest]}}.

