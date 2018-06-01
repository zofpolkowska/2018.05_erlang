% @doc rolnik public API.
% @end
-module(rolnik).

-behavior(application).

% Callbacks
-export([start/2]).
-export([stop/1]).

%--- Callbacks -----------------------------------------------------------------

start(_Type, _Args) ->
    application:ensure_all_started(folsom),
    %application:set_env(folsomite, grahite_host, {192,168,1,71}, [{persistent, true}]),
    rolnik_sup:start_link().

stop(_State) -> ok.
