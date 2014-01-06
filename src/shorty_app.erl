%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(shorty_app).
-behaviour(application).

-include_lib("shorty/include/shorty.hrl").

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile(?ROUTER),
    {ok, _}  = cowboy:start_http(http, 100, [{port, ?HTTP_PORT}], [
        {env, [
            {dispatch, Dispatch}
        ]}
    ]),
    shorty_sup:start_link().

stop(_State) ->
    ok.
