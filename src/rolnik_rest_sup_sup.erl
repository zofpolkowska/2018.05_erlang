-module(rolnik_rest_sup_sup).

% API
-export([start_link/0]).

% Callbacks
-export([init/1]).

%--- API -----------------------------------------------------------------------

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%--- Callbacks -----------------------------------------------------------------
init([]) ->
    Procs = [],
    {ok, {{one_for_one, 10, 10}, Procs}}.
