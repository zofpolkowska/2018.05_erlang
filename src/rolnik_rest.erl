-module(rolnik_rest).

% API
-export([start_link/0]).

%-- API -----------------------------------------------------------------------

start_link() ->
    Dispatch = cowboy_router:compile([
                                      {'_', [
                                             {"/[:metric]", rolnik_toppage_handler, []},
                                             {"/search", rolnik_search_handler, []},
                                             {"/annotations", rolnik_annotations_handler, []},
                                             {"/query", rolnik_query_handler, []}

                                            ]}
                                     ]),
    {ok, _} = cowboy:start_clear(http, [{port, 4321}], #{
                                                         env => #{dispatch => Dispatch}
                                                        }),
    rolnik_rest_sup_sup:start_link().
