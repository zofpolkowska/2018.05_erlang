-module(rolnik_event).

% API
-export([start_link/0, attach_handler/2, notify/1, sync_notify/1, 
         which_handlers/0, call/2, stop/0]).

%--- API -----------------------------------------------------------------------
start_link() ->
    {ok, Pid} = gen_event:start_link({local, ?MODULE}),
    attach_handler(rolnik_metrics_handler, []),
    {ok, Pid}.

attach_handler(Handler, Args) ->
    gen_event:add_handler(?MODULE, Handler, Args).

notify(Event) ->
    gen_event:notify(?MODULE, Event).

sync_notify(Event) ->
    gen_event:sync_notify(?MODULE, Event).

which_handlers() ->
    gen_event:which_handlers(?MODULE).

call(Handler, Request) ->
    gen_event:call(?MODULE, Handler, Request).

stop() ->
    gen_event:stop(?MODULE).

