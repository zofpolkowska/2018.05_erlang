-module(rolnik_graphite_cli).

-bahavior(gen_server).

% API
-export([start_link/0]).

% Callbacks

-export([init/1]).

%TODO -export([handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%--- API -----------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%-- Callbacks ------------------------------------------------------------------
init([]) ->
    %TODO ENV
    {ok, []}.
