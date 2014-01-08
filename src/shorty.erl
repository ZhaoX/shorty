-module(shorty).
-export([start/0, log/1]).

-include_lib("shorty/include/shorty.hrl").

start() ->
    ok = application:start(inets),
    ok = application:start(crypto),

    ok = application:start(cowlib),
    ok = application:start(ranch),
    ok = application:start(cowboy),

    ok = application:start(syntax_tools),
    ok = application:start(compiler),
    ok = application:start(erlson),

    ok = application:start(goldrush),
    ok = application:start(lager),

    ok = application:start(bson),
    ok = application:start(mongodb),

    ok = application:start(shorty),
    lager:set_loglevel(lager_console_backend, ?LOG_LEVEL).

log(Level) when is_atom(Level) ->
    lager:set_loglevel(lager_console_backend, Level).
